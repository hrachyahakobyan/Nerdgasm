//
//  RxTableView.swift
//  Nerdgasm
//
//  Created by Hrach on 11/24/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    public var allowsSelection: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { tableView, selectionAllowd in
            tableView.allowsSelection = selectionAllowd
        }
    }
}
