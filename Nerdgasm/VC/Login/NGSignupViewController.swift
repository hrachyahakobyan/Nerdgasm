//
//  NGSignupViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/1/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import RxCocoa

class NGSignupViewController: NGViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameExistsActivityIndicator: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()
    @IBOutlet weak var cancelButton: UIButton!
    private var latestUsername: Driver<String> {
        return usernameTextField.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        usernameExistsActivityIndicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        repeatPasswordTextField.isSecureTextEntry = true
        let viewModel = NGSignupViewModel(
            input: (
                username: latestUsername,
                password: passwordTextField.rx.text.orEmpty.asDriver(),
                repeatedPassword: repeatPasswordTextField.rx.text.orEmpty.asDriver(),
                loginTaps: signupButton.rx.tap.asDriver()
            ),
                validationService: NGDefaultSignupValidationService.sharedSignupValidationService
        )
        
        viewModel.signupEnabled
            .drive(onNext: { [weak self] valid  in
                self?.signupButton.isEnabled = valid
                self?.signupButton.alpha = valid ? 1.0 : 0.5
                })
            .addDisposableTo(disposeBag)
        
        viewModel.signingUp
            .map{!$0}
            .drive(cancelButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.validatedUsername
            .drive(usernameLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        viewModel.validatedPassword
            .drive(passwordLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
    
        viewModel.validatedPasswordRepeated
            .drive(repeatPasswordLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        viewModel.signingUp
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        viewModel.checkingUsername
            .drive(usernameExistsActivityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        viewModel.checkingUsername
            .drive(usernameLabel.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        viewModel.results
            .drive(onNext: { result in
                switch result {
                    case .success( _):
                        self.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        self.handleError(error: error)
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
    

    @IBAction func cancelButtonAction(_ sender: UIButton) {
        if !sender.isEnabled {
            return
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
