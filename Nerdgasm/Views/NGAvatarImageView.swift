//
//  NGAvatarImageView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import RxCocoa

class NGImageView: UIImageView, NGPlaceholderProviderType {
    var offlinePlaceholder: UIImage = #imageLiteral(resourceName: "placeholder")
}


class NGAvatarImageView: NGImageView {
    
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.offlinePlaceholder = #imageLiteral(resourceName: "avatar")
        NGUserCredentials.rxUser
            .filter{$0 != nil}
            .map{NGService.imageURL.appendingPathComponent($0!.image)}
            .distinctUntilChanged()
            .flatMapLatest { (url)  in
                return DefaultImageService.sharedImageService.imageFromURL(url)
            }
            .map{$0.0}
            .drive(self.rx.downloadableImage)
            .addDisposableTo(disposeBag)
    }
}
