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

enum NGService{
    case Signin(username: String, password: String)
    case Signup(username: String, password: String)
    case Signout
    case UsernameAvailable(username: String)
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
        case .Signout:
            return "/users/signout"
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
        case .Signout:
            return nil
        case .UsernameAvailable(let username):
            return ["username" : username]
        }
    }
    
    var task: Task{
        return .request
    }
}
