//
//  NGMeViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/23/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

enum NGAvatarAction {
    case Camera
    case Photo
    case Remove
    case Cancel
}

extension NGAvatarAction: CustomStringConvertible {
    var description: String {
        switch self {
        case .Camera:
            return "Camera"
        case .Photo:
            return "Photo Library"
        case .Cancel:
            return "Cancel"
        case .Remove:
            return "Remove"
        }
    }
}

class NGMeViewController: NGAuthenticatedViewController {

   
    @IBOutlet weak var avatarImageView: NGAvatarImageView!
    @IBOutlet weak var tableView: UITableView!
    let rowCount = 1
    let data = Observable<[String]>.just(["Sign out"])
    
    enum Rows: Int {
        case Signout = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NGUserCredentials.rxUser
                    .map{$0 == nil ? "" : $0?.username}
                    .drive(navigationItem.rx.title)
                    .addDisposableTo(disposeBag)
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        navigationItem.rightBarButtonItem = editItem
        
        NGUserCredentials.loggedIn
            .drive(editItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        editItem.rx.tap
            .asDriver()
            .drive(onNext: {self.editAction()}, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.allowsMultipleSelection = false
        tableView.register(R.nib.nGMeTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.meCell.identifier)
        data.bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.meCell.identifier)) { index, model, cell in
            let meCell = cell as! NGMeTableViewCell
            meCell.title = model
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.asDriver()
            .filter{return $0.row == Rows.Signout.rawValue}
            .drive(onNext: { (_) in
                NGUserCredentials.reset()
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    // Do any additional setup after loading the view.
    }
    
    func editAction(){
        self.performSegue(withIdentifier: R.segue.nGMeViewController.myProfile, sender: nil)
    }
}



