//
//  User.swift
//  Nerdgasm
//
//  Created by Hrach on 10/16/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

class NGUser: NSObject, NSCoding, Decodable, Encodable{
    enum Keys: String {
        case IdKey = "Id"
        case UsernameKey = "Username"
        case FirstnameKey = "Firstname"
        case LastnameKey = "Lastname"
    }
    
    public let username: String
    public let id: Int
    public var firstname: String = ""
    public var lastname: String = ""
    public var fullname: String {
        return String(format: "%@ %@", firstname, lastname)
    }

    init(username: String, id: Int){
        self.username = username
        self.id = id
        super.init()
    }
    
    convenience required init?(json: JSON){
        guard let username: String = "username" <~~ json else {return nil}
        guard let id: Int = ConverterHelper.toInt(val: json["id"]) else {return nil}
        self.init(username: username, id: id)
        self.firstname = ("firstname" <~~ json ?? "")
        self.lastname = ("lastname" <~~ json ?? "")
    }
    
    func toJSON() -> JSON? {
        return ["username" : self.username,
                "firstname" : self.firstname,
                "lastname" : self.lastname]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Keys.IdKey.rawValue)
        aCoder.encode(username, forKey: Keys.UsernameKey.rawValue)
        aCoder.encode(firstname, forKey: Keys.FirstnameKey.rawValue)
        aCoder.encode(lastname, forKey: Keys.LastnameKey.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObject(forKey: Keys.UsernameKey.rawValue) as? String else {return nil}
        self.id = aDecoder.decodeInteger(forKey: Keys.IdKey.rawValue)
        self.username = username
        self.firstname = aDecoder.decodeObject(forKey: Keys.FirstnameKey.rawValue) as? String ?? ""
        self.lastname = aDecoder.decodeObject(forKey: Keys.LastnameKey.rawValue) as? String ?? ""
        super.init()
    }
}
