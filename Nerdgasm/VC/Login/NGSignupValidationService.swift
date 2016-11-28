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
import RxCocoa

enum NGSignupValidationResult: NGValidationResult{
    case OK(message: String)
    case empty
    case validating
    case failed(message: String)
    
    var textColor: UIColor {
        switch self {
        case .OK:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
    
    var description: String {
        switch self {
        case let .OK(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
    
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
    func validateUsername(_ username: String) -> Observable<NGValidationResult>
    func validatePassword(_ password: String) -> NGValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> NGValidationResult
}

class NGDefaultSignupValidationService: NGSignupValidationService{
    let networking = NGNetworking.sharedNetworking
    let minPasswordCount = 8
    let minUsernameCount = 6
    static let sharedSignupValidationService = NGDefaultSignupValidationService()
    
    func validateUsername(_ username: String) -> Observable<NGValidationResult> {
        if username.characters.count == 0 {
            return .just(NGSignupValidationResult.empty)
        }
        
        if username.characters.count < minUsernameCount {
            return .just(NGSignupValidationResult.failed(message: "Username must be at least \(minUsernameCount) characters"))
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(NGSignupValidationResult.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = NGSignupValidationResult.validating
        
        return networking.request(NGService.UsernameAvailable(username: username))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { json in
                guard let validJson = json as? JSON else {
                    return NGSignupValidationResult.failed(message: "Invalid response")
                }
                guard let result = NGUsernameExistsResult(json: validJson) else {
                    return NGSignupValidationResult.failed(message: "Invalid response")
                }
                if result.usernameExists {
                    return NGSignupValidationResult.failed(message: "Username already taken")
                }
                else {
                    return NGSignupValidationResult.OK(message: "Username available")
                }
            }
            .catchErrorJustReturn(NGSignupValidationResult.failed(message: "Check internet connection"))
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> NGValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return NGSignupValidationResult.empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return NGSignupValidationResult.failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return NGSignupValidationResult.OK(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> NGValidationResult {
        if repeatedPassword.characters.count == 0 {
            return NGSignupValidationResult.empty
        }
        
        if repeatedPassword == password {
            return NGSignupValidationResult.OK(message: "Password repeated")
        }
        else {
            return NGSignupValidationResult.failed(message: "Passwords do not match")
        }
    }
    
}
