//
//  ResourceProviderError.swift
//  Games
//
//  Created by Django on 21/09/2019.
//  Copyright © 2019 LeeGame. All rights reserved.
//

import Foundation

/// 资源错误
public enum ResourceProviderError: Swift.Error {
    
    /// 找不到资源
    case notFound
    
    /// 解析 Json Object失败
    case mapObjectFail(error: Error)
    
    /// 资源为空
    case empty
}

extension ResourceProviderError {
    
    /// 资源错误描述
    public var errorRPDescription: String {
        switch self {
        case .notFound:
            return "找不到该资源"
        case .empty:
            return "资源为空"
        case .mapObjectFail(let error):
            return error.errorDescription
        }
    }
}
