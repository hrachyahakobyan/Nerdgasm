//
//  NGLoginValidationService.swift
//  Nerdgasm
//
//  Created by Hrach on 10/1/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Gloss

enum NGSignupValidationResult{
    case OK(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension NGSignupValidationResult {
    var isValid: Bool {
        switch self {
        case .OK:
            return true
        default:
            return false
        }
    }
}

struct NGUsernameExistsResult{
    let usernameExists: Bool
    
    init?(json: JSON) {
        guard let data: JSON = "data" <~~ json else {
            return nil
        }
        guard let exists: Bool = "username_exists" <~~ data else {
            return nil
        }
        self.usernameExists = exists
    }
}

protocol NGSignupValidationService{
    func validateUsername(_ username: String) -> Observable<NGSignupValidationResult>
    func validatePassword(_ password: String) -> NGSignupValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> NGSignupValidationResult
}

class NGDefaultSignupValidationService: NGSignupValidationService{
    let networking = NGNetworking.sharedNetworking
    let minPasswordCount = 8
    let minUsernameCount = 6
    static let sharedSignupValidationService = NGDefaultSignupValidationService()
    
    func validateUsername(_ username: String) -> Observable<NGSignupValidationResult> {
        if username.characters.count == 0 {
            return .just(.empty)
        }
        
        if username.characters.count < minUsernameCount {
            return .just(.failed(message: "Username must be at least \(minUsernameCount) characters"))
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = NGSignupValidationResult.validating
        
        return networking.request(NGService.UsernameAvailable(username: username))
            .debug()
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { json in
                guard let validJson = json as? JSON else {
                    return .failed(message: "Invalid response")
                }
                guard let result = NGUsernameExistsResult(json: validJson) else {
                    return .failed(message: "Invalid response")
                }
                if result.usernameExists {
                    return .failed(message: "Username already taken")
                }
                else {
                    return .OK(message: "Username available")
                }
            }
            .catchErrorJustReturn(.failed(message: "Check internet connection"))
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> NGSignupValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return .OK(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> NGSignupValidationResult {
        if repeatedPassword.characters.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .OK(message: "Password repeated")
        }
        else {
            return .failed(message: "Passwords do not match")
        }
    }
    
}
