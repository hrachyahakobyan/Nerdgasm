//
//  NGKeychain.swift
//  Nerdgasm
//
//  Created by Hrach on 9/25/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
//import KeychainAccess
//
//class NGKeychain {
//    private static let keychain = Keychain(service: "com.nerdgasm.Nerdgasm")
//    private enum Keys: String {
//        case Auth = "auth"
//    }
//    
//    static func getAuthToken() -> String?{
//        let token = try! keychain.get(Keys.Auth.rawValue)
//        return token
//    }
//    
//    static func authIsSet() -> Bool {
//        return try! keychain.contains(Keys.Auth.rawValue)
//    }
//    
//    static func setAuth(authToken: String){
//        try! keychain.set(authToken, key: Keys.Auth.rawValue)
//    }
//    
//    static func resetAuth(){
//        try! keychain.remove(Keys.Auth.rawValue)
//    }
//
//}
