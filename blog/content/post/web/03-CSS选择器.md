---
layout:     post
title:      "CSS选择器"
subtitle:   ""
description: "CSS选择器详解"
excerpt: ""
date:       2017-01-14 12:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - web
URL: "/2017/01/14/web03/"
categories: [ web ]

---

## 基础选择器

### 标签选择器

命名只要和对应的html标签相同即可

```
  h1{
      font-size: 30px;
      color: #333333;
  }
```

在开发中标签选择器一般用于定义全局样式

### 类选择器

也称class选择器，在class名称前加一个“，“符号

```
<style>
	.red{
		background:red
	}
</style>
<div class="red content"></div>
```

**注意：**从代码可读性，可维护性角度来讲，不要滥用类选择器，尽量不要为一个标签添加多于两个的class属性，如果项目比较大，可以考虑在命名时进行单词组合比如`control-group`这样的命名

### id选择器

”#“号加上id名称

```
<style>
    #user_123{
        width: 130px;
        line-height: 30px;
        height: 3px;
    }
</style>
<div id="user_123"></div>
```

id选择器一般两个用途

- id选择器拥有最高的权重，因此可以用于覆盖之前的一些定义
- 和后台数据定义，从而配合JavaScript进行一些逻辑操作

### 通配符选择器

```
*{
	color: red;
}
```

一般用于全局样式定义，可以与任意元素匹配

### 子元素选择器

用于表示某些特定html嵌套关系时的样式展现，器语法关键词是一个”>“符号

```
<li><a href="#">www.baidu.com</a></li>
<li><div><a href="#">www.baidu.com</a></div></li>
<style>
    li > a{
        color: red;
    }
</style>
```

要求两个元素必修时严格的”父子关系“，否则不会生效

### 后代选择器

类似于子元素选择器，只不过要求不那么严格，语法关键词是一个空格

```
<li><a href="#">www.baidu.com</a></li>
<li><div><a href="#">www.baidu.com</a></div></li>
<style>
    li  a{
        color: red;
    }
</style>
```

只要链接`<a>`标签是列表`<li>`的后代元素即可

### 相邻元素选择器

用于选取和某个元素相邻的同级元素，语法关键词”+“符号

```
<div class="content">
    <h1>测试</h1>
    <p>测试内容</p>
</div>
<style>
    h1+p{ //相邻选择器
        font-size: 15px;
    }
</style>
```

使用两个条件：

- 二者必须拥有同一个父元素
- 二者相邻

### 属性选择器

有些标签可以添加其他属性，比如`title、href、name`等。在css选择器中，开发中也可以通过判断某些属性是否存在或者通过属性的值来选取html元素，使用一对中括号

```
[title]{
	color:red;
	/*所有拥有title属性的元素的文字颜色设为红色*/
}
a[href][title]{
	color:red
	/*同时拥有href和title属性的a标签的文字颜色设为红色*/
}
```

还可以通过属性赋值来选取拥有特定属性值得元素

```
a[href="http:www.baidu.com"][title="baidu"] {
		color: red
}
```

### 组选择器

对多个元素定义同样的样式，使用”,“

```
h1, h2, h3, h4, h5, h6 {
	font-wight:bold
} 
```

### 复合选择器

如果说组选择器相当于一种并集关系，那么复合选择器久表示”与“（&）的关系

```
p.test{/*同时满足p标签和class=test的两个条件*/
	color:red
}
<p class="test">hehe</p>
<div>hehe</div>
<div class="test">hehe</div>
<p>hehe</p>
```

## 伪类选择器

伪类表示元素的状态：排序、鼠标是否悬停、是否已被访问过、光标是否指向等。

使用伪类选择器就可以得到诸如有鼠标悬停的元素、父元素下的第n个子元素、已被访问过的链接等使用基本选择器无法进行区分的元素

CSS2中只有：hover、:active、:visited、:link、:first-child、:lang、:link等几种有限的几种伪类选择器，CSS3增添了大量新的伪类选择器

### 结构化伪类

其实就是可以根据文档的结构来选取元素

这里用一个基本样例，后面介绍都是基于此样例

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>伪类选择器</title>
    <style>
        ul>li{
            display: inline-block;
            height: 24px;
            line-height:24px;
            width: 24px;
            font-size: 15px;
            text-align: center;
            background-color: rgb(226,129,129);
            border-radius: 4px;
            margin: 5px;
        }
    </style>

</head>
<body>
<ul class="test">
    <li>1</li>
    <li>2</li>
    <li>3</li>
    <li>4</li>
    <li>5</li>
    <li>6</li>
    <li>7</li>
    <li>8</li>
    <li>9</li>
    <li>10</li>
</ul>
<div>
    <ul class="test_one">
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
        <li>5</li>
        <li>6</li>
        <li>7</li>
        <li>8</li>
        <li>9</li>
        <li>10</li>
    </ul>
</div>
</body>

```

#### :nth-child(n)

`:nth-child(n)`n可以是大于0的整数

```
  /*:nth-child(n): 取某个父元素内第n个元素*/
  li:nth-child(2){
      background-color: #333333;
      color: white;
  }
```

表示取`<li>`元素父元素的第二个`<li>`元素

即需要同时满足两个条件

- 是不是第2个
- 是不是`<li>`元素

`:nth-child(n)`还能进行相应的计算，比如`:nth-child(n)`这种相当于全选

```
  li:nth-child(n){
      background-color: #333333;
      color: white;
  }
```

**注意**：这里的变量只能用字母n来表示

`:nth-child(2n)`则表示选取所有的偶数项

`:nth-child(2n+1)`表示所有的奇数项

`:nth-child(n+5)`从第5个元素开始进行全选

#### :nth-last-child(n)

`:nth-last-child(n)`和`:nth-child(n)`顺序相反，是从最后一个元素开始计算

#### :nth-of-type(n)

`:nth-of-type(n)`如果使用`p:nth-of-type(3)`这样的条件时，一旦第3个元素不为`<p>`元素，这个选择器就不起作用，`p:nth-of-type(3)`查询的是第3个`<p>`元素

#### :nth-last-of-type(n)

与`:nth-of-type(n)`顺序相反，从最后一个开始计算

#### :last-child

选择的是最后一个子元素，比如需要给列表最有一项设置不同的样式

#### :first-of-type和last-of-type

`first-of-type`相当于`:nth-of-type`, `:last-of-type`相当于`:nth-last-of-type(1)`

#### :only-child

父元素只有一个子元素那么选取这个子元素

```
<style>
/*父元素中只有一个p元素，那么选取这个p元素*/
	p:only-child{
			color:red
	}
</style>
```

#### :only-of-type

基本同：only-child，区别在于如果不指定type而直接使用：only-of-type的话会造成body被选中，而:only-child不会出现这种情况

#### ：root

选取文档元的根元素，不兼容IE6~8

#### :empty

选择没有任何内容的元素，哪怕是一个空格也不能有

### 目标伪类

URL前面有锚名称#，指向文档内某个具体的元素，例如`<a href="#id_name"></a>`那么`<div id="id_name"></div>`这个被链接的元素就是目标元素

### 状态伪类

CSS3中新增状态伪类选择器，用于表示表单元素的状态，虽然使用属性选择器可以达到同样的效果，但是使用状态伪类的语义性更强，但是IE6~8不支持状态伪类选择器，所以不建议使用

#### :enabled和:disabled

设置disabled属性表示禁用，`:enabled`选择器用于选择可用的元素，而`:disabled`则用于选择所有已被禁用的元素

```
/*将被禁用的input元素设置为透明*/
input:disabled{
	opacity:0;
}
```

使用属性选择器也可有同样效果

```
inout[disabled] {
	opacity:0
}
```

#### :checked

input表单中的checkbox和radio都是用checked属性表示是否选中，只要checked属性存在，使用checked=false或checked=0都会表示单选/复选框被选中

:checked选择器用于选择所有被选中的checkbox或者radio标签/

```
/*将被选中的输入框设置为透明*/
input:checked{
	opacity:0
}
```

#### :indeterminate和:default（不建议使用）

`:default`状态伪类选择器用来指定当前元素处于非选取状态的单选框或复选框的样式，`:indeterminate`状态伪类选择器用来指定当前页面打开时，某组中的单选框或复选框元素还没有选取状态时的样式

**注意：**这两个选择器只有Opera才支持

### 否定伪类

`:not(selector)`选择器匹配非指定元素/选择器的每个元素

```
:not(p){
	backgroud-color: red;
}
```





























