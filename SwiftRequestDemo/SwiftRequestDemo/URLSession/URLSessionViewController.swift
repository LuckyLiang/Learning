//
//  URLSessionViewController.swift
//  RXSwift+Moya
//
//  Created by admin on 18/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import MobileCoreServices
class URLSessionViewController: BaseViewController {
    
    @IBOutlet weak private var _progressView: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        _initSubView()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func _getRequest(_ sender: Any) {
        urlsessionMothod()
    }
    
    @IBAction private func _postRequest(_ sender: Any) {
        _postRequest()
    }
    
    @IBAction private func _uploadFile(_ sender: Any) {
        _uploadFile()
    }
    
    @IBAction private func downLoadFile(_ sender: Any) {
        
    }
}

extension URLSessionViewController {
    
    private func _initSubView() {
        _progressView.setProgress(0, animated: false)
    }
    
    ///1. URLSession请求
    func urlsessionMothod()  {
        
        var urlStr = "https://learnappmaking.com/ex/users.json"
        /// 链接转吗
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        ///请求网链接
        let url = URL(string: urlStr)
        
        ///创建config
        let config = URLSessionConfiguration.default
        /// 设置超时时间
        config.timeoutIntervalForRequest = 15.0
        ///会话
        let session = URLSession(configuration: config)
        
        guard let requestUrl = url else { return }
        
        let request =  URLRequest(url: requestUrl)
        
        self.view.makeActivity()
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            
            ///请求回调数据
            if error != nil {
                print("网络请求错误")
            }
            ///服务器响应
            guard let httpResponse = response as? HTTPURLResponse,  (200...299).contains(httpResponse.statusCode) else {
                print("服务器错误")
                return
            }
            guard let `data` = data else {return}
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            DispatchQueue.main.async {//回到主现场
                if let jsonData = json as? Dictionary<String, Any> {
                    print(jsonData)
                }
                self.view.hideToast()
            }
            
        }
        /// 开始请求
        task.resume()
        
    }
    /// POST请求
    private func _postRequest() {
        /// 请求链接
        let linkStr = "http://localhost:3001/getNews".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        
        guard let link = linkStr, let url = URL(string: link) else { return }
        
        //创建请求载体
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        ///请求参
        request.httpBody = "channel=\"头条\"&num=20".data(using: .utf8)
        
        self.view.makeActivity()
        //发起网络请求
        let postTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            ///子线程
            ///请求回调数据
            if error != nil {
                print("网络请求错误")
            }
            ///服务器响应
            guard let httpResponse = response as? HTTPURLResponse,  (200...299).contains(httpResponse.statusCode) else {
                print("服务器错误")
                return
            }
            guard let `data` = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            DispatchQueue.main.async {
                ///回到主线程刷新数据
                self.view.hideToast()
                if let jsonData = json as? Dictionary<String, Any> {
                    print(jsonData)
                }
            }
        }
        /// 开始请求
        postTask.resume()
    }
    
    /// 3. 文件上传
    private func _uploadFile() {
        //分割线
        let boundary = "Boundary-\(UUID().uuidString)"
        // 传递的参数
        let parameters = ["name":"chengcheng","interest":"basketBall"]
        //传递文件
        let files = [(name:"file1",path:Bundle.main.path(forResource: "header", ofType: "png")!),
                     (name:"file2",path:Bundle.main.path(forResource: "home", ofType: "jpg")!)]
        //上传链接
        let uploadLink = "http://localhost:3001/uploadFile".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        guard let link = uploadLink, let url = URL(string: link) else { return }
        
        ///请求体
        var request = URLRequest(url: url)
        request.httpMethod = "POST";
        request.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
        ///创建表单body
        request.httpBody = try! _creatBody(with: parameters, files: files, boundary: boundary)
        
        //创建一个表单上传任务
        let session = URLSession.shared
        let uploadTask = session.dataTask(with: request) { (data, response, error) in
            ///上传完毕
            if error != nil {
                
                print(error)
            }else {
                let str  = String(data: data!, encoding: .utf8)
                print("上传完毕 \(str!)")
                
            }
            
        }
        uploadTask.resume()
        
        //        let uploadTask = URLSession.shared.uploadTask(with: request, from: jpegImage) { (data, response, error) in
        //            ///子线程
        //            ///请求回调数据
        //            if error != nil {
        //                print("网络请求错误")
        //            }
        //            ///服务器响应
        //            guard let httpResponse = response as? HTTPURLResponse,  (200...299).contains(httpResponse.statusCode) else {
        //                print("服务器错误")
        //                return
        //            }
        //            guard let `data` = data else {return}
        //            let json = try? JSONSerialization.jsonObject(with: data, options: [])
        //
        //            DispatchQueue.main.async {
        //                ///回到主线程刷新数据
        //                self.view.hideToast()
        //                if let jsonData = json as? Dictionary<String, Any> {
        //                    print(jsonData)
        //                }
        //            }
        //        }
        //        uploadTask.resume()
        //
    }
    
    private func _creatBody(with paramenters:[String:String]?,files:[(name:String, path:String)], boundary: String) -> Data {
        var body = Data()
        //添加普通参数数据
        if let `paramenters` = paramenters {
            for (key, value) in paramenters {
                // 数据之前要用 --分割线 来隔开，否则后台会解析失败
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        //添加文件数据
        for file in files {
            let url = URL(fileURLWithPath: file.path)
            let filename = url.lastPathComponent
            let data = try! Data(contentsOf: url)
            let mimetype = _mimeType(pathExtension: url.pathExtension)
            
            // 数据之前要用 --分隔线 来隔开 ，否则后台会解析失败
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(("Content-Disposition: form-data; " + "name=\"\(file.name)\";filename=\"\(filename)\"\r\n").data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!) //文件类型
            body.append(data) //文件主体
            body.append("\r\n".data(using: .utf8)!) //使用\r\n来表示这个这个值的结束符
            
        }
        return body
    }
    
    //根据后缀获取对应的Mime-Type
    private func _mimeType(pathExtension: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }
        //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
        return "application/octet-stream"
    }
}
