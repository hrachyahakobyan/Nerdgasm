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

class NGSignupViewModel {

    let validatedUsername: Driver<NGSignupValidationResult>
    let validatedPassword: Driver<NGSignupValidationResult>
    let validatedPasswordRepeated: Driver<NGSignupValidationResult>
    
    // Is signup button enabled
    let signupEnabled: Driver<Bool>
    
    // Has user signed up
    let signedUp: Driver<NGSignupResult>
    
    // Is signing up process in progress
    let signingUp: Driver<Bool>
    
    // Is checking username validity
    let checkingUsername: Driver<Bool>

    init(input: (
            username: Driver<String>,
            password: Driver<String>,
            repeatedPassword: Driver<String>,
            loginTaps: Driver<Void>
        ),
         dependency: (
            provider: RxMoyaProvider<NGService>,
            validationService: NGSignupValidationService
        )
        ) {
        let provider = dependency.provider
        let validationService = dependency.validationService
        
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
                    .asDriver(onErrorJustReturn: .failed(message: "Error connecting server"))
            }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
            }
            .asDriver()
        
        validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) { ($0, $1) }
        
        let signingUp = ActivityIndicator()
        self.signingUp = signingUp.asDriver()

        signedUp = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                    return provider.request(NGService.Signup(username: username, password: password))
                                    .filterSuccessfulStatusCodes()
                                    .mapJSON()
                                    .map { json in
                                        print(json)
                                        guard let data: JSON = "data" <~~ (json as! JSON) else { return .failure(.Unknown) }
                                        if let user: NGUser = NGUser(json: data) {
                                            return .success(user)
                                        } else if let error: [String: String] = "error" <~~ (json as! JSON) {
                                            return .failure(.ValidationFailed(error))
                                        } else {
                                            return .failure(.Unknown)
                                        }
                                    }
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
