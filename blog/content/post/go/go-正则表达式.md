---
layout:     post
title:      "go - 正则表达式"
subtitle:   ""
description: "正则表达式(regular expression) retular:词意:正则，正规，规则，规律 expression：表达式"
excerpt: ""
date:       2018-03-15 21:25:23
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - go
URL: "/2018/03/15/goExpress/"
categories: [ go ]



---

## 正则的使用

golang中的正则和其他语言的用法，没有太多的差别。只是方法上稍微不同。

### 2.1 常用的方法以及说明

```
//判断在 b（s、r）中能否找到 pattern 所匹配的字符串 
func Match(pattern string, b []byte) (matched bool, err error)
func MatchString(pattern string, s string) (matched bool, err error)
func MatchReader(pattern string, r io.RuneReader) (matched bool, err error)
// 将 s 中的正则表达式元字符转义成普通字符。
func QuoteMeta(s string) string

// Regexp 代表一个编译好的正则表达式，我们这里称之为正则对象。正则对象可以
// 在文本中查找匹配的内容。
//
// Regexp 可以安全的在多个例程中并行使用。
type Regexp struct { ... }

------------------------------

// 1.编译

// 将正则表达式编译成一个正则对象（使用 PERL 语法）。
// 该正则对象会采用“leftmost-first”模式。选择第一个匹配结果。
// 如果正则表达式语法错误，则返回错误信息。
func Compile(expr string) (*Regexp, error)

// 将正则表达式编译成一个正则对象（正则语法限制在 POSIX ERE 范围内）。
// 该正则对象会采用“leftmost-longest”模式。选择最长的匹配结果。
// POSIX 语法不支持 Perl 的语法格式：\d、\D、\s、\S、\w、\W
// 如果正则表达式语法错误，则返回错误信息。
func CompilePOSIX(expr string) (*Regexp, error)

// 功能同上，但会在解析失败时 panic
func MustCompile(str string) *Regexp
func MustCompilePOSIX(str string) *Regexp

// 让正则表达式在之后的搜索中都采用“leftmost-longest”模式。
func (re *Regexp) Longest()

// 返回编译时使用的正则表达式字符串
func (re *Regexp) String() string

// 返回正则表达式中分组的数量
func (re *Regexp) NumSubexp() int

// 返回正则表达式中分组的名字
// 第 0 个元素表示整个正则表达式的名字，永远是空字符串。
func (re *Regexp) SubexpNames() []string

// 返回正则表达式必须匹配到的字面前缀（不包含可变部分）。
// 如果整个正则表达式都是字面值，则 complete 返回 true。
func (re *Regexp) LiteralPrefix() (prefix string, complete bool)

// 2.判断

// 判断在 b（s、r）中能否找到匹配的字符串
func (re *Regexp) Match(b []byte) bool
func (re *Regexp) MatchString(s string) bool
func (re *Regexp) MatchReader(r io.RuneReader) bool

// 3.查找

// 返回第一个匹配到的结果（结果以 b 的切片形式返回）。
func (re *Regexp) Find(b []byte) []byte

// 返回第一个匹配到的结果及其分组内容（结果以 b 的切片形式返回）。
// 返回值中的第 0 个元素是整个正则表达式的匹配结果，后续元素是各个分组的
// 匹配内容，分组顺序按照“(”的出现次序而定。
func (re *Regexp) FindSubmatch(b []byte) [][]byte

// 功能同 Find，只不过返回的是匹配结果的首尾下标，通过这些下标可以生成切片。
// loc[0] 是结果切片的起始下标，loc[1] 是结果切片的结束下标。
func (re *Regexp) FindIndex(b []byte) (loc []int)

// 功能同 FindSubmatch，只不过返回的是匹配结果的首尾下标，通过这些下标可以生成切片。
// loc[0] 是结果切片的起始下标，loc[1] 是结果切片的结束下标。
// loc[2] 是分组1切片的起始下标，loc[3] 是分组1切片的结束下标。
// loc[4] 是分组2切片的起始下标，loc[5] 是分组2切片的结束下标。
// 以此类推
func (re *Regexp) FindSubmatchIndex(b []byte) (loc []int)

// 功能同上，只不过返回多个匹配的结果，而不只是第一个。
// n 是查找次数，负数表示不限次数。
func (re *Regexp) FindAll(b []byte, n int) [][]byte
func (re *Regexp) FindAllSubmatch(b []byte, n int) [][][]byte

func (re *Regexp) FindAllIndex(b []byte, n int) [][]int
func (re *Regexp) FindAllSubmatchIndex(b []byte, n int) [][]int

// 功能同上，只不过在字符串中查找
func (re *Regexp) FindString(s string) string
func (re *Regexp) FindStringSubmatch(s string) []string

func (re *Regexp) FindStringIndex(s string) (loc []int)
func (re *Regexp) FindStringSubmatchIndex(s string) []int

func (re *Regexp) FindAllString(s string, n int) []string
func (re *Regexp) FindAllStringSubmatch(s string, n int) [][]string

func (re *Regexp) FindAllStringIndex(s string, n int) [][]int
func (re *Regexp) FindAllStringSubmatchIndex(s string, n int) [][]int

// 功能同上，只不过在 io.RuneReader 中查找。
func (re *Regexp) FindReaderIndex(r io.RuneReader) (loc []int)
func (re *Regexp) FindReaderSubmatchIndex(r io.RuneReader) []int

// 替换（不会修改参数，结果是参数的副本）

// 将 src 中匹配的内容替换为 repl（repl 中可以使用 $1 $name 等分组引用符）。
func (re *Regexp) ReplaceAll(src, repl []byte) []byte

// 将 src 中匹配的内容经过 repl 函数处理后替换回去。
func (re *Regexp) ReplaceAllFunc(src []byte, repl func([]byte) []byte) []byte

// 将 src 中匹配的内容替换为 repl（repl 为字面值，不解析其中的 $1 $name 等）。
func (re *Regexp) ReplaceAllLiteral(src, repl []byte) []byte

// 功能同上，只不过在字符串中查找。
func (re *Regexp) ReplaceAllString(src, repl string) string
func (re *Regexp) ReplaceAllStringFunc(src string, repl func(string) string) string
func (re *Regexp) ReplaceAllLiteralString(src, repl string) string

// Expand 要配合 FindSubmatchIndex 一起使用。FindSubmatchIndex 在 src 中进行
// 查找，将结果存入 match 中。这样就可以通过 src 和 match 得到匹配的字符串。
// template 是替换内容，可以使用分组引用符 $1、$2、$name 等。Expane 将其中的分
// 组引用符替换为前面匹配到的字符串。然后追加到 dst 的尾部（dst 可以为空）。
// 说白了 Expand 就是一次替换过程，只不过需要 FindSubmatchIndex 的配合。
func (re *Regexp) Expand(dst []byte, template []byte, src []byte, match []int) []byte

// 功能同上，参数为字符串。
func (re *Regexp) ExpandString(dst []byte, template string, src string, match []int) []byte

// 其它

// 以 s 中的匹配结果作为分割符将 s 分割成字符串列表。
// n 是分割次数，负数表示不限次数。
func (re *Regexp) Split(s string, n int) []string

// 将当前正则对象复制一份。在多例程中使用同一正则对象时，给每个例程分配一个
// 正则对象的副本，可以避免多例程对单个正则对象的争夺锁定。
func (re *Regexp) Copy() *Regexp
```

操作步骤：

1. 导入`regexp`包，获取`regexp`对象 `re,err := regexp.Compile("hanru723@163.com") re := regexp.MustCompile("hanru723@163.com")`

2. 调用方法` match := re.FindString(text) `查找一个` match := re.FindAllString(text,-1) `-1代表查找所有

获取满足正则表达式的一个文本

```
package main

import (
    "regexp"
    "fmt"
)

func main() {
    const text = "My email is hanru723@163.com@haha.com"
    //re,err := regexp.Compile("hanru723@163.com")
    re := regexp.MustCompile(`[a-zA-Z0-9]+@[a-zA-Z0-9.]+\.[a-zA-Z0-9]+`)

    match := re.FindString(text) //查找一个

    fmt.Println(match)
}
```

获取所有满足正则表达式的文本

```
package main

import (
    "regexp"
    "fmt"
)

func main() {
    const text = `
My email is hanru723@163.com@haha.com
email is wangergou@sina.com
email is kongyixueyuan@cldy.org.cn
`

    //re,err := regexp.Compile("hanru723@163.com")
    re := regexp.MustCompile(`[a-zA-Z0-9]+@[a-zA-Z0-9.]+\.[a-zA-Z0-9]+`)

    match := re.FindAllString(text,-1) //-1代表查找所有

    fmt.Println(match)

}
```

```
注意：``使用这种定义方式，\等可能不会转义。使用""，会被go语言转义。
``[a-zA-Z0-9]+@[a-zA-Z0-9.]+\.[a-zA-Z0-9]+``
"`[a-zA-Z0-9]+@[a-zA-Z0-9.]+\\.[a-zA-Z0-9]+`"
```

## 正则的规则

###  一般符号和特殊符号

```
正则的规则：
一.一般的符号
  1.字面量
  2..点代表1个任意字符，除\n外
  3.[],匹配[]中任意字符都可以
  4.[abc],匹配a或b或c。1位
  5.[a-z],匹配任意一位的小写字母
  6.[^abc],除abc外的任意一位字符

二、特殊的符号
    1.\d,代表0-9数字，同[0-9]
    2.\D,与\d相反，同[^0-9]
    3.\w,匹配一个单词字符：a-zA-Z0-9_
    4.\W,与\w相反，非[a-zA-Z0-9_]
    5.\s,匹配空白字符。即空格，tab键,\n,\r等
    6.\b,单词边界
```

示例代码：

```
package main

import (
    "regexp"
    "fmt"
)

func main() {
    //符号：一般符号和特殊符号
    // 1..代表匹配任意字符
    b1 := regexp.MustCompile(`123.`).MatchString(`123*emeda`)
    fmt.Println(b1)

    b2 := regexp.MustCompile(`123....`).MatchString(`123memeda`)
    fmt.Println(b2)

    //2.[],匹配[]里的任意一个
    b3 := regexp.MustCompile(`[abc]`).MatchString(`saaa`) // 或a或b或c开头即可。
    fmt.Println(b3)
    b4 := regexp.MustCompile(`a[abc]`).MatchString(`as`) //第一个字母必须是a，第二个字符a,或b或c
    fmt.Println(b4)

    b5 := regexp.MustCompile(`[a-z]`).MatchString(`A23abc`) //必须是小写字母开头
    fmt.Println(b5)

    b6 := regexp.MustCompile(`[a-zA-Z][a-z]c`).MatchString(`Abcabc`) //字母
    fmt.Println(b6)

    b7 := regexp.MustCompile(`[0-9]`).MatchString(`110abc`) //数字
    fmt.Println(b7)

    b8 := regexp.MustCompile(`[^abc]`).MatchString(`*&%ABC123abc`) // 非abc开头即可
    fmt.Println(b8)

    b9 := regexp.MustCompile(`[[^a-z]`).MatchString(`memeda`) //
    fmt.Println(b9)

    b10 := regexp.MustCompile(`1[^2345]`).MatchString(`1a6`) //
    fmt.Println(b10)

    // 3.特殊符号
    b11 := regexp.MustCompile(`^\d`).MatchString(`a123`) //[0-9]
    //如果是""，\需要转义，``不需要转义
    fmt.Println(b11) //此处为true，是因为只要匹配到一个0-9的数字就可以，如果想以数字开头，可以在正则表达式前加^：`^\d`

    b12 := regexp.MustCompile(`\d\d`).MatchString(`1a2bc`) //[0-9]
    fmt.Println(b12)

    b13 := regexp.MustCompile(`\D`).MatchString(`*123abc`) //
    fmt.Println(b13)

    b14 := regexp.MustCompile(`^\w\w`).MatchString(`+-memeda`) //\w：[a-zA-Z0-9_] ，以\w\w开头
    fmt.Println(b14)

    b15 := regexp.MustCompile(`\d\w..`).MatchString(`123memeda`) //[0-9][a-zA-Z0-9_]任意字符任意字符
    fmt.Println(b15)

    b16 := regexp.MustCompile(`\W`).MatchString(`\nmemeda`) //
    fmt.Println(b16)

    b17 := regexp.MustCompile(`\w\W`).MatchString(`a*b = 20`) //
    fmt.Println(b17)

    b18 := regexp.MustCompile(`a[b-d]\w\d\W`).MatchString(`abc1\tdefg`) //
    fmt.Println(b18)
    b19 := regexp.MustCompile(`a\s`).MatchString(`a bc`) //匹配空白字符。即空格
    fmt.Println(b19)
}
运行结果：
```

###  数量词

```
1.*，出现的次数是0次或多次
2.+,出现的次数是1次或多次
3.?,出现的次数是0次或1次
4.{M}，出现的次数刚好是m次
5.{M,},至少M次
6.{M,N},至少m次，至多n次
```

示例代码：

```
package main
import (
    "regexp"
    "fmt"
)

func main() {
    // 数量词

    b1 := regexp.MustCompile(`\d*`).MatchString(`123`)
    fmt.Println(b1)

    b2 := regexp.MustCompile(`\d*`).MatchString(`abc123`)
    fmt.Println(b2)

    b3 := regexp.MustCompile(`\d*`).MatchString(``)
    fmt.Println(b3)

    b4 := regexp.MustCompile(`a[b-f]*\d\d[xy]*`).MatchString(`abbbb123x`) //至少0位，意味着可以没有
    fmt.Println(b4)

    b5 := regexp.MustCompile(`a[b-f]*\d\d[xy]*`).MatchString(`a12xxyxx3x`)
    fmt.Println(b5)

    b6 := regexp.MustCompile(`\d+abc`).MatchString(`abcmemeda`) //+至少一位
    fmt.Println(b6)

    b7 := regexp.MustCompile(`\d+.*\w+`).MatchString(`1234\ncd`) //
    fmt.Println(b7)

    b8 := regexp.MustCompile(`\d?[a-z]+`).MatchString(`123abc`) //
    fmt.Println(b8)

    b9 := regexp.MustCompile(`\d?\w+`).MatchString(`123abc`) //
    fmt.Println(b9)

    b10 := regexp.MustCompile(`\d{4}[a-z]+`).MatchString(`1234abcd`) //\d刚好4次
    fmt.Println(b10)

    b11 := regexp.MustCompile(`\d{4,}[a-z]+`).MatchString(`12345abcd`) //\d至少4次
    fmt.Println(b11)

    // +-->1次或多次，至少1次{1,}

    b12 := regexp.MustCompile(`\d{4,6}[a-z]+`).MatchString(`1234567abcd`) //
    fmt.Println(b12)

    // ?-->0次或1次，{0,1}

    //1.匹配手机号码：
    /*
    13012345678, 131xxxxxxxx,132xxxxxxxx,133xxxxxxxx,134xxxxxxxx,135xxxxxxxx,136xxxxxxxx,137xxxxxxxx,138,139
    # 第一位：1，第二位：34578，第三位：0-9   11位。
    */
    b13 := regexp.MustCompile(`1[34578]\d{9}`).MatchString(`13212344321`)
    fmt.Println(b13)

    // 2.验证QQ号：第一位非0，长度：5位-11位。
    //441883704

    b14 := regexp.MustCompile(`[1-9]\d{4,10}`).MatchString(`44188370445`)
    fmt.Println(b14)

    /*
    练习1：日期：2017-11-29
        年份是4位数字，月份是1-2位数字，日期1-2位数字
    练习2：邮箱：163.com，qq.com?

    */

    b15 := regexp.MustCompile(`\d{4}-\d{1,2}-\d{1,2}`).MatchString(`2018-12-25`)
    fmt.Println(b15)

    b16 := regexp.MustCompile(`[1-9]\d{17}`).MatchString(`231412198807123214`)
    fmt.Println(b16)

}
运行结果：

true
true
true
true
true
false
true
true
true
true
true
true
true
true
true
true
3.3 转义字符
四、转义：\
    1.普通的字符-->特殊含义的字符
        n,r,t,b--->\n,\r,\t,\b
    2.特殊含义的字符-->普通字符
        ",',\-->\",\'

    "\"abc"-->"abc
    "\\abc"
    \"-->"
    \\-->\
    \.-->.
    \w,\d,\s,\b....-->正则中规定的字符
```

### 边界问题

```
1.^,表示匹配的起始位置
2.$,表示结束的位置
```

示例代码：

```
package main

import (
    "regexp"
    "fmt"
)

func main() {

    // 边界问题

    b1 := regexp.MustCompile(`1[34578]\d{9}`).MatchString(`13278652345`)
    fmt.Println(b1) //true

    b2 := regexp.MustCompile(`1[34578]\d{9}`).MatchString(`1327865234578484848955`)
    fmt.Println(b2) //true

    b3 := regexp.MustCompile(`^1[34578]\d{9}$`).MatchString(`13278652345`) //
    fmt.Println(b3)                                                        //true

    b4 := regexp.MustCompile(`^[1-9]\d{17}$`).MatchString(`12345619881023432132`) //
    fmt.Println(b4)                                                               //false

    // 单词边界 "today is good"   (空格/开头)单词(末尾空格/结束)
    fmt.Println(regexp.MustCompile(`^\w+ve`).FindString(`hover`))          //hove
    fmt.Println(regexp.MustCompile(`\w+ve`).FindString(`hoverhoverhover`)) // hoverhoverhove
    fmt.Println(regexp.MustCompile(`^\w+ve$`).FindString(`hover`))         // ""
    fmt.Println(regexp.MustCompile(`^\w+ve`).FindString(`hover hover`))    //hove
    fmt.Println(regexp.MustCompile(`\w+ve\b`).FindString(`hoverhover`))    //""
    fmt.Println(regexp.MustCompile(`\w+ve\b`).FindString(`hove r`))        //hove
    fmt.Println(regexp.MustCompile(`^\w+\sve\b`).FindString(`ho ve r`))    //ho ve

}
```

### 分组

```
    1.|,或者的意思
        a|b,a或者b
    2.(),代表了分组
        (abc)-->一组
        正则表达式中使用了分组，组默认是有编号的：1,2,3.。。
    3.\num,引用分组的内容
        num是分组的编号
    4.(?P<name>),给分组起别名
    5.(?P=name),引用分组
        P字母大写
```

示例代码：

```
package main

import (
    "regexp"
    "fmt"
)

func main() {

    // 分组

    b1 := regexp.MustCompile(`[0-9]|x`).MatchString(`x`)
    fmt.Println(b1)

    b2 := regexp.MustCompile(`[ab]`).MatchString(`a`)
    fmt.Println(b2)

    b3 := regexp.MustCompile(`abc|ddd`).MatchString(`ddd`)
    fmt.Println(b3)

    // 身份证：  练习3：身份证号：18位。0不能开头第一位：非0,16位。最后一位：(数字|X)
    fmt.Println(regexp.MustCompile(`[1-9]\d{17}|[1-9]\d{16}X`).MatchString(`13141219880712321X`))
    fmt.Println(regexp.MustCompile(`^[1-9]\d{16}(\d|X)$`).MatchString(`13141219880712321X`))

    //练习2：邮箱：163.com，qq.com?
    s1 := `wangergou@163.com`
    s2 := `sanpang@qq.com` // 828384848@qq.com
    s3 := `lixiaohua@sina.com`

    fmt.Println(regexp.MustCompile(`\w+@(163|qq)\.com`).MatchString(s1))
    fmt.Println(regexp.MustCompile(`\w+@(163|qq)\.com`).MatchString(s2))
    fmt.Println(regexp.MustCompile(`\w+@(163|qq)\.com`).MatchString(s3))

    // 练习3：邮箱：163.com,sina.cn,yahoo,cn,qq.com
    fmt.Println(regexp.MustCompile(`\w+@(163|sina|yahoo|qq)\.(com|cn)`).MatchString(`sanpang@163.com`))

    fmt.Println("----------------------")

    s4 := `<html><h1>helloworld</h1></html>李小花李小花`
    re1 := regexp.MustCompile(`<(.+)><.+>(.+)</.+></.+>`)

    //打印分组的数量
    fmt.Println(re1.NumSubexp()) //2

    res1 := re1.FindAllStringSubmatch(s4, -1)
    fmt.Println(res1)
    fmt.Println(res1[0])
    fmt.Println(res1[0][0])
    fmt.Println(res1[0][1])
    fmt.Println(res1[0][2])

    fmt.Println("-----------------------")

    s5 := `<html><body><h1>hello</h1></body></html>`
    re2 := regexp.MustCompile(`<(?P<t1>.+)><(?P<t2>.+)><(?P<t3>.+)>(?P<t4>.+)</(.+)></(.+)></(.+)>`)

    //获取分组名称
    for i := 0; i <= re2.NumSubexp(); i++ {
        fmt.Printf("%d: %q\n", i, re2.SubexpNames()[i])
    }

    res2 := re2.FindAllStringSubmatch(s5, -1)
    fmt.Println(res2)

}
```

> golang的正则表达式不支持backreference。所以我们在写的时候不能反向引用分组，据说是golang牺牲了性能保证效率。

### 贪婪和非贪婪

贪婪和非贪婪 1.贪婪：在使用数量词的时候，默认的就是贪婪模式 贪婪模式：意思是说，匹配的时候，尽可能多匹配。，不行再少

 2.非贪婪：也叫懒惰模式 非贪婪，尽可能少的匹配，不满足规则再增加

 启动费贪婪：数量词后加？

示例代码：

```
package main

import (
    "regexp"
    "fmt"
)

func main() {

    // 分组

    b1 := regexp.MustCompile(`\d{2,4}`).MatchString(`123c4abc`)
    fmt.Println(b1)

    b2 := regexp.MustCompile(`\d+`).MatchString(`13774kdf393`)
    fmt.Println(b2)

    b3 := regexp.MustCompile(`\d{2,4}?`).MatchString(`123c4abc`) //非贪婪模式，尽可能少匹配
    fmt.Println(b3)

    b4 := regexp.MustCompile(`\d+?`).MatchString(`13774kdf393`)
    fmt.Println(b4)

    s1 := "This is a number 234-245-236"
    //获取数字部分
    b5 := regexp.MustCompile(`(.+)(\d+-\d+-\d+)`).FindAllStringSubmatch(s1,-1)
    fmt.Println(b5)
    fmt.Println(b5[0][1])
    fmt.Println(b5[0][2])

    //非贪婪
    b6 := regexp.MustCompile(`(.+?)(\d+-\d+-\d+)`).FindAllStringSubmatch(s1,-1)
    fmt.Println(b6)
    fmt.Println(b6[0][1])
    fmt.Println(b6[0][2])

}
```

