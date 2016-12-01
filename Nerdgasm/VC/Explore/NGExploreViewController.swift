//
//  NGExploreViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/28/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class NGExploreViewController: NGViewController, NGDefaultStatefulVCType, UICollectionViewDelegateFlowLayout {
    
    typealias M = NGCategoryViewModel
    var backingView: UIView{
        return stateView
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stateView: UIView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Categories"
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(R.nib.nGCategoryCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.categoryCell.identifier)
        
        collectionView.addSubview(refreshControl)
        
        let reloadSubject = PublishSubject<Void>()
        refreshControl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: {(x) in
                reloadSubject.onNext(())
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        viewModel = NGCategoryViewModel(query: latestQuery, reloadAction: reloadSubject.asDriver(onErrorJustReturn: ()))
        
        let clean = viewModel.clean()
        let errors = viewModel.errors()
        
        Driver.of(clean, errors.map{_ in[]}).merge()
            .drive(collectionView.rx.items(cellIdentifier: R.reuseIdentifier.categoryCell.identifier)) { index, model, cell in
                let categoryCell = cell as! NGCategoryCollectionViewCell
                categoryCell.category = model
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
        
        reloadSubject.onNext(())

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: (width - 40)/2, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isPresenting && isVisible{
            guard let cell: NGCategoryCollectionViewCell = collectionView.cellForItem(at: indexPath) as? NGCategoryCollectionViewCell else {
                return
            }
            guard let category: NGCategory = cell.category else {
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: R.segue.nGExploreViewController.pagesSegue.identifier, sender: category)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.nGExploreViewController.pagesSegue.identifier {
            guard let category = sender as? NGCategory else {return}
            (segue.destination as! NGPagesViewController).category = category
        }
    }
}
