//
//  RxPageMenu.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//public class RxPageMenuDelegateProxy
//    : DelegateProxy
//    , DelegateProxyType
//    , CAPSPageMenuDelegate
//, UINavigationControllerDelegate {
//    
//    /**
//     For more information take a look at `DelegateProxyType`.
//     */
//    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
//        let pageMenuController: CAPSPageMenu = castOrFatalError(object)
//        pageMenuController.delegate = castOptionalOrFatalError(delegate)
//    }
//    
//    /**
//     For more information take a look at `DelegateProxyType`.
//     */
//    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
//        let pageMenuController: CAPSPageMenu = castOrFatalError(object)
//        return pageMenuController.delegate
//    }
//    
//}
//
//extension Reactive where Base: CAPSPageMenu {
//    
//    public var delegate: DelegateProxy {
//        return RxPageMenuDelegateProxy.proxyForObject(base)
//    }
//    
//    public var didMoveToView: Observable<(UIViewController, Int)> {
//        return delegate
//            .methodInvoked(#selector(CAPSPageMenuDelegate.didMoveToPage(_:index:)))
//            .map{($0[0] as! UIViewController, $0[1] as! Int)}
//    }
//    
//    public var willMoveToView: Observable<(UIViewController, Int)> {
//        return delegate
//            .methodInvoked(#selector(CAPSPageMenuDelegate.willMoveToPage(_:index:)))
//            .map{($0[0] as! UIViewController, $0[1] as! Int)}
//    }
//}
