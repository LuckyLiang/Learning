//
//  MoyaViewController.swift
//  RXSwift+Moya
//
//  Created by admin on 18/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import PromiseKit
import Moya
class MoyaViewController: BaseViewController {

    private let _provide = APIProvider<ServerApi>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MoyaViewController {
    func moyaRequest() {
        let requestPromis: Promise<RequestModel> = _provide.request(targetType: .getNews(channel: "头条", start: 0, num: 10))
        
        requestPromis.ensure {
            //请求完成前
            }.done { (result) in
                //请求完成
                print(result,result.msg)
                
            }.catch { (error) in
                //错误处理
                print(error)
        }
    }
}
