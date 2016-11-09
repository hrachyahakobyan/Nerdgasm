//
//  NGValidation.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol NGValidationResult {
    var description: String { get }
    var textColor: UIColor { get }
    var isValid: Bool { get }
}

extension Reactive where Base: UILabel {
    var validationResult: AnyObserver<NGValidationResult> {
        return UIBindingObserver(UIElement: base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
            }.asObserver()
    }
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}
