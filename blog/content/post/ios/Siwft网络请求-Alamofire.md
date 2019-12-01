---
layout:     post
title:      "Siwft网络请求 - Alamofire"
subtitle:   ""
description: "Swift 中Alamofire网络请求简单封装"
excerpt: ""
date:       2018-04-18 20:30:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - IOS
    - Swift
URL: "/2018/04/18/swiftURlAlamofire/"
categories: [ IOS ]

---

一个简单的get请求接口为例，搭建一个比较完整的网络框架，其中包括Session管理，路由和错误处理

这里以获取用户文章列表接口为例

#### 创建模型

```swift
/// 实用泛行实现通用格式
public struct ResponseData<ResultData>: Codable where ResultData: Codable {
    let code: String
    let message: String
    let data: ResultData
}

public struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userID: Int
}

extension Post {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case userID = "userId" //自定义key
    }
}
```

#### 创建路由`PostsApiRouter`

##### 常量配置

里面包含`baseURL`, 参数`key`, `header`常用字段定义，或者其他...

```swift
import Foundation

/// baseURL
struct ProductionServer {
    #if DEBUG
    static let baseURL = "http://localhost:3000/"
    #else
    static let baseURL = "https://jsonplaceholder.typicode.com/"
    #endif
}

/// 定义传参key值
struct APIParameterKey {
    static let password = "password"
    static let email    = "email"
    static let userId   = "userId"
}

/// httpheader
enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

/// 传输类型
enum ContentType: String {
    case json = "application/json"
}

```

##### 路由`PostsApiRouter`

```swift
import Alamofire

/// 文章类路由
enum PostsApiRouter{
    case getPosts(userId: Int)
}

extension PostsApiRouter: APIConfiguration {
    /// 请求方法
    var method: HTTPMethod {
        switch self {
        case .getPosts:
            return .get
        }
    }
    
    ///请求路径
    var path: String {
        switch self {
        case .getPosts:
            return "posts"
        }
    }
    
    /// 请求参数
    var parameters: Parameters? {
        switch self {
        case .getPosts(let userId):
            return [APIParameterKey.userId : userId]
        }
    }
    
    //重写encoding
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    ///构建request
    func asURLRequest() throws -> URLRequest {
        let url = try ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        //http method
        urlRequest.httpMethod = method.rawValue
        
        // header：
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        do {
            urlRequest = try encoding.encode(urlRequest, with: parameters)
        } catch  {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
        
    }
}
```

#### 创建请求管理类

```swift
import Foundation
import RxSwift
import Alamofire
import PromiseKit

public final class AFApiProvider {
    
    private static var _apiProvider = AFApiProvider(session: {() -> Session in
        ///自定义session
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.headers = .default
        let serverTrustManager = AFTrustManager() //自定义服务器信任管理器
        let interceptor = AFApiRequestInterceptor() //自定义/拦截器，根据需求自行添加
        
        return Session(configuration: sessionConfig,
                       interceptor: interceptor,
                       serverTrustManager: serverTrustManager,
                       redirectHandler: nil, //重定向操作
            cachedResponseHandler: nil, //缓存
            eventMonitors: []) //事件监听
    }())
    
    
    public static func shared() -> AFApiProvider {
        return _apiProvider
    }
    
    private let _disposeBag = DisposeBag()
    
    private var _session: Session
    
    private init(session: Session = Session.default) {
        _session = session
    }

}
```

##### 自定义`RequestInterceptor`

```swift
import Alamofire

/// 请求拦截器
public final class AFApiRequestInterceptor: RequestInterceptor {
    
    /// 定义准备请求闭包，可以回调在这个时候做某些事
    private let _prepare: ((URLRequest) -> URLRequest)?
    /// 将要发送请求闭包
    private let _willSend: ((URLRequest) -> Void)?
    
    init(prepare:((URLRequest) -> URLRequest)? = nil, willSend: ((URLRequest) -> Void)? = nil) {
        _prepare = prepare
        _willSend = willSend
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (AFResult<URLRequest>) -> Void) {
        // 准备请求, 然后对request做一些设置，比如这里设置header
        var request = _prepare?(urlRequest) ?? urlRequest
        request.setValue("zh-cn", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        //设置完成后将要发送
        _willSend?(request)
        completion(.success(request))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}
```

##### `ServerTrustManager`

服务器证书信任管理器`ServerTrustManager`，这里只是陪着不做验证，如果项目需要验证证书的可以写在这个管理器里

```swift
import Alamofire

/// 服务器证书信任管理,这里不做验证，信任所有
public final class AFTrustManager: ServerTrustManager {
    init() {
        let allHostsMustBeEvaluated = false
        let evaluators = ["": DisabledEvaluator()] //不做验证
        super.init(allHostsMustBeEvaluated: allHostsMustBeEvaluated, evaluators: evaluators)
    }

```

#### 错误处理，对服务器错误和服务器和客户端约定错误进行扩展

```swift
import Foundation
// 服务器报错
enum ServerError: Error {
    case forbidden              //Status code 403
    case notFound               //Status code 404
    case internalServerError    //Status code 500
}

/// 服务器错误处理
extension ServerError {
        
    public var errorDescription: String {
        switch self {
        case .forbidden:
            return "服务器禁止访问"
        case .notFound:
            return "未找到页面"
        case .internalServerError:
            return "服务器异常"
        }
    }
}

import Foundation

/// 自定义错误和服务器约定错误
public enum ServerApiError: Swift.Error {
        /// 解析Json格式错误
        case parseJsonError

        /// 解析服务器定义StatusCode格式错误
        case parseStatusCodeTypeError
        
        /// 服务器自定义错误
        case serverDefineError(code: String, message: String)
    
}
extension ServerApiError {
    
    /// 错误描述
    public var errorAPIDescription: String {
        switch self {
        case .parseJsonError:
            return "解析Json格式错误"
        case .parseStatusCodeTypeError:
            return "解析服务器定义StatusCode格式错误"
        case .serverDefineError(_, let message): //返回服务器定义的错误信息
            return message
        }
    }
}


import Alamofire

///扩展AFError描述属性
extension  AFError {
    public var AFErrorDescription: String {
        switch self {
        case .invalidURL(let urlConvertible):
            return "无效的URL，错误url: \(urlConvertible)"
        case .sessionDeinitialized:
            return """
            session无效而没有错误，因此它可能被意外取消了初始化。 \
            在请求期间，请确保保留对您的session的引用。
            """
        default:
//            return "剩余的自行定义，其实并没有什么用，Alamofire已经对其错误进行了定义`errorDescription`，不过是英文而已，也还比较好理解"
            return self.errorDescription
        }
    }
}

/// 扩展错误描述属性
extension Swift.Error {
    
    public var description: String {
        if let afError = self as? AFError {
            return afError.errorDescription
        }else if let serverError = self as? ServerError {
            return serverError.errorDescription
        }else if let serverApiError = self as? ServerApiError {
            return serverApiError.errorAPIDescription
        } else {
            return localizedDescription
        }
    }
}
	
```

#### 请求封装

```swift
/// 请求管理
extension AFApiProvider {
    /// 返回Promis
    /// - Parameters
    ///     - urlConvertible: `URLRequestConvertible`请求
    ///     - observerOn：`ImmediateSchedulerType` 监听队列 默认全局对列
    ///     - subscribeOn: `ImmediateSchedulerType`回调队列 默认主队列
    /// - return: Promise<T>
    public func request<T: Codable> (_ urlConvertible: Alamofire.URLRequestConvertible,
                                     observerOn: ImmediateSchedulerType = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()),
                                     subscribeOn: ImmediateSchedulerType = MainScheduler.instance) -> Promise<T> {
        return Promise{ seal in
            
            observerRequest(urlConvertible)
                .observeOn(observerOn)
                .subscribeOn(subscribeOn)
                .subscribe(onSuccess: { seal.fulfill($0)}) { seal.reject($0)}
                .disposed(by: _disposeBag)
        }
    }
    
    /// 发起请求，使用rxswift做回调，里面进行错误统一处理
    /// - Parameters:
    ///     - urlConvertible: `URLRequestConvertible` 构建DataRequest
    /// - return: `Single<T>`，`Single<T>` 携带返回模型或错误
    private func observerRequest<T: Codable>(_ urlConvertible: Alamofire.URLRequestConvertible) -> Single<T> {
        
        return Single<T>.create { (observer) -> Disposable in
            
            let request =  AFApiProvider.shared()._session
                .request(urlConvertible)
                .validate()
                .responseDecodable { (response: DataResponse<T> ) in
                    do {
                        let dataModel =  try response
                            ._storeServerTimerIntervalDistance()
                            ._catchRandomDomainFlag()
                            ._filterServerSuccessData()///验证服务器格式和定义的错误
                            .map(type: T.self)  //json转模型
                        observer(.success(dataModel))
                    } catch let error{
                        observer(.error(error))
                    }
            }
            
            return Disposables.create {
                
                request.cancel()
            }
        }
    }
}

extension DataResponse {
    
    /// 校验http返回 校准服务器时间，看自己需求是否需要
    fileprivate func _storeServerTimerIntervalDistance() throws -> DataResponse {
        guard let serverTime = response?.allHeaderFields["Date"] as? String else {
            return self
        }
        
        let dataFormatter = DateFormatter().then {
            $0.locale = Locale(identifier: "en_US_POSIX")
            $0.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        }
        
        if let serverDate = dataFormatter.date(from: serverTime) {
            let timeIntervaDistance = Date().timeIntervalSince1970 - serverDate.timeIntervalSince1970
            print("请求时间差: \(timeIntervaDistance)")
            
        }
        return self
    }
    
    ///根据http返回处理特殊逻辑，如切换域名等,看自己需求
    fileprivate func _catchRandomDomainFlag() -> DataResponse {
        guard let statusCode = response?.statusCode else { return self }
        if [403, 502, 503].contains(statusCode) {
            print("http 错误码: \(statusCode)")
        }
        return self
    }
    
    /// 服务器返回数据格式错误,这样就必须让服务端按规范的数据格式返回数据，不然直接抛出错误
    /// 根据自己项目需求更改
    fileprivate func _filterServerSuccessData() throws -> DataResponse {
        
        do {
            let responseJson = try mapJSON(failsOnEmptyData: false)
            guard let dic = responseJson as? [String : Any] else {
                throw ServerApiError.parseJsonError
            }
            if let error = _praseServerError(dic: dic) { throw error  }
            return self
        } catch  {
            throw error
        }
    }
    
    
    /// 服务器自定义数据错误，直接抛出错误
    private func _praseServerError(dic:[String: Any]) -> Error? {
        
        //returnCode 为服务器与前端约定的returnCode
        guard let code = dic["code"] as? String else { return ServerApiError.parseStatusCodeTypeError }
        let message = dic["message"] as? String
        guard ["000000"].contains(code) else { //比如0为请求成功，那么其他状态为错误信息，返回错误
            return ServerApiError.serverDefineError(code: code, message: message ?? "服务器返回 错误 code: \(code)")
        }
        return nil
    }
    
    
}

extension DataResponse {
    
    /// 对返回结果转Json
    /// - failsOnEmptyData：默认为true, 如果失败返回空
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        
        guard let `data` = data else { return NSNull() }
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
    
    /// 将json转成模型，参考moya
    func map<D: Decodable>(type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
            }
        }
        
        guard let `data` = data else { throw APIError.parseJsonError }
        let jsonData: Data
        
        keyPathCheck: if let keyPath = keyPath {
            guard let jsonObject = (try mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
                if failsOnEmptyData {
                    throw APIError.parseJsonError
                } else {
                    jsonData = data
                    break keyPathCheck
                }
            }
            
            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw APIError.parseJsonError
                }
                do {
                    return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
                } catch let error {
                    throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
                }
            }
        } else {
            jsonData = data
        }
        do {
            if jsonData.count < 1 && !failsOnEmptyData {
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
                    return emptyDecodableValue
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
                    return emptyDecodableValue
                }
            }
            return try decoder.decode(D.self, from: jsonData)
        } catch let error {
            throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
}

private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}
```

#### 也可提供一个api管理类，可有可无，方便管理

```swift
import Alamofire
import PromiseKit
import RxSwift

public final class APIClient {
    
    public static func getPosts(userId: Int) ->Promise<ResponseData<[Post]>> {
        
        return AFApiProvider.shared().request(PostsApiRouter.getPosts(userId: userId))
    }
}
```

#### 最后完成请求

```swift
    @IBAction func requestClick(_ sender: Any) {
        
        APIClient.getPosts(userId: 101).ensure {
          ///这里可做网络菊花之类的
            print("请求中....")
        }.done { (postData) in
            print("请求完成....")
            postData.data.forEach { (post) in
                print(post)
            }
        }.catch { (error) in
                 ///错误处理
            print(error.description)
        }
    }
```

