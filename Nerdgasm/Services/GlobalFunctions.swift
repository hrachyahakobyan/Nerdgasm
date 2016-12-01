//
//  GlobalFunctions.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

struct DateHelper{
    static let formatter = DateFormatter()
    static func stringFromUnitTimestamp(unix: Int) -> String {
        let interval: TimeInterval = Double(unix)
        let date = Date(timeIntervalSince1970: interval)
        formatter.locale = NSLocale.current
        formatter.dateFormat = "MMM d, H:mm a"
        return formatter.string(from: date)
    }
}

func toInt(val: Any?) -> Int?{
    if let _int: Int = val as? Int {
        return _int
    } else if let _str: String = val as? String {
        return Int(_str)
    } else {
        return nil
    }
}

func imageURLFrom(name: String) -> URL!{
    return NGService.imageURL.appendingPathComponent(name)
}


func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in:CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

func castOptionalOrFatalError<T>(_ value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func rxFatalError(_ lastMessage: String) -> Never {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

