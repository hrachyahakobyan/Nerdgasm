//
//  NGService.swift
//  Nerdgasm
//
//  Created by Hrach on 9/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Moya
import Result

public enum NGNetworkError: Swift.Error{
    case NoConnection
    case ValidationFailed([String:String])
    case Error(Swift.Error)
    case Unauthorized
    case NotFound
    case Unknown
    
    var error: Swift.Error? {
        switch self {
        case .Error(let error): return error
        default: return nil
        }
    }
    
    var nsError:  NSError? {
        guard let error = error else { return nil }
        guard type(of: error) == NSError.self else { return nil }
        return error as NSError
    }
}

protocol NGServiceType {
    
}

enum NGService: NGServiceType{
    case Signin(username: String, password: String)
    case Signup(username: String, password: String)
    case UsernameAvailable(username: String)
}

enum NGAuthenticatedService: NGServiceType {
    case Signout
    case Users
}

extension NGService: TargetType{
    var baseURL: URL {
        return URL(string: "https://www.hhakobyan.com/nerdgasm/api/v1")!
    }
    
    var path: String{
        switch self {
        case .Signin(_, _):
            return "/users/login"
        case .Signup(_, _):
            return "/users"
        case .UsernameAvailable(_):
            return "/users/username"
        }
    }
    
    var method: Moya.Method {
        return .POST
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .Signin(let username, let password):
            return ["username" : username, "password" : password]
        case .Signup(let username, let password):
            return ["username" : username, "password" : password]
        case .UsernameAvailable(let username):
            return ["username" : username]
        }
    }
    
    var task: Task{
        return .request
    }
}

extension NGAuthenticatedService: TargetType{
    var baseURL: URL {
        return URL(string: "https://www.hhakobyan.com/nerdgasm/api/v1")!
    }
    
    var path: String{
        switch self {
        case .Signout:
            return "/users/signout"
        case .Users:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .Users:
            return .GET
        default:
            return .POST
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .Signout:
            return nil
        case .Users:
            return nil
        }
    }
    
    var task: Task{
        return .request
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

