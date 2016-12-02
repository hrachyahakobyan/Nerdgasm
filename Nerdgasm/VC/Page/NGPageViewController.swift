//
//  NGPageViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import PagingMenuController

class NGPageViewController: NGViewController {

    let options: PagingMenuControllerCustomizable = NGPageViewControllerOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)
        pagingMenuController.view.backgroundColor = UIColor.green
        pagingMenuController.onMove = { state in
            switch state {
            case let .willMoveController(menuController, previousMenuController):
                print(previousMenuController)
                print(menuController)
            case let .didMoveController(menuController, previousMenuController):
                print(previousMenuController)
                print(menuController)
            case let .willMoveItem(menuItemView, previousMenuItemView):
                print(previousMenuItemView)
                print(menuItemView)
            case let .didMoveItem(menuItemView, previousMenuItemView):
                print(previousMenuItemView)
                print(menuItemView)
            }
        }
    }}
