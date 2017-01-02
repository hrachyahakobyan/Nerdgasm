//
//  NGArticle.swift
//  Nerdgasm
//
//  Created by Hrach on 12/8/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import Gloss

class NGArticle: NGContent{
    
    required init?(json: JSON) {
        super.init(json: json)
    }
}
