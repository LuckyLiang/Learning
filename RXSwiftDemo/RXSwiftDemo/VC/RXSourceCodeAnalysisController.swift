//
//  RXSourceCodeAnalysisController.swift
//  RXSwiftDemo
//
//  Created by admin on 17/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXSourceCodeAnalysisController: BaseViewController {

    
    let disponseBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
       creatSourceTest()
    }
    
    
    
   private func creatSourceTest() -> Void {
    

    let subject = PublishSubject<String>()
    subject.subscribe(onNext: { (str) in
        print(str)
    }, onError: { (error) in
        print(error)
    }, onCompleted: {
        print("订阅结束")
    }) {
        print("已经销毁")
        }.disposed(by: disponseBag)
    
    subject.onNext("🐱")
    subject.onNext("🐶")
    subject.onCompleted()

    
    
    
//        Observable<String>.create { (observer) -> Disposable in
//            observer.onNext("hahh")
//            observer.onCompleted()
//            return Disposables.create()
//            }.subscribe(onNext: { (str) in
//                print(str)
//            }, onError: { (error) in
//
//            }, onCompleted: {
//                print("订阅完成")
//
//            }, onDisposed: {print("已经销毁")}).disposed(by: disponseBag)
    
//            Observable<String>.of("hahha","ddd").subscribe(onNext: { (str) in
//                print(str)
//            }, onError: { (error) in
//                print(error)
//            }, onCompleted: {
//                print("订阅完成")
//            }, onDisposed: nil).disposed(by: disponseBag)
    

    
    }
    
    /**
         public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
            return AnonymousObservable(subscribe)
         }
     AnonymousObservable : 匿名可观擦序列
     
     final private class AnonymousObservable<Element>: Producer<Element> {
     
     typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable
     
     let _subscribeHandler: SubscribeHandler
     
     //1.初始化匿名序列， 包括外部传入的块
     init(_ subscribeHandler: @escaping SubscribeHandler) {
     self._subscribeHandler = subscribeHandler
     }
     
     override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
     let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
     let subscription = sink.run(self)
     return (sink: sink, subscription: subscription)
     }
     }

     
     */
}
