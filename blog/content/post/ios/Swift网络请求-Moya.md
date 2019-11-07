---
layout:     post
title:      "Swift网络请求 - RXSwift + PromiseKit + Moya"
subtitle:   ""
description: "Swift 中 Moya三方框架的配置和使用"
excerpt: ""
date:       2018-04-20 16:30:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - IOS
    - Swift
URL: "/2018/04/20/swiftURlMoya/"
categories: [ IOS ]

---

Moya是基于`Alamofire`网络框架上进行的封装，支持RXSwift

#### 创建模型

```
import Foundation

/// 实用泛行实现通用格式
public struct ResponseData<T>: Codable where T: Codable {
    let code: String
    let message: String
    let data: T?
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

#### 定义`TargetType`

```
import Moya

public enum ServerApi {
    ///定义请求接口参数
    case getNews(channel: String, start: Int, num: Int)
    case getPosts(id: Int)
}

/// 实现协议方法
extension ServerApi: TargetType {
    public var baseURL: URL {
        #if DEVELOP
        return URL(string: "http://localhost:3000")!
        #elseif PREVIEW
        return URL(string: "http://localhost:3000")!
        #else
        return URL(string: "http://localhost:3000")!
        #endif
    }
    /// 路径拼接
    public var path: String {
        switch self {
        case .getNews: ///获取新闻列表
            return "/getNews"
        case .getPosts:
            return "/posts"
        }
    }
    ///请求方式
    public var method: Method {
        switch self {
        case .getNews:
            return .post
        case .getPosts:
            return .get
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
            
        case .getPosts(let userId):
            let param: [String: Int] = ["userId":userId]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
            
        }
    }
    
    /// heder 可根据不同的接口设置不通的header
    public var headers: [String : String]? {
        return nil
    }
    
}

```

#### 网络请求管理

```
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
        configuration.timeoutIntervalForRequest = 15 //设置请求超时时间
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
                .observeOn(observeOn).map({
                    try $0._storeServerTimeIntervalDistance()
                        ._catchRandomDomainFlag()
                        ._filterServerSuccessData()
                        .map(T.self) ///这里根据自己需要，可直接转成模型，或者使用mapJson,或mapString
                })
                .subscribeOn(subscribeOn)
                .subscribe(onSuccess: {
                    seal.fulfill($0)
                }, onError: { (error) in
                    seal.reject(error)
                })
                .disposed(by: _disposeBag)
        }
    }
}


extension Response {
    
    /// 根据http返回 校准服务器时间
    fileprivate func _storeServerTimeIntervalDistance() throws -> Response {
        guard let serverTime = response?.allHeaderFields["Date"] as? String else {
            return self
        }
        
        let dateFormatter = DateFormatter().then {
            $0.locale = Locale(identifier: "en_US_POSIX")
            $0.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        }
        
        if let serverDate = dateFormatter.date(from: serverTime) { // 此处无需时区处理
            let timeIntervalDistance = Date().timeIntervalSince1970 - serverDate.timeIntervalSince1970
            print("请求时间差: \(timeIntervalDistance)")
//            SystemDataManager.shared.preinfoManager.timeIntervalDistance = timeIntervalDistance
        }
        
        return self
    }
    
    
    /// 根据http返回 处理特殊逻辑 如切换域名
    fileprivate func _catchRandomDomainFlag() -> Response {
        if [403, 502, 503].contains(statusCode) { // 有错误可以抛特殊异常 用与retry
            print("http 错误码: \(statusCode)")
        }
        return self
    }
    
    /// 服务器返回数据格式错误
    fileprivate func _filterServerSuccessData() throws -> Response {
        do {
            let responseJson = try mapJSON(failsOnEmptyData: false)
            guard let dict = responseJson as? [String: Any] else { throw APIError.parseJsonError }
            if let error = _praseServerError(dict: dict) { throw error }
            return self
        } catch {
            throw error
        }
    }
    
    
    /// 服务器自定义错误
    private func _praseServerError(dict: [String: Any]) -> Error? {
        /**
         {
            code: "000000"
            message: "请求成功"
            data: {}
         }
         */
        guard let code = dict["code"] as? String else { //跟自己服务器约定的返回值字段
            return APIError.parseStatusCodeTypeError
        }
        
        let message = dict["message"] as? String //跟服务器约定的message字段
        
        guard ["000000"].contains(code) else { // 有错误,根据与服务器约定code判断
            return APIError.serverDefineError(code: code,
                                              message: message ?? "服务器返回 returnCode：\(code)")
        }
        
        return nil
    }
    
}

```

#### `interceptor`

```
import Alamofire

/// 对request在发出前进行特殊处理
public struct APIRequestInterceptor: RequestInterceptor {
    private let _prepare: ((URLRequest) -> URLRequest)?
    private let _willSend: ((URLRequest) -> Void)?
    
    init(prepare: ((URLRequest) -> URLRequest)? = nil, willSend:((URLRequest) -> Void)? = nil) {
        _prepare = prepare
        _willSend = willSend
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (AFResult<URLRequest>) -> Void) {
        var request = _prepare?(urlRequest) ?? urlRequest
        request.setValue("iphoneX", forHTTPHeaderField: "User-Agent")
        request.setValue("ios", forHTTPHeaderField: "client-type")
        _willSend?(request)
        completion(.success(request))
    }
}
```

#### 服务器信任`ServerTrustManager`

```swift
import Alamofire

public final class APIServerTrustManager: ServerTrustManager {
    init() {
        let allHostsMustBeEvaluated = false
        let evaluators = ["": DisabledEvaluator()]
        super.init(allHostsMustBeEvaluated: allHostsMustBeEvaluated, evaluators: evaluators)
    }
}
```

#### 插件`Plugin`

网络知识器管理器

```
import UIKit

/// 网络活动指示器
public final class NetWorksIndicatorScheduler {
    
    public static let shared = NetWorksIndicatorScheduler()
    
    private init(){}
    
    private var _activityCount: Int = 0
    
    private lazy var _activityQueue = DispatchQueue(label: "ActivityIndicatorQueue")
    
    /// 加载网络活动指示器
    public func pushActivityIndicator() {
        _activityQueue.sync { [weak self] in
            guard let self = self else { return }
            self._activityCount += 1
            self._updateActivityIndicator()
        }
    }
    
    public func popActivityIndicator() {
        _activityQueue.sync { [weak self] in
            guard let self = self else { return }
            self._activityCount -= 1
            if self._activityCount < 0 {
                self._activityCount = 0
            }
            self._updateActivityIndicator()
        }
    }
    
    /// 更新状态
    private func _updateActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = self._activityCount > 0
        }
    }
    
}
```

`NetWorksActivityPlugin`

```
import Moya

/// 网络活动状态观察
public final class NetWorksActivityPlugin: PluginType {
    
    /// 将要发送的时候开启
    public func willSend(_ request: RequestType, target: TargetType) {
        NetWorksIndicatorScheduler.shared.pushActivityIndicator()
    }
    
    /// 数据返回关闭
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        NetWorksIndicatorScheduler.shared.popActivityIndicator()
    }
}

```

网络活动日志统计插件

```
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
```

#### 错误处理

`MoyaError`

```
import Moya

extension MoyaError {
    
    /// MoyaError错误描述
    public var errorMoyaDescription: String {
        switch self {
        case MoyaError.imageMapping:
            return "请求异常 (图片数据解析)."
        case MoyaError.jsonMapping:
            return "请求异常 (Json数据解析)."
        case MoyaError.stringMapping:
            return "请求异常 (字符串数据解析)."
        case MoyaError.objectMapping(let error, _):
            return error.errorDescription
        case MoyaError.encodableMapping:
            return "请求异常 (Encodable Mapping)."
        case MoyaError.statusCode(let response):
            return ("请求失败,请重试! 错误码： " + "(\(response.statusCode))")
        case MoyaError.requestMapping:
            return "请求异常 (Request Mapping)"
        case MoyaError.parameterEncoding(let error):
            return "请求异常 (Parameter Encoding): \(error.errorDescription)"
        case MoyaError.underlying(_, _):
            return "请求异常 (Underlying)"
        }
    }
}

```

 自己服务器错误

```
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
        case .serverDefineError(_, let message): //返回服务器定义的错误信息
            return message
        }
    }
}
```

错误描述扩展

```
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

```

#### 发送请求

```
import UIKit
import RxSwift
import PromiseKit
import Moya
class MoyaViewController: BaseViewController {

    private let _provide = APIProvider<ServerApi>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MoyaViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moyaRequest()
    }
    
    func moyaRequest() {
        let requestPromis: Promise<ResponseData<[Post]>> = _provide.request(targetType: .getPosts(id: 1))
        
        
        requestPromis.ensure {
            //请求完成前
            }.done { (result) in
                //请求完成
                print("请求成功回调：",result,result.message)
                 
            }.catch { (error) in
                //错误处理
                print("请求失败回调：",error)
        }
    }
}
```

#### 扩展，资源文件加载

```
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

```

资源错误处理

```
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
```

