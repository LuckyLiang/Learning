//
//  RXConditionViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 26/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RXConditionViewController: BaseViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        skipWhile()
        self.view.backgroundColor  =  .white
        // Do any additional setup after loading the view.
    }
    

    /***
     1，amb
     （1）基本介绍
     当传入多个 Observables 到 amb 操作符时，它将取第一个发出元素或产生事件的 Observable，然后只发出它的元素。并忽略掉其他的 Observables。
    */
    func ambTest() -> Void {
        
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
        let subject3 = PublishSubject<Int>()
        
        subject1
            .amb(subject2)
            .amb(subject3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(1)
        subject1.onNext(20)
        subject2.onNext(2)
        subject1.onNext(40)
        subject3.onNext(0)
        subject2.onNext(3)
        subject1.onNext(60)
        subject3.onNext(0)
        subject3.onNext(0)
    }
    
    /**
     2，takeWhile
     （1）基本介绍
     该方法依次判断 Observable 序列的每一个值是否满足给定的条件。 当第一个不满足条件的值出现时，它便自动完成。
     */
    func takeWhile() -> Void {
        Observable.of(2, 3, 4, 5, 6)
            .takeWhile { $0 < 4 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     3，takeUntil
     （1）基本介绍
     除了订阅源 Observable 外，通过 takeUntil 方法我们还可以监视另外一个 Observable， 即 notifier。
     如果 notifier 发出值或 complete 通知，那么源 Observable 便自动完成，停止发送事件。
     */
    func takeUntil() -> Void {
        let source = PublishSubject<String>()
        let notifier = PublishSubject<String>()
        source.takeUntil(notifier).subscribe(onNext:{print($0)}).disposed(by: disposeBag)
        
        source.onNext("a")
        source.onNext("b")
        
        source.onNext("c")
        
        notifier.onNext("z")
        
        source.onNext("e")
        source.onNext("f")
        
        source.onNext("g")
        
    }
    
    /**
     4，skipWhile
     （1）基本介绍
     该方法用于跳过前面所有满足条件的事件。
     一旦遇到不满足条件的事件，之后就不会再跳过了
    */
    func skipWhile() -> Void {
        Observable.of(2, 3, 4, 5, 6, 3, 2, 1)
            .skipWhile { $0 < 4 } //将跳过前面小于4的数
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        //456321
    }
    
}

