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

struct NGPostsViewModel{
    
    let gettingPosts: Driver<Bool>
    let results: Driver<NGPostsResult>
    let posts: Driver<[(NGPost, NGUser)]>
    let errors: Driver<NGNetworkError>
    
    init(threads: Driver<NGThread>, reloadAction: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        let gettingPosts = ActivityIndicator()
        self.gettingPosts = gettingPosts.asDriver()
        
        results = reloadAction.withLatestFrom(threads)
                    .flatMapLatest({ thread in
                        return networking.request(NGAuthenticatedService.GetPosts(thread_id: thread.id))
                            .filterSuccessfulStatusCodes()
                            .mapJSONDataArray()
                            .map{ jsonArray -> [(NGPost, NGUser)] in
                                return try jsonArray.map{ json in
                                    guard let post: NGPost = NGPost(json: json) else {throw NGNetworkError.Unknown}
                                    guard let userJson: JSON = "user" <~~ json else {throw NGNetworkError.Unknown}
                                    guard let user: NGUser = NGUser(json: userJson) else {throw NGNetworkError.Unknown}
                                    return (post, user)
                                }
                             }
                            .mapToFailable()
                            .trackActivity(gettingPosts)
                            .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
                    })
        
        posts = results
            .filter{result in
                guard case NGPostsResult.success(_) = result else {
                    return false
                }
                return true
            }
            .map{try! $0.dematerialize()}
            .asDriver(onErrorJustReturn: [])
        
        errors = results
            .filter{result in
                guard case NGPostsResult.failure(_) = result else {
                    return false
                }
                return true
            }
            .map{$0.error!}
            .asDriver(onErrorJustReturn: NGNetworkError.Unknown)
 
    }
    
}
