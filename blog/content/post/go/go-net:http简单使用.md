---
layout:     post
title:      "go - net/http的简单使用"
subtitle:   ""
description: "理解net/http 后端服务简单使用方法，方便自己调式和理解前后台数据交互"
excerpt: ""
date:       2018-03-10 20:32:40
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/03/10/goNet/"
categories: [ go ]

---

Go 语言中处理 HTTP 请求主要跟两个东西相关：`ServeMux` 和 `Handler`。

***ServrMux***：本质上是一个 HTTP 请求路由器,它把收到的请求与一组预先定义的 URL 路径列表做对比，然后在匹配到路径的时候调用关联的处理器

***处理器***（Handler）负责输出HTTP响应的头和正文。任何实现了[`http.Handler`接口](http://golang.org/pkg/net/http/#Handler)的对象都可作为一个处理器

```go
type Handler interface {
   ServeHTTP(ResponseWriter, *Request)
}
```

一个简单的net/http 服务

```go
func main() {
	// 默认路由中注册处理器
	http.HandleFunc("/hello", hello)
	//监听端口
	err := http.ListenAndServe(":3002",nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
func hello(w http.ResponseWriter, request *http.Request) {
	w.Write([]byte("hello go"))
}
```

在浏览器中输入http://localhost:3002 可以看到输出 hello go

先看`http.HandleFunc("/hello", hello)`，首先进入HandleFunc函数

```go
// pattern 路径， handler函数：这里传入的是func hello(w http.ResponseWriter, request *http.Request)
func HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
  // 使用默认路由
	DefaultServeMux.HandleFunc(pattern, handler)
}
```

先看看DefaultServeMux，其实就是一个空的ServeMux

```go
// 定义
var DefaultServeMux = &defaultServeMux
var defaultServeMux ServeMux //其实就是一个空的ServeMux

// ServeMux结构体
type ServeMux struct {
	mu    sync.RWMutex  //定义读写锁
	m     map[string]muxEntry //利用map储存路由入口
	es    []muxEntry // 所有路由入口切片
	hosts bool       // whether any patterns contain hostnames
}

type muxEntry struct {
	h       Handler   //处理器函数 func(ResponseWriter, *Request)
	pattern string   //入口，如/hello
}

```

DefaultServeMux调用HandleFunc函数

```go

func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
	if handler == nil {
		panic("http: nil handler")
	}
	mux.Handle(pattern, HandlerFunc(handler))
}
//最终调用ServeMux的Handle函数
func (mux *ServeMux) Handle(pattern string, handler Handler) {
	mux.mu.Lock() //加读写锁
	defer mux.mu.Unlock()

	if pattern == "" {
		panic("http: invalid pattern")
	}
	if handler == nil {
		panic("http: nil handler")
	}
  //判断之前是否组册过
	if _, exist := mux.m[pattern]; exist {
		panic("http: multiple registrations for " + pattern)
	}

	if mux.m == nil { //如果为空，初始化一个存储muxEntry
		mux.m = make(map[string]muxEntry)
	}
  //保存路由和对应的处理函数
	e := muxEntry{h: handler, pattern: pattern}
	mux.m[pattern] = e 
  
	if pattern[len(pattern)-1] == '/' {
		mux.es = appendSorted(mux.es, e)
	}
	if pattern[0] != '/' {
		mux.hosts = true
	}
}
```

既然注册存入了相应的信息，那么在处理HTTP请求的时候，就可以使用了。Go语言的`net/http`更底层细节就不详细分析了，我们只要知道处理HTTP请求的时候，会调用`Handler`接口的`ServeHTTP`方法，而`ServeMux`正好实现了`Handler`。

```go
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request) {
	//省略一些无关代码
	h, _ := mux.Handler(r)
	h.ServeHTTP(w, r)
}
```

上面代码中的`mux.Handler`会获取到我们注册的`Index`函数，然后执行它，具体`mux.Handler`的详细实现不再分析了，大家可以自己看下源代码。

现在我们可以总结下`net/http`包对HTTP请求的处理。

```
HTTP请求->ServeHTTP函数->ServeMux的Handler方法->Index函数
```

使用内置的`net/htp`的默认路径处理HTTP请求的时候，会发现很多不足，比如：

1. 不能单独的对请求方法(POST,GET等)注册特定的处理函数
2. 不支持Path变量参数
3. 不能自动对Path进行校准
4. 性能一般
5. 扩展性不足
6. .....

创建一个自定义处理器，功能是将以特定格式输出当前本地时间

```go
type timeHandler struct {
	format string //时间格式化
}
//实现ServeHTTP接口
//实现ServeHTTP接口
func (th *timeHandler) ServeHTTP(w http.ResponseWriter, r *http.Request)  {
	if r.Method == "GET" {
		tm := time.Now().Format(th.format)
		fmt.Fprint(w,[]byte("The time is: " + tm))
	}else  {
		fmt.Fprint(w,"bad http method request")
	}
}
func main() {
	//初始化路由
	mux := http.NewServeMux()
	//初始化时间处理器
	th := &timeHandler{format:time.RFC1123}
  	//注册到ServerMux中
	mux.Handle("/time",th)// 这里直接调用了最后一步Handle函数
	log.Println("Listenning...")
	//监听,注意端口前加冒号
  err := http.ListenAndServe(":3000",mux)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
```

这里只是简单记录下net/http的简单实用方法



















