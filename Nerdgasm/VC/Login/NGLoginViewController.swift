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

class NGLoginViewController: NGViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var inputFieldsView: UIStackView!
    @IBOutlet weak var signInResultLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        signInResultLabel.textColor = UIColor.red
        
        let allTaps = Observable.of(signInButton.rx.tap, signUpButton.rx.tap)
                            .merge()
                            .asDriver(onErrorJustReturn: Void())
        allTaps
            .drive(onNext: { _ in
                    self.view.endEditing(true)
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
            .drive(signUpButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.results
            .drive(onNext: { result in
                switch result {
                case .success(let credentials):
                    credentials.synchronize()
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
        
        //let x = R.segue.login
               // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

