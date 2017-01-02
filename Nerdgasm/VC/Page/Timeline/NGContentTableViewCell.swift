//
//  NGContentTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 12/9/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import TTTAttributedLabel


class NGContentTableViewCell: UITableViewCell {
    

    @IBOutlet weak var titleLabel: TTTAttributedLabel!
    @IBOutlet weak var dateLabel: TTTAttributedLabel!
    
    @IBOutlet weak var titleImageView: NGImageView!
    var content: NGContent! {
        didSet{
            guard let content = content else {return}
            self.titleImageView.images.value = content.image
            self.titleLabel.text = content.title
            self.dateLabel.text = content.dateString
        }
    }
    
    var user: NGUser!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
