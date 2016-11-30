//
//  RxSwiftCustom.swift
//  Nerdgasm
//
//  Created by Hrach on 10/26/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import Result
import Moya
import RxCocoa
import Gloss
import SVProgressHUD

extension ObservableType{
    public func mapToFailable() -> Observable<Result<E, NGNetworkError>>{
        return self
            .map(Result<E, NGNetworkError>.success)
            .catchError{ err in
                return .just(.failure(toNgError(err: err)))
        }
    }
}


extension ObservableType where E == Response {
    public func mapJSONData() -> Observable<JSON> {
        return self
            .mapJSON()
            .map{ json in
                guard let data: JSON = "data" <~~ (json as! JSON) else {
                    throw NGNetworkError.Unknown
                }
                return data
        }
    }
    
    public func mapJSONDataArray() -> Observable<[JSON]>{
        return self
            .mapJSON()
            .map{ json in
                guard let data: [JSON] = "data" <~~ (json as! JSON) else {
                    throw NGNetworkError.Unknown
                }
                return data
        }
    }
}

extension ObservableType where E == Bool {
    public func showProgress() -> Observable<E>{
        return self.do(onNext: { (loading) in
            if loading && SVProgressHUD.isVisible() == false{
                SVProgressHUD.show()
            } else if !loading {
                SVProgressHUD.dismiss()
            }
        }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
}

extension SharedSequenceConvertibleType where E == Bool {
    public func showProgress() -> SharedSequence<SharingStrategy,E>{
        return self.do(onNext: { (loading) in
            if loading && SVProgressHUD.isVisible() == false{
                SVProgressHUD.show()
            } else if !loading {
                SVProgressHUD.dismiss()
            }
        }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
}




