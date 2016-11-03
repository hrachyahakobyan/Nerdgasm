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
}

struct NGAuthorizedNetworking: NGNetworkingType {
    typealias T = NGAuthenticatedService
    let provider: NGOnlineProvider<NGAuthenticatedService>
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
}

// Static methods
extension NGNetworkingType {
    
    static func newDefaultNetworking() -> NGNetworking {
        return NGNetworking(provider: newProvider([]))
    }
    
    static func newAuthorizedNetworking(_ accessToken: String) -> NGAuthorizedNetworking {
        return NGAuthorizedNetworking(provider: newProvider([], accessToken: accessToken))
    }
    
    static func endpointsClosure<T>(_ accessToken: String? = nil) -> (T) -> Endpoint<T> where T: TargetType, T: NGServiceType {
        return { target in
            var endpoint: Endpoint<T> = Endpoint<T>(URL: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
            
            if let accessToken = accessToken {
                let field = String(format: "Bearer %@", accessToken)
                endpoint = endpoint.endpointByAddingHTTPHeaderFields(["Authorization": field])
            }
            print(endpoint.httpHeaderFields)
            return endpoint
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
}

private func newProvider<T>(_ plugins: [PluginType], accessToken: String? = nil) -> NGOnlineProvider<T> where T: TargetType, T: NGServiceType {
    return NGOnlineProvider(endpointClosure: NGNetworking.endpointsClosure(accessToken),
                          requestClosure: NGNetworking.endpointResolver(),
                          stubClosure: {_ in Moya.StubBehavior.never},
                          plugins: plugins)
}
