//
//  NGSignupViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 10/1/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Result
import Moya
import Gloss

typealias NGSignupResult = Result<NGUser, NGNetworkError>

class NGSignupViewModel: NGViewModelType {

    let validatedUsername: Driver<NGValidationResult>
    let validatedPassword: Driver<NGValidationResult>
    let validatedPasswordRepeated: Driver<NGValidationResult>
    
    // Is signup button enabled
    let signupEnabled: Driver<Bool>
    
    // Has user signed up
    let results: Driver<NGSignupResult>
    
    // Is signing up process in progress
    let loading: Driver<Bool>
    
    // Is checking username validity
    let checkingUsername: Driver<Bool>

    init(input: (
            username: Driver<String>,
            password: Driver<String>,
            repeatedPassword: Driver<String>,
            loginTaps: Driver<Void>
        ),
         validationService: NGSignupValidationService
        ) {
        let networking = NGNetworking.sharedNetworking
        let validationService = validationService
        
        /**
         Notice how no subscribe call is being made.
         Everything is just a definition.
         Pure transformation of input sequences to output sequences.
         */
        let checkingUsername = ActivityIndicator()
        self.checkingUsername = checkingUsername.asDriver()
        
        validatedUsername = input.username
            .flatMapLatest { username in
                return validationService.validateUsername(username)
                    .trackActivity(checkingUsername)
                    .asDriver(onErrorJustReturn: NGSignupValidationResult.failed(message: "Error connecting server"))
            }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
            .asDriver()
        
        validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) { ($0, $1) }
        
        let signingUp = ActivityIndicator()
        self.loading = signingUp.asDriver()

        results = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                    return networking.request(NGService.Signup(username: username, password: password))
                                    .filterSuccessfulStatusCodes()
                                    .mapJSON()
                                    .map { json in
                                        guard let data: JSON = "data" <~~ (json as! JSON) else { throw NGNetworkError.Unknown }
                                        if let user: NGUser = NGUser(json: data) {
                                            return user
                                        } else {
                                            throw NGNetworkError.Unknown
                                        }
                                    }
                                    .mapToFailable()
                                    .trackActivity(signingUp)
                                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
            }
    
        signupEnabled = Driver.combineLatest(
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated,
            signingUp
        )   { username, password, repeatPassword, signingUp -> Bool in
                username.isValid &&
                password.isValid &&
                repeatPassword.isValid &&
                !signingUp
            }
            .distinctUntilChanged()
    }
}
