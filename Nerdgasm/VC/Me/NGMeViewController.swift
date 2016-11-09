//
//  NGMeViewController.swift
//  Nerdgasm
//
//  Created by Hrach on 10/23/16.
//  Copyright © 2016 Hrach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NGMeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let rowCount = 2
    let data = Observable<[String]>.just(["My profile", "Sign out"])
    let disposeBag = DisposeBag()
    
    enum Rows: Int {
        case Profile = 0
        case Signout = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Me"
        tableView.allowsMultipleSelection = false
        tableView.register(R.nib.nGMeTableViewCell(), forCellReuseIdentifier: R.reuseIdentifier.meCell.identifier)
        data.bindTo(tableView.rx.items(cellIdentifier: R.reuseIdentifier.meCell.identifier)) { index, model, cell in
            let meCell = cell as! NGMeTableViewCell
            meCell.title = model
            }
            .addDisposableTo(disposeBag)
        
        let signoutTaps = tableView.rx.itemSelected.asDriver()
            .filter{return $0.row == Rows.Signout.rawValue}
            .map{_ in Void()}
        
        tableView
            .rx.itemSelected
            .subscribe { indexPath in
                if indexPath.element?.row == Rows.Profile.rawValue {
                    self.performSegue(withIdentifier: R.segue.nGMeViewController.myProfile, sender: nil)
                }
            }
            .addDisposableTo(disposeBag)
        
       let model = NGMeSignoutViewModel(loggingOutTaps: signoutTaps)
        
        model.loggingOut
            .map{!$0}
            .drive(tableView.rx.allowsSelection)
            .addDisposableTo(disposeBag)
        
        model.results
            .drive(onNext: { result in
                switch result {
                case .success:
                    NGUserCredentials.reset()
                case .failure(let error):
                    guard case NGNetworkError.Unauthorized = error else {
                        self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
                        return
                    }
                    NGUserCredentials.reset()
                }
            })
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


extension Reactive where Base: UITableView {
    public var allowsSelection: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { tableView, selectionAllowd in
            tableView.allowsSelection = selectionAllowd
        }
    }
}
