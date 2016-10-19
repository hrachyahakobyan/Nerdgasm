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

typealias NGLoginResult = Result<(NGUser, String), NGNetworkError>

class NGLoginViewModel {
    
    let validatedUsername: Driver<Bool>
    let validatedPassword: Driver<Bool>
    let loginEnabled: Driver<Bool>
    let loggedIn: Driver<NGLoginResult>
    let loggingIn: Driver<Bool>
    
    init(input: (
        username: Driver<String>,
        password: Driver<String>,
        loginTaps: Driver<Void>
        ),
         dependency: (
        provider: RxMoyaProvider<NGService>,
        validationService: NGLoginValidationService
        )
        ) {
        let provider = dependency.provider
        let validationService = dependency.validationService
        
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
        self.loggingIn = loggingIn.asDriver()
        
        loggedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest{ (username, password) in
                    return provider.request(NGService.Signin(username: username, password: password))
                        .filterSuccessfulStatusCodes()
                        .do(onNext: nil, onError: { err in
                            print(err)
                            }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
                        .mapJSON()
                        .map{ json in
                            print(json)
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
                            return (user, access_token)
                        }
                        .mapToFailable()
                        .trackActivity(loggingIn)
                        .catchError{.just(.failure(.Error($0)))}
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

extension ObservableType{
    public func mapToFailable() -> Observable<Result<E, NGNetworkError>>{
        return self
            .map(Result<E, NGNetworkError>.success)
            .catchError{ err in
                if type(of: err) == Moya.Error.self {
                    let moyaErr = err as! Moya.Error
                    switch moyaErr {
                    case .statusCode(let response):
                        switch response.statusCode{
                            case 404:
                                return .just(.failure(.NotFound))
                            case 401:
                                return .just(.failure(.Unauthorized))
                            default:
                                return .just(.failure(.Unknown))
                        }
                    case .underlying(let err):
                        return .just(.failure(.Error(err)))
                    default:
                        return .just(.failure(.Unknown))
                    }
                }
                else {
                    return .just(.failure(.Error(err)))
                }
        }
    }
}
