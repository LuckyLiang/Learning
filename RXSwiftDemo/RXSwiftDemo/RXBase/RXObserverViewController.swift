//
//  RXObserverViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 21/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RXObserverViewController: BaseViewController {

    @IBOutlet weak var label: UILabel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        binderRXCocoTest()
    }

    /**
     观察者（Observer）的作用就是监听事件，然后对这个事件做出响应。或者说任何响应事件的行为都是观察者。比如：
     当我们点击按钮，弹出一个提示框。那么这个“弹出一个提示框”就是观察者 Observer<Void>
     当我们请求一个远程的 json 数据后，将其打印出来。那么这个“打印 json 数据”就是观察者 Observer<JSON>
     */

    /**
     1，在 subscribe 方法中创建
     （1）创建观察者最直接的方法就是在 Observable 的 subscribe 方法后面描述当事件发生时，需要如何做出响应
     因为闭包里面会创建一个观擦着AnonymousObserver
     */
    func testObserver1() -> Void {
        let observable = Observable.of("A", "B", "C")
        
        observable.subscribe(onNext: { element in
            print(element)
        }, onError: { error in
            print(error)
        }, onCompleted: {
            print("completed")
        }).disposed(by: disposeBag)
    }
    
    /**
     2，在 bind 方法中创建
     */
    func bindTest() -> Void {
        
        Observable<Int>
            .interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map { (index) -> String in
                return "当前索引数：\(index)"
            }.bind { [weak self] (text) in
                self?.label.text = text
        }.disposed(by: disposeBag)
    }
    
    
    /**
     3、使用 AnyObserver 创建观察者
     //AnyObserver 可以用来描叙任意一种观察者。
     
     1，配合 subscribe 方法使用
     比如上面第一个样例我们可以改成如下代码：
     */
    
    func anyObserverTest() -> Void {
        //观察者
        let observer: AnyObserver<String> = AnyObserver { (event) in
            switch event {
            case .next(let data):
                print(data)
            case .error(let error):
                print(error)
            case .completed:
                print("completed")
            }
        }
        
        let observable = Observable.of("A", "B", "C")
        observable.subscribe(observer).disposed(by: disposeBag)
    }
    
    /**
     2，配合 bindTo 方法使用
     也可配合 Observable 的数据绑定方法（bindTo）使用。比如上面的第二个样例我可以改成如下代码：
     */
    
    func bindToTest() -> Void {
        //观察者
        let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
            switch event {
            case .next(let text):
                //收到发出的索引数后显示到label上
                self?.label.text = text
            default:
                break
            }
        }
        
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        observable
            .map { "当前索引数：\($0 )"}
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    /**
     使用 Binder 创建观察者
     
     1，基本介绍
     （1）相较于 AnyObserver 的大而全，Binder 更专注于特定的场景。Binder 主要有以下两个特征：
     不会处理错误事件
     确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
     （2）一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息。
     */
    
    func binderTest() -> Void {
        let observer : Binder<String> = Binder.init(label) { [weak self](label, text) in
            //收到发出的索引数后显示在label上,这里只回调.onNext方法
            self?.label.text = text
        }
        
        Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map{"当前索引\($0)"}
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        
    }
    
    /**
     Binder 在 RxCocoa 中的应用
    （1）其实 RxCocoa 在对许多 UI 控件进行扩展时，就利用 Binder 将控件属性变成观查者，比如 UIControl+Rx.swift 中的 isEnabled 属性便是一个 observer ：

     */
    
    func binderRXCocoTest() -> Void {
        let observer = label.rx.isHidden
        label.text = "label label"
    
//        label.textAlignment
//        let labeTextObserver = label.rx.text
        
        Observable<Int>.interval(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map{$0 % 2 == 0}
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        //自定义RX扩展
        let alignmentObserVer = label.rx.alignment
        Observable
            .create { (aliobserVer) -> Disposable in
            aliobserVer.onNext(.right)
            return Disposables.create()
        }
            .subscribe(alignmentObserVer)
            .disposed(by: disposeBag)
        
    }

}

/**
 自定义扩展label 的alignment
 */
extension Reactive where Base : UILabel{
    
    public var alignment : Binder<NSTextAlignment>{
        return Binder.init(self.base, binding: { (label , alignment) in
            label.textAlignment = alignment
        })
    }
}


