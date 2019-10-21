//
//  ServerApi.swift
//  RXSwift+Moya
//
//  Created by admin on 15/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//
/**
请求例子
随便找了个获取新闻数据的接口
 https://api.jisuapi.com/news/get
 https://api.jisuapi.com/news/get?channel=头条&start=0&num=10&appkey=yourappkey
*/

import Moya

public enum ServerApi {
    ///定义请求接口参数
    case getNews(channel: String, start: Int, num: Int)
}

/// 实现协议方法
extension ServerApi: TargetType {
    public var baseURL: URL {
        #if DEVELOP
        return URL(string: "http://localhost:3001")!
        #elseif PREVIEW
        return URL(string: "http://localhost:3001")!
        #else
        return URL(string: "http://localhost:3001")!
        #endif
    }
    /// 路径拼接
    public var path: String {
        switch self {
        case .getNews: ///获取新闻列表
            return "/getNews"
        }
    }
    ///请求方式
    public var method: Method {
        switch self {
        case .getNews:
            return .post
        }
    }
    ///编码格式
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    /// 请求任务
    public var task: Task {
        switch self {
        case .getNews(let channel, let start, let num):
            let param: [String: Any] = ["channel":channel,"start":start,"num": num]
            
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        }
    }
    
    /// heder 可根据不同的接口设置不通的header
    public var headers: [String : String]? {
        return nil
    }
    
}
