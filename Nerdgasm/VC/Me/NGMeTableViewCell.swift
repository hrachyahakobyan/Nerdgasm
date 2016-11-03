//
//  NGMeTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 10/23/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class NGMeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var title: String! = "" {
        didSet{
            titleLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
