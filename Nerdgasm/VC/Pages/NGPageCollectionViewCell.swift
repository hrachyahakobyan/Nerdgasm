//
//  NGPageCollectionViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/28/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGPageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: NGImageView!
    let disposeBag = DisposeBag()
    var page: NGPage? {
        didSet{
            titleLabel.text = page?.title ?? ""
            imageView.images.value = page?.image ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
