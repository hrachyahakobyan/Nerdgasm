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
            guard let page = page else {return}
            titleLabel.text = page.title
            DefaultImageService.sharedImageService.imageFromURL(imageURLFrom(name: page.image))
                .filter { (img, url) -> Bool in
                    self.page != nil && imageURLFrom(name: self.page!.image).absoluteString == url.absoluteString
                }
                .map{$0.0}
                .drive(imageView.rx.downloadableImage)
                .addDisposableTo(disposeBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
