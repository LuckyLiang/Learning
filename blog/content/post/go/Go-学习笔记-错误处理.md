---
layout:     post
title:      "Go 学习笔记（七） - 错误处理"
subtitle:   ""
description: "go学习笔记 - 错误处理"
excerpt: ""
date:       2018-02-09 19:35:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/02/09/goError/"
categories: [ go ]

---

错误指出程序中的异常情况。假设我们正在尝试打开一个文件，文件系统中不存在这个文件。这是一个异常情况，它表示为一个错误。

Go中的错误也是一种类型。错误用内置的`error` 类型表示。就像其他类型的，如int，float64，。错误值可以存储在变量中，从函数中返回，等等

### 如何使用错误

示例代码：

```
package main
import (  
    "fmt"
    "os"
)

func main() {  
    f, err := os.Open("/test.txt")
    if err != nil {
        fmt.Println(err)
        return
    }
  //根据f进行文件的读或写
    fmt.Println(f.Name(), "opened successfully")
}
```

处理错误的惯用方法是将返回的错误与nil进行比较。nil值表示没有发生错误，而非nil值表示出现错误。在我们的例子中，我们检查错误是否为nil。如果它不是nil，我们只需打印错误并从主函数返回。

运行结果：

```
open /test.txt: No such file or directory
```

我们得到一个错误，说明该文件不存在。

示例代码：

```
package main

import (
    "fmt"
    "errors"
)

func checkAge(age int) error {
    if age < 0 {
        //return errors.New("年龄不能为负数")
        // fmt包的Errorf函数的用武之地。这个函数根据一个格式说明器格式化错误，并返回一个字符串作为值来满足错误。
        return fmt.Errorf("age是：%d，年龄不能为负数", age)

    }
    fmt.Println("年龄无误，", age)
    return nil

}

func test()(int, int, error)  {
    return 1, 2, errors.New("啦啦啦")
}

func main() {
    /*
    在go中并不是像Java语言那样，有直接的异常处理机制。而是使用error.
    go中的error也是一种类型，内置接口类型的错误是表示错误条件的常规接口，nil值表示没有错误。

     */
    var e1 error // <nil>
    fmt.Println(e1)
    fmt.Printf("%T\n", e1) // <nil>

    //创建一个错误对象
    e2 := errors.New("错误了")
    fmt.Println(e2)        // 错误了
    fmt.Printf("%T\n", e2) // *errors.errorString


    err:=checkAge(-30)
    if err == nil{
        fmt.Println("ok。。。")
    }else{
        fmt.Println("失败，，", err)
    }

    a, b, err:= test()
    fmt.Println(a, b, err)


    p1:= new(int)
    fmt.Printf("%T,\n",p1)
    fmt.Println(*p1)

    p2:=new(string)
    fmt.Printf("%T\n",p2)
    fmt.Println(*p2)

}
```

### 错误类型表示

Go 语言通过内置的错误接口提供了非常简单的错误处理机制。

让我们再深入一点，看看如何定义错误类型的构建。错误是一个带有以下定义的接口类型，

```
type error interface {
    Error() string
}
```

它包含一个带有Error（）字符串的方法。任何实现这个接口的类型都可以作为一个错误使用。这个方法提供了对错误的描述。

#### 从错误中提取更多信息的不同方法

如果我们想要的是导致错误的文件的实际路径。一种可能的方法是解析错误字符串。这是我们程序的输出，

```
open /test.txt: No such file or directory
```

我们可以解析这个错误消息并从中获取文件路径"/test.txt"。但这是一个糟糕的方法。在新版本的语言中，错误描述可以随时更改，我们的代码将会中断。

标准Go库使用不同的方式提供更多关于错误的信息。让我们一看一看。

1. 断言底层结构类型并从结构字段获取更多信息

   ```
   type PathError struct {  
       Op   string
       Path string
       Err  error
   }
   
   func (e *PathError) Error() string { return e.Op + " " + e.Path + ": " + e.Err.Error() }
   ```

   从上面的代码中，您可以理解PathError通过声明错误（）string方法实现了错误接口。该方法连接操作、路径和实际错误并返回它。这样我们就得到了错误信息，

   ```
   open /test.txt: No such file or directory
   ```

   PathError结构的路径字段包含导致错误的文件的路径。让我们修改上面写的程序，并打印出路径。

   修改代码：

   ```
   package main
   
   import (  
       "fmt"
       "os"
   )
   
   func main() {  
       f, err := os.Open("/test.txt")
       if err, ok := err.(*os.PathError); ok {
           fmt.Println("File at path", err.Path, "failed to open")
           return
       }
       fmt.Println(f.Name(), "opened successfully")
   }
   ```

   在上面的程序中，我们使用类型断言获得错误接口的基本值。然后我们用错误来打印路径.这个程序输出,

   ```
   File at path /test.txt failed to open
   ```

2. 断言底层结构类型，并使用方法获取更多信息

   获得更多信息的第二种方法是断言底层类型，并通过调用struct类型的方法获取更多信息。

   ```
   type DNSError struct {  
       ...
   }
   
   func (e *DNSError) Error() string {  
       ...
   }
   func (e *DNSError) Timeout() bool {  
       ... 
   }
   func (e *DNSError) Temporary() bool {  
       ... 
   }
   ```

   从上面的代码中可以看到，`DNSError struct`有两个方法`Timeout() bool`和`Temporary() bool`，它们返回一个布尔值，表示错误是由于超时还是临时的。

   让我们编写一个断言*DNSError类型的程序，并调用这些方法来确定错误是临时的还是超时的。

   ```
   package main
   
   import (  
       "fmt"
       "net"
   )
   
   func main() {  
       addr, err := net.LookupHost("golangbot123.com")
       if err, ok := err.(*net.DNSError); ok {
           if err.Timeout() {
               fmt.Println("operation timed out")
           } else if err.Temporary() {
               fmt.Println("temporary error")
           } else {
               fmt.Println("generic error: ", err)
           }
           return
       }
       fmt.Println(addr)
   }
   ```

   在上面的程序中，我们正在尝试获取一个无效域名的ip地址，这是一个无效的域名。golangbot123.com。我们通过声明它来输入`*net.DNSError`来获得错误的潜在价值。

   在我们的例子中，错误既不是暂时的，也不是由于超时，因此程序会打印出来，

   ```
   generic error:  lookup golangbot123.com: no such host
   ```

   如果错误是临时的或超时的，那么相应的If语句就会执行，我们可以适当地处理它。

3. 直接比较

   直接与类型错误的变量进行比较。让我们通过一个例子来理解这个问题。

   `filepath`包的`Glob`函数用于返回与模式匹配的所有文件的名称。当模式出现错误时，该函数将返回一个错误`ErrBadPattern`。

   在filepath包中定义了ErrBadPattern，如下所述：

   ```
   var ErrBadPattern = errors.New("syntax error in pattern")
   ```

   `errors.New()`用于创建新的错误。

   当模式出现错误时，由`Glob`函数返回`ErrBadPattern`。

   ```
   package main
   
   import (  
       "fmt"
       "path/filepath"
   )
   
   func main() {  
       files, error := filepath.Glob("[")
       if error != nil && error == filepath.ErrBadPattern {
           fmt.Println(error)
           return
       }
       fmt.Println("matched files", files)
   }
   ```

   运行结果：

   ```
   syntax error in pattern
   ```

### 自定义错误

创建自定义错误的最简单方法是使用错误包的新功能。

在使用新函数创建自定义错误之前，让我们了解它是如何实现的。下面提供了错误包中的新功能的实现。

```
  package errors
  
  func New(text string) error {
      return &errorString{text}
  }
  // 错误描述
  type errorString struct {
      s string
  }
 // 实现接口
  func (e *errorString) Error() string {
      return e.s
  }
```

我们将创建一个简单的程序，计算一个圆的面积，如果半径为负，将返回一个错误。

```
package main

import (  
    "errors"
    "fmt"
    "math"
)

func circleArea(radius float64) (float64, error) {  
    if radius < 0 {
        return 0, errors.New("Area calculation failed, radius is less than zero")
    }
    return math.Pi * radius * radius, nil
}

func main() {  
    radius := -20.0
    area, err := circleArea(radius)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Printf("Area of circle %0.2f", area)
}
```

运行结果：

```
Area calculation failed, radius is less than zero
```

**使用Errorf向错误添加更多信息**

上面的程序运行得很好，但是如果我们打印出导致错误的实际半径，那就好了。这就是fmt包的Errorf函数的用武之地。这个函数根据一个格式说明器格式化错误，并返回一个字符串作为值来满足错误。

```
package main

import (  
    "fmt"
    "math"
)

func circleArea(radius float64) (float64, error) {  
    if radius < 0 {
    	//	格式化错误
        return 0, fmt.Errorf("Area calculation failed, radius %0.2f is less than zero", radius)
    }
    return math.Pi * radius * radius, nil
}

func main() {  
    radius := -20.0
    area, err := circleArea(radius)
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Printf("Area of circle %0.2f", area)
}
```

运行结果：

```
Area calculation failed, radius -20.00 is less than zero
```

**使用`struct`类型和字段提供关于错误的更多信息**

第一步是创建一个struct类型来表示错误。错误类型的命名约定是，名称应该以文本Error结束。让我们把struct类型命名为areaError

```
type areaError struct {  
    err    string
    radius float64
}
```

上面的struct类型有一个字段半径，它存储了为错误负责的半径的值，并且错误字段存储了实际的错误消息。

下一步，是实现error 接口

```
func (e *areaError) Error() string {  
    return fmt.Sprintf("radius %0.2f: %s", e.radius, e.err)
}
```

在上面的代码片段中，我们使用一个指针接收器区域错误来实现错误接口的Error() string方法。这个方法打印出半径和错误描述。

```
package main

import (  
    "fmt"
    "math"
)

type areaError struct {  
    err    string
    radius float64
}

func (e *areaError) Error() string {  
    return fmt.Sprintf("radius %0.2f: %s", e.radius, e.err)
}

func circleArea(radius float64) (float64, error) {  
    if radius < 0 {
        return 0, &areaError{"radius is negative", radius}
    }
    return math.Pi * radius * radius, nil
}

func main() {  
    radius := -20.0
    area, err := circleArea(radius)
    if err != nil {
        if err, ok := err.(*areaError); ok {
            fmt.Printf("Radius %0.2f is less than zero", err.radius)
            return
        }
        fmt.Println(err)
        return
    }
    fmt.Printf("Area of rectangle1 %0.2f", area)
}

```

程序输出：

```
Radius -20.00 is less than zero
```

**使用结构类型的方法提供关于错误的更多信息**

我们将编写一个程序来计算矩形的面积。如果长度或宽度小于0，这个程序将输出一个错误。

第一步是创建一个结构来表示错误。

```
type areaError struct {  
    err    string //error description
    length float64 //length which caused the error
    width  float64 //width which caused the error
}
```

上面的错误结构类型包含一个错误描述字段，以及导致错误的长度和宽度。

现在我们有了错误类型，让我们实现错误接口，并在错误类型上添加一些方法来提供关于错误的更多信息。

```
func (e *areaError) Error() string {  
    return e.err
}

func (e *areaError) lengthNegative() bool {  
    return e.length < 0
}

func (e *areaError) widthNegative() bool {  
    return e.width < 0
}
```

下一步是写出面积计算函数。

```
func rectArea(length, width float64) (float64, error) {  
    err := ""
    if length < 0 {
        err += "length is less than zero"
    }
    if width < 0 {
        if err == "" {
            err = "width is less than zero"
        } else {
            err += ", width is less than zero"
        }
    }
    if err != "" {
        return 0, &areaError{err, length, width}
    }
    return length * width, nil
}
```

主函数：

```
func main() {  
    length, width := -5.0, -9.0
    area, err := rectArea(length, width)
    if err != nil {
        if err, ok := err.(*areaError); ok {
            if err.lengthNegative() {
                fmt.Printf("error: length %0.2f is less than zero\n", err.length)

            }
            if err.widthNegative() {
                fmt.Printf("error: width %0.2f is less than zero\n", err.width)

            }
            return
        }
        fmt.Println(err)
        return
    }
    fmt.Println("area of rect", area)
}
```

运行结果：

```
error: length -5.00 is less than zero  
error: width -9.00 is less than zero
```

### Panic和Recover

go不支持传统的 `try...catch...finally`这种异常，在go中使用多值返回来返回错误，不要用异常代替错误，更不要用来控制流程。

也就是说，遇到真正的异常的情况下（比如除数为0了）。 才使用Go中引入的Exception处理：`defer`, `panic`, `recover`。

**Panic和Recover**

Go没有像Java那样的异常机制，它不能抛出异常，而是使用了`panic`和`recover`机制。一定要记住，你应当把它作为最后的手段来使用，也就是说，你的代码中应当没有，或者很少有`panic`的东西。这是个强大的工具，请明智地使用它。那么，我们应该如何使用它呢？

`Panic`是一个内建函数，可以中断原有的控制流程，进入一个令人恐慌的流程中。当函数F调用`panic`，函数F的执行被中断，但是F中的延迟函数会正常执行，然后F返回到调用它的地方。在调用的地方，F的行为就像调用了`panic`。这一过程继续向上，直到发生`panic`的`goroutine`中所有调用的函数返回，此时程序退出。恐慌可以直接调用`panic`产生。也可以由运行时错误产生，例如访问越界的数组。

`Recover`是一个内建的函数，可以让进入令人恐慌的流程中的`goroutine`恢复过来。`recover`仅在延迟函数中有效。**在正常的执行过程中，调用recover会返回nil，并且没有其它任何效果。如果当前的goroutine陷入恐慌，调用recover可以捕获到panic的输入值，并且恢复正常的执行。**

下面这个函数演示了如何在过程中使用`panic`

```
var user = os.Getenv("USER")
  func init() {
    if user == "" {
        panic("no value for $USER")
    }
}
```

下面这个函数检查作为其参数的函数在执行时是否会产生panic：

```
func throwsPanic(f func()) (b bool) {
  defer func() {
    if x := recover(); x != nil {
       b = true
    }
  }()
    f() //执行函数f，如果f中出现了panic，那么就可以恢复回来
    return
}
```

示例代码：

```
package main

import "fmt"

func main()  {
    /*
    panic:词意"恐慌"
        内建函数，可以中断原有的控制流程。进入一个恐慌中。
    recover:词意"恢复"
        通过恢复正常的执行并检索传递给panic的调用的错误值来停止恐慌序列

    注意：panic可以在任何地方引发，但是recover只能在defer函数中有效

     */
     testA()
     testB()
     testC()

}

func testA()  {
    fmt.Println("\t函数A。。。")
}

func testB()  {
    defer func() { // 必须是要先声明defer，否则不能捕获到panic异常
        if r:= recover(); r != nil{ // 这里的err其实就是panic传入的内容
            fmt.Println(r,"revocer....")
        }
    }()
    for i:=0;i<10;i++{
        fmt.Println("函数B。。。", i)
        if i == 5{
            panic("panic....")

        }

    }

}

func testC()  {
    fmt.Println("\t函数C...")
}
```

运行结果:

```
	函数A。。。
函数B。。。 0
函数B。。。 1
函数B。。。 2
函数B。。。 3
函数B。。。 4
函数B。。。 5
panic.... revocer....
	函数C...

Process finished with exit code 0
```

