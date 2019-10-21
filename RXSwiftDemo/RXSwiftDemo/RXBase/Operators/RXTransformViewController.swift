//
//  RXTransformViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 23/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RXTransformViewController: BaseViewController {

    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        groupByTest()
    }
    
    // 变换操作指的是对原始的 Observable 序列进行一些转换，类似于 Swift 中 CollectionType 的各种转换。
 
    /**
     1. map
     map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
     */
    func mapTest() -> Void {
        Observable.of(1, 2, 3).map{$0 * 10}.subscribe(onNext:{print($0)}).disposed(by: disposeBag)
    }
    
    /**
     2.flatMap
     将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并
     */
    
    func flatMapTest() -> Void {
        let disposeBag = DisposeBag()
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let variable = BehaviorRelay(value: first)
        
        variable.asObservable()
            .flatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("🐱")
        variable.accept(second)
        second.onNext("🅱️")
        first.onNext("🐶")
        
        /**
         👦🏻
         🐱
         🅰️
         🅱️
         🐶

         */
    }
    
    /**
     3.flatMapLatest
     将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个
     
     flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
     */
    
    func flatMapLatestTest() -> Void {
        let disposeBag = DisposeBag()
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        
        let variable = BehaviorRelay(value: first)
        
        variable.asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("🐱")
        variable.accept(second)
        
        second.onNext("🅱️")
        first.onNext("🐶")

    }
    
    /**
     4，flatMapFirst
     （1）基本介绍
     flatMapFirst 与 flatMapLatest 正好相反：flatMapFirst 只会接收最初的 value 事件。
     该操作符可以防止重复请求：
     比如点击一个按钮发送一个请求，当该请求完成前，该按钮点击都不应该继续发送请求。便可该使用 flatMapFirst 操作符。
     */
    func flatMapFirst() -> Void {
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        
        let variable = BehaviorRelay(value: subject1)
        
        variable.asObservable()
            .flatMapFirst { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("B")
        variable.accept(subject2)
        subject2.onNext("2")
        subject1.onNext("C")
    }
    
    /**
     5，buffer
     （1）基本介绍
     buffer 方法作用是缓冲组合，第一个参数是缓冲时间，第二个参数是缓冲个数，第三个参数是线程。
     该方法简单来说就是缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
     */
    func buffer() -> Void {
        let subject = PublishSubject<String>()
        
        
        //每缓存3个元素则组合起来一起发出。
        //如果1秒钟内不够3个也会发出（有几个发几个，一个都没有发空数组 []
        subject.buffer(timeSpan: DispatchTimeInterval.seconds(1), count: 3, scheduler: MainScheduler.instance).subscribe(onNext:{print($0)}).disposed(by: disposeBag)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
    }
    
    /**
     6，window
     （1）基本介绍
     window 操作符和 buffer 十分相似。不过 buffer 是周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
     同时 buffer 要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。
    */
    
    func windowTest() -> Void {
        let subject = PublishSubject<String>()
        subject
            .window(timeSpan: DispatchTimeInterval.seconds(1), count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](observable) in
                
                print("subscrible : \(observable)")
                observable.asObservable()
                    .subscribe(onNext: {print($0)})
                    .disposed(by: self!.disposeBag);
                
        }).disposed(by: disposeBag)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
    }
    
    /**
     7，concatMap
     （1）基本介绍
     concatMap 与 flatMap 的唯一区别是：当前一个 Observable 元素发送完毕后，后一个Observable 才可以开始发出元素。或者说等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
     */
    func concatMap() -> Void {
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
        
        let variable = BehaviorRelay(value: subject1)
        
        variable.asObservable()
            .concatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject1.onNext("B")
        variable.accept(subject2)
        subject2.onNext("2")
        subject1.onNext("C")
        subject1.onCompleted() //只有前一个序列结束后，才能接收下一个序列
    }
    
    /**
     8，scan
     （1）基本介绍
     scan 就是先给一个初始化的数，然后不断的拿前一个结果和最新的值进行处理操作。
     */
    
    func scanTest() -> Void {
        Observable.of(1, 2, 3, 4, 5)
            .scan(0) { acum, elem in
                acum + elem
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     9，groupBy
     （1）基本介绍
     groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
     也就是说该操作符会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
     */
    
    func groupByTest() -> Void {
        Observable<Int>.of(0,1,2,3,4,5).groupBy { (element) -> String in
            
            return element % 2 == 0 ? "偶数" : "基数"
            
            }
            .subscribe(onNext: { [weak self] (groupObservable) in
                
                groupObservable.subscribe(onNext: { (num) in
                    
                    print("groupObservable key: \(groupObservable.key)  num : \(num)")
                    
                }).disposed(by: self!.disposeBag)
                
            }).disposed(by: disposeBag)
    }
}

