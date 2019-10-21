//
//  RXSwiftCoreViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 15/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class RXSwiftCoreViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "swift 核心";
        binderTest()
        // Do any additional setup after loading the view.
    }
    
    
/**************************************** observable 可监听序列 ******************************************/
    //1. observable 可监听序列
    let disponseBag = DisposeBag.init()
    
    //1.1
    func jsonCommont() -> Void {
        typealias JSON = Any
        let json : Observable<JSON> = Observable.create { (observer) -> Disposable in
            
            let task = URLSession.shared.dataTask(with: URL.init(string: "http://www.baidu.com")!){ data,_, error in
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                
                guard let data = data, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
                    print("数据解析失败")
                    return
                }
                
                observer.onNext(jsonObject)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create { //如果数据绑定被清除，或者订阅被取消的话，就执行闭包里面的 取消请求任务
                task.cancel()
            }
        }
        
        
        //订阅
        json.subscribe(onNext: { (jsonObject) in
            
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: nil).disposed(by: disponseBag)
        
        
        
    }
    
    
    
    /// 1.2 Single 只能发出一个元素，要么成功，要么产生一个error事件, 例如网络请求返回成功和失败的数据
    /// 1. 发出一个元素，或者一个error事件
    /// 2. 不会共享附加作用
    func getRepo(_ repo: String) -> Single<[String : Any]> {
        
        return Single<[String :Any]>.create(subscribe: { (single) -> Disposable in
            let url = URL(string: "https://api.github.com/repos/\(repo)")!
            let task = URLSession.shared.dataTask(with: url){data,_,error in
                if let error = error {
                    single(.error(error))
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                    let result = json as? [String : Any] else {
                    print("data error")
//                    single(.error(dataError))
                    return;
                }
                
                single(.success(result))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        })
        
    }
    
    func testGetRepo() -> Void {
        getRepo("ReactiveX/RxSwift").subscribe(onSuccess: { (result) in
            print("result: ",result)
        }) { (error) in
            print("error: ",error)
        }.disposed(by: disponseBag)
    }
    
    /// 2. Completable
    /// 要么只能产生一个 completed 事件，要么产生一个 error 事件。适用于只关心任务是否完成，而不需要在意任务返回值的情况，他和Observer<Void>有点相似
    /// 发出零个元素
    /// 发出一个 completed 事件或者一个 error 事件
    /// 不会共享附加作用
    
    private func _cacheLocally(num : Int) -> Completable {
        return Completable.create(subscribe: { (completable) -> Disposable in
           
            var success = true
            let error : NSError = NSError.init(domain: "任务出现错误", code: 1, userInfo: nil)
            if (num > 10) {
                success = false
            }
            guard success else {
                completable(.error(error))
                return Disposables.create {}
            }
            completable(.completed)
            return Disposables.create {
                
            }
        })
    }
    
    func completableTest() -> Void {
        _cacheLocally(num: 20).subscribe(onCompleted: {
            print("Completed with no error")
        }) { (error) in
            print("error :" , error)
        }.disposed(by: disponseBag)
    }
    
    //3. Maybe
    // 它介于 Single 和 Completable 之间，它要么只能发出一个元素，要么产生一个 completed 事件，要么产生一个 error 事件。
    // 发出一个元素 或者 一个completed事件 或者 一个 error 事件
    // 不会共享附加作用
    
    func generateString(num : Int) -> Maybe<String> {
        return Maybe<String>.create(subscribe: { (maybe) -> Disposable in
            
            maybe(.success("RXSwift"))
            
            //
            guard num <= 10 else {
                let error : NSError = NSError.init(domain: "输入数字错误，请输入x不大于10的数", code: 1, userInfo: nil)
                maybe(.error(error))
                return Disposables.create {
                    
                }
            }
            
            maybe(.completed)
            
            return Disposables.create {
                
            }
        })
    }
    
    func maybeTest() -> Void {
        generateString(num: 8).subscribe(onSuccess: { (str) in
            print("string : ", str)
        }, onError: { (error) in
            print("error: ",error)
        }) {
            print("任务完成")
        }.disposed(by: disponseBag)
    }
    
    
    /**
     4. Driver
     不会产生error事件， 一定在MainScheduler 监听
     这些都是驱动UI的序列
     */
    @IBOutlet weak var query: UITextField!
    
    func dirverTest() -> Void {
     
     
    }

    
    @IBOutlet weak var textfield: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSize: UILabel!
    
    func signalTest() -> Void {
        
        let state : Driver<String?> = textfield.rx.text.asDriver()
        
        let observer = nameLabel.rx.text
        
        state.drive(observer).disposed(by: disponseBag)
        
        let newObserver = nameSize.rx.text
        
        state.map { $0?.count.description }.drive(newObserver).disposed(by: disponseBag)
        
        
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        
    }
    
    
    
    /**************************************** Observable & Observer 监听序列也是观察者 ***********************************************/
    
    /**
     1. AsyncSubject 在源Observable 产生完成事件后，发出最后一个元素（仅仅是最后一个元素）
     如果远Observble没有发出任何元素，只有一个完成事件，那么AsyncSubject就只有一个完成事件
     如果因为一个错误而终止，那么就不会发出任何元素，而是将这个error事件发送出来
     */
    
    
    func testAsyncSubject() -> Void {
        
        let disponseBag = DisposeBag()
        let subject = AsyncSubject<String>()
//        subject.subscribe{print("Subscriptition 1 Event :", $0)}.disposed(by: disponseBag)
        subject.subscribe(onNext: { (str) in
            print("Subscriptition 1 Event :", str)
        }, onError: { (error) in
            print("error = ", error)
        }, onCompleted: {
            print("发送完成")
        }, onDisposed: nil).disposed(by: disponseBag)
        
        subject.onNext("🐱")
        subject.onNext("🐶")
        subject.onNext("🐰")
        subject.onCompleted()
        
    }
    
    /**
     2. PublishSubject 将对观察者发送订阅后产生的元素，而在订阅前发送的元素将不会发送给观察者，
     如果你希望观擦着接收到所有的元素，你可通过使用Observable的creat方法来创建Observable,或者使用ReplaySubject
     如果源 Observable 因为产生了一个 error 事件而中止， PublishSubject 就不会发出任何元素，而是将这个 error 事件发送出来。
    
     */
    func testPublishSubject() -> Void {
        
        let subject = PublishSubject<String>()
        
        subject.subscribe(onNext: { (str) in
            print("Subscription 1 : ", str)
        }, onError: { (error) in
            print("error 1 : ",error)
        }, onCompleted: {
            print("完成 1 ")
        }, onDisposed: nil).disposed(by: disponseBag)
        
        
        subject.onNext("🐱")
        subject.onNext("🐶")
        subject.onNext("🐷")
        
        subject.subscribe(onNext: { (str) in
            print("Subscription 2 : ", str)
        }, onError: { (error) in
            print("error 2 : ",error)
        }, onCompleted: {
            print("完成 2")
        }, onDisposed: nil).disposed(by: disponseBag)
        
        subject.onNext("❤️")
        subject.onNext("👌")
        subject.onNext("🦢")
    }
    
    /**
     ReplaySubject 将对观察者发送全部的元素，无论观察者是何时进行订阅的。
     有的只会将最新的 n 个元素发送给观察者，有的只会将限制时间段内最新的元素发送给观察者。
     
     如果把 ReplaySubject 当作观察者来使用，注意不要在多个线程调用 onNext, onError 或 onCompleted。这样会导致无序调用，将造成意想不到的结果。

     */
    func replaySubject() -> Void {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        
        subject.subscribe{print("Subscription: 1 Event", $0)}.disposed(by: disponseBag)
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject.subscribe{print("Subscription: 2 Event", $0)}.disposed(by: disponseBag)
        subject.onNext("🅰️")
        subject.onNext("🅱️")

    }
    
    /**
     当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来。
     */
    func behaviorSubjectTest() -> Void {
        let disposeBag = DisposeBag()
        let subject = BehaviorSubject(value: "🔴")
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        
        subject
            .subscribe { print("Subscription: 3 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🍐")
        subject.onNext("🍊")
    }
    
    /*****************************************Operatior 操作符************************************/
    
    
    
    
    
    /*****************************************连接，合并 操作符************************************/

    /**
     combineLatest: 将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
     
     */
    func combinLatest() -> Void {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        Observable.combineLatest(first, second) { $0 + $1}.subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        first.onNext("1")
        second.onNext("A")
        first.onNext("2")
        second.onNext("B")
        second.onNext("C")
        second.onNext("D")
        first.onNext("3")
        first.onNext("4")
    }
    
    /**
     zip 操作符将多个(最多不超过8个) Observables 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。例如，返回的 Observable 的第一个元素，是由每一个源 Observables 的第一个元素组合出来的。它的第二个元素 ，是由每一个源 Observables 的第二个元素组合出来的。它的第三个元素 ，是由每一个源 Observables 的第三个元素组合出来的，以此类推。它的元素数量等于源 Observables 中元素数量最少的那个。
     */
    func zipTest() -> Void {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        Observable.zip(first, second) {$0 + $1}.subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        first.onNext("1")
        second.onNext("A")
        first.onNext("2")
        second.onNext("B")
        second.onNext("C")
        second.onNext("D")
        first.onNext("3")
        first.onNext("4")
    }
    
    /**
     让两个或多个 Observables 按顺序串连起来
     concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
     
     concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
     
     startWith 和它十分相似。但是startWith不是在后面添加元素，而是在前面插入元素。
     
     merge 和它也是十分相似。merge并不是将多个 Observables 按顺序串联起来，而是将他们合并到一起，不需要 Observables 按先后顺序发出元素。
     */
    
    func concatTest() -> Void {
        let subject1 = BehaviorSubject<String>(value: "🐶")
        let subject2 = BehaviorSubject<String>(value: "🍎")
    
        subject1.concat(subject2).subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        
        subject1.onNext("🍐")
        subject1.onNext("🍎")
        subject2.onNext("I would be ignored")
        subject2.onNext("🐱")
        
        subject1.onCompleted() //当subject1 发送完成后才会发送subject2 ,由于BehaviorSubject只会最新的值，没有最新的值就发出默认值
        
        subject2.onNext("🐭")
    }
    
    /**
     startWith 操作符会在 Observable 头部插入一些元素。
     */
    func startWithTest() -> Void {
        let subject1 = BehaviorSubject<String>(value: "🐶")
        subject1.startWith("🐒","🐷")
            .startWith("🐂")
            .subscribe(onNext: {print($0)})
            .disposed(by: disponseBag)
        
        subject1.onNext("🍐")
        subject1.onNext("🐱")
    }
    
    /**
     将多个 Observables 合并成一个
     
     通过使用 merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。
     如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。

     */
    func mergeTest() -> Void {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        Observable.of(subject1,subject2).merge().subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        subject1.onNext("🅰️")
        
        subject1.onNext("🅱️")
        
        subject2.onNext("①")
        
        subject2.onNext("②")
        
        subject1.onNext("🆎")
        
        subject2.onNext("③")
        
        
    }
    
    /**************************转换操作符***************************/
    
    
    /**
     通过一个转换函数，将 Observable 的每个元素转换一遍
     map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
     
     */
    
    func mapTest() -> Void {
        Observable.of(1,2,3,4,5).map{$0 * 10}.subscribe { print($0) }.disposed(by: disponseBag)
        
    }
    /***
     flatMap : 将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并
     
     flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。 然后将这些 Observables 的元素合并之后再发送出来。
     
     这个操作符是非常有用的，例如，当 Observable 的元素本身拥有其他的 Observable 时，你可以将所有子 Observables 的元素发送出来。
     */
    func flatMapTest() -> Void {
        
        //写法1
//        transformUsingFlatMap().subscribe(onNext:{print($0)}).disposed(by: disponseBag)
        
        //写法2
//        let subject = PublishSubject<Int>()
//        subject.flatMap { (number) -> Observable<String> in
//            return Observable.just("Number2 : \(number)")
//        }.subscribe(onNext: {print($0)}).disposed(by: disponseBag)
//
//        subject.onNext(1)
//        subject.onNext(2)
//        subject.onCompleted()
        
        //写法3
        Observable.of(1,2,3,4)
            .flatMap {
                number -> Observable<String> in
                return Observable.just("Number3: \(number)")
            }
            .subscribe(onNext: {print($0)})
            .disposed(by: disponseBag)
    }
    
    
    func transformUsingFlatMap() -> Observable<String> {
        return Observable.of(1, 2, 3).flatMap(generateTransformation)
    }
    
    func generateTransformation(int: Int) -> Observable<String> {
        return Observable.just("Number : \(int)")
    }
    
    /**
     flatMapLatest
     将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个
     */
    func flatMapLatestTest() -> Void {
//        Observable.of(1,2,3,4)
//            .flatMapLatest { (number) -> Observable<String> in
//            return Observable.just("Number : \(number)")
//        }.subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        
        let first = BehaviorSubject.init(value: "🐱")
        first.flatMapLatest { (str) -> Observable<String> in
            return Observable.just(str + "猪")
        }.subscribe(onNext: {print($0)}, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disponseBag)
        
        first.onNext("1")
        first.onNext("2")
        
    }
    
    
    /**
     concatMap 将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 串连起来
     
     concatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
     */
    func concatMapTest() -> Void {
        let subject1 = BehaviorSubject<String>(value: "🐶")
        let subject2 = BehaviorSubject<String>(value: "🐱")
        subject1.concatMap { value in
            //            return BehaviorSubject<String>(value: value + " hhh").map{$0 + " hhhh"}
            return subject2.map({ (value2) -> String in
                return value2 + value
            })
            }.subscribe(onNext: {print($0)}).disposed(by: disponseBag)

//        subject1.concatMap { value in
////            return BehaviorSubject<String>(value: value + " hhh").map{$0 + " hhhh"}
//            return subject2
//        }.subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        
        subject1.onNext("1")
        subject1.onNext("2")
        subject1.onCompleted()
        
        subject2.onNext("a ")
        subject2.onNext("b ")
        
        subject2.onCompleted()
        
        
    }
    /************************** 创建常用 操作符***************************/

    func justTest() -> Void {
        let array = ["wangxiaoer", "xiaohone"]
        Observable<[String]>.just(array).subscribe(onNext: {print($0)}).disposed(by: disponseBag)
        
    
    }
    
    
    func filterTest() -> Void {
  
    
    }
    
    
    /*********** 场景序列   ***************/

    @IBOutlet weak var _redLabel: UILabel!

    @IBOutlet weak var _showLabelBtn: UIButton!

    private var isHidden = false
    
    func binderTest() -> Void {
        
       
        let binder = Binder<Bool>(_redLabel){(label, isHidden) in
            label.isHidden = isHidden
        }
        let observable = Observable<Bool>.create { (observer) -> Disposable in
            
            observer.onNext(true)
            
            return Disposables.create()
        }
        
        observable.bind(to: binder).disposed(by: disponseBag)
        
    }
    
    /************************** 源码分析 ***************************/
    
    //1.创建序列
    
    func observableCreatCoreTest() -> Void {
        
        //1. creat 创建序列
        Observable<String>.create { (observer) -> Disposable in
            
            //3. 发送信号
            observer.onNext("RXSwift")
            
            return Disposables.create()
            
            //2. 订阅序列
            }.subscribe(onNext: { (text) in
                print("订阅到: \(text)")
            }).disposed(by: disponseBag)
    }
}


