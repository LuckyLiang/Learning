//
//  Create.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    // MARK: create

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        return AnonymousObservable(subscribe)
    }
    
}


/// 匿名可观擦序列， Element： 可观序列携带类型 Producer:Observable:ObservableType

//final :表示不允许对该内容进行继承或者重写操作， 并且对性能会有一定的改善
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

final private class AnonymousObservableSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = AnonymousObservable<Element>

    // state
    private let _isStopped = AtomicInt(0)

    #if DEBUG
        fileprivate let _synchronizationTracker = SynchronizationTracker()
    #endif

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        switch event {
        case .next:
            if load(self._isStopped) == 1 {
                return
            }
            self.forwardOn(event)
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.forwardOn(event)
                self.dispose()
            }
        }
    }

    func run(_ parent: Parent) -> Disposable {
        //AnyObserver(self) -> AnyObserver(AnonymousObservableSink对象)
        //创建通过AnonymousObservableSink来创建一个AnyObserver观察者，在初始化的时候 调用了AnonymousObservableSink的on函数，并保存了这个函数
        return parent._subscribeHandler(AnyObserver(self))
    }
}

