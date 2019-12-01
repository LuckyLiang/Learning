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
URL: "/2018/04/12/goErrorCollection/"
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

## Go test执行单个测试文件提示未定义

```
# command-line-arguments [command-line-arguments.test]
./citylist_test.go:15:17: undefined: ParserCityList
```

其实从看看上面的这段提示：`build failed`，构建失败，我们应该就能看出一下信息。go test与其他的指定源码文件进行编译或运行的命令程序一样（参考：`go run`和`go build`），会为指定的源码文件生成一个虚拟代码包——“command-line-arguments”，对于运行这次测试的命令程序来说，测试源码文件`getinfo_test.go`是属于代码包“command-line-arguments”的，可是它引用了其他包中的数据并不属于代码包“command-line-arguments”，编译不通过，错误自然发生了。

**解决方法**

**执行命令时加入这个测试文件需要引用的源码文件**，**在命令行后方的文件都会被加载到`command-line-arguments`中进行编译。**示例如下：

```
//citylist_test.go : 需要测试的文件
//parser.go：依赖文件
adminMacBook:parser admin$ go test -v citylist_test.go parser.go
```

