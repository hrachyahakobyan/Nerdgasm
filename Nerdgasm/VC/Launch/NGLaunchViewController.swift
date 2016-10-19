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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = NGUser.userInfo() {
            if !NGUser.tokenIsValid(){
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                self.performSegue(withIdentifier: "users", sender: nil)
            }
        } else {
            self.performSegue(withIdentifier: "login", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

