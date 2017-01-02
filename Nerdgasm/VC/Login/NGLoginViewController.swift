//
//  NGLoginViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 9/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGLoginViewController: NGViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    // MARK: Sign in outlets
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var openSignupButton: UIButton!
    @IBOutlet weak var inputFieldsView: UIStackView!
    @IBOutlet weak var signInResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Sign up outlets

    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupRepeatPasswordValidLabel: UILabel!
    @IBOutlet weak var signupRepeatPasswordTextField: UITextField!
    @IBOutlet weak var signupPasswordValidLabel: UILabel!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var usernameAvailableLabel: UILabel!
    @IBOutlet weak var signupUsernameTextField: UITextField!
    @IBOutlet weak var openSigninButton: UIButton!
    @IBOutlet weak var checkUsernameActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signupActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signupResultLabel: UILabel!
    let signinVisible = Variable<Bool>(true)
    
    private var latestSignupUsername: Driver<String> {
        return signupUsernameTextField.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        signInResultLabel.textColor = UIColor.red
        signupResultLabel.textColor = UIColor.red
        
        let allTaps = Observable.of(signInButton.rx.tap, signupButton.rx.tap, openSignupButton.rx.tap, openSignupButton.rx.tap)
                            .merge()
                            .asDriver(onErrorJustReturn: Void())
        allTaps
            .drive(onNext: {[weak self] _ in
                    self?.view.endEditing(true)
                    print(self?.signInResultLabel.text)
                    self?.signInResultLabel.text = ""
                    self?.signupResultLabel.text = ""
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        let viewModel = NGLoginViewModel(
            input: (
                username: usernameTextField.rx.text.orEmpty.asDriver(),
                password: passwordTextField.rx.text.orEmpty.asDriver(),
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

        viewModel.loading
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .map{!$0}
            .drive(openSignupButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.results
            .drive(onNext: {[weak self] result in
                switch result {
                case .success(let credentials):
                    credentials.synchronize()
                    self?.signInResultLabel.text = ""
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    switch error {
                    case .NoConnection:
                        self?.signInResultLabel.text = "Could not connect to the Internet"
                    case .NotFound:
                        self?.signInResultLabel.text = "Incorrect username/password"
                    default:
                        self?.signInResultLabel.text = "Unknown error"
                    }
                    self?.handleError(error: error)
                }
            })
            .addDisposableTo(disposeBag)
        
        signupActivityIndicator.hidesWhenStopped = true
        checkUsernameActivityIndicator.hidesWhenStopped = true
        signupPasswordTextField.isSecureTextEntry = true
        signupRepeatPasswordTextField.isSecureTextEntry = true
        let signupModel = NGSignupViewModel(
            input: (
                username: latestSignupUsername,
                password: signupPasswordTextField.rx.text.orEmpty.asDriver(),
                repeatedPassword: signupRepeatPasswordTextField.rx.text.orEmpty.asDriver(),
                loginTaps: signupButton.rx.tap.asDriver()
            ),
            validationService: NGDefaultSignupValidationService.sharedSignupValidationService
        )
        
        signupModel.signupEnabled
            .drive(onNext: { [weak self] valid  in
                self?.signupButton.isEnabled = valid
                self?.signupButton.alpha = valid ? 1.0 : 0.5
                })
            .addDisposableTo(disposeBag)
        
        signupModel.loading
            .map{!$0}
            .drive(openSigninButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        signupModel.loading
            .drive(signupActivityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        signupModel.validatedUsername
            .drive(usernameAvailableLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        signupModel.validatedPassword
            .drive(signupPasswordValidLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        signupModel.validatedPasswordRepeated
            .drive(signupRepeatPasswordValidLabel.rx.validationResult)
            .addDisposableTo(disposeBag)

        signupModel.checkingUsername
            .drive(checkUsernameActivityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        signupModel.checkingUsername
            .drive(usernameAvailableLabel.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        signupModel.results
            .drive(onNext: {[weak self] result in
                switch result {
                case .success(let user):
                    self?.usernameTextField.setRxText(text: user.username)
                    self?.signinVisible.value = true
                    self?.signupUsernameTextField.setRxText(text: "")
                    self?.signupPasswordTextField.setRxText(text: "")
                    self?.signupRepeatPasswordTextField.setRxText(text: "")
                    self?.signupResultLabel.text = ""
                case .failure(let error):
                    switch error {
                    case .NoConnection:
                        self?.signupResultLabel.text = "Could not connect to the Internet"
                    case .ValidationFailed(_):
                        self?.signupResultLabel.text = "Username already taken"
                    default:
                        self?.signupResultLabel.text = "Unknown error"
                    }
                    self?.handleError(error: error)
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
        
        openSigninButton.rx.tap
            .map{true}
            .bindTo(signinVisible)
            .addDisposableTo(disposeBag)
        
        openSignupButton.rx.tap
            .map{false}
            .bindTo(signinVisible)
            .addDisposableTo(disposeBag)
        
        signinVisible
            .asDriver()
            .drive(signupView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        signinVisible
            .asDriver()
            .map{!$0}
            .drive(signinView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        let loading = Driver.of(viewModel.loading, signupModel.loading).merge()
        
        loading
            .map{!$0}
            .drive(cancelButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        cancelButton.rx.tap.asDriver()
            .drive(onNext: {[weak self] (tap) in
                 self?.dismiss(animated: true, completion: nil)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

