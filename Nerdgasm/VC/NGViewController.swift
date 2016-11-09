//
//  NGViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGViewController: UIViewController {
    
    var isVisible: Bool {
        return isViewLoaded && (view.window != nil)
    }
    
    var isPresenting: Bool {
        return (presentedViewController != nil)
    }
    
    func handleError(error: NGNetworkError) {
        guard isVisible && !isPresenting else { return }
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
}
