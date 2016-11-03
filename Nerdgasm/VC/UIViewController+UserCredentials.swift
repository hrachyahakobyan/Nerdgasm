//
//  UIViewController+UserCredentials.swift
//  Nerdgasm
//
//  Created by Hrach on 10/20/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func resetAndPopToLaunch() {
        NGUserCredentials.reset()
        self.navigationController?.popToRootViewController(animated: false)
    }
}