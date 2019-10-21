//
//  ViewController.swift
//  RXSwift+Moya
//
//  Created by admin on 15/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

class ViewController: BaseViewController {
    
    private let _titleArray: Observable<[ItemModel]> = Observable.just(
        [ItemModel(titleString: "URLSession请求", vcString: "URLSessionViewController"),
         ItemModel(titleString: "Alamofire网络请求", vcString: "AlamofireViewController"),
         ItemModel(titleString: "Moya网络请求", vcString: "MoyaViewController")])
    
    private let _disposeBag = DisposeBag()
    
    @IBOutlet private weak var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _initSubView()
    }

}

extension ViewController {
    
    private func _initSubView() {
        
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        _titleArray
            .bind(to: _tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.titleString
            }
            .disposed(by: _disposeBag)
        
        _tableView.rx.modelSelected(ItemModel.self).subscribe(onNext:{ [weak self] itemModel in
            
            let vcClassType = NSClassFromString("SwiftRequestDemo."+itemModel.vcString) as? BaseViewController.Type
            if let vcClass = vcClassType {
                let vc = vcClass.init()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: _disposeBag)
    }
}

struct ItemModel {
    let titleString: String
    let vcString: String
}
