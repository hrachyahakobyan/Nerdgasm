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

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let rowCount = 2
    let data = Observable<[String]>.just(["Edit", "Sign out"])
    let disposeBag = DisposeBag()
    
    enum Rows: Int {
        case Profile = 0
        case Signout = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = "Me"
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
        
        tableView
            .rx.itemSelected
            .subscribe { indexPath in
                if indexPath.element?.row == Rows.Profile.rawValue {
                    self.performSegue(withIdentifier: R.segue.nGMeViewController.myProfile, sender: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
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
        
        let imageTap = UITapGestureRecognizer()
        imageTap.rx.event
            .flatMapLatest {[weak self] (tap) -> Observable<NGAvatarAction> in
                print("tap")
                return DefaultWireframe.sharedInstance.promptFor("", title: "Change avatar", cancelAction: NGAvatarAction.Cancel, actions: [NGAvatarAction.Camera, NGAvatarAction.Photo, NGAvatarAction.Remove])
                    .filter{ action -> Bool in
                        if case NGAvatarAction.Cancel = action {
                            return false
                        } else if case NGAvatarAction.Remove = action {
                            self?.avatarImageView.image = #imageLiteral(resourceName: "avatar")
                            return false
                        } else {
                            return true
                        }
                    }
            }
            .flatMapLatest {[weak self] action -> Observable<[String: AnyObject]>  in
                print(action)
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    if case NGAvatarAction.Camera = action {
                        picker.sourceType = .camera
                    } else {
                        picker.sourceType = .photoLibrary
                    }
                    picker.allowsEditing = false
                    }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                    .take(1)
            }
            .map { info -> UIImage? in
                print(info)
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .bindTo(avatarImageView.rx.image)
            .addDisposableTo(disposeBag)
        
    
        avatarImageView.addGestureRecognizer(imageTap)

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



