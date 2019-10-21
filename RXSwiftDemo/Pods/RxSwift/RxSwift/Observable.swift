//
//  Observable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// A type-erased `ObservableType`. 
///
/// It represents a push style sequence.
///
public class Observable<Element> : ObservableType {
    init() {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }
    
    /**
     执行订阅方法
     where Observer.Element == Element 观察者的元素要于可被观察序列的元素相同
     
     ObserverType： 观察着类型协议
     
     
     */
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        rxAbstractMethod()
    }
    
    public func asObservable() -> Observable<Element> {
        return self
    }
    
    deinit {
#if TRACE_RESOURCES
        _ = Resources.decrementTotal()
#endif
    }

    // this is kind of ugly I know :(
    // Swift compiler reports "Not supported yet" when trying to override protocol extensions, so ¯\_(ツ)_/¯

    /// Optimizations for map operator
    internal func composeMap<Result>(_ transform: @escaping (Element) throws -> Result) -> Observable<Result> {
        return _map(source: self, transform: transform)
    }
}

