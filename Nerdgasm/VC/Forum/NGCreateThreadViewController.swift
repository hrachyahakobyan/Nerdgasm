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

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Thread"
        automaticallyAdjustsScrollViewInsets = false
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        let canceItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.rightBarButtonItem = saveItem
        navigationItem.leftBarButtonItem = canceItem
        
        let titleInput = titleTextView.rx.text.orEmpty
                         .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
                         .asDriver(onErrorJustReturn: "")
                         .startWith("")
        
        
        let contentInput = contentTextView.rx.text.orEmpty
            .map{$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
            .asDriver(onErrorJustReturn: "")
        
        saveItem.rx.tap
            .asDriver()
            .drive(onNext: {
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        canceItem.rx.tap
            .asDriver()
            .drive(onNext: { DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil)
                }
             }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        let model = NGCreateThreadViewModel(title: titleInput, content: contentInput, createTaps: saveItem.rx.tap.asDriver())
        
        model.createEnabled
            .drive(saveItem.rx.isEnabled)
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
