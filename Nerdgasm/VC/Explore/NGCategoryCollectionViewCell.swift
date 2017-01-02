//
//  NGCategoryCollectionViewCell.swift
//  Nerdgasm
//
//  Created by Hrach on 11/28/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebImage

class NGCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: NGImageView!
    let disposeBag = DisposeBag()
    var category: NGCategory? {
        didSet{
            titleLabel.text = category?.title ?? ""
            imageView.images.value = category?.image ?? ""
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.offlinePlaceholder = #imageLiteral(resourceName: "placeholder")
        // Initialization code
    }

}
