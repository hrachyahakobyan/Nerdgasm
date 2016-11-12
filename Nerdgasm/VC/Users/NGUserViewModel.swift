//
//  NGUserViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 10/20/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import Moya
import RxCocoa
import Result
import Gloss

typealias NGUserSearchResult = Result<[NGUser], NGNetworkError>

class NGUserViewModel: NGViewModelType {
    
    typealias T = [NGUser]
    let results: Driver<NGUserSearchResult>
    let searching: Driver<Bool>
    
    init(userQuery: Driver<String>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        
        let searching = ActivityIndicator()
        self.searching = searching.asDriver()
        
        results = userQuery
            .flatMapLatest{query in
                return networking.request(NGAuthenticatedService.SearchUsers(query: query))
                        .filterSuccessfulStatusCodes()
                        .mapJSON()
                        .map{ json -> [NGUser] in
                            guard let data: [JSON] = "data" <~~ (json as! JSON) else {
                                throw NGNetworkError.Unknown
                            }
                            return [NGUser].from(jsonArray: data) ?? []
                        }
                        .mapToFailable()
                        .trackActivity(searching)
                        .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
            }

    }
}
