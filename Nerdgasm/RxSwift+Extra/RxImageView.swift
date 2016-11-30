//
//  RxImageView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol NGPlaceholderProviderType: class {
    var offlinePlaceholder: UIImage {get}
}

extension Reactive where Base: NGImageView {
    
    var downloadableImage: UIBindingObserver<Base, DownloadableImage>{
        return downloadableImageAnimated(nil)
    }
    
    func downloadableImageAnimated(_ transitionType:String?) -> UIBindingObserver<Base, DownloadableImage> {
        return UIBindingObserver(UIElement: base) { imageView, image in
            let imageView = imageView as NGImageView
            switch image {
            case .content(let image):
                imageView.rx.image.on(.next(image))
            case .offlinePlaceholder:
                imageView.rx.image.on(.next(imageView.offlinePlaceholder))
            }
        }
    }
}
