//
//  NGNetworking.swift
//  Nerdgasm
//
//  Created by Hrach on 10/19/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

class NGOnlineProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    
    override init(endpointClosure: @escaping EndpointClosure = MoyaProvider.DefaultEndpointMapping,
         requestClosure: @escaping RequestClosure = MoyaProvider.DefaultRequestMapping,
         stubClosure: @escaping StubClosure = MoyaProvider.NeverStub,
         manager: Manager = RxMoyaProvider<Target>.DefaultAlamofireManager(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    override func request(_ token: Target) -> Observable<Moya.Response> {
        return super.request(token)
    }
}


protocol NGNetworkingType {
    associatedtype T: TargetType, NGServiceType
    var provider: NGOnlineProvider<T> { get }
}

struct NGNetworking: NGNetworkingType {
    typealias T = NGService
    let provider: NGOnlineProvider<NGService>
    static let sharedNetworking = NGNetworking(provider: newProvider([]))
}

struct NGAuthorizedNetworking: NGNetworkingType {
    static var accessToken: String? = ""
    typealias T = NGAuthenticatedService
    let provider: NGOnlineProvider<NGAuthenticatedService>
    static let sharedNetworking = NGAuthorizedNetworking(provider: newProvider([]))
    static let disposeBag = DisposeBag()
}

// "Public" interfaces
extension NGNetworking {
    func request(_ token: NGService, defaults: UserDefaults = UserDefaults.standard) -> Observable<Moya.Response> {
        return self.provider.request(token)
    }
}

extension NGAuthorizedNetworking {
    func request(_ token: NGAuthenticatedService, defaults: UserDefaults = UserDefaults.standard) -> Observable<Moya.Response> {
        return self.provider.request(token)
    }
    
    static func endpointsClosure<T>() -> (T) -> Endpoint<T> where T: TargetType, T: NGServiceType {
        return { target in
            var endpoint: Endpoint<T> = Endpoint<T>(URL: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
            if let accessToken = accessToken {
                let field = String(format: "Bearer %@", accessToken)
                endpoint = endpoint.adding(newHttpHeaderFields:["Authorization": field])
            }
            return endpoint
        }
    }
    
    static func newProvider<T>(_ plugins: [PluginType]) -> NGOnlineProvider<T> where T: TargetType, T: NGServiceType {
        return NGOnlineProvider(endpointClosure: NGAuthorizedNetworking.endpointsClosure(),
                                requestClosure: NGAuthorizedNetworking.endpointResolver(),
                                stubClosure: {_ in Moya.StubBehavior.never},
                                plugins: plugins)
    }
}

// Static methods
extension NGNetworkingType {
    
    static func endpointsClosure<T>() -> (T) -> Endpoint<T> where T: TargetType, T: NGServiceType {
        return { target in
            let encoding: Moya.ParameterEncoding = (target.method == .post ? Moya.JSONEncoding.default : Moya.URLEncoding.default)
            return Endpoint<T>(URL: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters,parameterEncoding: encoding, httpHeaderFields: ["Content-Type" : "application/json"])
        }
    }
    
    // (Endpoint<Target>, NSURLRequest -> Void) -> Void
    static func endpointResolver<T>() -> MoyaProvider<T>.RequestClosure where T: TargetType {
        return { (endpoint, closure) in
            var request = endpoint.urlRequest!
            request.httpShouldHandleCookies = false
            closure(.success(request))
        }
    }
    
    
    static func newProvider<T>(_ plugins: [PluginType]) -> NGOnlineProvider<T> where T: TargetType, T: NGServiceType {
        return NGOnlineProvider(endpointClosure: NGNetworking.endpointsClosure(),
                                requestClosure: NGNetworking.endpointResolver(),
                                stubClosure: {_ in Moya.StubBehavior.never},
                                plugins: plugins)
    }
}

