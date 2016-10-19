//
//  User.swift
//  Nerdgasm
//
//  Created by Hrach on 10/16/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

class NGUser: NSObject, NSCoding{
    enum Keys: String {
        case IdKey = "Id"
        case UsernameKey = "Username"
        case TokenKey = "AccessToken"
        case UserKey = "User"
    }
    
    public let username: String
    public let id: Int

    init(username: String, id: Int){
        self.username = username
        self.id = id
        super.init()
    }
    
    convenience init?(json: JSON){
        guard let username: String = "username" <~~ json else {return nil}
        guard let id: Int = "id" <~~ json else {return nil}
        self.init(username: username, id: id)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Keys.IdKey.rawValue)
        aCoder.encode(username, forKey: Keys.UsernameKey.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObject(forKey: Keys.UsernameKey.rawValue) as? String else {return nil}
        self.id = aDecoder.decodeInteger(forKey: Keys.IdKey.rawValue)
        self.username = username
        super.init()
    }
    
    func saveToUserDefaults(userDefaults: UserDefaults = UserDefaults.standard){
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        userDefaults.set(data, forKey: Keys.UserKey.rawValue)
        userDefaults.synchronize()
    }
    
    static func userInfo(userDefaults: UserDefaults = UserDefaults.standard) -> NGUser? {
        guard let data = userDefaults.object(forKey: Keys.UserKey.rawValue) as? Data else {return nil}
        return (NSKeyedUnarchiver.unarchiveObject(with: data) as? NGUser)
    }
    
    static func tokenIsValid() -> Bool {
        guard let token = UserDefaults.standard.object(forKey: Keys.TokenKey.rawValue) as? String else { return false }
        return token.characters.count != 0
    }
    
    static func token() -> String? {
        return UserDefaults.standard.object(forKey: Keys.TokenKey.rawValue) as? String
    }
    
    static func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: Keys.TokenKey.rawValue)
    }
}
