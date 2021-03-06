//
//  NGLoginViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 10/16/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import Result
import Gloss

typealias NGLoginResult = Result<NGUserCredentials, NGNetworkError>

class NGLoginViewModel: NGViewModelType {
    
    let validatedUsername: Driver<Bool>
    let validatedPassword: Driver<Bool>
    let loginEnabled: Driver<Bool>
    let results: Driver<NGLoginResult>
    let loading: Driver<Bool>
    
    init(input: (
        username: Driver<String>,
        password: Driver<String>,
        loginTaps: Driver<Void>
        ),
        validationService: NGLoginValidationService
        ) {
        let networking = NGNetworking.sharedNetworking
        let validationService = validationService
        
        validatedUsername = input.username
            .map { username in
                    return validationService.validateUsername(username)
                }
            .asDriver()
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
                }
            .asDriver()
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) { ($0, $1) }
        
        let loggingIn = ActivityIndicator()
        self.loading = loggingIn.asDriver()
        
        results = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest{ (username, password) in
                    return networking.request(NGService.Signin(username: username, password: password))
                        .filterSuccessfulStatusCodes()
                        .mapJSON()
                        .map{ json in
                            guard let data: JSON = "data" <~~ (json as! JSON) else {
                                throw NGNetworkError.Unknown
                            }
                            guard let access_token: String = "access_token" <~~ data else {
                                throw NGNetworkError.Unknown
                            }
                            guard let userData: JSON = "user" <~~ data else {
                                throw NGNetworkError.Unknown
                            }
                            guard let user: NGUser = NGUser(json: userData) else {
                                throw NGNetworkError.Unknown
                            }
                            return NGUserCredentials(user: user, token: access_token)
                        }
                        .mapToFailable()
                        .trackActivity(loggingIn)
                        .asDriver(onErrorJustReturn: .failure(.NoConnection))
        }
        
        
        loginEnabled = Driver.combineLatest(
            validatedUsername,
            validatedPassword,
            loggingIn
        )   { username, password, signingUp -> Bool in
                username &&
                password &&
                !signingUp
            }
            .distinctUntilChanged()
    }

}
