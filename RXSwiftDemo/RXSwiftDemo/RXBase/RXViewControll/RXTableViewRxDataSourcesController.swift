//
//  RXTableViewRxDataSourcesController.swift
//  RXSwiftDemo
//
//  Created by admin on 28/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
//import RxDataSources
class RXTableViewRxDataSourcesController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //初始化数据
        let items = Observable.just([SectionModel(model:"", items: ["UITableView的用法","RXDataSource用法" ,"RXSectionModel用法"])])
        
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,String>>(configureCell: {(dataSrouce, tv, indexpath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = "\(indexpath.row): \(element)"
            return cell
        })
        
        //绑定数据
        items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
    }
    

}
