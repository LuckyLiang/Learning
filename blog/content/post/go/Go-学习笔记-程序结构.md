---
layout:     post
title:      "Go 学习笔记（一） - 程序结构"
subtitle:   ""
description: "读go圣经学习笔记 - 程序结构"
excerpt: ""
date:       2018-02-05 19:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/02/05/goStructure/"
categories: [ go ]

---

## 程序结构

### 命名

> Go语言中的函数名、变量名、常量名、类型名、语句标号和包名等所有的命名，都遵循一个简单的命名规则：一个名字必须以一个字母（Unicode字母）或下划线开头，后面可以跟任意数量的字母、数字或下划线。大写字母和小写字母是不同的：heapSort和Heapsort是两个不同的名字。

25个关键字

```
break      default       func     interface   select
case       defer         go       map         struct
chan       else          goto     package     switch
const      fallthrough   if       range       type
continue   for           import   return      var
```

大约30多个预定义的名字，比如int和true等

```
内建常量: true false iota nil

内建类型: int int8 int16 int32 int64
          uint uint8 uint16 uint32 uint64 uintptr
          float32 float64 complex128 complex64
          bool byte rune string error

内建函数: make len cap new append copy close delete
          complex real imag
          panic recover
```

Go语言的风格是尽量使用短小的名字，对于局部变量尤其是这样

在习惯上，Go语言程序员推荐使用 **驼峰式** 命名

### 声明

Go语言主要有四种类型的声明语句：`var`、`const`、`type`和`func`，分别对应变量、常量、类型和函数实体对象的声明。

```
package main
import "fmt"
const boilingF = 212.0 //常量声明
func main() {
    var f = boilingF //局部变量声明
    var c = (f - 32) * 5 / 9 //局部变量声明
    fmt.Printf("boiling point = %g°F or %g°C\n", f, c)
    // Output:
    // boiling point = 212°F or 100°C
    
    const freezingF, boilingF = 32.0, 212.0
    fmt.Printf("%g°F = %g°C\n", freezingF, fToC(freezingF)) // "32°F = 0°C"
}

//函数声明
func fToC(f float64) float64 {
    return (f - 32) * 5 / 9
}
```

### 变量

使用`var`声明语句可以创建一个特定类型的变量

```
var 变量名字 类型 = 表达式
```

如果初始化表达式被省略，那么将用**零值初始化**该变量

数值类型变量对应的零值是0，布尔类型变量对应的零值是false，字符串类型对应的零值是空字符串，接口或引用类型（包括slice、指针、map、chan和函数）变量对应的零值是nil。数组或结构体等聚合类型对应的零值是每个元素或字段都是对应该类型的零值。

```
var s string
fmt.Println(s) // ""
//声明一组变量
var i, j, k int                 // int, int, int
var b, f, s = true, 2.3, "four" // bool, float64, string

//一组变量也可以通过调用一个函数，由函数返回的多个返回值初始化：
var f, err = os.Open(name) // os.Open returns a file and an error
```

在包级别声明的变量会在main入口函数执行前完成初始化, 局部变量将在声明语句被执行到的时候完成初始化。

### 简短变量声明

在函数内部，有一种称为简短变量声明语句的形式可用于声明和初始化局部变量

```
anim := gif.GIF{LoopCount: nframes}
freq := rand.Float64() * 3.0
t := 0.0
i, j := 0, 1 //声明一组变量
i, j = j, i // 交换 i 和 j 的值
```

#### 指针

一个指针的值是另一个变量的地址。一个指针对应变量在内存中的存储位置

通过指针，我们可以直接读或更新对应变量的值，而不需要知道该变量的名字（如果变量有名字的话）。

```
x := 1
p := &x         // p, of type *int, points to x
fmt.Println(*p) // "1"
*p = 2          // equivalent to x = 2
fmt.Println(x)  // "2"
```

任何类型的指针的零值都是nil。

指针之间也是可以进行相等测试的，只有当它们指向同一个变量或全部是nil时才相等。

```
var x, y int 
fmt.Println(&x == &x, &x == &y, &x == nil) // "true false false"
```

### `new`函数

另一个创建变量的方法是调用内建的new函数。表达式new(T)将创建一个T类型的匿名变量，初始化为T类型的零值，然后返回变量地址，返回的指针类型为`*T`。

```
p := new(int)   // p, *int 类型, 指向匿名的 int 变量
fmt.Println(*p) // "0"
*p = 2          // 设置 int 匿名变量的值为 2
fmt.Println(*p) // "2"
```

### 变量的生命周期

对于在包一级声明的变量来说，它们的生命周期和整个程序的运行周期是一致的

局部变量的生命周期则是动态的：每次从创建一个新变量的声明语句开始，直到该变量不再被引用为止，然后变量的存储空间可能被回收

函数的参数变量和返回值变量都是局部变量。它们在函数每次被调用的时候创建。

### 赋值

```
x = 1                       // 命名变量的赋值
*p = true                   // 通过指针间接赋值
person.name = "bob"         // 结构体字段赋值
count[x] = count[x] * scale // 数组、slice或map的元素赋值
//二元算术运算符和赋值语句的复合操作有一个简洁形式
count[x] *= scale
```

数值变量也可以支持`++`递增和`--`递减语句

```
v := 1
v++    // 等价方式 v = v + 1；v 变成 2
v--    // 等价方式 v = v - 1；v 变成 1
```

### 元组赋值

```
x, y = y, x
a[i], a[j] = a[j], a[i]
```

元组赋值也可以使一系列琐碎赋值更加紧凑 (特别是在for循环的初始化部分)

```
i, j, k = 2, 3, 5
```

表达式会产生多个值

```
f, err = os.Open("foo.txt") // function call returns two values
```

和变量声明一样，我们可以用下划线空白标识符`_`来丢弃不需要的值。

```
_, err = io.Copy(dst, src) // 丢弃字节数
_, ok = x.(T)              // 只检测类型，忽略具体值
```

### 类型

一个类型声明语句

```
type 类型名字 底层类型
```

类型声明语句一般出现在包一级，因此如果新创建的类型名字的首字符大写，则在包外部也可以使用。

```
package tempconv
import "fmt"
type Celsius float64    // 摄氏温度
type Fahrenheit float64 // 华氏温度
const (
    AbsoluteZeroC Celsius = -273.15 // 绝对零度
    FreezingC     Celsius = 0       // 结冰点温度
    BoilingC      Celsius = 100     // 沸水温度
)
func CToF(c Celsius) Fahrenheit { return Fahrenheit(c*9/5 + 32) }

func FToC(f Fahrenheit) Celsius { return Celsius((f - 32) * 5 / 9) }
```

### 包和文件

Go语言中的包和其他语言的库或模块的概念类似，目的都是为了支持模块化、封装、单独编译和代码重用。

一个包的源代码保存在一个或多个以.go为文件后缀名的源文件中，通常一个包所在目录路径的后缀是包的导入路径；例如包gopl.io/ch1/helloworld对应的目录路径是$GOPATH/src/gopl.io/ch1/helloworld。也可以是项目的相对路径每个

包都对应一个独立的名字空间。例如，在image包中的Decode函数和在unicode/utf16包中的 Decode函数是不同的

### 导入包

```
package main

import (
    "fmt"
    "os"
    "strconv"
    "gopl.io/ch2/tempconv" //项目路径
)

func main() {
    for _, arg := range os.Args[1:] {
        t, err := strconv.ParseFloat(arg, 64)
        if err != nil {
            fmt.Fprintf(os.Stderr, "cf: %v\n", err)
            os.Exit(1)
        }
        f := tempconv.Fahrenheit(t)
        c := tempconv.Celsius(t)
        fmt.Printf("%s = %s, %s = %s\n",
            f, tempconv.FToC(f), c, tempconv.CToF(c))
    }
}
```

### 包的初始化

包的初始化首先是解决包级变量的依赖顺序，然后按照包级变量声明出现的顺序依次初始化

如果包中含有多个.go源文件，它们将按照发给编译器的顺序进行初始化，Go语言的构建工具首先会将.go文件根据文件名排序，然后依次调用编译器编译。

每个文件都可以包含多个init初始化函数

```
func init() { /* ... */ }
```

每个包在解决依赖的前提下，以导入声明的顺序初始化，每个包只会被初始化一次。

初始化工作是自下而上进行的，main包最后被初始化，以这种方式，可以确保在main函数执行之前，所有依赖的包都已经完成初始化工作了。