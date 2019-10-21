//
//  APIProvider.swift
//  RXSwift+Moya
//
//  Created by admin on 16/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Moya
import RxSwift
import PromiseKit

/// 服务器网络请求
public struct APIProvider<Target: TargetType> {
    
    private let _disposeBag = DisposeBag()
    ///定义网络请求发起着
    private let _privider = MoyaProvider<Target>(callbackQueue: .global(), session:{() -> Session in
        
        // 配置特殊网络需求
        let serverTrustManager = APIServerTrustManager()
        let interceptor = APIRequestInterceptor()
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return Session(configuration: configuration,
                              interceptor: interceptor,
                              serverTrustManager: serverTrustManager,
                              redirectHandler: nil,
                              cachedResponseHandler: nil,
                              eventMonitors: [])
    }(),  plugins: [NetWorksActivityPlugin(),
                    NetWorksLoggerPlugin()])
    
    /// 网络请求
    ///
    /// - Parameters:
    ///   - target: API类型
    ///   - observeOn: 发起请求的Scheduler
    ///   - subscribeOn: 相应请求返回的Scheduler
    ///   - retryCount: 发生错误时重试次数
    /// - Returns: 指定范型的Promise
    public func request<T: Codable>(targetType: Target,
                                    observeOn: ImmediateSchedulerType = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()),
                                    subscribeOn: ImmediateSchedulerType = MainScheduler.instance) -> Promise<T> {
        
        return Promise { seal in
            
            _privider.rx
                .request(targetType, callbackQueue: DispatchQueue.global())
                .observeOn(observeOn).subscribeOn(subscribeOn)
                .map(T.self)
                .subscribe(onSuccess: { (response) in
                    seal.fulfill(response)
                }, onError: { (error) in
                    seal.reject(error)
                })
                .disposed(by: _disposeBag)
        }
    }
}
