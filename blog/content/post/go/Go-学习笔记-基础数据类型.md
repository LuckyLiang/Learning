---
layout:     post
title:      "Go 学习笔记（二） - 基础数据类型"
subtitle:   ""
description: "读go圣经学习笔记 - 基础数据类型"
excerpt: ""
date:       2018-02-05 21:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/02/05/goBaseType/"
categories: [ go ]

---

## 基础数据类型

Go语言将数据类型分为四类：基础类型、复合类型、引用类型和接口类型。

- 基础类型：数字、字符串和布尔型等
- 复合数据类型：数组和结构体，是通过组合简单类型，来表达更加复杂的数据结构
- 引用类型：指针、切片、字典、函数、通道

### 整形

- 有符号整形：int8、int16、int32和int64，分别对应8、16、32、64bit大小的有符号整数
- 无符号整形：uint8、uint16、uint32和uint64四种无符号整数类型。

这里还有两种一般对应特定CPU平台机器字大小的有符号和无符号整数int和uint；其中int是应用最广泛的数值类型。这两种类型都有同样的大小，32或64bit，

还有一种无符号的整数类型uintptr，没有指定具体的bit大小但是足以容纳指针。uintptr类型只有在底层编程时才需要，

下面是Go语言中关于算术运算、逻辑运算和比较运算的二元运算符，它们按照优先级递减的顺序排列：

```
*      /      %      <<       >>     &       &^
+      -      |      ^
==     !=     <      <=       >      >=
&&
||
```

Go语言还提供了以下的bit位操作运算符，前面4个操作运算符并不区分是有符号还是无符号数：

```
&      位运算 AND
|      位运算 OR
^      位运算 XOR
&^     位清空 (AND NOT)
<<     左移
>>     右移
```

当使用fmt包打印一个数值时，我们可以用%d、%o或%x参数控制输出的进制格式，就像下面的例子：

```
o := 0666
fmt.Printf("%d %[1]o %#[1]o\n", o) // "438 666 0666"
x := int64(0xdeadbeef)
fmt.Printf("%d %[1]x %#[1]x %#[1]X\n", x)
// Output:
// 3735928559 deadbeef 0xdeadbeef 0XDEADBEEF
```

### 浮点数

Go语言提供了两种精度的浮点数，`float32`和`float64`

浮点数的范围极限值可以在math包找到, 常量math.MaxFloat32表示float32能表示的最大数值，大约是 3.4e38；对应的math.MaxFloat64常量大约是1.8e308。它们分别能表示的最小值近似为1.4e-45和4.9e-324。

```
var f float32 = 16777216 // 1 << 24
fmt.Println(f == f+1)    // "true"!
```

###  复数

Go语言提供了两种精度的复数类型：`complex64`和`complex128`,分别对应`float32`和`float64`两种浮点数精度

内置的`complex`函数用于构建复数,内建的`real`和`imag`函数分别返回复数的实部和虚部：

```
var x complex128 = complex(1, 2) // 1+2i
var y complex128 = complex(3, 4) // 3+4i
fmt.Println(x*y)                 // "(-5+10i)"
fmt.Println(real(x*y))           // "-5"
fmt.Println(imag(x*y))           // "10"
```

如果一个浮点数面值或一个十进制整数面值后面跟着一个i，例如3.141592i或2i，它将构成一个复数的虚部，复数的实部是0：

```
fmt.Println(1i * 1i) // "(-1+0i)", i^2 = -1
```

### 布尔型

`true`和`false`

布尔值可以和&&（AND）和||（OR）操作符结合，并且有短路行为：

```
s != "" && s[0] == 'x']
```

布尔值并不会隐式转换为数字值0或1，反之亦然。必须使用一个显式的if语句辅助转换：

```
i := 0
if b {
    i = 1
}
```

如果需要经常做类似的转换, 包装成一个函数会更方便:

```
func btoi(b bool) int {
    if b {
        return 1
    }
    return 0
}
```

数字到布尔型的逆转换则非常简单, 不过为了保持对称, 我们也可以包装一个函数:

```
// itob reports whether i is non-zero.
func itob(i int) bool { return i != 0 }
```

### 字符串

一个字符串是一个不可变的字节序列

`len`函数可以返回一个字符串中的字节数目

索引操作`s[i]`返回第i个字节的字节值，`i`必须满足`0 ≤ i< len(s)`条件约束。

```
s := "hello, world"
fmt.Println(len(s))     // "12"
fmt.Println(s[0], s[7]) // "104 119" ('h' and 'w')
```

如果试图访问超出字符串索引范围的字节将会导致panic异常：

```
c := s[len(s)] // panic: index out of range
```

子字符串操作`s[i:j]`

```
fmt.Println(s[0:5]) // "hello"
```

不管i还是j都可能被忽略，当它们被忽略时将采用0作为开始位置，采用len(s)作为结束的位置。

```
fmt.Println(s[:5]) // "hello"
fmt.Println(s[7:]) // "world"
fmt.Println(s[:])  // "hello, world"
```

`+`操作符将两个字符串连接构造一个新字符串：

```
fmt.Println("goodbye" + s[5:]) // "goodbye, world"
```

字符串可以用`==`和`<`进行比较；比较通过逐个字节比较完成的，因此比较的结果是字符串自然编码的顺序。

#### 字符串面值

在一个双引号包含的字符串面值中，可以用以反斜杠`\`开头的转义序列插入任意的数据。下面的换行、回车和制表符等是常见的ASCII控制代码的转义方式：

```
\a      响铃
\b      退格
\f      换页
\n      换行
\r      回车
\t      制表符
\v      垂直制表符
\'      单引号 (只用在 '\'' 形式的rune符号面值中)
\"      双引号 (只用在 "..." 形式的字符串面值中)
\\      反斜杠
```

一个十六进制的转义形式是`\xhh`，其中两个h表示十六进制数字（大写或小写都可以）。一个八进制转义形式是`\ooo`，包含三个八进制的o数字（0到7），但是不能超过`\377`（译注：对应一个字节的范围，十进制为255）

原生字符串面值用于编写正则表达式会很方便, 同时被广泛应用于HTML模板、JSON面值、命令行提示信息以及那些需要扩展到多行的场景。

```
const GoUsage = `Go is a tool for managing Go source code.

Usage:
    go command [arguments]
...`
```

我们可以使用一个简单的循环来统计字符串中字符的数目，像这样：

```
n := 0
for range s {
    n++
}
```

或者我们可以直接调用`utf8.RuneCountInString(s)`函数。

#### 字符串和Byte切片

标准库中有四个包对字符串处理尤为重要：`bytes`、`strings`、`strconv`和`unicode`包。

- `strings`包提供了许多如字符串的查询、替换、比较、截断、拆分和合并等功能。
- `bytes`包也提供了很多类似功能的函数，但是针对和字符串有着相同结构的`[]byte`类型。因为字符串是只读的，因此逐步构建字符串会导致很多分配和复制。在这种情况下，使用`bytes.Buffer`类型将会更有效
- `strconv`包提供了布尔型、整型数、浮点数和对应字符串的相互转换，还提供了双引号转义相关的转换。
- `unicode`包提供了`IsDigit`、`IsLetter`、`IsUpper`和`IsLower`等类似功能

`basename(s)`将看起来像是系统路径的前缀删除，同时将看似文件类型的后缀名部分删除：

```
fmt.Println(basename("a/b/c.go")) // "c"
fmt.Println(basename("c.d.go"))   // "c.d"
fmt.Println(basename("abc"))      // "abc"
```

这个简化版本使用了strings.LastIndex库函数：

```
func basename(s string) string {
    // Discard last '/' and everything before.
    for i := len(s) - 1; i >= 0; i-- {
        if s[i] == '/' {
            s = s[i+1:]
            break
        }
    }
    // Preserve everything before last '.'.
    for i := len(s) - 1; i >= 0; i-- {
        if s[i] == '.' {
            s = s[:i]
            break
        }
    }
    return s
}
```

让我们继续另一个字符串的例子。函数的功能是将一个表示整数值的字符串，每隔三个字符插入一个逗号分隔符，例如“12345”处理后成为“12,345”。

```
func comma(s string) string {
    n := len(s)
    if n <= 3 {
        return s
    }
    return comma(s[:n-3]) + "," + s[n-3:]
}
```

一个字符串是包含只读字节的数组，一旦创建，是不可变的。相比之下，一个字节`slice`的元素则可以自由地修改。

字符串和字节`slice`之间可以相互转换：

```
s := "abc"
b := []byte(s)
s2 := string(b)
```

为了避免转换中不必要的内存分配，`bytes`包和`strings`同时提供了许多实用函数。下面是`strings`包中的六个函数：

```
func Contains(s, substr string) bool
func Count(s, sep string) int
func Fields(s string) []string
func HasPrefix(s, prefix string) bool
func Index(s, sep string) int
func Join(a []string, sep string) string
```

`bytes`包中也对应的六个函数：

```
func Contains(b, subslice []byte) bool
func Count(s, sep []byte) int
func Fields(s []byte) [][]byte
func HasPrefix(s, prefix []byte) bool
func Index(s, sep []byte) int
func Join(s [][]byte, sep []byte) []byte
```

它们之间唯一的区别是字符串类型参数被替换成了字节`slice`类型的参数。

`bytes`包还提供了`Buffer`类型用于字节`slice`的缓存。一个`Buffer`开始是空的，但是随着`string`、`byte`或`[]byte`等类型数据的写入可以动态增长，一个`bytes.Buffer`变量并不需要初始化，因为零值也是有效的：

```
func intsToString(values []int) string {
    var buf bytes.Buffer
    buf.WriteByte('[')
    for i, v := range values {
        if i > 0 {
            buf.WriteString(", ")
        }
        fmt.Fprintf(&buf, "%d", v)
    }
    buf.WriteByte(']')
    return buf.String()
}

func main() {
    fmt.Println(intsToString([]int{1, 2, 3})) // "[1, 2, 3]"
}
```

#### 字符串和数字的转换

字符串和数值之间的转换由`strconv`包提供这类转换功能。

将一个整数转为字符串，一种方法是用`fmt.Sprintf`返回一个格式化的字符串；另一个方法是用`strconv.Itoa`(“整数到ASCII”)：

```Go
x := 123
y := fmt.Sprintf("%d", x)
fmt.Println(y, strconv.Itoa(x)) // "123 123"
```

`FormatInt`和`FormatUint`函数可以用不同的进制来格式化数字：

```
fmt.Println(strconv.FormatInt(int64(x), 2)) // "1111011"
```

`fmt.Printf`函数的`%b`、`%d`、`%o`和`%x`等参数提供功能往往比`strconv`包的`Format`函数方便很多，特别是在需要包含有附加额外信息的时候：

```
s := fmt.Sprintf("x=%b", x) // "x=1111011"
```

如果要将一个字符串解析为整数，可以使用`strconv`包的`Atoi`或`ParseInt`函数，还有用于解析无符号整数的ParseUint函数：

```
x, err := strconv.Atoi("123")             // x is an int
y, err := strconv.ParseInt("123", 10, 64) // base 10, up to 64 bits
```

`ParseInt`函数的第三个参数是用于指定整型数的大小；例如16表示`int16`，0则表示`int`。在任何情况下，返回的结果y总是`int64`类型，你可以通过强制类型转换将它转为更小的整数类型。

### 常量

常量表达式的值在**编译期计算**，而不是在**运行期**，每种常量的潜在类型都是基础类型：boolean、string或数字。

常量的值不可修改，这样可以防止在运行期被意外或恶意的修改

```
const pi = 3.14159 // approximately; math.Pi is a better approximation
//声明多个常量
const (
    e  = 2.71828182845904523536028747135266249775724709369995957496696763
    pi = 3.14159265358979323846264338327950288419716939937510582097494459
)
```

常量间的所有算术运算、逻辑运算和比较运算的结果也是常量，对常量的类型转换操作或以下函数调用都是返回常量结果：`len`、`cap`、`real`、`imag`、`complex`和`unsafe.Sizeof`

```
const noDelay time.Duration = 0
const timeout = 5 * time.Minute
fmt.Printf("%T %[1]v\n", noDelay)     // "time.Duration 0"
fmt.Printf("%T %[1]v\n", timeout)     // "time.Duration 5m0s"
fmt.Printf("%T %[1]v\n", time.Minute) // "time.Duration 1m0s"
```

如果是批量声明的常量，除了第一个外其它的常量右边的初始化表达式都可以省略，如果省略初始化表达式则表示使用前面常量的初始化表达式写法，对应的常量类型也一样的。例如：

```
const (
    a = 1
    b
    c = 2
    d
)
fmt.Println(a, b, c, d) // "1 1 2 2"
```

####  iota 常量生成器

它用于生成一组以相似规则初始化的常量，但是不用每行都写一遍初始化表达式。在一个const声明语句中，在第一个声明的常量所在的行，iota将会被置为0，然后在每一个有常量声明的行加一。

```
type Weekday int
const (
    Sunday Weekday = iota
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
)
```

复杂的常量表达式中使用iota， 给一个无符号整数的最低5bit的每个bit指定一个名字：

```
type Flags uint
const (
    FlagUp Flags = 1 << iota // is up
    FlagBroadcast            // supports broadcast access capability
    FlagLoopback             // is a loopback interface
    FlagPointToPoint         // belongs to a point-to-point link
    FlagMulticast            // supports multicast access capability
)
```

使用这些常量可以用于测试、设置或清除对应的bit位的值：

```
func IsUp(v Flags) bool     { return v&FlagUp == FlagUp }
func TurnDown(v *Flags)     { *v &^= FlagUp }
func SetBroadcast(v *Flags) { *v |= FlagBroadcast }
func IsCast(v Flags) bool   { return v&(FlagBroadcast|FlagMulticast) != 0 }

func main() {
    var v Flags = FlagMulticast | FlagUp
    fmt.Printf("%b %t\n", v, IsUp(v)) // "10001 true"
    TurnDown(&v)
    fmt.Printf("%b %t\n", v, IsUp(v)) // "10000 false"
    SetBroadcast(&v)
    fmt.Printf("%b %t\n", v, IsUp(v))   // "10010 false"
    fmt.Printf("%b %t\n", v, IsCast(v)) // "10010 true"
}
```

下面是一个更复杂的例子，每个常量都是1024的幂：

```
const (
    _ = 1 << (10 * iota)
    KiB // 1024
    MiB // 1048576
    GiB // 1073741824
    TiB // 1099511627776             (exceeds 1 << 32)
    PiB // 1125899906842624
    EiB // 1152921504606846976
    ZiB // 1180591620717411303424    (exceeds 1 << 64)
    YiB // 1208925819614629174706176
)
```

#### 无类型常量

六种未明确类型的常量类型，分别是无类型的布尔型、无类型的整数、无类型的字符、无类型的浮点数、无类型的复数、无类型的字符串。