//
//  NGService.swift
//  Nerdgasm
//
//  Created by Hrach on 9/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Moya

enum NGService{
    case Signin(username: String, password: String)
    case Signup(username: String, password: String)
    case Signout
}

extension NGService: TargetType{
    var baseURL: URL {
        return URL(string: "www.hhakobyan.com/nerdgasm/api/v1")!
    }
    
    var path: String{
        switch self {
        case .Signin(_, _):
            return "/users/signin"
        case .Signup(_, _):
            return "/users"
        case .Signout:
            return "/users/signout"
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
        }
    }
    
    var task: Task{
        return .request
    }
}
