//
//  AlamofireViewController.swift
//  RXSwift+Moya
//
//  Created by admin on 18/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import Alamofire
class AlamofireViewController: BaseViewController {

    @IBOutlet weak var upload: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func uploadImag(_ sender: Any) {
        downloadFile()
    }
}

extension AlamofireViewController {
    
    ///上传文件
    func uploadFile() {
        
        let image = UIImage(named: "testUpload.jpeg")
        guard let uploadImage = image else {
            return
        }
        //将图片转化为JPEG类型的data 后面的参数是压缩比例
        guard let jpegImage = uploadImage.jpegData(compressionQuality: 0.5) else { return  }
        
        //类似于网页上Form表单里的文件提交
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(jpegImage, withName: "file", fileName: "testUpload.jpeg", mimeType: "image/jpeg")
        }, to: "http://localhost:3000/uploadFile")
            .uploadProgress{progress in
                print("当前进度: \(progress.fractionCompleted)")
            }
            .responseString(queue: .main, encoding: .utf8) { (response) in
                debugPrint(response)
        }
    }
    
    func downloadFile() {
        AF.download("http://localhost:3000/dowloadFile").uploadProgress(closure: { (progress) in
            print(progress.completedUnitCount)
        }).responseData { (response) in
            if let data = response.value {
                //let image = UIImage(data: data)
                let imagePath = NSHomeDirectory().appending("/Documents").appending("/header.png")
                //保存图片
                let result = NSData(data: data).write(toFile: imagePath, atomically: true)
                if result == false {
                    print("图片保存失败，图片路径 = ", imagePath)
                }else {
                    print("图片保存成功")
                }
            }
        }
    }
    
    ///一般请求
    func commonRequest() {
        let parma = ["channel":"头条","start":"0","num":"10"]
        AF.request("http://localhost:3001/getNews", method: .get, parameters: parma).responseJSON { (response) in
            if let jsdic = response.value as? Dictionary<String,Any> {
                print(jsdic)
            }
        }
    }
}
