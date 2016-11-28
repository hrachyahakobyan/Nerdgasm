////
////  NGAvatarViewModel.swift
////  Nerdgasm
////
////  Created by Hrach on 11/23/16.
////  Copyright © 2016 Hrach. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import Result
//import RxCocoa
//
//typealias NGAvatarResult = Result<NGUser, NGNetworkError>
//
//class NGAvatarViewModel: NGViewModelType {
//    
//    let loading: Driver<Bool>
//    let results: Driver<NGAvatarResult>
//    
//    init(taps: Driver<Void>){
//        let networking = NGAuthorizedNetworking.sharedNetworking
//        let loading = ActivityIndicator()
//        self.loading = loading.asDriver()
//        
//        
//    }
//    
//    let loading: Driver<Bool>
//    let results: Driver<NGSignoutResult>
//    
//    init(loggingOutTaps: Driver<Void>){
//        let networking = NGAuthorizedNetworking.sharedNetworking
//        let loggingOut = ActivityIndicator()
//        self.loading = loggingOut.asDriver()
//        
//        results = loggingOutTaps
//            .flatMapLatest{
//                return networking.request(NGAuthenticatedService.Signout)
//                    .filterSuccessfulStatusCodes()
//                    .map{_ in Void()}
//                    .mapToFailable()
//                    .trackActivity(loggingOut)
//                    .asDriver(onErrorJustReturn: NGSignoutResult.failure(.NoConnection))
//        }
//        
//    }
//
//}
