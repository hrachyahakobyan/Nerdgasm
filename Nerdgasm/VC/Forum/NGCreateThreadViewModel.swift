//
//  NGCreateThreadViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Gloss
import Result

typealias NGCreateThreadResult = Result<(NGThread, NGPost), NGNetworkError>

struct NGCreateThreadViewModel: NGViewModelType {
    
    let loading: Driver<Bool>
    let results: Driver<NGCreateThreadResult>
    let createEnabled: Driver<Bool>
    let validatedTitle: Driver<NGValidationResult>
    let validatedContent: Driver<NGValidationResult>
    
    init(title: Driver<String>, content: Driver<String>, createTaps: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        let validationService = NGCreateThreadValidationService()
        validationService.optionalContent = true
        
        let creating = ActivityIndicator()
        loading = creating.asDriver()
        
        validatedTitle = title.map{ title in
            return validationService.validateTitle(title)
        }.asDriver()
        
        validatedContent = content.map{ content in
            return validationService.validateContent(content)
        }.asDriver()
        
        createEnabled = Driver.combineLatest(validatedTitle, validatedContent, creating, resultSelector: { (t, c, cr) -> Bool in
            t.isValid && c.isValid && !cr
        })
        
        let titleAndContent = Driver.combineLatest(title, content, resultSelector: {($0, $1)})
        
        let validTaps = createTaps.withLatestFrom(createEnabled) { (_, enabled) -> Bool in
            enabled
            }.filter{$0}
        
        results = validTaps.withLatestFrom(titleAndContent)
            .flatMapLatest({ (title, content) in
                print("Creating thread \(title) content \(content)")
                return networking.request(NGAuthenticatedService.CreateThread(title: title, content: content))
                    .filterSuccessfulStatusCodes()
                    .mapJSONData()
                    .map{ json -> (NGThread, NGPost) in
                        guard let threadJson: JSON = "thread" <~~ json else {throw NGNetworkError.Unknown}
                        guard let postJson: JSON = "post" <~~ json else {throw NGNetworkError.Unknown}
                        guard let thread = NGThread(json: threadJson) else {throw NGNetworkError.Unknown}
                        guard let post = NGPost(json: postJson) else {throw NGNetworkError.Unknown}
                        return (thread, post)
                    }
                    .mapToFailable()
                    .trackActivity(creating)
                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
            })
   
    }
}
