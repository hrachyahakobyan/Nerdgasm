//
//  NGCreateThreadValidationService.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum NGThreadValidationResult: NGValidationResult{
    case OK
    case empty(message: String)
    
    var isValid: Bool {
        switch self {
        case .OK:
            return true
        default:
            return false
        }
    }
    var description: String {
        switch self {
        case .OK:
            return ""
        case let .empty(message):
            return message
        }
    }

    var textColor: UIColor {
        switch self {
        case .OK:
            return ValidationColors.okColor
        case .empty:
            return ValidationColors.errorColor
        }
    }
}


class NGCreateThreadValidationService {
    
    static let sharedCreateThreadValidationService = NGCreateThreadValidationService()
    
    func validateTitle(_ title: String) -> NGValidationResult {
        return title.characters.count != 0 ? NGThreadValidationResult.OK : NGThreadValidationResult.empty(message: "Please enter a title")
    }
    
    func validateContent(_ content: String) -> NGValidationResult {
        return content.characters.count != 0 ? NGThreadValidationResult.OK : NGThreadValidationResult.empty(message: "Please enter a message")
    }
}




