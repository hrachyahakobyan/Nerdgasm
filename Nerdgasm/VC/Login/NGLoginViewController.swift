//
//  NGLoginViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 9/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class NGLoginViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var signInResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        let viewModel = NGLoginViewModel(
            input: (
                username: usernameTextField.rx.text.asDriver(),
                password: passwordTextField.rx.text.asDriver(),
                loginTaps: signInButton.rx.tap.asDriver()
            ),
                validationService: NGDefaultLoginValidationService.sharedLoginValidationService
        )
        
        viewModel.loginEnabled
            .drive(onNext: { [weak self] valid  in
            self?.signInButton.isEnabled = valid
            self?.signInButton.alpha = valid ? 1.0 : 0.5
            })
        .addDisposableTo(disposeBag)

        viewModel.loggingIn
            .drive(activityIndicator.rx.animating)
            .addDisposableTo(disposeBag)
        
        viewModel.loggingIn
            .map{!$0}
            .drive(signUpButton.rx.enabled)
            .addDisposableTo(disposeBag)
        
        viewModel.loggedIn
            .drive(onNext: { result in
                switch result {
                case .success(let user, let token):
                    user.saveToUserDefaults()
                    NGUser.setToken(token: token)
                    self.signInResultLabel.text = ""
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    switch error {
                    case .NoConnection:
                        self.signInResultLabel.text = "Could not connect to the Internet"
                    case .NotFound:
                        self.signInResultLabel.text = "Incorrect username/password"
                    default:
                        self.signInResultLabel.text = "Unknown error"
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                })
            .addDisposableTo(disposeBag)
        view.addGestureRecognizer(tapBackground)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

