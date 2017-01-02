//
//  NGContent.swift
//  Nerdgasm
//
//  Created by Hrach on 12/2/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

class NGContent: Decodable {
    let id: Int
    let title: String
    let image: String
    let content: String
    let unix: Int
    let dateString: String
    let pageId: Int
    let upvotes: Int
    let comments: Int
    
    enum Keys: String {
        case Id = "id"
        case Title = "title"
        case Image = "image"
        case Content = "content"
        case Date = "created_at"
        case PageID = "page_id"
        case Upvotes = "upvotes"
        case Comments = "comments"
    }
    
    required init?(json: JSON) {
        guard let id: Int = toInt(val: json[Keys.Id.rawValue]) else {return nil}
        guard let title: String = Keys.Title.rawValue <~~ json else {return nil}
        guard let image: String = Keys.Image.rawValue <~~ json else {return nil}
        guard let content: String = Keys.Content.rawValue <~~ json else {return nil}
        guard let unix: Int = toInt(val:json[Keys.Date.rawValue]) else {return nil}
        guard let pageID: Int = toInt(val: json[Keys.PageID.rawValue]) else {return nil}
        guard let upvotes: Int = toInt(val: json[Keys.Upvotes.rawValue]) else {return nil}
        guard let comments: Int = toInt(val: json[Keys.Comments.rawValue]) else {return nil}
        self.id = id
        self.title = title
        self.image = image
        self.content = content
        self.unix = unix
        self.dateString = DateHelper.stringFromUnitTimestamp(unix: unix)
        self.pageId = pageID
        self.upvotes = upvotes
        self.comments = comments
    }
}
