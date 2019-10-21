//
//  RXCreatTestViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 21/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RXCreatTestViewController: BaseViewController {

     let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RX创建方式"
        self.view.backgroundColor = .white
        self.timerTest()
        // Do any additional setup after loading the view.
    }
    
    /**
    1. 创建序列的最基本的方法
     */
    func creatTest() -> Void {
        let observable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("1111")
            observer.onCompleted()
            return Disposables.create {
                
            }
        }
        observable.subscribe(onNext: { num in
            print(num)
        }, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
        
    }
    
    //2. 利用just方式创建序列
    // 创建 Observable 发出唯一的一个元素
    // 操作符将某一个元素转换为 Observable
    private func justTest() -> Void {
        let observerabl = Observable<Int>.just(5)
        observerabl.subscribe(onNext: { num in
            print(num)
        }, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    /**
     3，of() 方法
     （1）该方法可以接受可变数量的参数（必需要是同类型的）
     （2）下面样例中我没有显式地声明出 Observable 的泛型类型，Swift 也会自动推断类型。
     */
    func ofTest() -> Void {
        let observerable = Observable.of("1","2","3")
        observerable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    /**
     4，from() 方法
     （1）该方法需要一个数组参数。
     （2）下面样例中数据里的元素就会被当做这个 Observable 所发出 event 携带的数据内容，最终效果同上面饿 of() 样例是一样的。
    */
    func formTest() -> Void {
        let observerable = Observable.from([1,2,3,4]);
        observerable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
//    5，empty() 方法
//    该方法创建一个空内容的 Observable 序列, 只发送一个完成事件
    func empty() -> Void {
        let observerable = Observable<Int>.empty()
        observerable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
        
    }
    
    /**
     6，never() 方法
     该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列。
     */
    func neverTest() -> Void {
        let observerable = Observable<Int>.never()
        observerable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    /**
     7，error() 方法
     该方法创建一个不做任何操作，而是直接发送一个错误的 Observable 序列。
     */
    func errorTest() -> Void {
        enum netError : Error {
            case A(_ str: String)
            case B
        }
        
        let error = netError.A("网络请求出错")
        let observerable = Observable<Int>.error(error)
        observerable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    /**
     8，range() 方法
     （1）该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的 Observable 序列。
     （2）下面样例中，两种方法创建的 Observable 序列都是一样的。
     */
    
    func rangeTest() -> Void {
  
        //使用range()
        let observable = Observable.range(start: 1, count: 5)
        observable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)

        //使用of()
//        let observable = Observable.of(1, 2, 3 ,4 ,5)
    }
    
    /**
     9，repeatElement() 方法
     该方法创建一个可以无限发出给定元素的 Event 的 Observable 序列（永不终止）。
     */
    func repeatElemenTest() -> Void {
       Observable.repeatElement(1).subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    /**
     10，generate() 方法
     （1）该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列。
     （2）下面样例中，两种方法创建的 Observable 序列都是一样的。
 
     */
    
    func generateTest() -> Void {
         Observable
            .generate(initialState: 0,
                      condition: { $0 < 10},
                      iterate: {$0 + 2})
            .subscribe(onNext: {print($0)},
                       onError: {print($0)},
                       onCompleted: {print("订阅完成")},
                       onDisposed: {print("已销毁")})
            .disposed(by: disposeBag)
        //使用of()方法
//        let observable = Observable.of(0 , 2 ,4 ,6 ,8 ,10)
    }
    
    /**
     11，deferred() 方法
     （1）直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable
     deferred 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。
     
     */
    
    func deferredTest() -> Void {
        var isOdd = true
        
        let observable = Observable<Int>.deferred { () -> Observable<Int> in
            isOdd = !isOdd //每次订阅取反
            return isOdd ? Observable.of(2 ,4, 6, 8, 10) : Observable.of(1,3,5,7,9)
        }
        
        observable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
        observable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
        observable.subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)

    }
    
    /**
     12，interval() 方法
     （1）这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去。
     （2）下面方法让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送。
     ///   _ dueTime: RxTimeInterval,  // 初始延时
     ///   period: RxTimeInterval?,    // 时间间隔
     */
    func interval() -> Void {
        Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    /**
     13，timer() 方法
     （1）这个方法有两种用法，一种是创建的 Observable 序列在经过设定的一段时间后，产生唯一的一个元素。
     ///   _ dueTime: RxTimeInterval,  // 初始延时
     ///   period: RxTimeInterval?,    // 时间间隔
     */

    func timerTest() -> Void {

        Observable<Int>.timer(1, period : 2, scheduler: MainScheduler.instance).subscribe(onNext: {print($0)}, onError: {print($0)}, onCompleted: {print("订阅完成")}, onDisposed: {print("已销毁")}).disposed(by: disposeBag)
    }
    
    
}
