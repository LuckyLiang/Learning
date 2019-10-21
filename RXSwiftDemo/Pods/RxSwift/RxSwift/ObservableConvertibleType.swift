//
//  ObservableConvertibleType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Type that can be converted to observable sequence (`Observable<Element>`).
public protocol ObservableConvertibleType {
    /// Type of elements in sequence. 在协议中定义序列中的关联类型，只有在真正使用到它的时候才知道是什么类型
    associatedtype Element

    @available(*, deprecated, message: "Use `Element` instead.")
    typealias E = Element // 为元素从命名

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`
    /// 定义一个转换方法， 转换为可观察序列
    func asObservable() -> Observable<Element>
}
