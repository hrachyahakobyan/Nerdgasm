//
//  NGPagesViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/28/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGPagesViewController: NGViewController, NGDefaultStatefulVCType, UICollectionViewDelegateFlowLayout {

    typealias M = NGPagesViewModel
    var backingView: UIView{
        return stateView
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    let disposeBag = DisposeBag()
    var viewModel: M!
    
    private var latestQuery: Driver<String> {
        return searchBar.rx.text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
            .asDriver(onErrorJustReturn: "")
            .startWith("")
    }
    
    var category: NGCategory! {
        didSet{
            guard let category = category else {return}
            if categoryVar == nil {
                categoryVar = Variable<NGCategory>(category)
            } else {
                categoryVar.value = category
            }
        }
    }
    
    private var categoryVar: Variable<NGCategory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.title = category.title
        searchBar.placeholder = "Search in \(category.title)"
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(R.nib.nGPageCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.pageCell.identifier)
        collectionView.addSubview(refreshControl)
        
        let reloadSubject = PublishSubject<Void>()
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: {(x) in
                reloadSubject.onNext(())
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        viewModel = NGPagesViewModel(category: categoryVar.asDriver(), query: latestQuery, reloadAction: reloadSubject.asDriver(onErrorJustReturn: Void()))
        
        let clean = viewModel.clean()
        let errors = viewModel.errors()
        
        Driver.of(clean, errors.map{_ in[]}).merge()
        .drive(collectionView.rx.items(cellIdentifier: R.reuseIdentifier.pageCell.identifier)) { index, model, cell in
                let pageCell = cell as! NGPageCollectionViewCell
                pageCell.page = model
            }
            .addDisposableTo(disposeBag)
      
        errors
            .drive(onNext: {[weak self] err in
                self?.handleError(error: err)
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
        
        _ = self.stateMachine
        
        errorView = ErrorView(frame: collectionView.frame)
        emptyView = EmptyView(frame: collectionView.frame)
        
        viewModel.loading
            .drive(onNext: {[weak self] (loading) in
                if loading && !(self?.refreshControl.isRefreshing)! {
                    self?.collectionView.setContentOffset(CGPoint(x: 0, y: -1.0 * (self?.refreshControl.frame.size.height)!), animated: true)
                    self?.refreshControl.beginRefreshing()
                } else if !loading {
                    self?.refreshControl.endRefreshing()
                }
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        collectionView
            .rx.itemSelected
            .subscribe {[weak self] indexPath in
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: R.segue.nGPagesViewController.pageSegue.identifier, sender: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
        reloadSubject.onNext(())
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: (width - 40)/2, height: 250)
    }
    
    

}
