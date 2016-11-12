//
//  NGThreadTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class NGThreadTableViewCell: UITableViewCell {
    
    var thread: (NGThread, NGUser)? {
        didSet{
            guard let thread = thread else {return}
            titleLabel.text = thread.0.title
            dateLabel.text = thread.0.dateString
            posterLabel.text = "By \(thread.1.fullname)"
            postsCountLabel.text = "\(thread.0.post_count)"
            viewsCountLabel.text = "\(thread.0.view_count)"
        }
    }

    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var posterLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: TTTAttributedLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.verticalAlignment = .top
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
