//
//  ResourceProvider.swift
//  Games
//
//  Created by Django on 04/09/2019.
//  Copyright © 2019 LeeGame. All rights reserved.
//

import Foundation
import RxSwift

/// ResourceProviderType 协议
public protocol ResourceProviderType {
    
    associatedtype ModelType: Codable
    
    func fetchSync(name: String, type: String) -> Result<ModelType, ResourceProviderError>
    
    func fetchAsync(name: String, type: String, callbackQueue: DispatchQueue?, completionHandler: @escaping (_ result: Result<ModelType, ResourceProviderError>) -> Void)
}

/// 资源 Provider
public struct ResourceProvider<ModelType: Codable>: ResourceProviderType {
    
    /// 同步获取
    public func fetchSync(name: String, type: String) -> Result<ModelType, ResourceProviderError> {
        do {
            guard let resourcePath = Bundle.main.path(forResource: name, ofType: type) else { throw ResourceProviderError.notFound }
            
            let decoder: JSONDecoder = JSONDecoder()
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
            
            guard jsonData.count < 1 else {
                let resultObj = try decoder.decode(ModelType.self, from: jsonData)
                return .success(resultObj)
            }
            
            if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(ModelType.self, from: emptyJSONObjectData) {
                return .success(emptyDecodableValue)
            } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(ModelType.self, from: emptyJSONArrayData) {
                return .success(emptyDecodableValue)
            } else {
                throw ResourceProviderError.empty
            }
            
        } catch {
            
            if let errorT = error as? ResourceProviderError {
                return .failure(errorT)
            } else {
                return .failure(ResourceProviderError.mapObjectFail(error: error))
            }
        }
    }
    
    /// 异步获取 默认在主线程返回数据
    public func fetchAsync(name: String, type: String, callbackQueue: DispatchQueue?, completionHandler: @escaping (Result<ModelType, ResourceProviderError>) -> Void) {
        
        let callbackQueueT = callbackQueue ?? DispatchQueue.main
        
        DispatchQueue.global().async {
            do {
                guard let resourcePath = Bundle.main.path(forResource: name, ofType: type) else { throw ResourceProviderError.notFound }
                
                let decoder: JSONDecoder = JSONDecoder()
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
                
                guard jsonData.count < 1 else {
                    let resultObj = try decoder.decode(ModelType.self, from: jsonData)
                    callbackQueueT.async { completionHandler(.success(resultObj)) }
                    return
                }
                
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(ModelType.self, from: emptyJSONObjectData) {
                    callbackQueueT.async { completionHandler(.success(emptyDecodableValue)) }
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(ModelType.self, from: emptyJSONArrayData) {
                    callbackQueueT.async { completionHandler(.success(emptyDecodableValue)) }
                } else {
                    throw ResourceProviderError.empty
                }
                
                return
                
            } catch {
                if let errorT = error as? ResourceProviderError {
                    callbackQueueT.async { completionHandler(.failure(errorT)) }
                } else {
                    callbackQueueT.async { completionHandler(.failure(.mapObjectFail(error: error))) }
                }
                return
            }
        }
    }
}

// MARK: - Rx支持
extension ResourceProvider: ReactiveCompatible {}
extension Reactive where Base: ResourceProviderType {
    
    public func fetch(name: String, type: String) -> Single<Base.ModelType> {
        
        return Single.create { single in
            self.base.fetchAsync(name: name, type: type, callbackQueue: nil, completionHandler: { result in
                switch result {
                case let .success(model):
                    single(.success(model))
                case let .failure(error):
                    single(.error(error))
                }
            })
            return Disposables.create()
        }
    }
}
