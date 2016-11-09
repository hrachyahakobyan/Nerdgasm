//
//  NGThreadTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGThreadTableViewCell: UITableViewCell {
    
    var thread: NGThread? {
        didSet{
            guard let thread = thread else {return}
            titleLabel.text = thread.title
            dateLabel.text = thread.dateString
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
