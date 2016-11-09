//
//  NGViewModelType.swift
//  Nerdgasm
//
//  Created by Hrach on 11/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Result
import RxSwift
import RxCocoa

protocol NGViewModelType{
    associatedtype T: Any
    var results: Driver<Result<T, NGNetworkError>> {get}
}

extension NGViewModelType{
    func clean() -> Driver<T> {
        return results.filter{result in
                guard case Result<T, NGNetworkError>.success(_) = result else {
                    return false
                }
                return true
                }
            .map{try! $0.dematerialize()}
    }
    
    func errors() -> Driver<NGNetworkError> {
           return results.filter{result in
                guard case Result<T, NGNetworkError>.failure(_) = result else {
                    return false
                }
                return true
            }
            .map{$0.error!}
    }
}
