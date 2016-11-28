//
//  NGTabBarController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/4/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift

class NGTabBarController: UITabBarController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NGUserCredentials.loggedIn.drive(onNext: { logged in
//            print("Logged \(logged)")
//            if logged == false && self.presentedViewController == nil {
//                DispatchQueue.main.async {
//                    let _ = self.navigationController?.popToRootViewController(animated: false)
//                    self.performSegue(withIdentifier: R.segue.nGTabBarController.login.identifier, sender: nil)
//                }
//            }
//            }, onCompleted: nil, onDisposed: nil)
//            .addDisposableTo(disposeBag)
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
