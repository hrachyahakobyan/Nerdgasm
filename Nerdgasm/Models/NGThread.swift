//
//  NGThread.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import Gloss

struct NGThread: Decodable {
    
    let id: Int
    let title: String
    let dateString: String
    let post_count: Int
    let view_count: Int
    let date: Int
    
    enum Keys: String {
        case id = "id"
        case title = "title"
        case date = "created_at"
        case post_count = "post_count"
        case view_count = "views"
    }
    
    init?(json: JSON) {
        guard let id: Int =   toInt(val: json[Keys.id.rawValue]) else {return nil}
        guard let title: String = Keys.title.rawValue <~~ json else {return nil}
        guard let date: Int =   toInt(val: json[Keys.date.rawValue]) else {return nil}
        guard let post_count: Int =   toInt(val: json[Keys.post_count.rawValue]) else {return nil}
        guard let view_count: Int =   toInt(val: json[Keys.view_count.rawValue]) else {return nil}
        self.date = date
        self.id = id
        self.title = title
        self.post_count = post_count
        self.view_count = view_count
        self.dateString = DateHelper.stringFromUnitTimestamp(unix: date)
    }
    

}
