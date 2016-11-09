//
//  NGCreatePostViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 11/7/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Result

typealias CreatePostResult = Result<NGPost, NGNetworkError>

struct NGCreatePostViewModel: NGViewModelType{
    
    let creating: Driver<Bool>
    let results: Driver<CreatePostResult>
    let validatedContent: Driver<NGValidationResult>
    let createEnabled: Driver<Bool>
    
    init(content: Driver<String>, thread: Driver<NGThread>, createTaps: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        let validationService = NGCreateThreadValidationService.sharedCreateThreadValidationService
        
        let creating = ActivityIndicator()
        self.creating = creating.asDriver()
        
        validatedContent = content.map{ content in
            return validationService.validateContent(content)
            }.asDriver()
        
        createEnabled = Driver.combineLatest(validatedContent, creating, resultSelector: { (c, cr) -> Bool in
            c.isValid && !cr
        })
        
        let threadAndContent = Driver.combineLatest(content, thread, resultSelector: {($0, $1)})
       
        let validTaps = createTaps.withLatestFrom(createEnabled) { (_, enabled) -> Bool in
            enabled
            }.filter{$0}
        
        results = validTaps.withLatestFrom(threadAndContent)
            .flatMapLatest({ (content, thread) in
                print("Creating post content \(content)")
                return networking.request(NGAuthenticatedService.CreatePost(thread_id: thread.id, content: content))
                    .filterSuccessfulStatusCodes()
                    .mapJSONData()
                    .map{ json -> NGPost in
                        guard let post = NGPost(json: json) else {throw NGNetworkError.Unknown}
                        return post
                    }
                    .mapToFailable()
                    .trackActivity(creating)
                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
            })
        
    }

    
}
