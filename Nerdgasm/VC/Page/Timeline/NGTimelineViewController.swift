//
//  NGTimelineViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/30/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class NGTimelineViewController: NGPageChildViewController, NGDefaultStatefulVCType,
                                 UITableViewDelegate {
    
    var backingView: UIView {
        return tableView.backgroundView!
    }

    typealias M = NGTimelineViewModel
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: NGTimelineViewModel!
    let refreshControl = UIRefreshControl()
    
    var errorInput: Driver<NGStatefulViewControllerStateInput> {
        return viewModel.errors()
            .filter{[weak self] _ in self?.tableView.visibleCells.count == 0}
            .map{ _  in (.Error, false, nil) }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
        let reloadSubject = PublishSubject<Void>()
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: {(x) in
                reloadSubject.onNext(())
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        tableView.backgroundView = UIView()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.rowHeight = 150
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        
        tableView.register(R.nib.nGContentTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.contentCell.identifier)
        
        viewModel = NGTimelineViewModel(pageID: page.id, reloadAction: reloadSubject.asDriver(onErrorJustReturn: ()))
        
        viewModel.loading
            .drive(refreshControl.rx.refreshing)
            .addDisposableTo(disposeBag)
        
        viewModel.clean()
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.contentCell.identifier)) { index, model, cell in
                let contentCell = cell as! NGContentTableViewCell
                contentCell.content = model.0
                contentCell.user = model.1
            }
            .addDisposableTo(disposeBag)
        
        viewModel.errors()
            .drive(onNext: {[weak self] err in
                self?.handleError(error: err, showError: true)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
        _ = self.stateMachine
        
        errorView = ErrorView(frame: tableView.frame)
        emptyView = EmptyView(frame: tableView.frame)
        
        reloadSubject.onNext(())
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell: NGContentTableViewCell = cell as? NGContentTableViewCell else {return}
        cell.titleImageView.images.value = ""
    }
    
}
