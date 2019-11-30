---
layout:     post
title:      "CSS基础复习"
subtitle:   ""
description: "主要包含CSS盒子模型，浮动和定位"
excerpt: ""
date:       2017-01-13 19:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - web
URL: "/2017/01/13/web02/"
categories: [ web ]

---

### 盒子 模型

一个块级元素，包括内容、外边距（margin）、边框（border）、内边距（padding）4个组成部分，在不设定的情况下内外边距和边框都是没有的

![盒子模型](/img/web/css_box.png)

### 跨浏览器的css

如果您需要IE10或以上的特殊样式，则必须找到其他方法，因为条件注释在IE10中被禁用。然而，这些版本相比与早期版本还是少得多。

兼容浏览器的通用方法

```
<!--[if IE]>
      // 支持所有IE浏览器
<![endif]-->

<!--[if IE 6]>
     // 仅仅支持IE6
<![endif]-->

<!--[if IE 7]>
      // 仅仅支持IE7
<![endif]-->

<!--[if IE 8]>
     //仅仅支持IE8
<![endif]-->

<!--[if IE 9]>
       // 仅仅支持IE9
<![endif]-->

<!--[if gte IE 8]>
      // 高于IE8(包括IE8)的版本
<![endif]-->

<!--[if lt IE 9]>
        // 小于IE9的版本
<![endif]-->

<!--[if lte IE 7]>
        // 小于等于IE7的版本
<![endif]-->

<!--[if gt IE 6]>
        //大于IE的版本
<![endif]-->

<!--[if !IE]> -->
        // 非IE浏览器
<!-- <![endif]-->
```

- `lt`表示小于版本号，不包括条件版本号本身；而`lte`是小于或等于版本号，包括了版本号自身。
- `gt`表示大于, `gte`则表示大于或等于。

### 浏览器的属性前缀

#### 常用的属性前缀

- -webkit: webkit核心浏览器，包括Chrome、Safari等
- -moz：火狐（Firefox）浏览器
- -ms：IE浏览器
- -o：Opera浏览器

在实际开发中，考虑到兼容性往往需要把所有前缀都写上去

```
  .transform{
      -webkit-transform: rotate(-3deg); /*带有Chrome、safari浏览器属性前缀*/
      -moz-transform: rotate(-3deg);/*带有Firefox浏览器的属性前缀*/
      -ms-transform: rotate(-3deg); /*带IE浏览器属性的前缀*/
      -o-transform: rotate(-3deg); /*带opera浏览器的属性前缀*/
      transform: rotate(-3deg); /*W3C标准愈发，无属性前缀*/
  }
```

### 浮动布局

正常情况下，页面中的块级元素（block）就像一个个沉在水中的铁块，如果换成木块呢就飘起来了

#### 浮动导致的布局变动

float属性有4个可选项：none、left、right、inherit。

- none为默认值即不浮动
- inherit表示继承父元素的float值
- left、right 向左、右浮动

**注意**：一般不建议使用inherit，因为IE不支持这个选项

1. 对于块级元素来说，在不设置宽度的情况下，默认的宽度是100%，一旦设置了浮动，它的宽度就会根据内容进行自动调整

2. 设置浮动的元素会脱离正常的文档流，设置浮动后，元素不仅在y轴上浮了起来，在z轴上也浮起来。 比如：默认情况下父元素的高度会根据子元素的内容自动进行调整，如果我们将子元素设置为浮动，父元素的高度就会变为0

3. 浮动元素虽然脱离了文档流，但里面的内容仍然占据空间，会根据相对位置进行布局

   

#### 清除浮动

有时我们需要用到浮动，但又不想浮动的某些特性影响布局，这时就要清除浮动

主要应用的是css中的clear属性，可选值：left、right、both

```
img{float:left; clear: both} /*左右两侧都不允许出现浮动元素*/
```

应用比较广泛的两种清除浮动的方法

1. 在需要的地方添加定义了`clear：both`的空标签

   ```
     html body div.clear,
     html body span.clear {
         background: none;
         border: 0;
         clear: both; /*这句是重点，其他的都是兼容性代码*/
         display: block;
         font-size: 0;
         float: none;
         margin: 0;
         padding: 0;
         overflow: hidden;
         visibility: hidden;
         width: 0;
         height: 0;
     }
   
   ```

     在需要清除浮动的元素后面添加<div class="clear"><div>即可

   ```
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>清除浮动</title>
       <style>
           html body div.clear,
           html body span.clear {
               background: none;
               border: 0;
               clear: both; /*这句是重点，其他的都是兼容性代码*/
               display: block;
               font-size: 0;
               float: none;
               margin: 0;
               padding: 0;
               overflow: hidden;
               visibility: hidden;
               width: 0;
               height: 0;
           }
           .box {
               border: 1px solid #cccccc;
               background: #fc9;
               color: #fff;
               margin: 50px auto;
               padding: 50px;
           }
           .div1{
               width: 100px;
               height: 100px;
               background: darkblue;
               float: left;
           }
           .div2 {
               width: 100px;
               height: 100px;
               background: darkgoldenrod;
               float: left;
           }
           .div3{
               width: 100px;
               height: 100px;
               background: darkgreen;
               float: left;
           }
       </style>
   <!--在需要清除浮动的元素后面添加<div class="clear"><div>即可-->
   </head>
   <body>
   <div class="box">
       <div class="div1">1</div>
       <div class="div2">1</div>
       <div class="div3">1</div>
   <!--    清除浮动后 父元素高度会根据子元素高度计算，如果不使用父元素内容高度为0-->
       <div class="clear"></div>
   </div>
   </body>
   </html>
   ```

   这是一个万能的清除浮动代码，可以在不同浏览器下兼容

2. 对父元素使用：after伪类

   ```
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>清除浮动</title>
       <style>
           .clearfix:after{
           /*    对父元素使用after*/
               content: '020';
               display: block;
               height: 0;
               clear:both;
   
           }
           .clearfix{
       				/*兼容IE6和IE7*/
               zoom: 1;
               background: red;
           }
           .left{
               float: left;
           }
           .right{
               float: right;
           }
   
       </style>
   </head>
   <body>
   <div class="div1 clearfix">
       <div class="left">Left</div>
       <div class="right">Right</div>
   </div>
   </body>
   </html>
   ```

   可以看到父元素的高度不再为0，由于IE6和IE7不支持：after伪类，因此需要添加zoom:1兼容代码

### 定位

CSS使用`top、left、right、bottom`设置元素的二维（x轴和y轴）偏移量，使用`z-index`设置元素的垂直于屏幕的方向，也就是"z轴"的偏移量

CSS使用`position`属性来定义元素的定位属性

可选值`static、relative、absolute、fixed、sticky、inherit`，默认值为`static`。`inherit`属性表示继承父元素的定位属性

#### 相对定位

指相对于文档流中其他已定义的元素位置进行定位

**注意：**那些脱离文档流的元素，比如设置了浮动或者绝对定位的元素不会对相对定位产生影响。

`relative`和`static`都是相对定位

1. static(默认值)：在CSS中为元素定义`top、left、right、bottom、z-index`都不会生效，如果想设置元素的偏移量和`z-index`必须为元素定义`position`属性

2. `relative`表现和默认值一样，只不过可以通过设置偏移量和z-index俩控制相对于其正常位置进行偏移

   ```
   div {
     position: relative;
     top: 20px;
   }
   ```

   

所有元素的定位都默认是static相对定位，relative在不设置top、left、z-index等值情况下和默认值表现一样的

#### 绝对定位

绝对定位的元素有以下几个特点

- 块级元素的宽度在未定义时不再为100%，而是根据内容自动调整。
- 在不定义z-index的情况下，absolute元素会覆盖在其他元素之上。
- 它会脱离正常的文档流，不再占据空间，类似于浮动后的效果

`absolute`和`fixed`都属于绝对定位

##### absolute属性值

`absolute`表示相对于**不为`static`的上级元素**（一般是父元素）进行偏移，即定位基点是父元素，如果不指定父元素的position，absolute将相对于整个html文档进行绝对定位

```
/*
  HTML 代码如下
  <div id="father">
    <div id="son"></div>
  </div>
*/
#father {
  positon: relative; //必须指定position不为static元素
}
#son {
  position: absolute; //相对于father进行绝对定位，如果father为static，则相对于html文档进行定位
  top: 20px;
}
```

##### fixed属性值

fixed表示相对于浏览器窗口（viewport）进行定位，这会导致元素的位置不随页面滚动而变化，好像固定在网页上一样。比如希望侧边栏始终对用户可见可以使用`position:fixed`来进行定位

#### sticky定位属性

这是2017年才出来的新的属性值，跟前面四个属性都不一样，它会产生动态效果，很想`relative`和`fixed`的结合：一些时候是`relative`定位（定位基点是自身位置），另外一些时候会自动变成`fixed`定位（定位基点是浏览器窗口）

就像网页搜索工具栏，初始加载时在自己的默认位置（`relative`定位）。页面向下滚动时，工具栏变成固定位置，始终停留在页面头部（`fixed`定位）









