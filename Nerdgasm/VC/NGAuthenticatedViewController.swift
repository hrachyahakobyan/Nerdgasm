//
//  NGAuthenticatedViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NGAuthenticatedViewController: NGViewController {
    
    var loginView: NGLoginView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView = NGLoginView(frame: CGRect.zero)
        view.addSubview(loginView)
        loginView.layer.zPosition = 1
        loginView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        NGUserCredentials.loggedIn
            .drive(loginView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        loginView.allTaps
            .drive(onNext: { (tapDestination: NGLoginTapDestination) in
                DefaultWireframe.sharedInstance.presentLogin(configure: { (login) in
                    login.signinVisible.value = (tapDestination == .Signin ? true : false)
                })
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    override func handleError(error: NGNetworkError, showError: Bool = false) {
        if case NGNetworkError.Unauthorized = error  {
            NGUserCredentials.reset()
        }
        super.handleError(error: error, showError: showError)
    }
}
