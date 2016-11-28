//
//  NGLoginView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum NGLoginTapDestination {
    case Signin
    case Signup
}

class NGLoginView: ViewFromNib {
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    var signupTaps: Driver<Void>!
    var signinTaps: Driver<Void>!
    
    var allTaps: Driver<NGLoginTapDestination> {
        return Driver.of(signupTaps.map{NGLoginTapDestination.Signup}, signinTaps.map{NGLoginTapDestination.Signin}).merge()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        signupTaps = signupButton.rx.tap.asDriver()
        signinTaps = signinButton.rx.tap.asDriver()
    }
    
    override func nibSetup(){
        super.nibSetup()
        signupTaps = signupButton.rx.tap.asDriver()
        signinTaps = signinButton.rx.tap.asDriver()
    }
}
