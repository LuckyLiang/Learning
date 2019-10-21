//
//  RXTraitsViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 27/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public enum CompletableEvent {
    case error(Swift.Error)
    case completed
}

public enum CacheError: Error {
    case failedCaching
}

//与缓存相关的错误类型
enum StringError: Error {
    case failedGenerate
}

enum DataError : Error {
    case cantParseJson
}

class RXTraitsViewController: BaseViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.rx.isVisible.subscribe(onNext:{print("当前页面显示状态\($0)")}).disposed(by: disposeBag)
        
        self.rx.viewDidLoad.subscribe(onNext:{print("viewDidLoad")}).disposed(by: disposeBag)
        
        self.rx.viewWillAppear.subscribe(onNext: { (bool) in
            print("viewWillAppear", bool)
            
        }).disposed(by: disposeBag)
        
        
        self.rx.viewWillDisapper.subscribe(onNext: { (bool) in
            print("viewWillDisapper", bool)
        }).disposed(by: disposeBag)
        
        
        self.rx.viewDidDisapper.subscribe(onNext: { (bool) in
            print("viewDidDisapper", bool)
            
        }).disposed(by: disposeBag)
        
        self.rx.isDismissing.subscribe(onNext: { (bool) in
            print("VC被dismiss时会触发", bool)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//
//    }
    
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        controlProperty()
        // Do any additional setup after loading the view.
    }
    
    /**
     Single
     1，基本介绍
     Single 是 Observable 的另外一个版本。但它不像 Observable 可以发出多个元素，它要么只能发出一个元素，要么产生一个 error 事件。
        1.1 发出一个元素，或一个 error 事件
        1.2 不会共享状态变化
     
     2，应用场景
     Single 比较常见的例子就是执行 HTTP 请求，然后返回一个应答或错误。不过我们也可以用 Single 来描述任何只有一个元素的序列。
     
     3，SingleEvent
     为方便使用，RxSwift 还为 Single 订阅提供了一个枚举（SingleEvent）：
     
     .success：里面包含该 Single 的一个元素值
     .error：用于包含错误
     
     */
    
    func single() -> Void {
        getPlaylist("0").subscribe { (event) in
            switch event {
            case .success(let json):
                print("json结果 ：", json)
            case .error(let error):
                print("发生错误：", error)
            }
        }.disposed(by: disposeBag)
        
//        getPlaylist("0").subscribe(onSuccess: { (json) in
//            print("json结果 ：", json)
//        }) { (error) in
//            print("发生错误：", error)
//        }.disposed(by: disposeBag)
    }
    
    func getPlaylist(_ channel: String) -> Single<[String : Any]> {
        return Single<[String : Any]>.create(subscribe: {single in
            let url = "https://douban.fm/j/mine/playlist?"+"type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!){data, _ , error in
                
                if let error  = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data, let json = try?JSONSerialization.jsonObject(with: data, options: .mutableLeaves), let result = json as? [String : Any] else {
                    
                    single(.error(DataError.cantParseJson))
                    return
                }
                
                single(.success(result))
            }
            
            task.resume()
            
            return Disposables.create{task.cancel()}
        })
    }

   /**
     （2）我们可以通过调用 Observable 序列的 .asSingle() 方法，将它转换为 Single。
     */
    func single2() -> Void {
        Observable.of("1").asSingle()
            .subscribe(onSuccess: {print($0)}, onError: {print($0)})
            .disposed(by: disposeBag)
    }
    
    /**
    Completable
     1，基本介绍
     Completable 是 Observable 的另外一个版本。不像 Observable 可以发出多个元素，它要么只能产生一个 completed 事件，要么产生一个 error 事件。
        不会发出任何元素
        只会发出一个 completed 事件或者一个 error 事件
        不会共享状态变化
     
     2，应用场景
     Completable 和 Observable<Void> 有点类似。适用于那些只关心任务是否完成，而不需要在意任务返回值的情况。比如：在程序退出时将一些数据缓存到本地文件，供下次启动时加载。像这种情况我们只关心缓存是否成功。
     
     3，CompletableEvent
     为方便使用，RxSwift 为 Completable 订阅提供了一个枚举（CompletableEvent）：
     .completed：用于产生完成事件
     .error：用于产生一个错误
     
    */
    
    func cacheLocally() -> Completable {
        return Completable.create(subscribe: {completanle in
            
           //将数据缓存到本地（这里掠过具体的业务代码，随机成功或失败）

            let success = (arc4random() % 2 == 0)
            
            guard success else {
                completanle(.error(CacheError.failedCaching))
                return Disposables.create{}
            }
            completanle(.completed)
            return Disposables.create{}
        })
    }
    
    func CompletableTest() -> Void {
        cacheLocally().subscribe(onCompleted: {print("保存成功")}) { (error) in
            print("保存失败", error.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
    /**
     Maybe
     1. 基本介绍
     Maybe 同样是 Observable 的另外一个版本。它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
     发出一个元素、或者一个 completed 事件、或者一个 error 事件
     不会共享状态变化
     
     2，应用场景
     Maybe 适合那种可能需要发出一个元素，又可能不需要发出的情况。
     
     3，MaybeEvent
     为方便使用，RxSwift 为 Maybe 订阅提供了一个枚举（MaybeEvent）：
     .success：里包含该 Maybe 的一个元素值
     .completed：用于产生完成事件
     .error：用于产生一个错误
     
     */
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            
            //成功并发出一个元素
            maybe(.success("hangge.com"))
            
            //成功但不发出任何元素
            maybe(.completed)
            
            //失败
            //maybe(.error(StringError.failedGenerate))
            
            return Disposables.create {}
        }
    }
    
    func mybeTest() -> Void {
        generateString().subscribe(onSuccess: { (str) in
            print("执行完毕 str = ", str)
        }, onError: {print("error = ", $0)}, onCompleted: {print("执行完毕")}).disposed(by: disposeBag)
    }
    
    /**
     Driver
     1，基本介绍
     （1）Driver 可以说是最复杂的 trait，它的目标是提供一种简便的方式在 UI 层编写响应式代码。
     （2）如果我们的序列满足如下特征，就可以使用它：
     不会产生 error 事件
     一定在主线程监听（MainScheduler）
     共享状态变化（shareReplayLatestWhileConnected）
     
     
     2，为什么要使用 Driver?
     （1）Driver 最常使用的场景应该就是需要用序列来驱动应用程序的情况了，比如：
     通过 CoreData 模型驱动 UI
     使用一个 UI 元素值（绑定）来驱动另一个 UI 元素值
     （2）与普通的操作系统驱动程序一样，如果出现序列错误，应用程序将停止响应用户输入。
     （3）在主线程上观察到这些元素也是极其重要的，因为 UI 元素和应用程序逻辑通常不是线程安全的。
     （4）此外，使用构建 Driver 的可观察的序列，它是共享状态变化。
     
     */
    
    /**使用方法见首页*/
  
    
    /**
     ControlProperty
     （1）ControlProperty 是专门用来描述 UI 控件属性，拥有该类型的属性都是被观察者（Observable）。
     （2）ControlProperty 具有以下特征：
     不会产生 error 事件
     一定在 MainScheduler 订阅（主线程订阅）
     一定在 MainScheduler 监听（主线程监听）
     共享状态变化
     
     2，使用样例
     （1）其实在 RxCocoa 下许多 UI 控件属性都是被观察者（可观察序列）。比如我们查看源码（UITextField+Rx.swift），可以发现 UITextField 的 rx.text 属性类型便是 ControlProperty<String?>：
    */
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var textLabel: UILabel!
    
    func controlProperty() -> Void {
        //将textField输入的文字绑定到label上
        textField.rx.text.bind(to: textLabel.rx.text).disposed(by: disposeBag)
    }
    
    /**
     ControlEvent
     1，基本介绍
     （1）ControlEvent 是专门用于描述 UI 所产生的事件，拥有该类型的属性都是被观察者（Observable）。
     （2）ControlEvent 和 ControlProperty 一样，都具有以下特征：
     不会产生 error 事件
     一定在 MainScheduler 订阅（主线程订阅）
     一定在 MainScheduler 监听（主线程监听）
     共享状态变化
     
     2，使用样例
     （1）同样地，在 RxCocoa 下许多 UI 控件的事件方法都是被观察者（可观察序列）。比如我们查看源码（UIButton+Rx.swift），可以发现 UIButton 的 rx.tap 方法类型便是 ControlEvent<Void>：
     */
    
    @IBOutlet weak var button: UIButton!
    func controlEvent() -> Void {
        button
            .rx
            .tap
            .subscribe(onNext:{print("点击按钮事件")})
            .disposed(by: disposeBag)
        
    }
}

/**
 1，UIViewController+Rx.swift
 这里我们对 UIViewController 进行扩展：
 将 viewDidLoad、viewDidAppear、viewDidLayoutSubviews 等各种 ViewController 生命周期的方法转成 ControlEvent 方便在 RxSwift 项目中使用。
 增加 isVisible 序列属性，方便对视图的显示状态进行订阅。
 
 增加 isDismissing 序列属性，方便对视图的释放进行订阅。
 
 */

extension Reactive where Base: UIViewController {
    
    public var viewDidLoad : ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { (_)  in }
        return ControlEvent(events: source)
    }
    
    public var viewWillAppear: ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map{$0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }
    
    public var viewDidApper : ControlEvent<Bool> {
        
        let source = self.methodInvoked(#selector(Base.viewDidAppear(_:))).map{$0.first as? Bool ?? false}
        return ControlEvent(events: source)
        
    }
    
    public var viewWillDisapper : ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear(_:))).map{$0.first as? Bool ?? false}
        return ControlEvent(events: source)
        
    }
    
    public var viewDidDisapper : ControlEvent<Bool> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear(_:))).map{$0.first as? Bool ?? false}
        return ControlEvent(events: source)
        
    }
    
    //表示试图是否显示的可观察序列，当VC显示状态改变时会触发
    public var isVisible : Observable<Bool> {
        
        //viewDidApper 触发时 为可见，viewWillDisapper触发时 为不可见
        return Observable<Bool>.merge(self.base.rx.viewDidApper.map{_ in true}, self.base.rx.viewWillDisapper.map{_ in false})
    }
    
    ////表示页面被释放的可观察序列，当VC被dismiss时会触发
    public var isDismissing : ControlEvent<Bool> {
        let source = self.sentMessage(#selector(Base.dismiss(animated:completion:))).map{$0.first as? Bool ?? false}
        return ControlEvent(events: source)
    }
}
