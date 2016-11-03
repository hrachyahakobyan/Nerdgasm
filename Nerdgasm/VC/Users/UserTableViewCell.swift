//
//  UserTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 10/21/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: NGUser! {
        didSet{
            usernameLabel.text = (user != nil) ? user.username : ""
            fullnameLabel.text = (user != nil) ? user.firstname : ""
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
