//
//  NGForumViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/3/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGForumViewController: NGAuthenticatedViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var refreshControl: UIRefreshControl!
    let disposeBag = DisposeBag()
    
    private var latestQuery: Driver<String> {
        return searchBar.rx.text.orEmpty
            .throttle(0.2, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
            .asDriver(onErrorJustReturn: "")
            .startWith("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        tableView.rowHeight = 120
        let addThreadItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addThreadItem
        navigationItem.title = "Forum"
        
        addThreadItem.rx.tap
            .subscribe(onNext: { _ in
                if self.presentedViewController == nil {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: R.segue.nGForumViewController.createThread.identifier, sender: nil)
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        tableView.register(R.nib.nGThreadTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.threadCell.identifier)
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    
        
        let model = NGThreadsViewModel(query: latestQuery, reloadAction: refreshControl.rx.controlEvent(.valueChanged).asDriver().startWith(Void()))
        
        model.searching
            .drive(refreshControl.rx.refreshing)
            .addDisposableTo(disposeBag)
        
        tableView
            .rx.itemSelected
            .subscribe {indexPath in
                guard let cell = self.tableView.cellForRow(at: indexPath.element!) as? NGThreadTableViewCell else {return}
                guard let thread = cell.thread else {return}
                self.tableView.deselectRow(at: indexPath.element!, animated: false)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: R.segue.nGForumViewController.posts.identifier, sender: thread)
                }
            }
            .addDisposableTo(disposeBag)
        
        model.filteredThreads()
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.threadCell.identifier)) { index, model, cell in
                let usercell = cell as! NGThreadTableViewCell
                usercell.thread = model
            }
            .addDisposableTo(disposeBag)

        model.errors()
            .drive(onNext: { err in
               self.handleError(error: err)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)


        let tapBackground = UITapGestureRecognizer()
        tapBackground.cancelsTouchesInView = false
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                })
            .addDisposableTo(disposeBag)
        view.addGestureRecognizer(tapBackground)

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == R.segue.nGForumViewController.posts.identifier {
            let thread = sender as! NGThread
            (segue.destination as! NGPostsViewController).thread = thread
        }
        
    }
}
