//
//  RequestModel.swift
//  RXSwift+Moya
//
//  Created by admin on 18/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

struct RequestModel: Codable {
    let status: String
    let msg: String
    let data: [ResultData]?
}
struct ResultData: Codable {
    let title: String
    let content: String
    let index: Int
    
    
}
