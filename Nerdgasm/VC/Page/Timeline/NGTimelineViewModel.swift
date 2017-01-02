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

typealias NGTimelineResult = Result<[(NGArticle, NGUser)], NGNetworkError>

class NGTimelineViewModel: NGViewModelType {
    
    typealias T = [(NGArticle, NGUser)]
    let results: Driver<NGTimelineResult>
    let loading: Driver<Bool>
    
    init(pageID: Int, reloadAction: Driver<Void>){
        let networking = NGNetworking.sharedNetworking
        let searching = ActivityIndicator()
        self.loading = searching.asDriver()
        
        results = reloadAction
            .flatMapLatest{ _ in
                return networking.request(NGService.GetPageArticles(pageID: pageID))
                    .filterSuccessfulStatusCodes()
                    .mapJSONDataArray()
                    .map { jsons -> [(NGArticle, NGUser)] in
                        return try jsons.map{json -> (NGArticle, NGUser) in
                            guard let article = NGArticle(json: json) else {throw NGNetworkError.Unknown}
                            guard let user_json: JSON = "user" <~~ json else {throw NGNetworkError.Unknown}
                            guard let user = NGUser(json: user_json) else {throw NGNetworkError.Unknown}
                            return (article, user)
                            }.sorted{$0.0.upvotes > $1.0.upvotes}
                    }
                    .mapToFailable()
                    .trackActivity(searching)
                    .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
        }
    }
}
