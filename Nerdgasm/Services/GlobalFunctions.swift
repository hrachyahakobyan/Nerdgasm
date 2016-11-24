//
//  GlobalFunctions.swift
//  Nerdgasm
//
//  Created by Hrach on 11/5/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation

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

struct ConverterHelper{
    static func toInt(val: Any?) -> Int?{
        if let _int: Int = val as? Int {
            return _int
        } else if let _str: String = val as? String {
            return Int(_str)
        } else {
            return nil
        }
    }
}
