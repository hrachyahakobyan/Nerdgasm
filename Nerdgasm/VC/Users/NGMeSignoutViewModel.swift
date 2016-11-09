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

typealias NGSignoutResult = Result<Void, NGNetworkError>

class NGMeSignoutViewModel {
    let loggingOut: Driver<Bool>
    let loggedOut: Driver<NGSignoutResult>
    
    init(loggingOutTaps: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        let loggingOut = ActivityIndicator()
        self.loggingOut = loggingOut.asDriver()
        
        loggedOut = loggingOutTaps
            .flatMapLatest{
                return networking.request(NGAuthenticatedService.Signout)
                    .filterSuccessfulStatusCodes()
                    .map{_ in Void()}
                    .mapToFailable()
                    .trackActivity(loggingOut)
                    .asDriver(onErrorJustReturn: NGSignoutResult.failure(.NoConnection))
        }
        
    }
}
