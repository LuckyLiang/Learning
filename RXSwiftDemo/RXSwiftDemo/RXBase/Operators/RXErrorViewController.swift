//
//  RXErrorViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 27/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case A
    case B
}

/**错误处理操作符可以用来帮助我们对 Observable 发出的 error 事件做出响应，或者从错误中恢复。*/

class RXErrorViewController: BaseViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        retry()
        // Do any additional setup after loading the view.
    }
    

    /*
    
     1，catchErrorJustReturn
     （1）基本介绍
     当遇到 error 事件的时候，就返回指定的值，然后结束。
    */
    
    func catchErrorJustReturn() -> Void {
        let sequenceThatFails = PublishSubject<String>()
        
        sequenceThatFails
            .catchErrorJustReturn("错误")
            .subscribe(onNext:{print($0)})
            .disposed(by: disposeBag)
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")
    }

    /**
     2，catchError
     （1）基本介绍
     该方法可以捕获 error，并对其进行处理。
     同时还能返回另一个 Observable 序列进行订阅（切换到新的序列）。
     */
    
    func catchError() -> Void {
        let recoverySequence = Observable.of("1", "2", "3")
        let sequenceThatFails = PublishSubject<String>()

        sequenceThatFails.catchError { (error) -> Observable<String> in
            print("error = \(error)")
            return recoverySequence
            }.subscribe(onNext:{print($0)}).disposed(by: disposeBag)
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")
    }
    
    /**
     3，retry
     （1）基本介绍
     使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
     retry() 方法可以传入数字表示重试次数。不传的话只会重试一次。
    */
    func retry() -> Void {
        var count = 1
        
        Observable<String>
            .create { (observer) -> Disposable in
            observer.onNext("a")
            observer.onNext("b")
            
            //让第一个订阅时发生错误
            if (count == 1) {
                observer.onError(MyError.A)
                count += 1
            }
            observer.onNext("c")
            observer.onNext("d")
            observer.onCompleted()
            return Disposables.create()
            
            
            }
            .retry(2) //遇到错误最多重试两次
            .subscribe(onNext:{print($0)})
            .disposed(by: disposeBag)
        
        
    }
}

