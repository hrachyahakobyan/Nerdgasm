//
//  NGPostTableViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/7/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import RxSwift

class NGPostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: TTTAttributedLabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: NGImageView!
    let disposeBag = DisposeBag()
    
    var post: (NGPost, NGUser)! {
        didSet{
            guard let post = post else {return}
            usernameLabel.text = post.1.username
            contentLabel.text = post.0.content
            dateLabel.text = post.0.dateString
            avatarImageView.images.value = post.1.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.offlinePlaceholder = #imageLiteral(resourceName: "avatar")
        contentLabel.verticalAlignment = .top
        usernameLabel.verticalAlignment = .top
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
