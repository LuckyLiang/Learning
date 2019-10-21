//
//  RXFilterViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 25/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXFilterViewController: BaseViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        sampleTest()
    }
    /**
     1，filter
     （1）基本介绍
     该操作符就是用来过滤掉某些不符合要求的事件。
     （2）使用样例
     */
    func filtest() -> Void {
        
        Observable
            .of(2, 30, 22, 5, 60, 3, 40, 9)
            .filter { (num) -> Bool in
            return num > 10
            }
            .subscribe(onNext: {print($0)})
            .disposed(by: disposeBag)
        
    }
    
    /**
     2，distinctUntilChanged
     （1）基本介绍
     该操作符用于过滤掉连续重复的事件。
     */
    
    func distinctUntilChanged() -> Void {
        Observable
            .of(1, 2, 3, 1, 1, 4)
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     3，single
     （1）基本介绍
     限制只发送一次事件，或者满足条件的第一个事件。
     如果存在有多个事件或者没有事件都会发出一个 error 事件。
     如果只有一个事件，则不会发出 error 事件。
     */
    func singleTest() -> Void {
        
        Observable
            .of(1, 2, 3, 4)
            .single{ $0 == 2 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        Observable
            .of("A", "B", "C", "D")
            .single()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     4，elementAt
     基本介绍
     该方法实现只处理在指定位置的事件。
     */
    func elementAt() -> Void {
        
        Observable
            .of(1, 2, 3, 4)
            .elementAt(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }

    /**
     5，ignoreElements
     基本介绍
     该操作符可以忽略掉所有的元素，只发出 error 或 completed 事件。
     如果我们并不关心 Observable 的任何元素，只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符。
     */
    func ignoreElemnetsTest() -> Void {
        Observable
            .of(1, 2, 3, 4)
            .ignoreElements()
            .subscribe{
                print($0)
            }
            .disposed(by: disposeBag)
    }
    
    /**
     6 take
     基本介绍
     该方法实现仅发送 Observable 序列中的前 n 个事件，在满足数量之后会自动 .completed。
     */
    func takeTest() -> Void {
        Observable
            .of(1, 2, 3, 4)
            .take(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     7 takeLast
     基本介绍
     该方法实现仅发送 Observable 序列中的后 n 个事件。
     */
    
    func takeLastTest() -> Void {
        Observable
            .of(1, 2, 3, 4)
            .takeLast(1)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    
    /**
     8 skip
     基本介绍
     该方法用于跳过源 Observable 序列发出的前 n 个事件。
     */
    func skipTest() -> Void {
        
        Observable
            .of(1, 2, 3, 4)
            .skip(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
    }
    
    /**
     9 Sample
     基本介绍
     Sample 除了订阅源 Observable 外，还可以监视另外一个 Observable， 即 notifier 。
     每当收到 notifier 事件，就会从源序列取一个最新的事件并发送。而如果两次 notifier 事件之间没有源序列的事件，则不发送值。
     */
    
    func sampleTest() -> Void {
        
        let source = PublishSubject<Int>()
        let notifier = PublishSubject<String>()
        
        source
            .sample(notifier)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        source.onNext(1)
        
        //让源序列接收接收消息
        notifier.onNext("A")
        
        source.onNext(2)
        
        //让源序列接收接收消息
        notifier.onNext("B")
        notifier.onNext("C")
        
        source.onNext(3)
        source.onNext(4)
        
        //让源序列接收接收消息
        notifier.onNext("D")
        
        source.onNext(5)
        
        //让源序列接收接收消息
        notifier.onCompleted()
    }
    
}
