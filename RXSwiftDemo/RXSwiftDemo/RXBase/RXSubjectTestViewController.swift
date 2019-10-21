//
//  RXSubjectTestViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 22/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class RXSubjectTestViewController: BaseViewController {

     let disponseBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        behaviorReplayTest()
    }
    /**
     1. AsyncSubject 在源Observable 产生完成事件后，发出最后一个元素（仅仅是最后一个元素）
     如果远Observble没有发出任何元素，只有一个完成事件，那么AsyncSubject就只有一个完成事件
     如果因为一个错误而终止，那么就不会发出任何元素，而是将这个error事件发送出来
     */

    func testAsyncSubject() -> Void {
        
        let disponseBag = DisposeBag()
        let subject = AsyncSubject<String>()

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
        
        /**
         Subscriptition 1 Event : 🐰
         发送完成
         */
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
    
    /**
     BehaviorRelay 是作为 Variable 的替代者出现的。它的本质其实也是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
     BehaviorRelay 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
     与 BehaviorSubject 不同的是，不需要也不能手动给 BehaviorReply 发送 completed 或者 error 事件来结束它（BehaviorRelay 会在销毁时也不会自动发送 .complete 的 event）。
     BehaviorRelay 有一个 value 属性，我们通过这个属性可以获取最新值。而通过它的 accept() 方法可以对值进行修改。

     */
    func behaviorReplayTest() -> Void {
        
        //创建一个初始值为111的BehaviorRelay
        let subject = BehaviorRelay<String>(value: "111")
        
        //修改value值
        subject.accept("222")
        
        //第1次订阅
        subject.asObservable().subscribe {
            print("第1次订阅：", $0)
            }.disposed(by: disponseBag)
        
        //修改value值
        subject.accept("333")//实际调用的就是 behaviorSubject 的onNext方法
        
        //第2次订阅
        subject.asObservable().subscribe {
            print("第2次订阅：", $0)
            }.disposed(by: disponseBag)
        
        //修改value值
        subject.accept("444")
    }

    /**
     （3）如果想将新值合并到原值上，可以通过 accept() 方法与 value 属性配合来实现。（这个常用在表格上拉加载功能上，BehaviorRelay 用来保存所有加载到的数据）
     
     */
    func behaviorReplayTest2() -> Void {
        //创建一个初始值为包含一个元素的数组的BehaviorRelay
        let subject = BehaviorRelay<[String]>(value: ["1"])
        
        //修改value值
        subject.accept(subject.value + ["2", "3"])
        
        //第1次订阅
        subject.asObservable().subscribe {
            print("第1次订阅：", $0)
            }.disposed(by: disponseBag)
        
        //修改value值
        subject.accept(subject.value + ["4", "5"])
        
        //第2次订阅
        subject.asObservable().subscribe {
            print("第2次订阅：", $0)
            }.disposed(by: disponseBag)
        
        //修改value值
        subject.accept(subject.value + ["6", "7"])
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
