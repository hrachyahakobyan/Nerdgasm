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

class NGThreadsViewModel: NGViewModelType {

    let results: Driver<NGThreadsResult>
    let searching: Driver<Bool>
    private let query: Driver<String>
    
    init(query: Driver<String>, reloadAction: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        self.query = query
        let searching = ActivityIndicator()
        self.searching = searching.asDriver()
        
        results = reloadAction
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
    }
    
    func filteredThreads() -> Driver<[NGThread]>{
        return Driver.combineLatest(clean(), self.query) { (ts, query) -> [NGThread] in
            return ts.filter{ query.isEmpty || $0.title.lowercased().range(of: query.lowercased()) != nil }
        }
    }
}
