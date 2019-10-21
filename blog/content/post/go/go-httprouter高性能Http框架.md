---
layout:     post
title:      "go - httprouter高性能Http框架"
subtitle:   ""
description: "HttpRouter是一个轻量级但却非常高效的multiplexer。本篇文章主要记录HttpRouter一些基础使用方法"
excerpt: ""
date:       2018-03-12 20:35:23
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/03/12/gohttprouter/"
categories: [ go ]


---

### 安装 HttpRouter

```go
go get github.com/julienschmidt/httprouter
```

### 认识httprouter

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"github.com/julienschmidt/httprouter"
)

func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	fmt.Fprint(w, "Welcome!\n")
}

func main() {
	router := httprouter.New()
	router.GET("/", Index)
	log.Fatal(http.ListenAndServe(":3000", router))
}
```

执行`go run main.go` 然后在浏览器输入`http:// localhost:3000/`就可看见运行效果

在这个例子中，首先通过`httprouter.New()`生成了一个`*Router`路由指针,然后使用`GET`方法注册一个适配`/`路径的`Index`函数，最后`*Router`作为参数传给`ListenAndServe`函数启动HTTP服务即可。

其实不止是`GET`方法，httprouter 为所有的HTTP Method 提供了快捷的使用方式，只需要调用对应的方法即可。

```go
func (r *Router) GET(path string, handle Handle) {
	r.Handle("GET", path, handle)
}

func (r *Router) HEAD(path string, handle Handle) {
	r.Handle("HEAD", path, handle)
}

func (r *Router) OPTIONS(path string, handle Handle) {
	r.Handle("OPTIONS", path, handle)
}

func (r *Router) POST(path string, handle Handle) {
	r.Handle("POST", path, handle)
}

func (r *Router) PUT(path string, handle Handle) {
	r.Handle("PUT", path, handle)
}

func (r *Router) PATCH(path string, handle Handle) {
	r.Handle("PATCH", path, handle)
}

func (r *Router) DELETE(path string, handle Handle) {
	r.Handle("DELETE", path, handle)
}
```

以上这些方法都是 httprouter 支持的，我们可以非常灵活的根据需要，使用对应的方法，这样就解决了`net/http`默认路由的问题。

### httprouter命名参数

现代的API，基本上都是Restful API，httprouter提供的命名参数的支持，可以很方便的帮助我们开发Restful API。比如我们设计的API`/user/flysnow`，这这样一个URL，可以查看`flysnow`这个用户的信息，如果要查看其他用户的，比如`zhangsan`,我们只需要访问API`/user/zhangsan`即可。

现在我们可以发现，其实这是一种URL匹配模式，我们可以把它总结为`/user/:name`,这是一个通配符，看个例子。

```go
func UserInfo(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	fmt.Fprintf(w, "hello, %s!\n", ps.ByName("name"))
}

func main() {
	router := httprouter.New()
	router.GET("/user/:name",UserInfo)

	log.Fatal(http.ListenAndServe(":3000", router))
}
```

通过上面的代码示例，可以看到，路径的参数是以`:`开头的，后面紧跟着变量名，比如`:name`，然后在`UserInfo`这个处理函数中，通过`httprouter.Params`的`ByName`获取对应的值。

`:name`这种匹配模式，是精准匹配的，同时只能匹配一个，比如：

```go
Pattern: /user/:name

 /user/gordon              匹配
 /user/you                 匹配
 /user/gordon/profile      不匹配
 /user/                    不匹配
```

因为httprouter这个路由就是单一匹配的，所以当我们使用命名参数的时候，一定要注意，是否有其他注册的路由和命名参数的路由，匹配同一个路径，比如`/user/new`这个路由和`/user/:name`就是冲突的，不能同时注册。

这里稍微提下httprouter的另外一种通配符模式，就是把`:`换成`*`，也就是`*name`，这是一种匹配所有的模式，不常用，比如：

```
Pattern: /user/*name

 /user/gordon              匹配
 /user/you                 匹配
 /user/gordon/profile      匹配
 /user/                    匹配
```

### httprouter兼容http.hander

通过上面的例子，我们应该已经发现，`GET`方法的handle，并不是我们熟悉的`http.Handler`，它是httprouter自定义的，相比`http.Handler`多了一个通配符参数的支持。

```go
type Handle func(http.ResponseWriter, *http.Request, Params)
```

自定义的Handle，唯一的目的就是支持通配符参数，如果你的HTTP服务里，有些路由没有用到通配符参数，那么可以使用原生的`http.Handler`，httprouter是兼容支持的，这也为我们从`net/http`的方式，升级为httprouter路由提供了方便，会高效很多。

```go
func (r *Router) Handler(method, path string, handler http.Handler) {
	r.Handle(method, path,
		func(w http.ResponseWriter, req *http.Request, _ Params) {
			handler.ServeHTTP(w, req)
		},
	)
}

func (r *Router) HandlerFunc(method, path string, handler http.HandlerFunc) {
	r.Handler(method, path, handler)
}
```

httprouter通过`Handler`和`HandlerFunc`两个函数，提供了兼容`http.Handler`和`http.HandlerFunc`的完美支持。从以上源代码中，我们可以看出，实现的方式也比较简单，就是做了一个`http.Handler`到`httprouter.Handle`的转换，舍弃了通配符参数的支持。

### Httprouter 处理链

得益于`http.Handler`的模式，我们可以把不同的`http.Handler`组成一个处理链，`httprouter.Router`也是实现了`http.Handler`的，所以它也可以作为`http.Handler`处理链的一部分，比如和`Negroni`、`Gorilla handlers`这两个库配合使用。

这里使用一个官方的例子，作为Handler处理链的演示。

```go
//一个新类型，用于存储域名对应的路由
type HostSwitch map[string]http.Handler

//实现http.Handler接口，进行不同域名的路由分发
func (hs HostSwitch) ServeHTTP(w http.ResponseWriter, r *http.Request) {

    //根据域名获取对应的Handler路由，然后调用处理（分发机制）
	if handler := hs[r.Host]; handler != nil {
		handler.ServeHTTP(w, r)
	} else {
		http.Error(w, "Forbidden", 403)
	}
}

func main() {
    //声明两个路由
	playRouter := httprouter.New()
	playRouter.GET("/", PlayIndex)
	
	toolRouter := httprouter.New()
	toolRouter.GET("/", ToolIndex)

    //分别用于处理不同的二级域名
	hs := make(HostSwitch)
	hs["play.flysnow.org:12345"] = playRouter
	hs["tool.flysnow.org:12345"] = toolRouter

    //HostSwitch实现了http.Handler,所以可以直接用
	log.Fatal(http.ListenAndServe(":12345", hs))
}
```

以上就是一个简单的，针对不同域名，使用不同路由的例子，代码中的注释比较详细了，这里就不一一解释了。这个例子中,`HostSwitch`和`httprouter.Router`这两个`http.Handler`就组成了一个`http.Handler`处理链。

### httprouter静态文件服务

httprouter提供了很方便的静态文件服务，可以把一个目录托管在服务器上，以供访问。

```go
	router.ServeFiles("/static/*filepath",http.Dir("./"))
```

只需要这一句核心代码即可，这个就是把当前目录托管在服务器上，以供访问，访问路径是`/static`。

使用`ServeFiles`需要注意的是，第一个参数路径，必须要以`/*filepath`，因为要获取我们要访问的路径信息。

```go
func (r *Router) ServeFiles(path string, root http.FileSystem) {
	if len(path) < 10 || path[len(path)-10:] != "/*filepath" {
		panic("path must end with /*filepath in path '" + path + "'")
	}

	fileServer := http.FileServer(root)

	r.GET(path, func(w http.ResponseWriter, req *http.Request, ps Params) {
		req.URL.Path = ps.ByName("filepath")
		fileServer.ServeHTTP(w, req)
	})
}
```

这是源代码实现，我们发现，最后还是一个`GET`请求服务，通过`http.FileServer`把`filepath`的路径的内容显示出来（如果路径是个目录则列出目录文件；如果路径是文件，则显示内容）。

通过上面的源代码，我们也可以知道，`*filepath`这个通配符是为了获取要放问的文件路径，所以要符合预定，不然就会panic。

### httprouter异常捕获

很少有路由支持这个功能的，httprouter允许使用者，设置`PanicHandler`用于处理HTTP请求中发生的panic。

```json
func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	panic("故意抛出的异常")
}

func main() {
	router := httprouter.New()
	router.GET("/", Index)
	router.PanicHandler = func(w http.ResponseWriter, r *http.Request, v interface{}) {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "error:%s",v)
	}

	log.Fatal(http.ListenAndServe(":8080", router))
}
```

演示例子中，我们通过设置`router.PanicHandler`来处理发生的panic，处理办法是打印出来异常信息。然后故意在`Index`函数中抛出一个painc，然后我们运行测试，会看到异常信息。

这是一种非常好的方式，可以让我们对painc进行统一处理，不至于因为漏掉的panic影响用户使用

httprouter还有不少有用的小功能，比如对404进行处理，我们通过设置`Router.NotFound`来实现，我们看看`Router`这个结构体的配置，可以发现更多有用的功能。

```go
type Router struct {
    //是否通过重定向，给路径自定加斜杠
	RedirectTrailingSlash bool
    //是否通过重定向，自动修复路径，比如双斜杠等自动修复为单斜杠
	RedirectFixedPath bool
    //是否检测当前请求的方法被允许
	HandleMethodNotAllowed bool
	//是否自定答复OPTION请求
	HandleOPTIONS bool
    //404默认处理
	NotFound http.Handler
    //不被允许的方法默认处理
	MethodNotAllowed http.Handler
    //异常统一处理
	PanicHandler func(http.ResponseWriter, *http.Request, interface{})
}
```

这些字段都是导出的(export)，我们可以直接设置，来达到我们的目的。

httprouter是一个高性能，低内存占用的路由，它使用radix tree实现存储和匹配查找，所以效率非常高，内存占用也很低。关于radix tree大家可以查看相关的资料。

httprouter因为实现了`http.Handler`，所以可扩展性非常好，可以和其他库、中间件结合使用，gin这个web框架就是使用的自定义的httprouter。

### httprouter案例

上面介绍了很多，现在来实现一个稍微复杂一点的API，我们现在有一个名为 `Book` 的实体，可以把 `ISDN` 字段作为唯一标识。让我们创建更多的动作，即分表代表着 Index 和 Show 动作的 GET `/books` 和 GET `/books/:isdn`。 我们的 `main.go` 文件此时如下：

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"github.com/julienschmidt/httprouter"
)
type Book struct {
	// The main identifier for the Book. This will be unique.
	ISDN   string `json:"isdn"`
	Title  string `json:"title"`
	Author string `json:"author"`
	Pages  int    `json:"pages"`
}

type JsonResponse struct {
	// Reserved field to add some meta information to the API response
	Meta interface{} `json:"meta"`
	Data interface{} `json:"data"`
}

type JsonErrorResponse struct {
	Error *ApiError `json:"error"`
}

type ApiError struct {
	Status int16  `json:"status"`
	Title  string `json:"title"`
}

// A map to store the books with the ISDN as the key
// This acts as the storage in lieu of an actual database
var bookstore = make(map[string]*Book)

// Handler for the books index action
// GET /books
func BookIndex(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	books := []*Book{}
	for _, book := range bookstore {
		books = append(books, book)
	}
	response := &JsonResponse{Data: &books}
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		panic(err)
	}
}

// Handler for the books Show action
// GET /books/:isdn
func BookShow(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	isdn := params.ByName("isdn")
	book, ok := bookstore[isdn]
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	if !ok {
		// No book with the isdn in the url has been found
		w.WriteHeader(http.StatusNotFound)
		response := JsonErrorResponse{Error: &ApiError{Status: 404, Title: "Record Not Found"}}
		if err := json.NewEncoder(w).Encode(response); err != nil {
			panic(err)
		}
	}
	response := JsonResponse{Data: book}
	if err := json.NewEncoder(w).Encode(response); err != nil {
		panic(err)
	}
}

func main() {
  	// Create a couple of sample Book entries
	bookstore["123"] = &Book{
		ISDN:   "123",
		Title:  "Silence of the Lambs",
		Author: "Thomas Harris",
		Pages:  367,
	}
	bookstore["124"] = &Book{
		ISDN:   "124",
		Title:  "To Kill a Mocking Bird",
		Author: "Harper Lee",
		Pages:  320,
	}
  
	router := httprouter.New()
	router.GET("/books", BookIndex)
	router.GET("/books/:isdn", BookShow)
	log.Fatal(http.ListenAndServe(":8080", router))
}
如果您现在尝试请求 GET https:// localhost:8080/books，您将得到以下响应：
{
    "meta": null,
    "data": [
        {
            "isdn": "123",
            "title": "Silence of the Lambs",
            "author": "Thomas Harris",
            "pages": 367
        },
        {
            "isdn": "124",
            "title": "To Kill a Mocking Bird",
            "author": "Harper Lee",
            "pages": 320
        }
    ]
}
```

让我们来重构一下代码。 到目前为止，我们所有的代码都放置在同一个文件中：`main.go`。我们可以把它们移到各个单独的文件中。此时我们有一个目录：

```
.
├── handlers.go
├── main.go
├── models.go
└── responses.go
```

我们把所有与 `JSON` 响应相关的结构体移动到 `responses.go`，将 handler 函数移动到 `Handlers.go`，且将 `Book` 结构体移动到 `models.go`。

现在，我们跳过来写一些测试。在 Go 中，`*_test.go` 文件是用于测试的。因此让我们创建一个 `handlers_test.go`。

```go
package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"github.com/julienschmidt/httprouter"
)

func TestBookIndex(t *testing.T) {
	// Create an entry of the book to the bookstore map
	testBook := &Book{
		ISDN:   "111",
		Title:  "test title",
		Author: "test author",
		Pages:  42,
	}
	bookstore["111"] = testBook
	// A request with an existing isdn
	req1, err := http.NewRequest("GET", "/books", nil)
	if err != nil {
		t.Fatal(err)
	}
	rr1 := newRequestRecorder(req1, "GET", "/books", BookIndex)
	if rr1.Code != 200 {
		t.Error("Expected response code to be 200")
	}
	// expected response
	er1 := "{\"meta\":null,\"data\":[{\"isdn\":\"111\",\"title\":\"test title\",\"author\":\"test author\",\"pages\":42}]}\n"
	if rr1.Body.String() != er1 {
		t.Error("Response body does not match")
	}
}

// Mocks a handler and returns a httptest.ResponseRecorder
func newRequestRecorder(req *http.Request, method string, strPath string, fnHandler func(w http.ResponseWriter, r *http.Request, param httprouter.Params)) *httptest.ResponseRecorder {
	router := httprouter.New()
	router.Handle(method, strPath, fnHandler)
	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()
	// Our handlers satisfy http.Handler, so we can call their ServeHTTP method
	// directly and pass in our Request and ResponseRecorder.
	router.ServeHTTP(rr, req)
	return rr
}
```

我们使用 `httptest` 包的 Recorder 来 mock handler。同样，您也可以为 handler `BookShow` 编写测试。

让我们稍微做些重构。我们仍然把所有路由都定义在了 `main` 函数中，handler 看起来有点臃肿，我们可以做点 DRY，我们仍然在终端中输出一些日志消息，并且可以添加一个 `BookCreate` handler 来创建一个新的 Book。

首先，让我们解决 `handlers.go`。

```go
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"github.com/julienschmidt/httprouter"
)

func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	fmt.Fprint(w, "Welcome!\n")
}

// Handler for the books Create action
// POST /books
func BookCreate(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	book := &Book{}
	if err := populateModelFromHandler(w, r, params, book); err != nil {
		writeErrorResponse(w, http.StatusUnprocessableEntity, "Unprocessible Entity")
		return
	}
	bookstore[book.ISDN] = book
	writeOKResponse(w, book)
}

// Handler for the books index action
// GET /books
func BookIndex(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	books := []*Book{}
	for _, book := range bookstore {
		books = append(books, book)
	}
	writeOKResponse(w, books)
}

// Handler for the books Show action
// GET /books/:isdn
func BookShow(w http.ResponseWriter, r *http.Request, params httprouter.Params) {
	isdn := params.ByName("isdn")
	book, ok := bookstore[isdn]
	if !ok {
		// No book with the isdn in the url has been found
		writeErrorResponse(w, http.StatusNotFound, "Record Not Found")
		return
	}
	writeOKResponse(w, book)
}

// Writes the response as a standard JSON response with StatusOK
func writeOKResponse(w http.ResponseWriter, m interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(&JsonResponse{Data: m}); err != nil {
		writeErrorResponse(w, http.StatusInternalServerError, "Internal Server Error")
	}
}

// Writes the error response as a Standard API JSON response with a response code
func writeErrorResponse(w http.ResponseWriter, errorCode int, errorMsg string) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(errorCode)
	json.
		NewEncoder(w).
		Encode(&JsonErrorResponse{Error: &ApiError{Status: errorCode, Title: errorMsg}})
}

//Populates a model from the params in the Handler
func populateModelFromHandler(w http.ResponseWriter, r *http.Request, params httprouter.Params, model interface{}) error {
	body, err := ioutil.ReadAll(io.LimitReader(r.Body, 1048576))
	if err != nil {
		return err
	}
	if err := r.Body.Close(); err != nil {
		return err
	}
	if err := json.Unmarshal(body, model); err != nil {
		return err
	}
	return nil
}
```

我创建了两个函数，`writeOKResponse` 用于将 `StatusOK` 写入响应，其返回一个 model 或一个 model slice，`writeErrorResponse` 将在发生预期或意外错误时将 `JSON` 错误作为响应。像任何一个优秀的 gopher 一样，我们不应该 panic。我还添加了一个名为 `populateModelFromHandler` 的函数，它将内容从 body 中解析成所需的任何 model（struct）。在这种情况下，我们在 `BookCreate` handler 中使用它来填充一个 `Book`。

现在，我们来看看日志。我们简单地创建一个 `Logger` 函数，它包装了 handler 函数，并在执行 handler 函数之前和之后打印日志消息。

```go
package main

import (
	"log"
	"net/http"
	"time"
	"github.com/julienschmidt/httprouter"
)

// A Logger function which simply wraps the handler function around some log messages
func Logger(fn func(w http.ResponseWriter, r *http.Request, param httprouter.Params)) func(w http.ResponseWriter, r *http.Request, param httprouter.Params) {
	return func(w http.ResponseWriter, r *http.Request, param httprouter.Params) {
		start := time.Now()
		log.Printf("%s %s", r.Method, r.URL.Path)
		fn(w, r, param)
		log.Printf("Done in %v (%s %s)", time.Since(start), r.Method, r.URL.Path)
	}
}
```

我们来看看路由。首先，在一个地方集中定义所有路由，比如 `routes.go`。

```go
package main

import "github.com/julienschmidt/httprouter"

/*
Define all the routes here.
A new Route entry passed to the routes slice will be automatically
translated to a handler with the NewRouter() function
*/
type Route struct {
	Name        string
	Method      string
	Path        string
	HandlerFunc httprouter.Handle
}

type Routes []Route

func AllRoutes() Routes {
	routes := Routes{
		Route{"Index", "GET", "/", Index},
		Route{"BookIndex", "GET", "/books", BookIndex},
		Route{"Bookshow", "GET", "/books/:isdn", BookShow},
		Route{"Bookshow", "POST", "/books", BookCreate},
	}
	return routes
}
```

让我们创建一个 `NewRouter` 函数，它可以在 `main` 函数中调用，它读取上面定义的所有路由，并返回一个可用的 `httprouter.Router`。因此创建一个文件 `router.go`。我们还将使用新创建的 `Logger` 函数来包装 handler。

```go
package main

import "github.com/julienschmidt/httprouter"

//Reads from the routes slice to translate the values to httprouter.Handle
func NewRouter(routes Routes) *httprouter.Router {
	router := httprouter.New()
	for _, route := range routes {
		var handle httprouter.Handle
		handle = route.HandlerFunc
		handle = Logger(handle)
		router.Handle(route.Method, route.Path, handle)
	}
	return router
}
```

您的目录此时应该像这样：

```go
.
├── handlers.go
├── handlers_test.go
├── logger.go
├── main.go
├── models.go
├── responses.go
├── router.go
└── routes.go
```

这应该可以让你开始编写你自己的 API 服务器了。 你当然需要把你的功能放在不同的包中，所以一个好办法就是：

```go
.
├── LICENSE
├── README.md
├── handlers
│   ├── books_test.go
│   └── books.go
├── models
│   ├── book.go
│   └── *
├── store
│   ├── *
└── lib
|   ├── *
├── main.go
├── router.go
├── rotes.go
```

如果您有一个大的单体服务器，您还可以将 `handlers`、`models` 和所有路由功能都放在另一个名为 `app` 的包中。只要记住，go 不像 Java 或 Scala 那样可以有循环的包调用。因此你必须格外小心您的包结构。