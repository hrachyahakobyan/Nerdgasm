//
//  NGUserCredentials.swift
//  Nerdgasm
//
//  Created by Hrach on 10/20/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGUserCredentials: NSObject, NSCoding {
    var user: NGUser
    var access_token: String
    private static let userDefaults = UserDefaults.standard
    
    init(user: NGUser, token: String){
        self.user = user
        self.access_token = token
        super.init()
    }
    
    enum Keys: String {
        case User = "User"
        case Token = "Token"
        case Credentials = "Credentials"
    }
    
    static func reset(){
        userDefaults.removeObject(forKey: Keys.Credentials.rawValue)
    }
    
    static func credentials() -> NGUserCredentials? {
        guard let data = userDefaults.object(forKey: Keys.Credentials.rawValue) as? Data else {return nil}
        return (NSKeyedUnarchiver.unarchiveObject(with: data) as? NGUserCredentials)
    }
    
    func synchronize(){
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        NGUserCredentials.userDefaults.set(data, forKey: Keys.Credentials.rawValue)
        NGUserCredentials.userDefaults.synchronize()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(user, forKey: Keys.User.rawValue)
        aCoder.encode(access_token, forKey: Keys.Token.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let user = aDecoder.decodeObject(forKey: Keys.User.rawValue) as? NGUser else {return nil}
        guard let token = aDecoder.decodeObject(forKey: Keys.Token.rawValue) as? String else {return nil}
        self.user = user
        self.access_token = token
        super.init()
    }
}
