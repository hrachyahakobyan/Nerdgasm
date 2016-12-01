//
//  NGViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import SVProgressHUD

class NGViewController: UIViewController {
    
    var isVisible: Bool {
        return isViewLoaded && (view.window != nil)
    }
    
    var isPresenting: Bool {
        return (presentedViewController != nil)
    }
    
    func handleError(error: NGNetworkError, showError: Bool = false) {
        if !showError {
            return
        }
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss(completion: { 
                DispatchQueue.main.async {
                    SVProgressHUD.setBackgroundColor(UIColor.red)
                    SVProgressHUD.showError(withStatus: error.description)
                }
            })
        } else {
            DispatchQueue.main.async {
               SVProgressHUD.setBackgroundColor(UIColor.red)
               SVProgressHUD.showError(withStatus: error.description)
            }
        }
    }
    
}
