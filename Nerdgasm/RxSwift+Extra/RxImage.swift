//
//  RxImage.swift
//  Nerdgasm
//
//  Created by Hrach on 11/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import UIKit


extension UIImage{
    func forceLazyImageDecompression() -> UIImage {
        #if os(iOS)
            UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
            self.draw(at: CGPoint.zero)
            UIGraphicsEndImageContext()
        #endif
        return self
    }
}
