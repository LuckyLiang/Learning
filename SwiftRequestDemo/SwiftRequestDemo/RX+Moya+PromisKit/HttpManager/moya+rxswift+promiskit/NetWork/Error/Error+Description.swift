//
//  Error+Description.swift
//  SwiftRequestDemo
//
//  Created by admin on 21/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Moya

extension Swift.Error {
    /// Swift.Error错误描述 兼容所有错误类型的描述
    public var errorDescription: String {
        if let moyaError = self as? MoyaError {
            return moyaError.errorMoyaDescription
        } else if let apiError = self as? APIError {
            return apiError.errorAPIDescription
        }else if let rpError = self as? ResourceProviderError {
            return rpError.errorRPDescription
        } else {
            return localizedDescription
        }
    }
    
    /// 是否是 Moya被取消的网络请求
    public var isMoyaCancledType: Bool {
        let result: Bool
        
        guard let moyaError = self as? MoyaError else {
            result = false
            return result
        }
        
        switch moyaError {
        case .underlying(let err, _):
            result = (err as NSError).code == -999
        default:
            result = false
        }
        
        return result
    }
}
