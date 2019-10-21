//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 14/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class ViewController: UIViewController {
    
    

    @IBOutlet weak var tableView: UITableView!
//    let titleArray = []
    
    let disposeBag = DisposeBag()
    
    let items  = Observable.just(["输入验证码实例","RXSwift核心"
        ,"1.RX创建方式"
        ,"2.RX声明周期"
        ,"3.观察者observer、Binder,自定义可绑定属性"
        ,"4. Subject即是订阅者也是Observable"
        ,"5.RX变换操作符buffer、map、flatMap、scan等"
        ,"6.过滤操作符：filter、take、skip等"
        ,"7.RxSwift 条件和布尔操作符：amb、takeWhile、skipWhile等）"
        ,"8.RxSwift 结合操作符：startWith、merge、zip等"
        ,"8.RxSwift连接操作符：connect、publish、replay、multicast"
        ,"9.算数&聚合操作符：toArray、reduce、concat"
        ,"10.其他一些实用的操作符"
        ,"11.错误处理操作"
        ,"12.rx特征序列：single, Completable, Maybe, driver, ControlProperty、 ControlEvent"
        ,"13. RXSwift UITableView的使用 - RxDataSources"
        ]);
    
    let vcClassArray : [String] = ["VerifiyViewController",
                                   "RXSwiftCoreViewController",
                                   "RXCreatTestViewController",
                                   "RXOtherEventCycleViewController",
                                   "RXObserverViewController",
                                   "RXSubjectTestViewController",
                                   "RXTransformViewController",
                                   "RXFilterViewController",
                                   "RXConditionViewController",
                                   "RXCombiningViewController",
                                   "RXConnectableViewController",
                                   "RXMathematicalViewController",
                                   "RXOtherOperatorViewController",
                                   "RXErrorViewController",
                                   "RXTraitsViewController",
                                   "RXTableViewRxDataSourcesController"
        
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MainTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MainTableViewCell")
        
        items.asDriver(onErrorJustReturn: [""]).drive(tableView.rx.items(cellIdentifier: "MainTableViewCell", cellType: MainTableViewCell.self)) { (row, element, cell) in
            
            cell.textLabel?.text = "\(element)"
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] (indexPath) in
            self?.pushToSubVC(vcStr: self?.vcClassArray[indexPath.item])
        }).disposed(by: disposeBag)
        // Do any additional setup after loading the view.
    }
   
}

extension ViewController {
    func pushToSubVC(vcStr: String?) -> Void {
        guard vcStr != nil else { return }
        
        let vcClass = NSClassFromString("RXSwiftDemo."+vcStr!) as! BaseViewController.Type
        let vc =  vcClass.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


