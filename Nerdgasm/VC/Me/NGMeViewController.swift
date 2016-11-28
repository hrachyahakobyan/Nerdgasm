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

    @IBOutlet weak var avatarImageView: NGImageView!
    @IBOutlet weak var tableView: UITableView!
    let rowCount = 1
    let data = Observable<[String]>.just(["Sign out"])
    
    enum Rows: Int {
        case Signout = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        navigationItem.rightBarButtonItem = editItem
        
        editItem.rx.tap
            .asDriver()
            .drive(onNext: {self.editAction()}, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        avatarImageView.offlinePlaceholder = #imageLiteral(resourceName: "avatar")
    
        let profileURLs = NGUserCredentials.rxCredentials
            .filter{$0 != nil}
            .map{NGService.imageURL.appendingPathComponent($0!.user.image)}
        
        profileURLs
            .distinctUntilChanged()
            .flatMapLatest { (url)  in
                return DefaultImageService.sharedImageService.imageFromURL(url)
            }
            .observeOn(MainScheduler.instance)
            .map{$0.0}
            .bindTo(avatarImageView.rx.downloadableImage)
            .addDisposableTo(disposeBag)
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = NGUserCredentials.credentials()?.user.username
        tableView.allowsMultipleSelection = false
        tableView.register(R.nib.nGMeTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.meCell.identifier)
        data.bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.meCell.identifier)) { index, model, cell in
            let meCell = cell as! NGMeTableViewCell
            meCell.title = model
            }
            .addDisposableTo(disposeBag)
        
        let signoutTaps = tableView.rx.itemSelected.asDriver()
            .filter{return $0.row == Rows.Signout.rawValue}
            .map{_ in Void()}
        
       let model = NGMeSignoutViewModel(loggingOutTaps: signoutTaps)
    
        model.loading
            .map{!$0}
            .drive(tableView.rx.allowsSelection)
            .addDisposableTo(disposeBag)
        
        model.results
            .drive(onNext: { result in
                switch result {
                case .success:
                    NGUserCredentials.reset()
                case .failure(let error):
                    self.handleError(error: error)
                }
            })
            .addDisposableTo(disposeBag)
        
    // Do any additional setup after loading the view.
    }
    
    func editAction(){
        self.performSegue(withIdentifier: R.segue.nGMeViewController.myProfile, sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



