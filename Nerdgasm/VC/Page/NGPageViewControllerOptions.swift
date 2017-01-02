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
    let forumVC: NGForumViewController = R.storyboard.forum.instantiateInitialViewController()!
    
    var controllers: [UIViewController] {
        return [timelineVC, forumVC]
    }
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: [timelineVC, forumVC])
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
            return 40
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemTimeline(), MenuItemForum()]
        }
    }
    
    struct MenuItemTimeline: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Timeline"))
        }
    }
    
    struct MenuItemForum: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "Forum"))
        }
    }
}

