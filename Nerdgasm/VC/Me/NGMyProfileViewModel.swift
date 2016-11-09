//
//  NGMyProfileViewModel.swift
//  Nerdgasm
//
//  Created by Hrach on 10/25/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import Moya
import RxCocoa
import Result

typealias NGUserUpdateResult = Result<NGUser, NGNetworkError>

class NGMyProfileViewModel: NGViewModelType {
    let results: Driver<NGUserUpdateResult>
    let updatingUser: Driver<Bool>
    let disposeBag = DisposeBag()
    
    init(user: Driver<NGUser>, updateUserTaps: Driver<Void>){
        let networking = NGAuthorizedNetworking.sharedNetworking
        
        let updating = ActivityIndicator()
        self.updatingUser = updating.asDriver()
        
        results = updateUserTaps.withLatestFrom(user)
            .flatMapLatest{ user in
                return networking.request(NGAuthenticatedService.UpdateMe(firstname: user.firstname, lastname: user.lastname))
                        .filterSuccessfulStatusCodes()
                        .mapJSONData()
                        .map{json in
                            guard let user: NGUser = NGUser(json: json) else {
                                throw NGNetworkError.Unknown
                            }
                            return user
                        }
                        .mapToFailable()
                        .trackActivity(updating)
                        .asDriver(onErrorJustReturn: .failure(.NoConnection))
                }
    }

}

extension Reactive where Base: NGUser {
    var firstname: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { user, firstname in
            user.firstname = firstname
        }
    }
    
    var lastname: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { user, lastname in
            user.lastname = lastname
        }
    }
}
