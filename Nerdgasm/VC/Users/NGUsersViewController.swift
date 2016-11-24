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
import FLEX

class NGUsersViewController: NGViewController, NGDefaultStatefulVCType {

    var backingView: UIView{
        return self.stateView
    }
 
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var viewModel: NGUserViewModel!
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
        viewModel = NGUserViewModel(userQuery: latestQuery)
        
        tableView
            .rx.itemSelected
            .subscribe { indexPath in
                if self.searchBar.isFirstResponder == true {
                    self.view.endEditing(true)
                }
            }
            .addDisposableTo(disposeBag)
        
        
        viewModel.clean()
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.userCell.identifier)) { index, model, cell in
                let usercell = cell as! UserTableViewCell
                usercell.user = model
            }
            .addDisposableTo(disposeBag)
        
         _ = self.stateMachine;
        errorView = ErrorView(frame: tableView.frame)
        loadingView = LoadingView(frame: tableView.frame)
        emptyView = EmptyView(frame: tableView.frame)
        FLEXManager.shared().showExplorer()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
