//
//  NGPost.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

struct NGPost: Decodable{
    let id: Int
    let thread_id: Int
    let content: String
    let dateString: String
    
    enum Keys: String{
        case Id = "id"
        case ThreadId = "thread_id"
        case Date = "created_at"
        case Content = "content"
    }
    
    init?(json: JSON) {
        guard let content: String = Keys.Content.rawValue <~~ json else {return nil}
        guard let id: Int = Keys.Id.rawValue <~~ json else {return nil}
        guard let thread_id: Int = Keys.ThreadId.rawValue <~~ json else {return nil}
        guard let unix: Int  = Keys.Date.rawValue <~~ json else {return nil}
        self.content = content
        self.id = id
        self.thread_id = thread_id
        self.dateString = DateHelper.stringFromUnitTimestamp(unix: unix)
    }
}
