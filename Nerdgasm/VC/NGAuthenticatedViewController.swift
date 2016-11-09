//
//  NGAuthenticatedViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGAuthenticatedViewController: NGViewController {
    
    override func handleError(error: NGNetworkError) {
        guard case NGNetworkError.Unauthorized = error else {
            super.handleError(error: error)
            return
        }
        NGUserCredentials.reset()
    }
}
