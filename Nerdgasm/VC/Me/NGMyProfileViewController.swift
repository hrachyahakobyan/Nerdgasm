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
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let credentials = NGUserCredentials.credentials()!
        firstnameTextField.text = credentials.user.firstname
        lastNameTextField.text = credentials.user.lastname
        let modelInput = Driver.combineLatest(firstnameTextField.rx.text.orEmpty.asDriver(),
                                      lastNameTextField.rx.text.orEmpty.asDriver(),
                                      Driver.just(credentials.user),
                                      resultSelector: {f, l, u -> NGUser in
                                        u.firstname = f
                                        u.lastname = l
                                        return u
        })
        
        
        let model = NGMyProfileViewModel(user: modelInput, updateUserTaps: navigationItem.rightBarButtonItem!.rx.tap.asDriver())
        
        model.loading
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
                    credentials.user = user
                    credentials.synchronize()
                case .failure(let err):
                    self.handleError(error: err)
                }
                }, onCompleted: nil, onDisposed: {print("Dismposed")})
            .addDisposableTo(disposeBag)
    }

    
    func closeAction(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
