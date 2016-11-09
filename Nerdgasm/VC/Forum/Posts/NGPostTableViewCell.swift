//
//  NGPostTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/7/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class NGPostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: TTTAttributedLabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var post: (NGPost, NGUser)! {
        didSet{
            guard let post = post else {return}
            print(post.1.fullname)
            usernameLabel.text = post.1.fullname
            contentLabel.text = post.0.content
            dateLabel.text = post.0.dateString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.verticalAlignment = .top
        usernameLabel.verticalAlignment = .top
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
