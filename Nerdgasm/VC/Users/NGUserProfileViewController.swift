//
//  NGUserProfileViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/20/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import Result

class NGUserProfileViewController: UIViewController {

    @IBOutlet weak var signoutButton: UIButton!
    let disposeeBag = DisposeBag()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let credentials = NGUserCredentials.credentials() else {
//            self.navigationController?.popToRootViewController(animated: true)
//            return
//        }
//        activityIndicator.hidesWhenStopped = true
//        let viewmodel = NGUserLogoutViewModel(loggingOutTaps: signoutButton.rx.tap.asDriver(), access_token: credentials.access_token)
//        
//        viewmodel.loggingOut
//            .map{!$0}
//            .drive(signoutButton.rx.enabled)
//            .addDisposableTo(disposeeBag)
//        
//        viewmodel.loggingOut
//            .drive(activityIndicator.rx.animating)
//            .addDisposableTo(disposeeBag)
//        
//        viewmodel.loggedOut
//            .drive(onNext: { result in
//                switch result {
//                case .success:
//                    NGUserCredentials.reset()
//                    self.navigationController?.popToRootViewController(animated: true)
//                case .failure(let error):
//                    guard case NGNetworkError.Unauthorized = error else {
//                        self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
//                        return
//                    }
//                    self.resetAndPopToLaunch()
//                }
//            })
//            .addDisposableTo(disposeeBag)
//        
        // Do any additional setup after loading the view.
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
