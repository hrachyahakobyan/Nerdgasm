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
import UIKit

typealias NGUserUpdateResult = Result<NGUser, NGNetworkError>

class NGMyProfileViewModel: NGViewModelType {
    let results: Driver<NGUserUpdateResult>
    let loading: Driver<Bool>
    let disposeBag = DisposeBag()
    
    init(user: Driver<NGUser>, avatarTaps: Driver<Void>, updateUserTaps: Driver<Void>,
         vc: UIViewController, shouldResize:Bool = true,
         resizeWidth: CGFloat = 150.0){
        weak var weakVC = vc
        let networking = NGAuthorizedNetworking.sharedNetworking

        let updatingUser = ActivityIndicator()
        let updatingUserDriver = updatingUser.asDriver()
        
        let updateUserResults: Driver<NGUserUpdateResult> = updateUserTaps.withLatestFrom(user)
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
                        .trackActivity(updatingUser)
                        .asDriver(onErrorJustReturn: .failure(.NoConnection))
        }
        
        let updatingAvatar = ActivityIndicator()
        let updatingAvatarDriver = updatingAvatar.asDriver()
        
        let removingAvatar = ActivityIndicator()
        let removingAvatarDriver = removingAvatar.asDriver()
        
        let avatarActions: Driver<NGAvatarAction> = avatarTaps
            .flatMapLatest{ (tap) -> Driver<NGAvatarAction> in
                var actions = [NGAvatarAction.Camera, NGAvatarAction.Photo]
                if (NGUserCredentials.rxCredentials.value?.user.image.characters.count ?? 0) > 0 {
                    actions.append(NGAvatarAction.Remove)
                }
                return DefaultWireframe.sharedInstance.promptFor("", title: "Change avatar", cancelAction: NGAvatarAction.Cancel, actions: actions)
                    .filter{ action -> Bool in
                        if case NGAvatarAction.Cancel = action {
                            return false
                        } else {
                            return true
                        }
                    }
                    .asDriver(onErrorJustReturn: .Cancel)
            }
        
        
        let removeAvatarActions = avatarActions
            .filter{ action in
                if case NGAvatarAction.Remove = action {
                    return true
                } else {
                    return false
                }
        }
        
        let updateAvatarActions = avatarActions
            .filter{ action in
                if case NGAvatarAction.Remove = action {
                    return false
                } else {
                    return true
                }
        }
        
        let updateAvatarResults: Driver<NGUserUpdateResult> = updateAvatarActions
            .flatMapLatest { action -> Driver<[String: AnyObject]>  in
                print(action)
                return UIImagePickerController.rx.createWithParent(weakVC) { picker in
                    if case NGAvatarAction.Camera = action {
                        picker.sourceType = .camera
                    } else {
                        picker.sourceType = .photoLibrary
                    }
                    picker.allowsEditing = false
                    }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                    .take(1)
                    .asDriver(onErrorJustReturn: [:])
            }
            .map { info -> UIImage? in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .map{ img in
                shouldResize ? resizeImage(image: img!, newWidth: resizeWidth) : img
            }
            .flatMapLatest{ image in
                return networking.request(NGAuthenticatedService.UploadAvatar(image: image!))
                    .filterSuccessfulStatusCodes()
                    .mapJSONData()
                    .map{json in
                        guard let user: NGUser = NGUser(json: json) else {
                            throw NGNetworkError.Unknown
                        }
                        return user
                    }
                    .mapToFailable()
                    .trackActivity(updatingAvatar)
                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
                }
        
        let removeAvatarResults: Driver<NGUserUpdateResult> = removeAvatarActions
            .flatMapLatest { _  in
                return networking.request(NGAuthenticatedService.DeleteAvatar)
                    .filterSuccessfulStatusCodes()
                    .mapJSONData()
                    .map{json in
                        guard let user: NGUser = NGUser(json: json) else {
                            throw NGNetworkError.Unknown
                        }
                        return user
                    }
                    .mapToFailable()
                    .trackActivity(removingAvatar)
                    .asDriver(onErrorJustReturn: .failure(.NoConnection))
            }
        
        self.loading = Driver.combineLatest(removingAvatarDriver, updatingAvatarDriver, updatingUserDriver, resultSelector: { $0 || $1 || $2})
        self.results = Driver.of(updateAvatarResults, updateUserResults, removeAvatarResults).merge()
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
