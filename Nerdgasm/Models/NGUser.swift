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
}
