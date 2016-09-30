//
//  NGLoginViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 9/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import SwiftValidator
import RxSwift

class NGLoginViewController: UIViewController {

    fileprivate let validator = Validator()
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        passwordTextField.isSecureTextEntry = true
        validator.registerField(usernameTextField, errorLabel: usernameLabel, rules: [RequiredRule(), MinLengthRule(length: 6, message: "Username must be at least 6 characters long"), MaxLengthRule(length:30, message: "Username must be at most 30 characters long")])
        validator.registerField(passwordTextField, rules: [PasswordRule()])
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInAction(sender: UIButton) {
        validator.validate(self)
    }

    @IBAction func signUpAction(sender: UIButton) {
    }
}

extension NGLoginViewController: ValidationDelegate{
    func validationSuccessful() {
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        
    }
}

extension NGLoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        validator.validate(self)
    }
}
