//
//  NGPageViewControllerOptions.swift
//  Nerdgasm
//
//  Created by Hrach on 12/2/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import Foundation
import PagingMenuController

struct NGPageViewControllerOptions: PagingMenuControllerCustomizable {
    let timelineVC: NGTimelineViewController = NGTimelineViewController(nib: R.nib.nGTimelineViewController)
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: [timelineVC])
    }
    var lazyLoadingPage: LazyLoadingPage {
        return .all
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .standard(widthMode: .flexible, centerItem: false, scrollingMode: .pagingEnabled)
        }
        var focusMode: MenuFocusMode {
            return .none
        }
        var height: CGFloat {
            return 60
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemTimeline()]
        }
    }
    
    struct MenuItemTimeline: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Timeline")
            let description = MenuItemText(text: "Timeline")
            return .multilineText(title: title, description: description)
        }
    }
}

