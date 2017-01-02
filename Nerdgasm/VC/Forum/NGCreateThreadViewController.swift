//
//  NGCreateThreadViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/6/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NGCreateThreadViewController: NGAuthenticatedViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!

    var pageID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        let titleInput = titleTextView.rx.text.orEmpty
                         .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
                         .asDriver(onErrorJustReturn: "")
                         .startWith("")
        
        
        let contentInput = contentTextView.rx.text.orEmpty
            .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
            .asDriver(onErrorJustReturn: "")
        
        postButton.rx.tap
            .asDriver()
            .drive(onNext: {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: {
                DispatchQueue.main.async {[weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
             }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        let model = NGCreateThreadViewModel(pageID: pageID, title: titleInput, content: contentInput, createTaps: postButton.rx.tap.asDriver())
        
        model.createEnabled
            .drive(postButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        model.results
            .drive(onNext: { result in
                switch result{
                case .success(_):
                    print("Created thread")
                case .failure(let err):
                    self.handleError(error: err, showError: true)
                }
                }, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleTextView.setContentOffset(CGPoint.zero, animated: false)
        contentTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
}
