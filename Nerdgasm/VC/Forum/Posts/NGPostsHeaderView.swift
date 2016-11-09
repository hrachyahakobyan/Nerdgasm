//
//  NGPostsHeaderView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGPostsHeaderView: ViewFromNib {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var thread: NGThread! {
        didSet{
            guard let thread = thread else {return }
            dateLabel.text = thread.dateString
            titleLabel.text = thread.title
        }
    }
}
