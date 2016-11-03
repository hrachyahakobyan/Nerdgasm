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
import Gloss

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
                print(json)
                guard let data: JSON = "data" <~~ (json as! JSON) else {
                    throw NGNetworkError.Unknown
                }
                return data
        }
    }
}


