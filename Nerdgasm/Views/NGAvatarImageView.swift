//
//  NGAvatarImageView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import RxSwift
import RxCocoa
import WebImage

class NGImageView: UIImageView, NGPlaceholderProviderType {
    var offlinePlaceholder: UIImage = #imageLiteral(resourceName: "placeholder")
    let images = Variable<String>("")
    let disposeBag = DisposeBag()
    var options: SDWebImageOptions = [.cacheMemoryOnly, .avoidAutoSetImage]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        images.asDriver()
            .distinctUntilChanged()
            .drive(onNext: {[weak self] (img) in
                guard img.characters.count > 0 else {
                    self?.sd_cancelCurrentImageLoad()
                    self?.image = self?.offlinePlaceholder
                    return
                }
                let url = NGService.imageURL.appendingPathComponent(img)
                self?.sd_setImage(with: url, placeholderImage: self!.offlinePlaceholder,
                          options: self!.options,
                          completed: { (img, err, type, url) in
                            guard let image = img else {return}
                            guard imageURLFrom(name: self!.images.value).absoluteString == url?.absoluteString else {return}
                            self!.image = image
                })
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}

protocol NGPlaceholderProviderType: class {
    var offlinePlaceholder: UIImage {get}
}

class NGAvatarImageView: NGImageView {
    override var offlinePlaceholder: UIImage {
        get {
            return #imageLiteral(resourceName: "avatar")
        }
        set {
            
        }
    }
    override var options: SDWebImageOptions{
        get {
            return [SDWebImageOptions.avoidAutoSetImage]
        }
        set {
            
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NGUserCredentials.rxDriver
            .map{$0?.user.image ?? ""}
            .drive(images)
            .addDisposableTo(disposeBag)
    }
}
