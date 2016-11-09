//
//  NGUsersViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/17/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxDataSources

class NGUsersViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let disposeBag = DisposeBag()
    private var latestQuery: Driver<String> {
        return searchBar.rx.text.orEmpty
            .throttle(0.4, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Users"
        automaticallyAdjustsScrollViewInsets = false
        activityIndicator.hidesWhenStopped = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        tableView.register(R.nib.userTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.userCell.identifier)
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                })
            .addDisposableTo(disposeBag)
        view.addGestureRecognizer(tapBackground)
        setupRx()
        }
    
    func setupRx() {
        let model = NGUserViewModel(userQuery: latestQuery)
        
        tableView
            .rx.itemSelected
            .subscribe { indexPath in
                if self.searchBar.isFirstResponder == true {
                    self.view.endEditing(true)
                }
            }
            .addDisposableTo(disposeBag)
        
        model.searching
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(disposeBag)
        
        model.clean()
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.userCell.identifier)) { index, model, cell in
                let usercell = cell as! UserTableViewCell
                usercell.user = model
            }
            .addDisposableTo(disposeBag)
        
        model.errors()
            .drive(onNext: { err in
                guard case NGNetworkError.Unauthorized = err else {
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                NGUserCredentials.reset()
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
