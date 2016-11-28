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
    @IBOutlet weak var avatarIMageView: NGImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = NGUserCredentials.credentials()?.user
        firstnameTextField.text = user?.firstname
        lastNameTextField.text = user?.lastname
        
        avatarIMageView.offlinePlaceholder = #imageLiteral(resourceName: "avatar")
        
        let profileURLs = NGUserCredentials.rxCredentials
            .filter{$0 != nil}
            .map{NGService.imageURL.appendingPathComponent($0!.user.image)}
        
        profileURLs
            .distinctUntilChanged()
            .flatMapLatest { (url)  in
                DefaultImageService.sharedImageService.imageFromURL(url)
            }
            .observeOn(MainScheduler.instance)
            .bindTo(avatarIMageView.rx.downloadableImage)
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
        
        let userDriver: Driver<NGUser> = NGUserCredentials.rxCredentials.asDriver(onErrorJustReturn: nil).filter{$0 != nil}.map{$0!.user}
        
        let fname: Driver<String> = firstnameTextField.rx.text.orEmpty.asDriver()
        let lname: Driver<String> = lastNameTextField.rx.text.orEmpty.asDriver()
        let modelInput: Driver<NGUser> = Driver.combineLatest(fname,
                                              lname,
                                              userDriver) { (f: String, l: String, u: NGUser) -> NGUser in
                                                u.firstname = f
                                                u.lastname = l
                                                return u
                                            }
        
        let imageTap = UITapGestureRecognizer()
        avatarIMageView.isUserInteractionEnabled = false
        avatarView.addGestureRecognizer(imageTap)
        
        let model = NGMyProfileViewModel(user: modelInput, avatarTaps: imageTap.rx.event.asDriver().map{_ in Void()}, updateUserTaps:  navigationItem.rightBarButtonItem!.rx.tap.asDriver(), vc: self)
        
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
                    let cred = NGUserCredentials.credentials()
                    cred?.user = user
                    cred?.synchronize()
                case .failure(let err):
                    self.handleError(error: err)
                }
                }, onCompleted: nil, onDisposed: {print("Dismposed")})
            .addDisposableTo(disposeBag)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func closeAction(){
        self.navigationController?.popViewController(animated: true)
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
