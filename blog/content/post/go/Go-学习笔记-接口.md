---
layout:     post
title:      "Go 学习笔记（六） - 接口"
subtitle:   ""
description: "读go圣经学习笔记 - 接口"
excerpt: ""
date:       2018-02-08 22:45:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/02/08/goInterface/"
categories: [ go ]

---

在Go中，接口是一组方法签名。当类型为接口中的所有方法提供定义时，它被称为实现接口。

### 接口的定义语法

定义接口

```
/* 定义接口 */
type interface_name interface {
   method_name1 [return_type]
   method_name2 [return_type]
   method_name3 [return_type]
   ...
   method_namen [return_type]
}

/* 定义结构体 */
type struct_name struct {
   /* variables */
}

/* 实现接口方法 */
func (struct_name_variable struct_name) method_name1() [return_type] {
   /* 方法实现 */
}
...
func (struct_name_variable struct_name) method_namen() [return_type] {
   /* 方法实现*/
}
```

示例代码：

```
package main

import (
    "fmt"
)

type Phone interface {
    call()
}

type NokiaPhone struct {
}

func (nokiaPhone NokiaPhone) call() {
    fmt.Println("I am Nokia, I can call you!")
}

type IPhone struct {
}

func (iPhone IPhone) call() {
    fmt.Println("I am iPhone, I can call you!")
}

func main() {
    var phone Phone

    phone = new(NokiaPhone)
    phone.call()

    phone = new(IPhone)
    phone.call()

}
```

运行结果：

```
I am Nokia, I can call you!
I am iPhone, I can call you!
```

### 实现接口的条件

一个类型如果拥有一个接口需要的**所有方法**，那么这个类型就实现了这个接口。

例如，`*os.File`类型实现了`io.Reader`，`Writer`，`Closer`，和`ReadWriter`接口。`*bytes.Buffer`实现了`Reader`，`Writer`, 和`ReadWriter`这些接口

接口指定的规则非常简单：表达一个类型属于某个接口只要这个类型实现这个接口。所以：

```
var w io.Writer
w = os.Stdout           // OK: *os.File has Write method
w = new(bytes.Buffer)   // OK: *bytes.Buffer has Write method
w = time.Second         // compile error: time.Duration lacks Write method

var rwc io.ReadWriteCloser
rwc = os.Stdout         // OK: *os.File has Read, Write, Close methods
rwc = new(bytes.Buffer) // compile error: *bytes.Buffer lacks Close meth
```

这个规则甚至适用于等式右边本身也是一个接口类型

```
w = rwc                 // OK: io.ReadWriteCloser has Write method
rwc = w                 // compile error: io.Writer lacks Close method
```

### 空接口

使用空接口，可以实现各种类型的对象存储。

使用空接口，接收任意类型作为参数。也就是任意类型都可实现空接口

```

type Dog struct {
    age int
}

type Cat struct{
    weigh float64
}

type Animal1 interface {

}

//使用空接口，接收任意类型作为参数
func info(v interface{})  {
    fmt.Println(v)
}


func main()  {
    /*
    使用空接口，可以实现各种类型的对象存储。
     */
    d1:= Dog{1}
    d2 := Dog{2}
    c1 :=Cat{3.2}
    c2:=Cat{3.5}

    animals:=[4] Animal1{d1,d2,c1,c2}
    fmt.Println(animals)


    info(d1)
    info(c1)
    info("aaa")
    info(100)

    var i Animal1
    i = d1
    switch m:=i.(type) {
    case Dog:
        fmt.Println(m.age)
    case Cat:
        fmt.Println(m.weigh)

    }
}
```

### interface值

```
package main

import "fmt"

type Human struct {
    name  string
    age   int
    phone string
}
type Student struct {
    Human  //匿名字段
    school string
    loan   float32
}
type Employee struct {
    Human   //匿名字段
    company string
    money   float32
} //Human实现Sayhi方法
func (h Human) SayHi() {
    fmt.Printf("Hi, I am %s you can call me on %s\n", h.name, h.phone)
} //Human实现Sing方法
func (h Human) Sing(lyrics string) {
    fmt.Println("La la la la...", lyrics)
} //Employee重写Human的SayHi方法
func (e Employee) SayHi() {
    fmt.Printf("Hi, I am %s, I work at %s. Call me on %s\n", e.name,
        e.company, e.phone) //Yes you can split into 2 lines here.
}

// Interface Men被Human,Student和Employee实现
// 因为这三个类型都实现了这两个方法
type Men interface {
    SayHi()
    Sing(lyrics string)
}

func main() {
    mike := Student{Human{"Mike", 25, "222-222-XXX"}, "MIT", 0.00}
    paul := Student{Human{"Paul", 26, "111-222-XXX"}, "Harvard", 100}
    sam := Employee{Human{"Sam", 36, "444-222-XXX"}, "Golang Inc.", 1000}
    Tom := Employee{Human{"Sam", 36, "444-222-XXX"}, "Things Ltd.", 5000}
    //定义Men类型的变量i
    var i Men
    //i能存储Student
    i = mike
    fmt.Println("This is Mike, a Student:")
    i.SayHi()
    i.Sing("November rain")
    //i也能存储Employee
    i = Tom
    fmt.Println("This is Tom, an Employee:")
    i.SayHi()
    i.Sing("Born to be wild")
    //定义了slice Men
    fmt.Println("Let's use a slice of Men and see what happens")
    x := make([]Men, 3)
    //T这三个都是不同类型的元素，但是他们实现了interface同一个接口
    x[0], x[1], x[2] = paul, sam, mike
    for _, value := range x {
        value.SayHi()
    }
}
```

运行结果

```
    This is Mike, a Student:
    Hi, I am Mike you can call me on 222-222-XXX
    La la la la... November rain
    This is Tom, an Employee:
    Hi, I am Sam, I work at Things Ltd.. Call me on 444-222-XXX
    La la la la... Born to be wild
    Let's use a slice of Men and see what happens
    Hi, I am Paul you can call me on 111-222-XXX
    Hi, I am Sam, I work at Golang Inc.. Call me on 444-222-XXX
    Hi, I am Mike you can call me on 222-222-XXX
```

那么interface里面到底能存什么值呢？如果我们定义了一个interface的变量，那么这个变量里面可以存实现这个interface的任意类型的对象。例如上面例子中，我们定义了一个Men interface类型的变量m，那么m里面可以存Human、Student或者Employee值

### 警告：一个包含nil指针的接口不是nil接口

一个不包含任何值的nil接口值和一个刚好包含nil指针的接口值是不同的。这个细微区别产生了一个容易绊倒每个Go程序员的陷阱。

思考下面的程序。当debug变量设置为true时，main函数会将f函数的输出收集到一个bytes.Buffer类型中。

```
const debug = true

func main() {
    var buf *bytes.Buffer
    if debug {
        buf = new(bytes.Buffer) // enable collection of output
    }
    f(buf) // NOTE: subtly incorrect!
    
}

// If out is non-nil, output will be written to it.
func f(out io.Writer) {
    if out != nil {
        out.Write([]byte("done!\n"))
    }
}
```

当把变量debug设置为false时， 在out.Write方法调用时程序发生了panic：

```
if out != nil {
    out.Write([]byte("done!\n")) // panic: nil pointer dereference
}
```

当main函数调用函数f时，它给f函数的out参数赋了一个*bytes.Buffer的空指针，所以out的动态值是nil。

然而，它的动态类型是*bytes.Buffer，意思就是out变量是一个包含空指针值的非空接口

所以检查`out!=nil`的结果依然是`true`。

解决方法

```
var buf io.Writer
if debug {
    buf = new(bytes.Buffer) // enable collection of output
}
f(buf) // OK
```

### 判断接口的实际类型

1. a可能是任意类型
   a.(某个类型) 返回两个值 inst 和 ok ，ok代表是否是这个类型，Ok如果是 inst 就是转换后的类型。
2. a.(type) type是关键字 结合switch case使用
   TypeA(a) 是强制转换。

```
package main

import (
    "math"
    "fmt"
)

type Shape interface {
    area() float64
    peri() float64
}
type Triangle struct {
    a float64
    b float64
    c float64
}

func (t Triangle) peri() float64 {
    return t.a + t.b + t.c
}
func (t Triangle) area() float64 {
    p := t.peri() / 2
    area := math.Sqrt(p * (p - t.a) * (p - t.b) * (p - t.c))
    return area
}

type Circle struct {
    r float64
}

func (c Circle) peri() float64 {
    return 2 * math.Pi * c.r
}
func (c Circle) area() float64 {
    return math.Pi * c.r * c.r
}


//测试函数
func testArea(s Shape){ //s = t
    fmt.Println("面积：",s.area())
}
func testPeri(s Shape){
    fmt.Printf("周长：%.2f\n",s.peri())
}

//判断类型
func getType(s Shape){
    /*
    a可能是任意类型
    a.(某个类型) 返回两个值 inst 和 ok ，ok代表是否是这个类型，Ok如果是 inst 就是转换后的类型。
     */
    if inst,ok := s.(Triangle);ok{
        fmt.Println("是Triangle类型。。三边是：",inst.a,inst.b,inst.c)
    }else if inst,ok:=s.(Circle);ok{
        fmt.Println("是Circle类型，半径是：",inst.r)
    }else{
        fmt.Println("以上都不对。。")
    }
}
//
func getType2(s Shape){
    /*
    a.(type)    type是关键字 结合switch case使用
    TypeA(a) 是强制转换
     */
    switch inst:=s.(type) {
    case Triangle:
        fmt.Println("三角形啊。。",inst.a,inst.b,inst.c)
    case Circle:
        fmt.Println("圆形啊。。",inst.r)
    }
}


func main() {
    t := Triangle{3,4,5}

    testArea(t)
    c := Circle{2.5}
    testPeri(c)

    //定义一个接口类型的数组：Shape类型，可以存储该接口的任意实现类的对象作为数据。
    var arr[4] Shape
    arr[0] = t
    arr[1] = c
    arr[2] = Triangle{1,2,3}
    arr[3] = Circle{5}


    //判断类型
    getType(t)
    getType2(c)

}

/*
课堂练习题：
定义一个接口：形状
    定义两个方法：
        周长()
        面积()

定义三个结构体分别实现该接口：
    三角形：周长()，面积()
        海伦公式：
a,b,c
p = (a+b+c)/2
area = (p-a)*(p-b)*(p-c)开平方
    math.Sqrt()
    矩形：周长()，面积()
    圆形：周长()，面积()

在主函数中：分别创建三种形状的对象，并调用对应的周长和面积的方法

增加一个测试的的函数：
    testArea(接口形状)-->三角形，原型，矩形
    testPeri()-->三角形，圆形，矩形
 */
```

运行结果：

```
面积： 6
周长：15.71
是Triangle类型。。三边是： 3 4 5
圆形啊。。 2.5
```