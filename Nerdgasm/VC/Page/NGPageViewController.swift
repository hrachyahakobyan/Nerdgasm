//
//  NGPageViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import PagingMenuController
import RxSwift
import RxCocoa

class NGPageViewController: NGViewController {

    let options = NGPageViewControllerOptions()
    var page: NGPage!
    
    var willMove: Variable<UIViewController>!
    var didMove: Variable<UIViewController>!
    
    var pagingMenuController: PagingMenuController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = page.title
        
        let addThreadItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addThreadItem
        
        NGUserCredentials.loggedIn
            .drive(addThreadItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        let addItemTaps = addThreadItem.rx.tap
        
        pagingMenuController = self.childViewControllers.first as! PagingMenuController
        
        willMove = Variable<UIViewController>(options.controllers.first!)
        didMove = Variable<UIViewController>(options.controllers.first!)
        
        for childVC in options.controllers {
            let pageChildVC = (childVC as! NGPageChildViewController)
            pageChildVC.page = page
            pageChildVC.addItemTaps = addItemTaps.asDriver().filter({[weak self, weak child = childVC] _ -> Bool in
                child != nil && child == (self?.pagingMenuController.pagingViewController?.currentViewController)!
            })
            // FIXME: Memory leak
//            pageChildVC.willMove = willMove.asDriver().filter({[weak child = childVC] (vc) -> Bool in
//              child != nil && child == vc
//            }).map{_ in Void()}
//            pageChildVC.didMove = didMove.asDriver().filter({[weak child = childVC] (vc) -> Bool in
//               child != nil && child == vc
//            }).map{_ in Void()}
        }

        pagingMenuController.onMove = {[weak self] state in
            switch state {
            case let .willMoveController(menuController, _):
                self?.willMove.value = menuController
            case let .didMoveController(menuController, _):
                self?.didMove.value = menuController
            default:
                return
            }
        }
        
        pagingMenuController.setup(options)
    }

}
