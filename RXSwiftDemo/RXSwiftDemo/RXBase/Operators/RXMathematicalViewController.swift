//
//  RXMathematicalViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 26/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class RXMathematicalViewController: BaseViewController {

    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        toArray()
    }
    
    /**
     1，toArray
     （1）基本介绍
     该操作符先把一个序列转成一个数组，并作为一个单一的事件发送，然后结束。
     */
    func toArray() -> Void {
        Observable.of(1, 2, 3)
            .toArray().subscribe(onSuccess: { (num) in
                print(num)
            }) { (error) in
                print(error)
        }.disposed(by: disposeBag)
    }
    
    /**
     2，reduce
     （1）基本介绍
     reduce 接受一个初始值，和一个操作符号。
     reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去。
    */
    func reduce() -> Void {
        Observable.of(1, 2, 3, 4, 5)
            .reduce(0, accumulator: +)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
    /**
     3，concat
     （1）基本介绍
     concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
     并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个 Observable 序列事件。
     */
    
    func concat() -> Void {
        let subject1 = BehaviorSubject(value: 1)
        let subject2 = BehaviorSubject(value: 2)
        
        let variable = BehaviorRelay(value:subject1)
        variable.asObservable()
            .concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        subject2.onNext(2)
        subject1.onNext(1)
        subject1.onNext(1)
        subject1.onCompleted()
        
        variable.accept(subject2)
        subject2.onNext(2)
    }

}
