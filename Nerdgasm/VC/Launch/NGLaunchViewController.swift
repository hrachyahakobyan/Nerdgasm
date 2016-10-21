//
//  NGLaunchViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 9/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGLaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let credential = NGUserCredentials.credentials() {
            if credential.access_token.characters.count == 0{
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                self.performSegue(withIdentifier: "tabbar", sender: nil)
            }
        } else {
            self.performSegue(withIdentifier: "login", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

