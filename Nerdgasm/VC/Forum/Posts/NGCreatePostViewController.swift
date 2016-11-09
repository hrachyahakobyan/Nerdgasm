//
//  NGCreatePostViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 11/7/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NGCreatePostViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    
    var threadVar: Variable<NGThread>!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Post"
        
        automaticallyAdjustsScrollViewInsets = false
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        let canceItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.rightBarButtonItem = saveItem
        navigationItem.leftBarButtonItem = canceItem
        
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
        
        let model = NGCreatePostViewModel(content: contentInput, thread: threadVar.asDriver(), createTaps: saveItem.rx.tap.asDriver())
        
        model.createEnabled
            .drive(saveItem.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        model.posts
            .drive(onNext: { result in
                switch result{
                case .success(_):
                    print("Created post")
                case .failure(let err):
                    guard case NGNetworkError.Unauthorized = err else {
                        print(err)
                        return
                    }
                    NGUserCredentials.reset()
                }
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        
        // Do any additional setup after loading the view.
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
