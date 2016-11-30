//
//  NGThread.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

struct NGPage: Decodable {
    
    let id: Int
    let title: String
    let image: String
    
    enum Keys: String {
        case id = "id"
        case title = "title"
        case image = "image"
    }
    
    init?(json: JSON) {
        guard let id: Int =   toInt(val: json[Keys.id.rawValue]) else {return nil}
        guard let title: String = Keys.title.rawValue <~~ json else {return nil}
        self.image = (Keys.image.rawValue <~~ json ?? "")
        self.id = id
        self.title = title
    }
}
