//
//  RXConnectableViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 26/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXConnectableViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareRelay()
    }
    
    /**
     2，publish
     （1）基本介绍
     publish 方法会将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
     */
    func publich() -> Void {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .publish()
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    
    /**
     3，replay
     （1）基本介绍
     replay 同上面的 publish 方法相同之处在于：会将将一个正常的序列转换成一个可连接的序列。同时该序列不会立刻发送事件，只有在调用 connect 之后才会开始。
     replay 与 publish 不同在于：新的订阅者还能接收到订阅之前的事件消息（数量由设置的 bufferSize 决定）。
    */
    func replay() -> Void {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .replay(5)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval
            .subscribe(onNext: { print("订阅1: \($0)") })
        
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
    }
    
    /**
     4，multicast
     （1）基本介绍
     multicast 方法同样是将一个正常的序列转换成一个可连接的序列。
     同时 multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送。
    */
    
    func multicast() -> Void {
        //每隔1秒钟发送1个事件
        let subject = PublishSubject<Int>()

        
        //这个Subject的订阅
        _ = subject.subscribe(onNext: { print("Subject: \($0)") })
        
        let interval = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).multicast(subject)
        
        //第一个订阅者（立刻开始订阅）
        _ = interval.subscribe(onNext:{print("订阅1:\($0)")})
        
        
        //相当于把事件消息推迟了两秒
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            _ = interval.connect()
        }
        
        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
        }
        
        
    }
    
    /**
     5，refCount
     （1）基本介绍
     refCount 操作符可以将可被连接的 Observable 转换为普通 Observable
     即该操作符可以自动连接和断开可连接的 Observable。当第一个观察者对可连接的 Observable 订阅时，那么底层的 Observable 将被自动连接。当最后一个观察者离开时，那么底层的 Observable 将被自动断开连接。
     */
    
    func refCountTest() -> Void {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).publish().refCount()

        //第一个订阅者（立刻开始订阅）
        _ = interval.subscribe(onNext: { print("订阅1: \($0)") })


        //第二个订阅者（延迟5秒开始订阅）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            _ = interval
                .subscribe(onNext: { print("订阅2: \($0)") })
            }
    }

    /**
     6，share(relay:)
     该操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
     简单来说 shareReplay 就是 replay 和 refCount 的组合。
     */
    func shareRelay() -> Void {
        //每隔1秒钟发送1个事件
        let interval = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance).share(replay: 5)
        //第一个订阅者
        interval.subscribe(onNext:{print("订阅：\($0)")}).disposed(by: disposeBag)
        
        
        //第二个订阅者
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) { [weak self] in
            interval.subscribe(onNext:{ print("订阅2: \($0)") }).disposed(by: self?.disposeBag ?? DisposeBag())
        }
        
    }
    
    
}
