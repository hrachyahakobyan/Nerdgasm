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

class NGCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: NGImageView!
    let disposeBag = DisposeBag()
    var category: NGCategory? {
        didSet{
            guard let category = category else {return}
            titleLabel.text = category.title
            DefaultImageService.sharedImageService.imageFromURL(imageURLFrom(name: category.image))
                .filter { (img, url) -> Bool in
                    self.category != nil && imageURLFrom(name: self.category!.image).absoluteString == url.absoluteString
                }
                .map{$0.0}
                .drive(imageView.rx.downloadableImage)
                .addDisposableTo(disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.offlinePlaceholder = #imageLiteral(resourceName: "placeholder")
        // Initialization code
    }

}
