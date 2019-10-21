//
//  ApiError.swift
//  SwiftRequestDemo
//
//  Created by admin on 21/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

/// 自己服务器错误
public enum APIError: Swift.Error {
    
    /// 解析Json格式错误
    case parseJsonError

    /// 解析服务器定义StatusCode格式错误
    case parseStatusCodeTypeError
    
    /// 服务器自定义错误
    case serverDefineError(code: String, message: String)
}


extension APIError {
    
    /// 自己服务器错误描述
    public var errorAPIDescription: String {
        switch self {
        case .parseJsonError:
            return "解析Json格式错误"
        case .parseStatusCodeTypeError:
            return "解析服务器定义StatusCode格式错误"
        case .serverDefineError(_, let message):
            return message
        }
    }
}
