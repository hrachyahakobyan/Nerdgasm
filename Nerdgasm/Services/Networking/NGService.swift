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

public enum NGNetworkError: Swift.Error, CustomStringConvertible{
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
    
    public var description: String {
        switch self {
        case .NoConnection:
            return "Sorry, could not reach Nerdgasm"
        case .NotFound:
            return "Could not find that"
        case .ValidationFailed(let dict):
            return "Invalid parameters \(dict)"
        case .Unauthorized:
            return "Please sign in"
        case .Unknown:
            return "Something went wrong"
        case .Error(let err):
            return err.localizedDescription
        }
    }
    
}

func toNgError(err: Swift.Error) -> NGNetworkError{
    if type(of: err) == Moya.Error.self {
        let moyaErr = err as! Moya.Error
        switch moyaErr {
        case .statusCode(let response):
            switch response.statusCode{
            case 404:
                return .NotFound
            case 401:
                return .Unauthorized
            case 422:
                return .ValidationFailed([:])
            default:
                return .Unknown
            }
        case .underlying(let err):
            let nserr = err as NSError
            switch nserr.code {
            case -1001, -1009:
                return .NoConnection
            default:
                return .Error(err)
            }
        default:
            return .Unknown
        }
    }
    else {
        return .Error(err)
    }
}

func isunAuhtorized(error: Swift.Error) -> Bool {
    guard case NGNetworkError.Unauthorized = toNgError(err: error) else {
        return false
    }
    return true
}

protocol NGServiceType {
    
}

enum NGService: NGServiceType{
    case Signin(username: String, password: String)
    case Signup(username: String, password: String)
    case UsernameAvailable(username: String)
    case GetThreads
    case GetPosts(thread_id: Int)
    case ViewThread(thread_id: Int)
    case SearchUsers(query: String)
    case Image(name: String)
    case GetCategories
    case GetCategory(id: Int)
    case GetCategoryPages(categoryID: Int)
}

enum NGAuthenticatedService: NGServiceType {
    case Signout
    case UpdateMe(firstname: String, lastname: String)
    case CreateThread(title: String, content: String)
    case CreatePost(thread_id: Int, content: String)
    case UploadAvatar(image: UIImage)
    case DeleteAvatar
}

extension NGService: TargetType{
    static var imageURL: URL {
        return URL(string: "https://www.hhakobyan.com/nerdgasm/api/images/")!
    }
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
        case .SearchUsers(_):
            return "/users/search"
        case .GetThreads:
            return "/threads"
        case .GetPosts(let thread_id):
            return "/threads/\(thread_id)/posts"
        case .ViewThread(let thread_id):
            return "/threads/\(thread_id)/addview"
        case .Image(_):
            return "/images"
        case .GetCategories:
            return "/category"
        case .GetCategory(let id):
            return "/category/\(id)"
        case .GetCategoryPages(let catID):
            return "/category/\(catID)/pages"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .GetThreads, .GetPosts(_), .SearchUsers(_), .GetCategory(_), .GetCategories, .GetCategoryPages(_):
            return .get
        default:
            return .post
        }
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
        case .SearchUsers(let query):
            return ["query" : query]
        default:
            return nil
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
            return "/users/logout"
        case .UpdateMe(_, _):
            return "/me"
        case .CreateThread(_, _):
            return "/me/thread"
        case .CreatePost(_, _):
            return "/me/post"
        case .DeleteAvatar, .UploadAvatar(_):
            return "/me/avatar"

        }
    }
    
    var method: Moya.Method {
        switch self {
        case .DeleteAvatar:
            return .delete
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .UpdateMe(let firstname, let lastname):
            return ["firstname" : firstname, "lastname" : lastname]
        case .CreateThread(let title, let content):
            return ["title" : title, "content" : content, "page_id" : 4]
        case .CreatePost(let thread_id, let content):
            return ["thread_id" : thread_id, "content" : content]
        default:
            return nil
        }
    }
    
    var task: Task{
        switch self {
        case .UploadAvatar(let image):
            let data = UIImageJPEGRepresentation(image, 1.0)
            let multipart = MultipartFormData(provider: .data(data ?? Data()), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            return .upload(.multipart([multipart]))
        default:
            return .request
        }
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

