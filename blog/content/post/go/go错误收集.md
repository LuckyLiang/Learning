---
layout:     post
title:      "go 错误收集"
subtitle:   ""
description: "初学go语言，收集一些平时学习时遇到的错误和坑"
excerpt: ""
date:       2018-04-12 19:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/04/12/goerror/"
categories: [ go ]
---
 
## ListenAndServe: listen tcp: address 3000: missing port in address exit status 1

学习go net/http包，代码如下

```go
func getNews(writer http.ResponseWriter, request *http.Request) {
	writer.Write([]byte("hello"))
}

func main() {

	http.HandleFunc("/getNews",getNews)
	log.Println("Listening....")
	err := http.ListenAndServe("3000",nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
```

执行命令 `$ go run main.go`的时候得到如下报错

```go
## ListenAndServe: listen tcp: address 3000: missing port in address exit status 1
```

这是端口号不正确，把上面端口号前加个冒号解决 (有时不注意忘记写了，而且初学者难找原因)

```go
err := http.ListenAndServe(":3000",nil)
```

