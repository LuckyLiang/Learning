//
//  NetWorksLoggerPlugin.swift
//  SwiftRequestDemo
//
//  Created by admin on 21/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Moya

/// 网络活动日志统计
public final class NetWorksLoggerPlugin: PluginType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        print(request.request?.url ?? "request error")
        print(request.request?.allHTTPHeaderFields ?? "")
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            let printString = response.request?.url?.absoluteString ?? "无法找到请求路径"
            print("success" + printString)
        case .failure(let error):
            print("error: " + error.errorDescription)
        }
        #endif
    }
}
