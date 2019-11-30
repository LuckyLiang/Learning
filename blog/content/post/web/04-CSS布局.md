---
layout:     post
title:      "CSS布局"
subtitle:   ""
description: "CSS布局方式：网格布局、盒布局、flex布局"
excerpt: ""
date:       2017-01-14 21:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - web
URL: "/2017/01/14/web04/"
categories: [ web ]

---

## 使用float属性或position属性布局

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>float或postion布局</title>
    <style type="text/css">
        div{
            width: 20em;
            float: left;
        }
        div#div1{
            margin-right: 2em;

        }
        div#div3 {
            width: 100%;
            background-color: yellow;
            height: 200px;
        }
    </style>
</head>
<body>
<div id="div1">
    <p>示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长</p>
</div>
<div id="div2">
    <p>示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长</p>
</div>
<div id="div3">页面中其他内容</div>
</body>
</html>
```

运行效果如下：

![css_float](/img/web/css_float.png)

使用flaot属性或position属性进行布局的一个比较明显的缺点：

第一个div元素与第二个div元素各自独立，其中一个内容多点就会导致底部对齐不了

## 多栏布局

### column-count设定多栏显示

使用多栏布局可以将一个元素中的内容分为两栏或多栏显示，并且确保各栏中的内容底部对齐

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>多栏布局</title>
    <style type="text/css">
        div#div1{
            width: 40em;
            column-count: 2;
            -moz-column-count: 2;
            -webkit-column-count: 2;
        }
        div#div3{
            width: 100%;
            background-color: yellow;
            height: 200px;
        }
    </style>
</head>
<body>
<div id="div1">
    <p>示例文字11.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长</p>
    <p>示例文字2.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长，示例文字1.文字内容比较长</p>

</div>

<div id="div3">页面中其他内容</div>
</body>
</html>
```

通过`column-count`属性来使用多栏布局方式，该属性的含义是将一个元素中的内容分为多个栏进行显示

使用多栏布局时，需要将元素的宽度**设置成多个栏目的总宽度**

### column-width 单独设置每一栏的宽度

也可以使用`column-width`属性单独设置每一栏的宽度而不设定元素的宽度

```
  div#div1{
      column-count: 2;
      -moz-column-count: 2;
      -webkit-column-count: 2;
      column-width: 20em;
      -moz-column-width: 20em;
      -webkit-column-width: 20em;
  }
```

使用`column-width`属性指定每栏宽度而不设定元素的宽度，则需要在元素外面单独设立一个容器元素，然后指定该容器元素的宽度

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>多栏布局</title>
    <style type="text/css">
        div#container{
            width: 42em;
        }
        div#div1{
            column-count: 2;
            -moz-column-count: 2;
            -webkit-column-count: 2;
            column-width: 20em;
            -moz-column-width: 20em;
            -webkit-column-width: 20em;
        }
        div#div3{
            width: 100%;
            background-color: yellow;
            height: 200px;
        }
    </style>
</head>
<body>
<div id="container">
    <div id="div1">
        <p>示例文字1.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，较长，示例文字.文字内容比较长，示例文字.文字内容比较长较长，示例文字.文字内容比较长，示例文字.文字内容比较长较长，示例文字.文字内容比较长，示例文字.文字内容比较长示例文.文字内容比较长</p>
        <p>示例文字2.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长，示例文字.文字内容比较长</p>
    </div>
    <div id="div3">页面中其他内容</div>
</div>
</body>
</html>
```

column-gap属性设定多栏之间的间隔距离

```
 div#div1{
      column-count: 2;
      -moz-column-count: 2;
      -webkit-column-count: 2;
      column-width: 20em;
      -moz-column-width: 20em;
      -webkit-column-width: 20em;
      column-gap: 3em;
      -moz-column-gap: 3em;
      -webkit-column-gap: 3em;
  }
```

### column-rule属性

在栏栏之间增加一条间隔线，并且可设定该间隔线的宽度、颜色等

## 盒布局

先使用float属性布局三个div元素，展示网页中左侧栏、中间内容和右侧边栏

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>使用float属性进行布局</title>
    <style type="text/css">
        #left-sidebar{
            float: left;
            width: 200px;
            padding: 20px;
            background-color: orange;
        }
        #contents{
            float: left;
            width: 300px;
            padding: 20px;
            background-color: yellow;
        }
        #right-sidebar{
            float: left;
            width: 300px;
            padding: 20px;
            background-color: limegreen;
        }
        #left-sidebar,#contents,#right-sidebar{
            box-sizing: border-box;
        }
    </style>
</head>
<body>
<div id="container">
    <div id="left-sidebar">
        <h2>左侧边栏</h2>
        <ul>
            <li>超链接</li>
            <li>超链接</li>
            <li>超链接</li>
            <li>超链接</li>
            <li>超链接</li>
        </ul>
    </div>
    <div id="contents">
        <h2>内容</h2>
        <p>示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字示例文字</p>
    </div>
    <div id="right-sidebar">
        <h2>右侧边栏</h2>
        <ul>
            <li>超链接</li>
            <li>超链接</li>
            <li>超链接</li>
        </ul>
    </div>
</div>
</body>
</html>
```

效果如下

![css_floatbox](/Users/admin/Desktop/leo/other/blog/Learning/blog/static/img/web/css_floatbox.png)

使用float属性或position属性时，左右两栏或多栏中div元素底部并没有对齐

### 使用盒布局

使用盒布局可以很容易解决这个问题

修改代码如下

```
<style type="text/css">
        #container{
            display: -moz-box;
            display: -webkit-box;
        }
        #left-sidebar{
            width: 200px;
            padding: 20px;
            background-color: orange;
        }
        #contents{
            width: 300px;
            padding: 20px;
            background-color: yellow;
        }
        #right-sidebar{
            width: 300px;
            padding: 20px;
            background-color: limegreen;
        }
        #left-sidebar,#contents,#right-sidebar{
            box-sizing: border-box;
        }
    </style>
```

盒布局与多栏布局区别

- 使用多栏布局时各栏宽度必须相等，在指定每栏宽度时，也只能为所有栏指定一个统一宽度，栏与栏之间的宽度不可能是一样的
- 使用多栏布局也不可能具体指定什么栏中显示什么内容，因此比较适合使用在显示文章内容的时候，不适合用于安排整个网页中由各元素组成的网页结构的时候

## CSS Grid 网格布局教程

[Grid 网格布局教程](https://www.ruanyifeng.com/blog/2019/03/grid-layout-tutorial.html)

## Flex 布局

[Flex 布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)

[Flex 布局教程：实例篇](http://www.ruanyifeng.com/blog/2015/07/flex-examples.html)

































































