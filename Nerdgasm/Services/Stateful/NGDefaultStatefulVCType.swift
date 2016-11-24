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

protocol NGViewModelVCType: class {
    associatedtype M: NGViewModelType
    var viewModel: M! {get}
}

protocol NGDefaultStatefulVCType: class, NGStatefulViewControllerType, NGViewModelVCType{

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
    var contentInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.clean()
            .filter{ $0.count != 0}
            .map{ _ in (.Content, false, nil) }
    }
    
     var emptyInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.clean()
            .filter{ $0.count == 0}
            .map{_ in (.Empty, false, nil)}
    }
}

