---
layout:     post
title:      "Swift - PromisKit使用"
subtitle:   ""
description: "Swift PromisKit常用使用方法"
excerpt: ""
date:       2018-04-17 20:31:08
author:     "Cheng"
image: "./img/swift_promiskit.png"
published: true
tags:
    - IOS
    - Swift
URL: "/2018/04/17/swiftPromisKit/"
categories: [ IOS ]


---

promistKit主要是解决异步回调地狱的问题，举个例子，比如需要下载一个图片文件，而且这个图片文件的下载链接也需要请求，也就是先请求一个接口然后图片的下载链接，然后通过该链接去下载图片，普通做法大概就是这样：

```

URLSession.shared.dataTask(with: backendurl!) { data, _, error in
    if error != nil {
        print(error)
        return
    }
    
    let imageurl = String(data: data!, encoding: String.Encoding.utf8) as String! 
    
    URLSession.shared.dataTask(with: URL(string:imageurl!)!) { (data, response, error) in
        if error != nil {
            print(error)
            return
        }
        DispatchQueue.main.async {
            imageView.image = UIImage(data: data!)
        }
    }.resume()
}.resume()
```

如果再有其他操作，一层嵌套一层 的网络请求，结构很不清晰很不具有阅读性，而PromiseKit的出现就很好的解决了这个问题

### Promise创建

promise包含两个回调闭包，当任务完成可以使用`fulfill`来回调成功信息，也可以使用`reject`来回调错误信息

```
Promise() { fulfill, reject in
    // code       
}
```

比如下载一个图片的请求可以这样做

```
func fetch(url: URL) -> Promise<Data> {
    return Promise { seal in
        URLSession.shared.dataTask(with: url!) { data, _, error in
            seal.resolve(data, error)
        }.resume()
    }
}
```

当然在编程过程中也不是总会有处理错误信息的时候，可以用`Guarantee`创建一个没有错误信息的

```
Guarantee { seal in
    seal("Hello World")
}.done {
            print($0)
        }
```

### Promise 链

#### `then(),done(),catch()`

上面我们创建了一个图片下载的`promise`请求，然后我们可以使用`then()`函数来链接，

```
fetch(url: <backend-url>).then { value in
    // value
}
```

`then()`需要返回一个Promise，以此一直then，可以用`done()`来结束调用链，用`catch()`来捕获错误信息

```
fetch(url: <backend-url>).then { value in
    // value
}.then {value in 
	// value
}.done {value in 
	// value
}.catch {error in
	//error
}
```

#### `recover()`

当然，有时候希望在发生错误前给一个默认值，可以用`recover()`函数

```

fetch(url: <imageurl>).recover { error -> Promise<UIImage> in
    return UIImage(name: <placeholder>)
}...
```

因此上面图片请求例子就可以写成这样

```
func fetch(url: URL) -> Promise<Data> {
    return Promise { seal in
        URLSession.shared.dataTask(with: url!) { data, _, error in
            seal.resolve(data, error)
        }.resume()
    }
}

fetch(url: <backendURL>).then { data in
		//解析返回结果
    return JSONParsePromise(data)
}.then { imageurl in
    //下载图片文件
    return fetch(url: imageurl)
}.then { data in
		//UI赋值
    imageView.image = UIImage(data: data)
}.catch { error in
	//错误处理	
}
```

其他链元素

#### `firstly()`

使用`firstly()`来作为一个链的开始

```
firstly {
    return fetch(url:url)
}.then{ 
    ...
}
```

#### `ensure()`

如果想在promise完成之前做的事情，可以使用`ensure()`

```
firstly {
    fetch(url: url)
}.ensure {
    cleanup()
}.catch {
    handle(error: $0)
}
```

比如在请求中加入网络指示器

```
func fetch(url: URL) -> Promise<Data> {
    return Promise { seal in
        URLSession.shared.dataTask(with: url!) { data, _, error in
            seal.resolve(data, error)
        }.resume()
    }
}

firstly {
//开始旋转
  UIApplication.shared.isNetworkActivityIndicatorVisible = true
  return fetch(url: <backendURL>)
}.then { data in
    return JSONParsePromise(data) // we skip the wrapping of JSONParsing
}.then { imageurl in
    return fetch(url: imageurl)
}.then { data in
    imageView.image = UIImage(data: data)
}.ensure {
	//在完成之前执行
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
}.catch { error in
    // in case we have an error
}
```

#### `get()`

如果想在同样的数据结果做不同的事情，可以用`get()`来讲任务分开

```
firstly {
    fetch(url: url)
}.get { data in
    //…
}.done { data in
    // 跟get数据相同，并没有发生变化
}
```

#### `when()`

使用when来链接多个promise，当每个promise都完成时才会回调，如果其中一个promise发生错误，那么就会跳到`catch`处

```
firstly {
    when(fulfilled: promise1(), promise2())
}.done { result1, result2 in
    //…
}
```

### 自定义回调线程

Promise默认的所有回调都在主线程，如果想在其他线程中处理事，可以这样做

```
fetch(url: url).then(on: .global(QoS: .userInitiated)) {
    //then closure executes on different thread 
}
```

### 延迟Delay

```
let waitAtLeast = after(seconds: 0.3)

firstly {
    fetch(url: url)
}.then {
    waitAtLeast
}.done {
    //…
}
```

### 超时

使用`race()`来处理超时

```
let timeout = after(seconds: 4)

race(when(fulfilled: fetch(url:url)).asVoid(), timeout).then {
    //…
}
```

### 重试

网络请求不会总是成功，有时我们希望在一次失败时，再重新请求几次，那么可以使用`recover().`

```
func attempt<T>(maximumRetryCount: Int = 3, delayBeforeRetry: DispatchTimeInterval = .seconds(2), _ body: @escaping () -> Promise<T>) -> Promise<T> {
    var attempts = 0
    func attempt() -> Promise<T> {
        attempts += 1
        return body().recover { error -> Promise<T> in
            guard attempts < maximumRetryCount else { throw error }
            return after(delayBeforeRetry).then(on: nil, attempt)
        }
    }
    return attempt()
}

attempt(maximumRetryCount: 3) {
    fetch(url: url)
}.then {
    //…
}.catch { _ in
    // we still failed
}
```

