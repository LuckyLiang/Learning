---
layout:     post
title:      "Go flag - 命令行参数解析"
subtitle:   ""
description: "go学习笔记 - flag命令行参数解析"
excerpt: ""
date:       2018-01-09 19:35:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/02/09/goflag/"
categories: [ go ]


---

# flag - 命令行参数解析

概念：
命令行参数（或参数）：是指运行程序时提供的参数

## 示例

以nginx为例 执行`nginx -h` 输出：

```shell
$ nginx -h
nginx version: nginx/1.17.8
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/local/Cellar/nginx/1.17.8/)
  -c filename   : set configuration file (default: /usr/local/etc/nginx/nginx.conf)
  -g directives : set global directives out of configuration file
```

然后通过flg实现类似Nginx的这个输出

```go
import (
	"flag"
	"fmt"
	"os"
)

var (
	h bool
	v, V bool
	t, T bool
	q  *bool

	s string
	p string
	c string
	g string
)

func init() {

	flag.BoolVar(&h, "h", false, "this help")
	flag.BoolVar(&v, "v", false, "show version and exit")
	flag.BoolVar(&V, "V", false, "show version and configure options then exit")

	flag.BoolVar(&t, "t", false, "test configuration and exit")
	flag.BoolVar(&T, "T", false, "test configuration, dump it and exit")

	// 另一种绑定方式
	q = flag.Bool("q", false, "suppress non-error messages during configuration testing")

	// 注意 `signal`。默认是 -s string，有了 `signal` 之后，变为 -s signal
	flag.StringVar(&s, "s", "", "send `signal` to a master process: stop, quit, reopen, reload")
	flag.StringVar(&p, "p", "/usr/local/nginx/", "set `prefix` path")
	flag.StringVar(&c, "c", "conf/nginx.conf", "set configuration `file`")
	flag.StringVar(&g, "g", "conf/nginx.conf", "set global `directives` out of configuration file")
	// 改变默认的 Usage,自定义输出
	flag.Usage = usage
}

func usage() {
	_, _ = fmt.Fprintf(os.Stderr, `nginx version: nginx/1.10.0
Usage: nginx [-hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
`)
	flag.PrintDefaults()
}

func FlagRun() {
	flag.Parse()
	if h {
		flag.Usage()
	}
}
```



```shell
$ go run main.go -h
nginx version: nginx/1.10.0
Usage: nginx [-hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -T    test configuration, dump it and exit
  -V    show version and configure options then exit
  -c file
        set configuration file (default "conf/nginx.conf")
  -g directives
        set global directives out of configuration file (default "conf/nginx.conf")
  -h    this help
  -p prefix
        set prefix path (default "/usr/local/nginx/")
  -q    suppress non-error messages during configuration testing
  -s signal
        send signal to a master process: stop, quit, reopen, reload
  -t    test configuration and exit
  -v    show version and exit

```

## flag包

`flag` 包实现了命令行参数的解析。

### 定义flags的方式

1. `flag.XXX()`,其中xxx可以是`Int， String`等，返回一个相应类型的指针

   ```go
   func Int(name string, value int, usage string) *int 
   func Bool(name string, value bool, usage string) *bool 
   func Int64(name string, value int64, usage string) *int64 
   func String(name string, value string, usage string) *string 
    ...
   ```

   例如：

   ```go
   var ip = flag.Int("flagname", 1234, "help message for flagname")
   var q = flag.Bool("q", false, "suppress non-error messages during configuration testing")
   var flag.String(&p, "p", "/usr/local/nginx/", "set `prefix` path")
   ```

2. 将 flag 绑定到一个变量上

   ```go
   func StringVar(p *string, name string, value string, usage string) 
   func IntVar(p *int, name string, value int, usage string) 
   ...
   ```

   如

   ```go
   var flagvar int
   flag.IntVar(&flagvar, "flagname", 1234, "help message for flagname")
   ```

其实第一种定义flags的方式也是调用的绑定变量的方式，比如：

```go
var q = flag.Bool("q", false, "suppress non-error messages during configuration testing")

//1.创建了CommandLine，其实是FlagSet
func Bool(name string, value bool, usage string) *bool {
	return CommandLine.Bool(name, value, usage)
}
//2.相当于定义了一个变量，然后调用绑定变量的方式
func (f *FlagSet) Bool(name string, value bool, usage string) *bool {
	p := new(bool) //申请一块储存bool值得地址
	f.BoolVar(p, name, value, usage) //内部会把value赋值给p: *p = value
	return p
}
//最终调用的绑定变量的方式
func (f *FlagSet) BoolVar(p *bool, name string, value bool, usage string) {
	f.Var(newBoolValue(value, p), name, usage)
}
```

### 自定义value

自定义`value`只要实现` flag.Value `接口即可（要求 `receiver` 是指针），这时候可以通过如下方式定义该 flag：

```go
type Value interface {
	String() string
	Set(string) error
}
type Getter interface {
	Value
	Get() interface{}
}
```

例如，解析我喜欢的编程语言，我们希望直接解析到 slice 中，我们可以定义如下 Value：

```go
package flagLearing

import (
	"flag"
	"fmt"
	"os"
	"strings"
)

//例如，解析我喜欢的编程语言，我们希望直接解析到 slice 中，我们可以定义如下 Value：

type sliceValue []string

func newSliceValue(vals []string, p *[]string) *sliceValue {
	*p = vals
	return (*sliceValue)(p)
}
//实现flag.Value接口
func (s *sliceValue) String() string {
	return strings.Join(*s,",")
}

func (s *sliceValue) Set(val string) error {
	*s = strings.Split(val,",")
	return nil
}
//实现flag.Getter接口
func (s *sliceValue) Get() interface{} {
	return ([]string)(*s)
}

var languages []string	//定义变量

func init() {
	flag.Var(newSliceValue([]string{}, &languages),"slice","I like programming languages")
	flag.Usage = sliceUsage
}

func sliceUsage() {
	_, _ = fmt.Fprintf(os.Stderr, "Usage: apppName -slice '[aaa, xxxx]' ")
	flag.PrintDefaults()
}
func FlagSliceRun() {
	flag.Parse()	//解析flag

	if len(languages) != 0 {
		fmt.Println(languages)
	}
}
```

运行结果

```go
$ go run main.go -slice "go, java"
[go  java]
```

### 解析flag

在所有的 flag 定义完成之后，可以通过调用 `flag.Parse()` 进行解析。

命令行 flag 的语法有如下三种形式：

```go
-flag // 只支持 bool 类型
-flag=x
-flag x // 只支持非 bool 类型
```

其中第三种形式只能用于非 bool 类型的 flag

## 类型和函数

在看类型和函数之前，先看一下变量。

ErrHelp：该错误类型用于当命令行指定了 · -help` 参数但没有定义时。

Usage：这是一个函数，用于输出所有定义了的命令行参数和帮助信息（usage message）。一般，当命令行参数解析出错时，该函数会被调用。我们可以指定自己的 Usage 函数，即：`flag.Usage = func(){}`

### 函数

go 标准库中，经常这么做：

> 定义了一个类型，提供了很多方法；为了方便使用，会实例化一个该类型的实例（通用），这样便可以直接使用该实例调用方法。比如：encoding/base64 中提供了 StdEncoding 和 URLEncoding 实例，使用时：base64.StdEncoding.Encode()

在 flag 包使用了有类似的方法，比如 CommandLine 实例，只不过 flag 进行了进一步封装：将 FlagSet 的方法都重新定义了一遍，也就是提供了一序列函数，而函数中只是简单的调用已经实例化好了的 FlagSet 实例：CommandLine 的方法。这样，使用者是这么调用：flag.Parse() 而不是 flag. CommandLine.Parse()。

###  类型（数据结构）

1. `ErrorHandling`

   ```go
   type ErrorHandling int
   ```

   该类型定义了在参数解析出错时错误处理方式。定义了三个该类型的常量：

   ```go
   const (
       ContinueOnError ErrorHandling = iota
       ExitOnError
       PanicOnError
   )
   ```

   三个常量在源码的 FlagSet 的方法 parseOne() 中使用了。

2. `Flag`

3. ```go
   type Flag struct {
   	Name     string // name as it appears on command line
   	Usage    string // help message
   	Value    Value  // value as set
   	DefValue string // default value (as text); for usage message
   }
   ```

   Flag 类型代表一个 flag 的状态。

   比如，对于命令：`./nginx -c /etc/nginx.conf`，相应代码是：

   ```go
   flag.StringVar(&c, "c", "conf/nginx.conf", "set configuration `file`")
   ```

   则该 Flag 实例（可以通过 `flag.Lookup("c")` 获得）相应各个字段的值为：

   ```go
   &Flag{
       Name: c,
       Usage: set configuration file,
       Value: /etc/nginx.conf,
       DefValue: conf/nginx.conf,
   }
   ```

3. `FlagSet`

   ```go
   type FlagSet struct {
      // Usage is the function called when an error occurs while parsing flags.
      // The field is a function (not a method) that may be changed to point to
      // a custom error handler. What happens after Usage is called depends
      // on the ErrorHandling setting; for the command line, this defaults
      // to ExitOnError, which exits the program after calling Usage.
      Usage func()
   
      name          string
      parsed        bool
      actual        map[string]*Flag
      formal        map[string]*Flag	//储存了Flag
      args          []string // arguments after flags
      errorHandling ErrorHandling
      output        io.Writer // nil means stderr; use out() accessor
   }
   ```

4. `Value` 接口

   ```go
   type Value interface {
       String() string
       Set(string) error
   }
   ```

   所有参数类型需要实现 Value 接口，flag 包中，为 int、float、bool 等实现了该接口。借助该接口，我们可以自定义 flag。（上文已经给了具体的例子）

## 主要类型的方法（包括类型实例化）

flag 包中主要是 FlagSet 类型。

###  实例化方式

`NewFlagSet()` 用于实例化 FlagSet。预定义的 FlagSet 实例 `CommandLine` 的定义方式：

```go
var CommandLine = NewFlagSet(os.Args[0], ExitOnError)
```

可见，默认的 FlagSet 实例在解析出错时会退出程序。

由于 FlagSet 中的字段没有 export，其他方式获得 FlagSet 实例后，比如：FlagSet{} 或 new(FlagSet)，应该调用 Init() 方法，以初始化 name 和 errorHandling，否则 name 为空，errorHandling 为 ContinueOnError。

### 定义 flag 参数的方法

这一序列的方法都有两种形式，在一开始已经说了两种方式的区别。这些方法用于定义某一类型的 flag 参数。

### 解析参数（Parse）

```go
func (f *FlagSet) Parse(arguments []string) error
```

从参数列表中解析定义的 flag。方法参数 arguments 不包括命令名，即应该是 os.Args[1:]。事实上，`flag.Parse()` 函数就是这么做的：

```go
// Parse parses the command-line flags from os.Args[1:].  Must be called
// after all flags are defined and before flags are accessed by the program.
func Parse() {
    // Ignore errors; CommandLine is set for ExitOnError.
    CommandLine.Parse(os.Args[1:])
}
```

如果提供了 `-help` 参数（命令中给了）但没有定义（代码中没有），该方法返回 `ErrHelp` 错误。默认的 CommandLine，在 Parse 出错时会退出程序（ExitOnError）。

为了更深入的理解，我们看一下 `Parse(arguments []string)` 的源码：

```go
func (f *FlagSet) Parse(arguments []string) error {
    f.parsed = true
    f.args = arguments
    for {
        seen, err := f.parseOne()
        if seen {
            continue
        }
        if err == nil {
            break
        }
        switch f.errorHandling {
        case ContinueOnError:
            return err
        case ExitOnError:
            os.Exit(2)
        case PanicOnError:
            panic(err)
        }
    }
    return nil
}
```

真正解析参数的方法是非导出方法 `parseOne`。

结合 `parseOne` 方法，我们来解释 `non-flag` 以及包文档中的这句话：

> Flag parsing stops just before the first non-flag argument ("-" is a non-flag argument) or after the terminator "--".

我们需要了解解析什么时候停止。

根据 Parse() 中 for 循环终止的条件（不考虑解析出错），我们知道，当 parseOne 返回 `false, nil` 时，Parse 解析终止。正常解析完成我们不考虑。看一下 parseOne 的源码发现，有两处会返回 `false, nil`。

1）第一个 non-flag 参数

```go
s := f.args[0]
if len(s) == 0 || s[0] != '-' || len(s) == 1 {
    return false, nil
}
```

也就是，当遇到单独的一个 "-" 或不是 "-" 开始时，会停止解析。比如：

> ./nginx - -c 或 ./nginx build -c

这两种情况，`-c` 都不会被正确解析。像该例子中的 "-" 或 build（以及之后的参数），我们称之为 `non-flag` 参数。

2）两个连续的 "--"

```go
if s[1] == '-' {
    num_minuses++
    if len(s) == 2 { // "--" terminates the flags
        f.args = f.args[1:]
        return false, nil
    }
}
```

也就是，当遇到连续的两个 "-" 时，解析停止。

*说明：这里说的 "-" 和 "--"，位置和 "-c" 这种的一样。*也就是说，下面这种情况并不是这里说的：

> ./nginx -c --

这里的 "--" 会被当成是 `c` 的值

parseOne 方法中接下来是处理 `-flag=x` 这种形式，然后是 `-flag` 这种形式（bool 类型）（这里对 bool 进行了特殊处理），接着是 `-flag x` 这种形式，最后，将解析成功的 Flag 实例存入 FlagSet 的 actual map 中。

另外，在 parseOne 中有这么一句：

```
f.args = f.args[1:]
```

也就是说，每执行成功一次 parseOne，f.args 会少一个。所以，FlagSet 中的 args 最后留下来的就是所有 `non-flag` 参数。

### Arg(i int) 和 Args()、NArg()、NFlag()

Arg(i int) 和 Args() 这两个方法就是获取 `non-flag` 参数的；NArg() 获得 `non-flag` 的个数；NFlag() 获得 FlagSet 中 actual 长度（即被设置了的参数个数）。

###  Visit/VisitAll

这两个函数分别用于访问 FlatSet 的 actual 和 formal 中的 Flag，而具体的访问方式由调用者决定。

### PrintDefaults()

打印所有已定义参数的默认值（调用 VisitAll 实现），默认输出到标准错误，除非指定了 FlagSet 的 output（通过 SetOutput() 设置）

### Set(name, value string)

设置某个 flag 的值（通过 name 查找到对应的 Flag）















