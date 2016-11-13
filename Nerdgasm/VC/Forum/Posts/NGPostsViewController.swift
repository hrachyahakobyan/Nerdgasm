//
//  NGPostsViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGPostsViewController: NGAuthenticatedViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let refreshControl = UIRefreshControl()
    
    var thread: NGThread! {
        didSet{
            guard let thread = thread else {return}
            if threadVar == nil {
                threadVar = Variable<NGThread>(thread)
            } else {
                threadVar.value = thread
            }
        }
    }
    
    private var threadVar: Variable<NGThread>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.addSubview(refreshControl)
        tableView.rowHeight = 100
        tableView.allowsSelection = false
        
        let addPostItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.rightBarButtonItem = addPostItem
        
        addPostItem.rx.tap
            .subscribe(onNext: { _ in
                if self.presentedViewController == nil {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: R.segue.nGPostsViewController.createPost, sender: self.threadVar)
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        tableView.register(R.nib.nGPostTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.postCell.identifier)
        
        
        let model = NGPostsViewModel(threads: threadVar.asDriver(), reloadAction: refreshControl.rx.controlEvent(.valueChanged).asDriver().startWith(Void()))
        
        model.clean()
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.postCell.identifier)) { index, model, cell in
                let postCell = cell as! NGPostTableViewCell
                postCell.post = model
            }
            .addDisposableTo(disposeBag)
        
        model.errors()
            .drive(onNext: { err in
                self.handleError(error: err)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        model.loading
            .drive(refreshControl.rx.refreshing)
            .addDisposableTo(disposeBag)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         super.prepare(for: segue, sender: sender)
        if segue.identifier == R.segue.nGPostsViewController.createPost.identifier {
            ((segue.destination as! UINavigationController).topViewController as! NGCreatePostViewController).threadVar = (sender as! Variable<NGThread>)
        }
    }
    

}
