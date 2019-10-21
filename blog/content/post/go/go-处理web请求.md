---
layout:     post
title:      "go - 处理web请求"
subtitle:   ""
description: "主要记录go如和处理web数据处理的，包括get,post,文件上传，文件下载，数据返回格式"
excerpt: ""
date:       2018-03-13 19:25:21
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/03/13/goRequest/"
categories: [ go ]

---

web应用非常重要的功能之一就是接受来自客户端发起的请求，然后返回数据以完成与客服端的数据交互，这篇文章主要记录go在处理这些数据请求时常用的方法

## web请求

每个web请求都包含的三部分：***请求行***，***请求头***，***请求体***

### 请求方法

主要包含7种：`GET`,`POST`,`PUT`,`HEADER`,`PATCH`,`DELETE`,`OPTIONS`。其中常用的`GET`和`POST`请求

GET请求没有请求体body，请求数据一般通过`URL`中的`查询参数(query)`传给服务端

POST请求则会携带请求体，在请求体中带数据传递给服务端

### Content-Type

`Content-Type`是`请求头部(Header)`中一个用于指`请求实体`类型的内容头部，在请求或响应用于指`请求实体`到底存放什么样的数据，所以只有会推带`请求实体`的方法起作用，如`POST`方法。

Content-Type最常用取值：

1. `application/json`：JSON数据
2. `application/x-www-form-urlencoded`：form表单请求使用的类型，在发送前会编码所有字符
3. `multipart/form-data`：不对字符编码，一般用于文件上传
4. `text/html`：一般用于响应中的响应头，告诉客户端返回的是HTML文档。

### 查询参数(query)

查询参数是URL中?后面跟着的部分，如URL中的query=Go&type=1`,这个部分,查询参数由&分隔开，这是GET方法携带数据的方式

### 请求实体(body)

`请求实体`是一次Web请求中数据携带部分，一般只有POST请求才有这个部分，服务器由Content-Type首部来判断`请求实体`的内容编码格式，如果想向服务器发送大量数据，一般都用POST请求。

## go处理Web请求数据

### Request

在Go语言中，使用`http.Request`结构来处理http请求的数据

```go
http.HandleFunc("/hello", func(writer http.ResponseWriter, request *http.Request) {
    //使用request可以获取http请求的数据
})
```

request公开访问的字段

```go
type Request struct {
        Method string //方法:POST,GET...
        URL *url.URL //URL结构体
        Proto      string // 协议："HTTP/1.0"
        ProtoMajor int    // 1
        ProtoMinor int    // 0
        Header Header    //头部信息
        Body io.ReadCloser //请求实体
        GetBody func() (io.ReadCloser, error) // Go 1.8
        ContentLength int64  //首部：Content-Length
        TransferEncoding []string
        Close bool           //是否已关闭
        Host string          //首部Host
        Form url.Values      //参数查询的数据
        PostForm url.Values // application/x-www-form-urlencoded类型的body解码后的数据
        MultipartForm *multipart.Form //文件上传时的数据
        Trailer Header
        RemoteAddr string          //请求地址
        RequestURI string          //请求的url地址
        TLS *tls.ConnectionState
        Cancel <-chan struct{} // 
        Response *Response //      响应数据
}
```

#### 获取请求头（Header）

对于常用的请求头部信息，http.Request结构有对应的字段和方法，如下所示：

```go
http.HandleFunc("/hello", func(writer http.ResponseWriter, request *http.Request) {
    request.RemoteAddr
    request.RequestURI
    request.ContentLength 
    request.Proto
    request.Method 
    request.Referer()
    request.UserAgent()
})
```

当然，其他的信息可以通过request.Header字段来获取，request.Header的定义如下所示：

```go
type Header map[string][]string
```

也就是说,request.Header是一个的类型是map，另外request.Header也提供相应的方法来获取和设置请求头，如下所示：

```go
// CanonicalHeaderKey.
func (h Header) Add(key, value string)
func (h Header) Set(key, value string) 
func (h Header) Get(key string) string 
func (h Header) get(key string) string
func (h Header) has(key string) bool 
func (h Header) Del(key string) 
func (h Header) Write(w io.Writer) error 
func (h Header) write(w io.Writer, trace *httptrace.ClientTrace) error 
func (h Header) clone() Header 
```

也就是说，我们除了使用上面的方法获取头部信息外，也可以使用request.Header来获取，示例：

```go
http.HandleFunc("/hello", func(writer http.ResponseWriter, request *http.Request) {
    request.Header.Get("Content-Type")//返回的是string
    request.Header["Content-Type"] //返回的是[]string
})
```

#### 获取查询参数(Query)

如何获取查询参数(url中?后面使用&分隔的部分)呢？可以使用`request.FormValue(key)`方法获取查询参数，其中key为参数的名称，代码如下：

```go
func main() {
	http.HandleFunc("/userInfo",userInfo)
	fmt.Printf("listening...")
	err := http.ListenAndServe(":3000",nil)
	if err != nil {
		log.Fatalln(err)
	}
}
func userInfo(w http.ResponseWriter, r *http.Request) {
	username := r.FormValue("username")
	gender := r.FormValue("gender")
	fmt.Fprintln(w,fmt.Sprintf("用户名：%s,性别:%s",username,gender))
}
```

执行 `http://localhost:3000/userInfo?username="xiaoxiao"&gender="1"`会得到结果：

```go
用户名："xiaoxiao",性别:"1"
```

#### 获取表单信息(Form)

我们说获取表单信息，一般是指获取Content-Type是`application/x-www-form-urlencoded`或`multipart/form-data`时，`请求实体`中的数据，如果你有做传统网页中的表单提交数据的经历，相信对这两种提交数据的方式应该是熟悉的，而`multipart/form-data`一般是用来上传文件的。

##### application/x-www-form-urlencoded

获取Content-Type为application/x-www-form-urlencoded时提交上来的数据，可以使用request.PostForm字段request.Form和request.PostFormValue(key)方法获取，但必须先调用request.ParseForm()将数据写入request.PostForm字段中。

步骤为：

1. 使用`request.ParseForm()`函数解析body参数，这时会将参数写入Form字段和PostForm字段当中。
2. 使用`request.Form`、`request.PostForm`或r`equest.PostFormValue(key)`都可以获取

注意，`request.Form`和`request.PostForm`的类型`url.Values`，结构定义如下

```go
type Values map[string][]string
```

示例如下：

```go
func main() {
	http.HandleFunc("/userInfo",userInfo)
	fmt.Printf("listening...")
	err := http.ListenAndServe(":3000",nil)
	if err != nil {
		log.Fatalln(err)
	}
}
func userInfo(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
		if err != nil{
			fmt.Fprintln(w,"解析错误")
		}
		username := r.PostForm["username"][0]
		gender := r.PostFormValue("gender")
		age := r.Form["age"][0]
		email := r.FormValue("email")

		ageInt , err := strconv.Atoi(age)
		genderInt, err := strconv.Atoi(gender)
  //转json
		personInfo, err := json.Marshal(Person{username,ageInt,genderInt,email})
  
  	w.Header().Set("Conten-Type", "application/json")
		w.Write(personInfo)
}
type Person struct {
	Name 	string 	`json:"name"` //首字母大写才能转json，可用`json:"name"`把最终返回数据转为其他名字
	Age  	int    	`json:"age"`
	Gender 	int 	`json:"gender"`
	Email	string 	`json:"email"`
}
```

postman请求

[postman](/img/go/go-requestpost01.png)

##### multipart/form-data 文件上传

获取`Content-Type`为`multipart/form-data`时提交上来的数据，步骤如下:

1. 使用`request.ParseMultipartForm(maxMemory)`，解析参数，将参数写入到MultipartForm字段当中，其中maxMemory为上传文件最大内存。
2. 使用`request.FormFile`(文件域)，可以获取上传的文件对象：`multipart.File`
3. 除了文件域，其中参数可以从`request.PostForm`字段获取，注意，此时不需要再调用`request.ParseForm()`了

```go
// 定义上传文件路径
const BaseUploadPath = "./upload"

func main() {
  //上传
	http.HandleFunc("/uploadFile",uploadFile)
  //下载
  http.HandleFunc("/dowloadFile",dowloadFile)
	fmt.Printf("listening...")
	err := http.ListenAndServe(":3000",nil)
	if err != nil {
		log.Fatalln("server run error :",err)
	}
}

func uploadFile(w http.ResponseWriter, r *http.Request) {

	// 文件只允许POST方法
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_,_ = w.Write([]byte("Mehtod not allowed"))
		return
	}

	// 读取信息
	username := r.FormValue("username")

	// 从表单中读取文件
	file, fileHeader, err := r.FormFile("file")
	if err != nil {
		_, _ = io.WriteString(w,"Read file error")
		return
	}
	//defer 结束时关闭文件
	defer file.Close()
	log.Println("filename: " + fileHeader.Filename)

	//创建文件
	newFile, err := os.Create(BaseUploadPath + "/" + fileHeader.Filename)
	if err != nil {
		_, _ = io.WriteString(w, "Create file error")
		return
	}
	//defer 结束时关闭文件
	defer newFile.Close()

	//初始化返回结果
	result := new(BaseData)

	//将文件写到本地
	_, err = io.Copy(newFile, file)
	if err != nil {
		result.Status = "2"
		result.Mgs = "文件写入失败"
		resultStr, _ := json.Marshal(result)
		w.Write(resultStr)
		return
	}

	result.Status = "1"
	result.Mgs = "上传成功"
	result.Data = username
	resultStr, _ := json.Marshal(result)
	w.Write(resultStr)
}
```

##### 文件下载

```go

//4.文件下载
func dowloadFile(w http.ResponseWriter, request *http.Request)  {

	//文件上传只允许GET方法
	if request.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_, _ = w.Write([]byte("Method not allowed"))
		return
	}
	//文件名
	filename := request.FormValue("filename")
	if filename == "" {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = io.WriteString(w, "Bad request")
		return
	}
	log.Println("filename: " + filename)

	//打开文件
	file, err := os.Open(BaseUploadPath + "/" + filename)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = io.WriteString(w, "Bad request")
		return
	}

	//结束后关闭文件
	defer file.Close()

	//设置响应的header头
	w.Header().Add("Content-type", "application/octet-stream")
	w.Header().Add("content-disposition", "attachment; filename=\""+filename+"\"")
	//将文件写至responseBody
	_, err = io.Copy(w, file)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = io.WriteString(w, "Bad request")
		return
	}
}
```



**参考文章**：

[Go 如何处理web请求](https://juejin.im/post/5c9a26016fb9a070b0487146)











