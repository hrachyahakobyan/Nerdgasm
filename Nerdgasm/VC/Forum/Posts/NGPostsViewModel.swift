//
//  NGPostsViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Result
import Gloss

typealias NGPostsResult = Result<[(NGPost, NGUser)], NGNetworkError>

struct NGPostsViewModel: NGViewModelType{
    
    let loading: Driver<Bool>
    let results: Driver<NGPostsResult>
    
    init(threads: Driver<NGThread>, reloadAction: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        let gettingPosts = ActivityIndicator()
        self.loading = gettingPosts.asDriver()
        
        results = reloadAction.withLatestFrom(threads)
                    .flatMapLatest({ thread in
                        networking.provider.request(NGAuthenticatedService.ViewThread(thread_id: thread.id)){ result in
                            print(result)
                        }
                        return networking.request(NGAuthenticatedService.GetPosts(thread_id: thread.id))
                            .filterSuccessfulStatusCodes()
                            .mapJSONDataArray()
                            .map{ jsonArray -> [(NGPost, NGUser)] in
                                return try jsonArray.map{ json in
                                    guard let post: NGPost = NGPost(json: json) else {throw NGNetworkError.Unknown}
                                    guard let userJson: JSON = "user" <~~ json else {throw NGNetworkError.Unknown}
                                    guard let user: NGUser = NGUser(json: userJson) else {throw NGNetworkError.Unknown}
                                    return (post, user)
                                }.sorted{$0.0.date < $1.0.date}
                             }
                            .mapToFailable()
                            .trackActivity(gettingPosts)
                            .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
                    })
        }
}
