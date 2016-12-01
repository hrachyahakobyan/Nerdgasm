//
//  NGMyProfileViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/25/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGMyProfileViewController: NGAuthenticatedViewController {

    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarImageView: NGAvatarImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cleanUser = NGUserCredentials.rxUser.filter{$0 != nil}.map{$0!}
        
        cleanUser
            .map{$0.firstname}
            .drive(firstnameTextField.rx.text)
            .addDisposableTo(disposeBag)
        
        cleanUser
            .map{$0.lastname}
            .drive(lastNameTextField.rx.text)
            .addDisposableTo(disposeBag)
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        let canceItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.rightBarButtonItem = saveItem
        navigationItem.leftBarButtonItem = canceItem
        
        saveItem.rx.tap
            .asDriver()
            .drive(onNext: {self.closeAction()}, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        canceItem.rx.tap
            .asDriver()
            .drive(onNext: {self.closeAction()}, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        let fname: Driver<String> = firstnameTextField.rx.text.orEmpty.asDriver()
        let lname: Driver<String> = lastNameTextField.rx.text.orEmpty.asDriver()
        let modelInput: Driver<NGUser> = Driver.combineLatest(fname,
                                              lname,
                                              cleanUser) { (f: String, l: String, u: NGUser) -> NGUser in
                                                u.firstname = f
                                                u.lastname = l
                                                return u
                                            }
        
        let imageTap = UITapGestureRecognizer()
        avatarImageView.isUserInteractionEnabled = false
        avatarView.addGestureRecognizer(imageTap)
        
        let model = NGMyProfileViewModel(user: modelInput, avatarTaps: imageTap.rx.event.asDriver().map{_ in Void()}, updateUserTaps:  navigationItem.rightBarButtonItem!.rx.tap.asDriver(), vc: self)
        
        model.loading
            .showProgress()
            .map{!$0}
            .drive(navigationItem.leftBarButtonItem!.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        model.loading
            .map{!$0}
            .drive(navigationItem.rightBarButtonItem!.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        model.results
            .drive(onNext:{result in
                switch result {
                case .success(let user):
                    let cred = NGUserCredentials.rxCredentials.value
                    cred?.user = user
                    cred?.synchronize()
                case .failure(let err):
                    self.handleError(error: err, showError: true)
                }
                }, onCompleted: nil, onDisposed: {print("Dismposed")})
            .addDisposableTo(disposeBag)
        // Do any additional setup after loading the view.
    }
    
    func closeAction(){
        _ = self.navigationController?.popViewController(animated: true)
    }

}
