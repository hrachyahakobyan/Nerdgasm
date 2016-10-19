//
//  NGLoginValidationService.swift
//  Nerdgasm
//
//  Created by Hrach on 10/16/16.
//  Copyright © 2016 Hrach. All rights reserved.
//


import Foundation
import RxSwift

protocol NGLoginValidationService {
    func validateUsername(_ username: String) -> Bool
    func validatePassword(_ password: String) -> Bool
}

class NGDefaultLoginValidationService: NGLoginValidationService {
    
    func validateUsername(_ username: String) -> Bool {
        return username.characters.count != 0
    }

    static let sharedLoginValidationService = NGDefaultLoginValidationService()
    
    func validatePassword(_ password: String) -> Bool {
        return password.characters.count != 0
    }
}
