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

typealias NGCreateThreadResult = Result<Void, NGNetworkError>

struct NGCreateThreadViewModel: NGViewModelType {
    
    let loading: Driver<Bool>
    let results: Driver<NGCreateThreadResult>
    let createEnabled: Driver<Bool>
    let validatedTitle: Driver<NGValidationResult>
    let validatedContent: Driver<NGValidationResult>
    
    init(pageID: Int, title: Driver<String>, content: Driver<String>, createTaps: Driver<Void>){
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
                return networking.request(NGAuthenticatedService.CreateThread(page_id: pageID, title: title, content: content))
                    .filterSuccessfulStatusCodes()
                    .map{_ in Void()}
                    .mapToFailable()
                    .trackActivity(creating)
                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
            })
   
    }
}
