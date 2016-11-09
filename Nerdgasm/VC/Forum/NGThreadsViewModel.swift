//
//  NGThreadsViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxCocoa
import RxSwift
import Moya
import Gloss
import Result
import Foundation

typealias NGThreadsResult = Result<[NGThread], NGNetworkError>

class NGThreadsViewModel: NSObject {
    
    let threads: Driver<[NGThread]>
    let result: Driver<NGThreadsResult>
    let errors: Driver<NGNetworkError>
    let searching: Driver<Bool>
    
    init(query: Driver<String>, reloadAction: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        
        let searching = ActivityIndicator()
        self.searching = searching.asDriver()
        
        result = reloadAction
                    .flatMapLatest{ _ in
                        print("Fetching")
                        return networking.request(NGAuthenticatedService.GetThreads)
                                .filterSuccessfulStatusCodes()
                                .mapJSONDataArray()
                                .map { json -> [NGThread] in
                                    return [NGThread].from(jsonArray: json) ?? []
                                }
                                .mapToFailable()
                                .trackActivity(searching)
                                .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
                    }
        
        let rawThreads = result
            .filter{result in
                guard case NGThreadsResult.success(_) = result else {
                    return false
                }
                return true
            }
            .map{try! $0.dematerialize()}
            .asDriver(onErrorJustReturn: [])
        
        errors = result
            .filter{result in
                guard case NGThreadsResult.failure(_) = result else {
                    return false
                }
                return true
            }
            .map{$0.error!}
            .asDriver(onErrorJustReturn: NGNetworkError.Unknown)
        
        threads = Driver.combineLatest(rawThreads, query) { (ts, query) -> [NGThread] in
            return ts.filter{ query.isEmpty || $0.title.lowercased().range(of: query.lowercased()) != nil }
        }
    }

}
