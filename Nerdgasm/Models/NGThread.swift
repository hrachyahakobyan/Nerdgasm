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
    
    enum Keys: String {
        case id = "id"
        case title = "title"
        case date = "created_at"
    }
    
    init?(json: JSON) {
        guard let id: Int = Keys.id.rawValue <~~ json else {return nil}
        guard let title: String = Keys.title.rawValue <~~ json else {return nil}
        guard let date: Int = Keys.date.rawValue <~~ json else {return nil}
        self.id = id
        self.title = title
        self.dateString = DateHelper.stringFromUnitTimestamp(unix: date)
    }
    

}
