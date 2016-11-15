//
//  NGDefaultStatefulVCType.swift
//  Nerdgasm
//
//  Created by Hrach on 11/13/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Result

protocol NGDefaultStatefulVCType: class, NGStatefulViewControllerType{
    associatedtype M: NGViewModelType
    var viewModel: M! {get}
}

extension NGDefaultStatefulVCType{
    var errorInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.errors().map{ _  in (.Error, false, nil) }
    }
    
    var contentInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.clean().map{ _ in (.Content, false, nil) }
    }
    
    var loadingInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.loading
            .filter{$0}
            .map{_ in (.Loading, false, nil)}
    }
}

extension NGDefaultStatefulVCType where M.T: Collection{
     var emptyInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.clean()
            .filter{ result -> Bool in
                return result.count == 0
            }
        .map{_ in (.Empty, false, nil)}
    }
}

extension NGDefaultStatefulVCType where Self: NGViewController {
    
//    var loadingView: UIView? {
//        return LoadingView(frame: view.frame)
//    }
//    
//    /// The error view is shown when the `endLoading` method returns an error
//    var errorView: UIView? {
//        return ErrorView(frame: view.frame)
//    }
//    
//    /// The empty view is shown when the `hasContent` method returns false
//    var emptyView: UIView? {
//        return EmptyView(frame: view.frame)
//    }
    
    var handleError: ((Error) -> ())? {
        return self.handleError
    }
}

