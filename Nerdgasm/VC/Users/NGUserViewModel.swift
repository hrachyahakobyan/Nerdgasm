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

typealias NGUserLougoutResult = Result<Void, NGNetworkError>

class NGUserViewModel {
    let loggingOut: Driver<Bool>
    let loggedOut: Driver<NGUserLougoutResult>
    
    init(loggingOutTaps: Driver<Void>, access_token: String){
        let networking = NGAuthorizedNetworking.newAuthorizedNetworking(access_token)
        
        let loggingOut = ActivityIndicator()
        self.loggingOut = loggingOut.asDriver()
        
        loggedOut = loggingOutTaps
            .flatMapLatest{
                return networking.request(NGAuthenticatedService.Signout)
                    .filterSuccessfulStatusCodes()
                    .map{_ in .success()}
                    .trackActivity(loggingOut)
                    .catchError{ err in
                        if isunAuhtorized(error: err){
                            return .just(.success(Void()))
                        } else {
                            return .just(.failure(toNgError(err: err)))
                        }
                    }
                    .asDriver(onErrorJustReturn: NGUserLougoutResult.failure(.NoConnection))
        }

    }
}
