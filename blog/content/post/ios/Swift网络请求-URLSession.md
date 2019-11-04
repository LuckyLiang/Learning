---
layout:     post
title:      "Siwft网络请求 - URLSession"
subtitle:   ""
description: "Swift 中URLSession网络请求简单应用，get,post,文件上传，文件下载"
excerpt: ""
date:       2018-04-18 19:40:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - IOS
    - Swift
URL: "/2018/04/18/swiftURlSession/"
categories: [ IOS ]

---

### URLSession功能

- NSURLSession 支持 http2.0 协议
- 在处理下载任务的时候可以直接把数据下载到磁盘
- 支持后台下载与上传
- 同一个 session 发送多个请求，只需要建立一次连接（复用了TCP）
- 提供了全局的 session 并且可以统一配置，使用更加方便
- 下载的时候是多线程异步处理，效率更高

[URLSession基本请求类](/img/swift/02-URLSession.png)

### URLSessionConfiguration的三种模式

1. ***default***: 默认配置，使用磁盘持久化全局缓存，认证和cookie储存对象
2. ***ephemeral***：暂时会话，不使用磁盘保存任何数据，所有会话相关的都保存在内存中，因此当会话无效时，这些数据被自动清空
3. ***background***： 该模式在后台完成上传和下载，在创建Configuration对象的时候需要提供一个NSString类型的ID用于标识完成工作的后台会话。

```swift
URLSessionConfiguration.default
URLSessionConfiguration.ephemeral
URLSessionConfiguration.background(withIdentifier: "nw-Session")
```

URLSessionConfiguration也可以配置请求超时时间，缓存策略，和header，可以看 [Apple’s documentation](https://developer.apple.com/reference/foundation/urlsessionconfiguration) 的配置列表

### URLSessionTask

1. ***URLSessionTask***：一个可撤销的对象,指的是生命周期内处理一个给定的请求。
2. ***URLSessionDataTask***：一个 数据请求 的 `URLSessionTask` 的子类，用于数据的请求。
3. ***URLSessionUploadTask***：是一个 上传数据 的 `URLSessionDataTask` 的子类。
4. ***URLSessionDownloadTask***：是一个下载数据 的` URLSessionTask` 的子类
5. ***URLSessionStreamTask***：是一个双向会话的 `URLSessionTask `的子类

[URLSessionTask](03-URLSessionTask.png)

简单请求

```swift
  var urlStr = "https://learnappmaking.com/ex/users.json"
  /// 链接转吗
  urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
  ///请求网链接
  let url = URL(string: urlStr)

  ///创建config
  let config = URLSessionConfiguration.default
  /// 设置超时时间
  config.timeoutIntervalForRequest = 15.0
  ///会话
  let session = URLSession(configuration: config)

  guard let requestUrl = url else { return }

  let request =  URLRequest(url: requestUrl)

  self.view.makeActivity()

  let task = session.dataTask(with: request) { (data, response, error) in
      ///请求回调数据
      if error != nil {
          print("网络请求错误")
      }
      ///服务器响应
      guard let httpResponse = response as? HTTPURLResponse,  (200...299).contains(httpResponse.statusCode) else {
          print("服务器错误")
          return
      }
      guard let `data` = data else {return
      let json = try? JSONSerialization.jsonObject(with: data, options: [])
      DispatchQueue.main.async {//回到主线程
          if let jsonData = json as? Dictionary<String, Any> {
              print(jsonData)
          }
          self.view.hideToast()
      }
  }
  /// 开始请求
  task.resume()
```

### Post带参请求

这里自己用go写了个简单的测试服务端，终端运行go run main.go就可以了

```go
import (
	json2 "encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
)

type BaseData struct {
	Status string	 `json:"status"`
	Msg string 	  	 `json:"msg"`
	Data [] NewData	 `json:"data"`
}

type NewData struct {
	Title string		`json:"title"`
	Content string		`json:"content"`
	Index int			`json:"index"`
}
/*
3. 获取json数据
*/
func getNews(writer http.ResponseWriter, request *http.Request) {

	// Form：存储了post、put和get参数，在使用之前需要调用 ParseForm 方法。
	err :=  request.ParseForm()
	if err != nil{
		return
	}

	///获取请求参数
	num := request.Form.Get("num")
	title := request.Form.Get("channel")
	// 字符窜转int
	index, err  := strconv.Atoi(num)

	var dataList []NewData
	///制作假数据
	for i := 0; i < index; i++ {
		newData := NewData{ fmt.Sprint(title,i), fmt.Sprint("今日内容:",title,i,"内容"),i}
		dataList = append(dataList, newData)
	}

	data := BaseData{Status:"200", Msg:"请求成功", Data:dataList}

	///转成json
	json, err := json2.Marshal(data)

	if err != nil {
		http.Error(writer, err.Error(), http.StatusInternalServerError)
		return
	}

	writer.Header().Set("Content-Type", "application/json")
	writer.Write(json)
}

func main() {
	go http.HandleFunc("/getNews",getNews)
	///监听端口
	log.Println("Listening....")
	err := http.ListenAndServe(":3001",nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
```

客户端代码

```swift
   private func _postRequest() {
      /// 请求链接
      let linkStr = "http://localhost:3001/getNews".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)

      guard let link = linkStr, let url = URL(string: link) else { return }

      //创建请求载体
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      ///请求参
      request.httpBody = "channel=\"头条\"&num=20".data(using: .utf8)

      self.view.makeActivity()
      //发起网络请求
      let postTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
          ///子线程
          ///请求回调数据
          if error != nil {
              print("网络请求错误")
          }
          ///服务器响应
          guard let httpResponse = response as? HTTPURLResponse,  (200...299).contains(httpResponse.statusCode) else {
              print("服务器错误")
              return
          }
          guard let `data` = data else {return}
          let json = try? JSONSerialization.jsonObject(with: data, options: [])

          DispatchQueue.main.async {
              ///回到主线程刷新数据
              self.view.hideToast()
              if let jsonData = json as? Dictionary<String, Any> {
                  print(jsonData)
              }
          }
          }
      /// 开始请求
      postTask.resume()

  }
```



