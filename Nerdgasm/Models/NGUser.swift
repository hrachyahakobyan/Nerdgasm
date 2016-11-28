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
        case IdKey = "id"
        case UsernameKey = "username"
        case FirstnameKey = "firstname"
        case LastnameKey = "lastname"
        case ImageKey = "image"
    }
    
    public let username: String
    public let id: Int
    public var firstname: String = ""
    public var lastname: String = ""
    public var image: String = ""
    public var fullname: String {
        return String(format: "%@ %@", firstname, lastname)
    }

    init(username: String, id: Int){
        self.username = username
        self.id = id
        super.init()
    }
    
    convenience required init?(json: JSON){
        guard let username: String = Keys.UsernameKey.rawValue <~~ json else {return nil}
        guard let id: Int = ConverterHelper.toInt(val: json[Keys.IdKey.rawValue]) else {return nil}
        self.init(username: username, id: id)
        self.firstname = (Keys.FirstnameKey.rawValue <~~ json ?? "")
        self.lastname = (Keys.LastnameKey.rawValue <~~ json ?? "")
        self.image = (Keys.ImageKey.rawValue <~~ json ?? "")
    }
    
    func toJSON() -> JSON? {
        return [Keys.UsernameKey.rawValue : self.username,
                Keys.FirstnameKey.rawValue : self.firstname,
                Keys.LastnameKey.rawValue : self.lastname,
                Keys.ImageKey.rawValue : self.image]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Keys.IdKey.rawValue)
        aCoder.encode(username, forKey: Keys.UsernameKey.rawValue)
        aCoder.encode(firstname, forKey: Keys.FirstnameKey.rawValue)
        aCoder.encode(lastname, forKey: Keys.LastnameKey.rawValue)
        aCoder.encode(image, forKey: Keys.ImageKey.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObject(forKey: Keys.UsernameKey.rawValue) as? String else {return nil}
        self.id = aDecoder.decodeInteger(forKey: Keys.IdKey.rawValue)
        self.username = username
        self.firstname = aDecoder.decodeObject(forKey: Keys.FirstnameKey.rawValue) as? String ?? ""
        self.lastname = aDecoder.decodeObject(forKey: Keys.LastnameKey.rawValue) as? String ?? ""
        self.image = aDecoder.decodeObject(forKey: Keys.ImageKey.rawValue) as? String ?? ""
        super.init()
    }
}
