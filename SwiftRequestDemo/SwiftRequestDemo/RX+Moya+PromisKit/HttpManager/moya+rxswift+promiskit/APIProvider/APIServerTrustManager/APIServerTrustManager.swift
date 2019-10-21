//
//  APIServerTrusManager.swift
//  RXSwift+Moya
//
//  Created by admin on 16/10/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Alamofire

public final class APIServerTrustManager: ServerTrustManager {
    init() {
        let allHostsMustBeEvaluated = false
        let evaluators = ["": DisabledEvaluator()]
        super.init(allHostsMustBeEvaluated: allHostsMustBeEvaluated, evaluators: evaluators)
    }
}
