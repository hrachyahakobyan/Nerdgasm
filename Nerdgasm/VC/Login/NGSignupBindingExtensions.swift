//
//  NGSignupBindingExtensions.swift
//  Nerdgasm
//
//  Created by Hrach on 10/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Result

extension NGSignupValidationResult: CustomStringConvertible {
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
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension NGSignupValidationResult {
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
}

extension Reactive where Base: UILabel {
    var validationResult: AnyObserver<NGSignupValidationResult> {
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
            }.asObserver()
    }
}
