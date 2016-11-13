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

typealias NGThreadsResult = Result<[(NGThread, NGUser)], NGNetworkError>

class NGThreadsViewModel: NGViewModelType {

    typealias T = [(NGThread, NGUser)]
    let results: Driver<NGThreadsResult>
    let loading: Driver<Bool>
    private let query: Driver<String>
    
    init(query: Driver<String>, reloadAction: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        self.query = query
        let searching = ActivityIndicator()
        self.loading = searching.asDriver()
        
        results = reloadAction
                    .flatMapLatest{ _ in
                        print("Fetching")
                        return networking.request(NGAuthenticatedService.GetThreads)
                                .filterSuccessfulStatusCodes()
                                .mapJSONDataArray()
                                .map { jsons -> [(NGThread, NGUser)] in
                                    return try jsons.map{json -> (NGThread, NGUser) in
                                        guard let thread = NGThread(json: json) else {throw NGNetworkError.Unknown}
                                        guard let user_json: JSON = "user" <~~ json else {throw NGNetworkError.Unknown}
                                        guard let user = NGUser(json: user_json) else {throw NGNetworkError.Unknown}
                                        return (thread, user)
                                    }.sorted{$0.0.post_count > $1.0.post_count}
                                }
                                .mapToFailable()
                                .trackActivity(searching)
                                .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
                    }
    }
    
    func filteredThreads() -> Driver<T>{
        return Driver.combineLatest(clean(), self.query) { (ts, query) -> T in
            return ts.filter{ query.isEmpty || $0.0.title.lowercased().range(of: query.lowercased()) != nil }
        }
    }

}
