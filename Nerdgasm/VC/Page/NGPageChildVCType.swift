//
//  NGPageChildVCType.swift
//  Nerdgasm
//
//  Created by Hrach on 12/8/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NGPageChildViewController: NGViewController {
    var page: NGPage!
    var addItemTaps: Driver<Void>!
    var willMove: Driver<Void>!
    var didMove: Driver<Void>!
}
