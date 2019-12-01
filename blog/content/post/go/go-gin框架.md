---
layout:     post
title:      "go - gin框架"
subtitle:   ""
description: "Gin是一个golang的微框架，封装比较优雅，API友好，源码注释比较明确，具有快速灵活，容错方便等特点。其实对于golang而言，web框架的依赖要远比Python，Java之类的要小。自身的net/http足够简单，性能也非常不错"
excerpt: ""
date:       2018-03-14 19:25:23
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/03/14/goGin/"
categories: [ go ]


---

## gin简介

Gin是一个golang的微框架，封装比较优雅，API友好，源码注释比较明确，已经发布了1.0版本。具有快速灵活，容错方便等特点。其实对于golang而言，web框架的依赖要远比Python，Java之类的要小。自身的net/http足够简单，性能也非常不错。框架更像是一些常用函数或者工具的集合。借助框架开发，不仅可以省去很多常用的封装带来的时间，也有助于团队的编码风格和形成规范。

Gin 包括以下几个主要的部分:

- 设计精巧的路由/中间件系统;
- 简单好用的核心上下文 `Context`;
- 附赠工具集(JSON/XML 响应, 数据绑定与校验等).

### 安装

终端输入：

```
go get -u github.com/gin-gonic/gin
```

使用的时候要导入包：

```
import "github.com/gin-gonic/gin"
```

### helloworld

新建一个go文件(helloworld.go)：

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    router := gin.Default()
    router.GET("/", func(c *gin.Context) {
        c.String(http.StatusOK, "Hello World")
    })
    router.Run(":8000") 
}
```

使用Gin实现Hello world非常简单，创建一个router（路由），然后执行Run方法即可。

代码结构：

- 1、`router:=gin.Default()`：这是默认的服务器。使用gin的`Default`方法创建一个路由`Handler`；
- 2、然后通过Http方法绑定路由规则和路由函数。不同于`net/http`库的路由函数，gin进行了封装，把`request`和`response`都封装到了`gin.Context`的上下文环境中。
- 3、最后启动路由的Run方法监听端口。还可以用`http.ListenAndServe(":8080", router)`，或者自定义Http服务器配置。

```
//Run方法
func (engine *Engine) Run(addr ...string) (err error) {
    defer func() { debugPrintError(err) }()

    address := resolveAddress(addr)
    debugPrint("Listening and serving HTTP on %s\n", address)
    err = http.ListenAndServe(address, engine)
    return
}
```

## 路由

### 服务器

#### 默认服务器

如果不传端口号，默认8080

```
router.Run() 
```

从上面run方法可以看出吗，其内部也是调用的 `http.ListenAndServe()`，只是在这之前对端口进行了处理

还可以用 `http.ListenAndServe()`，比如

```go
func main() {
	router := gin.Default()
	router.GET("/", func(context *gin.Context) {
		context.String(http.StatusOK,"Hello World")
	})
	http.ListenAndServe("3000",router)
}
```

 `http.ListenAndServe()`方法内部调用

```
func ListenAndServe(addr string, handler Handler) error {
//初始化server
	server := &Server{Addr: addr, Handler: handler} 
	return server.ListenAndServe()
}
```

因此我们也可以自定义HTTP服务器的配置：

```
func main() {
	router := gin.Default()
	s := &http.Server{
		Addr: ":3000",
		Handler:router,
		ReadTimeout: 10 * time.Second,
		WriteTimeout: 10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	s.ListenAndServe()
}
```

当然Server还有很多其他配置，这里不一一列举

### 路由

#### 基本路由

gin框架中的基本路由采用的是`httprouter`

```
// 创建带有默认中间件的路由:
// 日志与恢复中间件
router := gin.Default()
//创建不带中间件的路由：
//r := gin.New()

router.GET("/someGet", getting)
router.POST("/somePost", posting)
router.PUT("/somePut", putting)
router.DELETE("/someDelete", deleting)
router.PATCH("/somePatch", patching)
router.HEAD("/someHead", head)
router.OPTIONS("/someOptions", options)
```

#### 路由参数

gin的路由来自httprouter库。因此httprouter具有的功能，gin也具有，不过gin不支持路由正则表达式。

##### api参数

api参数通过Context的Param方法来获取

```
router.GET("/user/:name", func(c *gin.Context) {
    name := c.Param("name")
    c.String(http.StatusOK, name)
})
```

运行后浏览器输入：http://127.0.0.1:3000/user/hanru运行

冒号`:`加上一个参数名组成路由参数。可以使用c.Params的方法读取其值。当然这个值是字串string。诸如`/user/hanru`，和`/user/hello`都可以匹配，而`/user/`和`/user/hanru/`不会被匹配。

```
router.GET("/user/:name/*action", func(c *gin.Context) {
    name := c.Param("name")
    action := c.Param("action")
    message := name + " is " + action
    c.String(http.StatusOK, message)
})
```

浏览器中输入：http://127.0.0.1:3000/user/hanru/send

##### URL参数

URL 参数通过 DefaultQuery 或 Query 方法获取。

对于参数的处理，经常会出现参数不存在的情况，对于是否提供默认值，gin也考虑了，并且给出了一个优雅的方案，使用c.DefaultQuery方法读取参数，其中当参数不存在的时候，提供一个默认值。使用Query方法读取正常参数，当参数不存在的时候，返回空字串。

```
func main() {
    router := gin.Default()
    router.GET("/welcome", func(c *gin.Context) {
        name := c.DefaultQuery("name", "Guest") //可设置默认值：”“
        //nickname := c.Query("nickname") // 是 c.Request.URL.Query().Get("nickname") 的简写
        c.String(http.StatusOK, fmt.Sprintf("Hello %s ", name))
    })
    router.Run(":3000")
}
```

##### 表单参数

常见的格式就有四种。例如`application/json`，`application/x-www-form-urlencoded`, `application/xml`和`multipart/form-data`。后面一个主要用于图片上传。json格式的很好理解，urlencode其实也不难，无非就是把query string的内容，放到了body体里，同样也需要urlencode。默认情况下，c.PostFROM解析的是`x-www-form-urlencoded`或`from-data`的参数。

表单参数通过 PostForm 方法获取：

```

func main() {

    router := gin.Default()
    //form
    router.POST("/form", func(c *gin.Context) {
        type1 := c.DefaultPostForm("type", "alert") //可设置默认值
        username := c.PostForm("username")
        password := c.PostForm("password")

        //hobbys := c.PostFormMap("hobby")
        //hobbys := c.QueryArray("hobby")
        hobbys := c.PostFormArray("hobby")

        c.String(http.StatusOK, fmt.Sprintf("type is %s, username is %s, password is %s,hobby is %v", type1, username, password,hobbys))

    })

    router.Run(":9527")
}
```

##### 文件上传

###### 上传单个文件

`multipart/form-data`用于文件上传。gin文件上传也很方便，和原生的net/http方法类似，不同在于gin把原生的request封装到c.Request中了。

```
func main() {
    router := gin.Default()
    // Set a lower memory limit for multipart forms (default is 32 MiB)
    // router.MaxMultipartMemory = 8 << 20  // 8 MiB
    router.POST("/upload", func(c *gin.Context) {
        // 单个文件
        file, _ := c.FormFile("file")
        log.Println(file.Filename)

        // Upload the file to specific dst.
        c.SaveUploadedFile(file, file.Filename)

        /*
        也可以直接使用io操作，拷贝文件数据。
        out, err := os.Create(filename)
        defer out.Close()
        _, err = io.Copy(out, file)
        */

        c.String(http.StatusOK, fmt.Sprintf("'%s' uploaded!", file.Filename))
    })
    router.Run(":8080")
}
```

使用`c.Request.FormFile`解析客户端文件name属性。如果不传文件，则会抛错，因此需要处理这个错误。此处我们略写了错误处理。一种是直接用c.SaveUploadedFile()保存文件。另一种方式是使用os的操作，把文件数据复制到硬盘上。

###### 上传多个文件

所谓多个文件，无非就是多一次遍历文件，然后一次copy数据存储即可。

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
    "fmt"
)

func main() {
    router := gin.Default()
    // Set a lower memory limit for multipart forms (default is 32 MiB)
    router.MaxMultipartMemory = 8 << 20 // 8 MiB
    //router.Static("/", "./public")
    router.POST("/upload", func(c *gin.Context) {

        // Multipart form
        form, err := c.MultipartForm()
        if err != nil {
            c.String(http.StatusBadRequest, fmt.Sprintf("get form err: %s", err.Error()))
            return
        }
        files := form.File["files"] 

        for _, file := range files {
            if err := c.SaveUploadedFile(file, file.Filename); err != nil {
                c.String(http.StatusBadRequest, fmt.Sprintf("upload file err: %s", err.Error()))
                return
            }
        }

        c.String(http.StatusOK, fmt.Sprintf("Uploaded successfully %d files ", len(files)))
    })
    router.Run(":8080")
}
```

##### Grouping routes

router group是为了方便一部分相同的URL的管理，在项目中也会经常用到，可以适配多种版本

```
package main
import (
    "github.com/gin-gonic/gin"
    "net/http"
    "fmt"
)

func main() {
    router := gin.Default()

    // Simple group: v1
    v1 := router.Group("/v1")
    {
        v1.GET("/login", loginEndpoint)
        v1.GET("/submit", submitEndpoint)
        v1.POST("/read", readEndpoint)
    }

    // Simple group: v2
    v2 := router.Group("/v2")
    {
        v2.POST("/login", loginEndpoint)
        v2.POST("/submit", submitEndpoint)
        v2.POST("/read", readEndpoint)
    }

    router.Run(":8080")
}
func loginEndpoint(c *gin.Context) {
    name := c.DefaultQuery("name", "Guest") //可设置默认值
    c.String(http.StatusOK, fmt.Sprintf("Hello %s \n", name))
}

func submitEndpoint(c *gin.Context) {
    name := c.DefaultQuery("name", "Guest") //可设置默认值
    c.String(http.StatusOK, fmt.Sprintf("Hello %s \n", name))
}

func readEndpoint(c *gin.Context) {
    name := c.DefaultQuery("name", "Guest") //可设置默认值
    c.String(http.StatusOK, fmt.Sprintf("Hello %s \n", name))
}
```

访问地址http://127.0.0.1:8080/v1/login?name=hanru

## Model

### 数据解析绑定

模型绑定可以将请求体绑定给一个类型。目前Gin支持JSON、XML、YAML和标准表单值的绑定。简单来说,，就是根据Body数据类型，将数据赋值到指定的结构体变量中 (类似于序列化和反序列化) 。

Gin提供了两套绑定方法：

- Must bind
  - 方法：Bind`,`BindJSON`,`BindXML`,`BindQuery`,`BindYAML
  - 行为：这些方法使用MustBindWith。如果存在绑定错误，则用c终止请求，使用`c.AbortWithError (400) .SetType (ErrorTypeBind)`即可。将响应状态代码设置为400，Content-Type header设置为`text/plain;charset = utf - 8`。请注意，如果在此之后设置响应代码，将会受到警告：`[GIN-debug][WARNING] Headers were already written. Wanted to override status code 400 with 422`将导致已经编写了警告[GIN-debug][warning]标头。如果想更好地控制行为，可以考虑使用ShouldBind等效方法。
- Should bind
  - 方法：ShouldBind`,`ShouldBindJSON`,`ShouldBindXML`,`ShouldBindQuery`,`ShouldBindYAML
  - 行为：这些方法使用ShouldBindWith。如果存在绑定错误，则返回错误，开发人员有责任适当地处理请求和错误

注意，使用绑定方法时，Gin 会根据请求头中 Content-Type 来自动判断需要解析的类型。如果你明确绑定的类型，你可以不用自动推断，而用 BindWith 方法。 你也可以指定某字段是必需的。如果一个字段被 `binding:"required"` 修饰而值却是空的，请求会失败并返回错误。

### JSON绑定

JSON的绑定，其实就是将request中的Body中的数据按照JSON格式进行解析，解析后存储到结构体对象中。

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

type Login struct {
    User     string `form:"username" json:"user" uri:"user" xml:"user"  binding:"required"`
    Password string `form:"password" json:"password" uri:"password" xml:"password" binding:"required"`
}

func main() {
    router := gin.Default()
    //1.binding JSON
    // Example for binding JSON ({"user": "hanru", "password": "hanru123"})
    router.POST("/loginJSON", func(c *gin.Context) {
        var json Login
        //其实就是将request中的Body中的数据按照JSON格式解析到json变量中
        if err := c.ShouldBindJSON(&json); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }
        if json.User != "hanru" || json.Password != "hanru123" {
            c.JSON(http.StatusUnauthorized, gin.H{"status": "unauthorized"})
            return
        }
        c.JSON(http.StatusOK, gin.H{"status": "you are logged in"})
    })

    router.Run(":8080")
}
```

前面我们使用c.String返回响应，顾名思义则返回string类型。content-type是plain或者text。调用c.JSON则返回json数据。其中gin.H封装了生成json的方式，是一个强大的工具。使用golang可以像动态语言一样写字面量的json，对于嵌套json的实现，嵌套gin.H即可。

### Form表单

其实本质是将c中的request中的body数据解析到form中。首先我们先看一下绑定普通表单的例子：

```
// 3. Form 绑定普通表单的例子
    // Example for binding a HTML form (user=hanru&password=hanru123)
    router.POST("/loginForm", func(c *gin.Context) {
        var form Login
        //方法一：对于FORM数据直接使用Bind函数, 默认使用使用form格式解析,if c.Bind(&form) == nil
        // 根据请求头中 content-type 自动推断.
        if err := c.Bind(&form); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        if form.User != "hanru" || form.Password != "hanru123" {
            c.JSON(http.StatusUnauthorized, gin.H{"status": "unauthorized"})
            return
        }

        c.JSON(http.StatusOK, gin.H{"status": "you are logged in"})
    })
```

方式二

```
    router.POST("/login", func(c *gin.Context) {
        var form Login
        //方法二: 使用BindWith函数,如果你明确知道数据的类型
        // 你可以显式声明来绑定多媒体表单：
        // c.BindWith(&form, binding.Form)
        // 或者使用自动推断:
        if c.BindWith(&form, binding.Form) == nil {
            if form.User == "user" && form.Password == "password" {
                c.JSON(200, gin.H{"status": "you are logged in ..... "})
            } else {
                c.JSON(401, gin.H{"status": "unauthorized"})
            }
        }
    })
```

### Uri绑定

```
// 5.URI
    router.GET("/:user/:password", func(c *gin.Context) {
        var login Login
        if err := c.ShouldBindUri(&login); err != nil {
            c.JSON(400, gin.H{"msg": err})
            return
        }
        c.JSON(200, gin.H{"username": login.User, "password": login.Password})
    })
```

## 响应

既然请求可以使用不同的content-type，响应也如此。通常响应会有html，text，plain，json和xml等。 gin提供了很优雅的渲染方法。

### JSON/XML/YAML渲染

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
    "github.com/gin-gonic/gin/testdata/protoexample"
)

func main() {
    r := gin.Default()

    // gin.H is a shortcut for map[string]interface{}
    r.GET("/someJSON", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})
    })

    r.GET("/moreJSON", func(c *gin.Context) {
        // You also can use a struct
        var msg struct {
            Name    string `json:"user"`
            Message string
            Number  int
        }
        msg.Name = "hanru"
        msg.Message = "hey"
        msg.Number = 123
        // 注意 msg.Name 变成了 "user" 字段
        // 以下方式都会输出 :   {"user": "hanru", "Message": "hey", "Number": 123}
        c.JSON(http.StatusOK, msg)
    })

    r.GET("/someXML", func(c *gin.Context) {
        c.XML(http.StatusOK, gin.H{"user":"hanru","message": "hey", "status": http.StatusOK})
    })

    r.GET("/someYAML", func(c *gin.Context) {
        c.YAML(http.StatusOK, gin.H{"message": "hey", "status": http.StatusOK})
    })

    r.GET("/someProtoBuf", func(c *gin.Context) {
        reps := []int64{int64(1), int64(2)}
        label := "test"
        // The specific definition of protobuf is written in the testdata/protoexample file.
        data := &protoexample.Test{
            Label: &label,
            Reps:  reps,
        }
        // Note that data becomes binary data in the response
        // Will output protoexample.Test protobuf serialized data
        c.ProtoBuf(http.StatusOK, data)
    })

    // Listen and serve on 0.0.0.0:8080
    r.Run(":8080")
}
```

### HTML模板渲染

gin支持加载HTML模板, 然后根据模板参数进行配置并返回相应的数据。

先要使用 `LoadHTMLGlob() `或者` LoadHTMLFiles()`方法来加载模板文件

```
func main() {
    router := gin.Default()
    //加载模板
    router.LoadHTMLGlob("templates/*")
    //router.LoadHTMLFiles("templates/template1.html", "templates/template2.html")
    //定义路由
    router.GET("/index", func(c *gin.Context) {
        //根据完整文件名渲染模板，并传递参数
        c.HTML(http.StatusOK, "index.tmpl", gin.H{
            "title": "Main website",
        })
    })
    router.Run(":8080")
}
```

创建一个目录：templates，然后在该目录下创建一个模板文件：

templates/index.tmpl

```
<html>
    <h1>
        {{ .title }}
    </h1>
</html>
```

运行项目，打开浏览器输入地址：http://127.0.0.1:8080/index

不同文件夹下模板名字可以相同，此时需要 LoadHTMLGlob() 加载两层模板路径。

```
router.LoadHTMLGlob("templates/**/*")
    router.GET("/posts/index", func(c *gin.Context) {
        c.HTML(http.StatusOK, "posts/index.tmpl", gin.H{
            "title": "Posts",
        })
        c.HTML(http.StatusOK, "users/index.tmpl", gin.H{
            "title": "Users",
        })

    })
```

gin也可以使用自定义的模板引擎，如下

```
import "html/template"

func main() {
    router := gin.Default()
    html := template.Must(template.ParseFiles("file1", "file2"))
    router.SetHTMLTemplate(html)
    router.Run(":8080")
}
```

### 文件响应

#### 静态文件服务

可以向客户端展示本地的一些文件信息，例如显示某路径下地文件。服务端代码是：

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    router := gin.Default()
    // 下面测试静态文件服务
    // 显示当前文件夹下的所有文件/或者指定文件
    router.StaticFS("/showDir", http.Dir("."))
    router.StaticFS("/files", http.Dir("/bin"))
    //Static提供给定文件系统根目录中的文件。
    //router.Static("/files", "/bin")
    router.StaticFile("/image", "./assets/miao.jpg")

    router.Run(":8080")
}
```

### 重定向

```
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    r := gin.Default()
    r.GET("/redirect", func(c *gin.Context) {
        //支持内部和外部的重定向
        c.Redirect(http.StatusMovedPermanently, "http://www.baidu.com/")
    })

    r.Run(":8080")
}
```

### 同步异步

goroutine 机制可以方便地实现异步处理。当在中间件或处理程序中启动新的Goroutines时，你不应该在原始上下文使用它，你必须使用只读的副本。

```
import (
    "time"
    "github.com/gin-gonic/gin"
    "log"
)

func main() {
    r := gin.Default()
    //1. 异步
    r.GET("/long_async", func(c *gin.Context) {
        // goroutine 中只能使用只读的上下文 c.Copy()
        cCp := c.Copy()
        go func() {
            time.Sleep(5 * time.Second)

            // 注意使用只读上下文
            log.Println("Done! in path " + cCp.Request.URL.Path)
        }()
    })
    //2. 同步
    r.GET("/long_sync", func(c *gin.Context) {
        time.Sleep(5 * time.Second)

        // 注意可以使用原始上下文
        log.Println("Done! in path " + c.Request.URL.Path)
    })

    // Listen and serve on 0.0.0.0:8080
    r.Run(":8080")
}
```

## 中间件middleware

golang的net/http设计的一大特点就是特别容易构建中间件。gin也提供了类似的中间件。需要注意的是中间件只对注册过的路由函数起作用。对于分组路由，嵌套使用中间件，可以限定中间件的作用范围。中间件分为全局中间件，单个路由中间件和群组中间件。

我们之前说过, `Context` 是 `Gin` 的核心, 它的构造如下:

```
type Context struct {
    writermem responseWriter
    Request   *http.Request
    Writer    ResponseWriter

    Params   Params
    handlers HandlersChain
    index    int8

    engine   *Engine
    Keys     map[string]interface{}
    Errors   errorMsgs
    Accepted []string
}
```

其中 `handlers` 我们通过源码可以知道就是 `[]HandlerFunc`. 而它的签名正是:

```
type HandlerFunc func(*Context)
```

所以中间件和我们普通的 `HandlerFunc` 没有任何区别对吧, 我们怎么写 `HandlerFunc` 就可以怎么写一个中间件.

### 全局中间件

定义一个中间件函数：

```
func MiddleWare() gin.HandlerFunc {
    return func(c *gin.Context) {
        t := time.Now()
        fmt.Println("before middleware")
        //设置request变量到Context的Key中,通过Get等函数可以取得
        c.Set("request", "client_request")
        //发送request之前
        c.Next()

        //发送requst之后

        // 这个c.Write是ResponseWriter,我们可以获得状态等信息
        status := c.Writer.Status()
        fmt.Println("after middleware,", status)
        t2 := time.Since(t)
        fmt.Println("time:", t2)
    }
}
```

该函数很简单，只会给c上下文添加一个属性，并赋值。后面的路由处理器，可以根据被中间件装饰后提取其值。需要注意，虽然名为全局中间件，只要注册中间件的过程之前设置的路由，将不会受注册的中间件所影响。只有注册了中间件以下代码的路由函数规则，才会被中间件装饰。

```
func main() {

	router := gin.Default()
	router.Use(MiddleWare())
	{
		router.GET("/middleware", func(c *gin.Context) {
			//获取用gin上下文中的变量
			request := c.MustGet("request").(string)
			req, _ := c.Get("request")
			fmt.Println("request:", request)
			c.JSON(http.StatusOK, gin.H{
				"middle_request": request,
				"request":        req,
			})
		})
	}

	router.Run(":3000")
}
```

使用router装饰中间件，然后在`/middlerware`即可读取request的值，注意在`router.Use(MiddleWare())`代码以上的路由函数，将不会有被中间件装饰的效果。

> 使用花括号包含被装饰的路由函数只是一个代码规范，即使没有被包含在内的路由函数，只要使用router进行路由，都等于被装饰了。想要区分权限范围，可以使用组返回的对象注册中间件。

### `Next()`方法

怎么解决一个请求和一个响应经过我们的中间件呢？神奇的语句出现了， 没错就是 `c.Next()`，所有中间件都有 `Request` 和 `Response` 的分水岭， 就是这个 `c.Next()`，否则没有办法传递中间件。

如果将`c.Next()`放在`fmt.Println("after middleware,", status)`后面，那么`fmt.Println("after middleware,", status)`和`fmt.Println("request:",request)`执行的顺序就调换了。所以一切都取决于`c.Next()`执行的位置。`c.Next()`的核心代码如下：

```
func (c *Context) Next() {
    c.index++
    // for循环，执行完后买呢所有的handlers
    for s := int8(len(c.handlers)); c.index < s; c.index++ {
        c.handlers[c.index](c)
    }
}
```

它其实是执行了后面所有的handlers。

一个请求过来， `Gin` 会主动调用 `c.Next()` 一次。因为 `handlers` 是 `slice` ，所以后来者中间件会追加到尾部。这样就形成了形如 `m1(m2(f()))` 的调用链。正如上面数字① ② 标注的一样, 我们会依次执行如下的调用：

```
m1① -> m2① -> f -> m2② -> m1②
```

另外，如果没有注册就使用`MustGet`方法读取c的值将会抛错，可以使用Get方法取而代之。上面的注册装饰方式，会让所有下面所写的代码都默认使用了router的注册过的中间件。

### 单个路由中间件

gin也提供了针对指定的路由函数进行注册。

```
router.GET("/before", MiddleWare(), func(c *gin.Context) {
        request := c.MustGet("request").(string)
        c.JSON(http.StatusOK, gin.H{
            "middile_request": request,
        })
    })
```

把上述代码写在` router.Use(Middleware())`之前，同样也能看见`/before`被装饰了中间件。

### 中间件实践

中间件最大的作用，莫过于用于一些记录log，错误handler，还有就是对部分接口的鉴权。下面就实现一个简易的鉴权中间件。

#### 简单认证BasicAuth

关于使用`gin.BasicAuth() middleware,` 可以直接使用一个`router group`进行处理, 本质和上面的一样。

定义私有数据：

```
// 模拟私有数据
var secrets = gin.H{
    "hanru":    gin.H{"email": "hanru@163.com", "phone": "123433"},
    "wangergou": gin.H{"email": "wangergou@example.com", "phone": "666"},
    "ruby":   gin.H{"email": "ruby@guapa.com", "phone": "523443"},
}
```

然后使用 gin.BasicAuth 中间件，设置授权用户

```
   authorized := r.Group("/admin", gin.BasicAuth(gin.Accounts{
        "hanru":    "hanru123",
        "wangergou": "1234",
        "ruby":   "hello2",
        "lucy":   "4321",
    }))
```

最后定义路由：

```
    authorized.GET("/secrets", func(c *gin.Context) {
        // 获取提交的用户名（AuthUserKey）
        user := c.MustGet(gin.AuthUserKey).(string)
        if secret, ok := secrets[user]; ok {
            c.JSON(http.StatusOK, gin.H{"user": user, "secret": secret})
        } else {
            c.JSON(http.StatusOK, gin.H{"user": user, "secret": "NO SECRET :("})
        }
    })
```

然后启动项目，打开浏览器输入以下网址：http://127.0.0.1:8080/admin/secrets

### 总结

1. 全局中间件` router.Use(gin.Logger()) router.Use(gin.Recovery())`
2. 单路由的中间件，可以加任意多个` router.GET("/benchmark", MyMiddelware(), benchEndpoint)`
3. 群组路由的中间件 `authorized := router.Group("/", MyMiddelware())`  或者这样用：` authorized := router.Group("/") authorized.Use(MyMiddelware()) { authorized.POST("/login", loginEndpoint) }`

## 