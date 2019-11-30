---
layout:     post
title:      "web学习笔记（一）- html5的结构"
subtitle:   ""
description: "读html5与css权威指南 - html5的结构"
excerpt: ""
date:       2017-01-12 19:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - web
URL: "/2017/01/12/web01/"
categories: [ web ]

---

## 新增的主体结构元素

### article`元素

> `article`元素代表文档、页面或应用程序中独立完整的、可以独自被外部引用的内容

一个article元素通常有它自己的标题（一般放在一个header元素里面），有时还有自己的脚注

例如：讲述苹果的博客

```
<article>
    <header>
        <h1>苹果 </h1>
        <p>发表日期：<time pubdate="pubdate">2010/10/09</time></p>
    </header>
    <p><b>苹果</b>植物类水果，多次花果...("苹果"文章正文)</p>
    <footer>
        <p><small>著作全归****所有</small></p>
    </footer>
</article>
```

`article`元素是可以嵌套使用的，内层的内容在原则上需要与外层内容相关联

例如：博客文章中，针对该文章的评论就可以使用嵌套article元素的方式

```
<article>
    <!--文章区 -->
    <header>
        <h1>苹果 </h1>
        <p>发表日期：<time pubdate="pubdate">2010/10/09</time></p>
    </header>
    <p><b>苹果</b>植物类水果，多次花果...("苹果"文章正文)</p>
    <footer>
        <p><small>著作全归****所有</small></p>
    </footer>

    <!-- 评论区 ，使用section把正文与评论部分区分开来   -->
    <section>
        <h2>评论</h2>
        
<!--        每个人的评论都是相对独立的，所以每个评论都用article包起来-->
        <article>
            <header>
                <h3>发表着：xxx1</h3>
                <p>
                    <time pubdate datetime="2010-10-10T19:10-01">1小时前</time>
                </p>
            </header>
            <p>我喜欢苹果，我最喜爱的品种是红富士。</p>
        </article>
        
        <article>
            <header>
                <h3>发表着：xxx2</h3>
                <p>
                    <time pubdate datetime="2010-10-10T19:10-01">1小时前</time>
                </p>
            </header>
            <p>我喜欢苹果，我最喜爱的品种是红富士。</p>
        </article>
    </section>

</article>
```

### `section`元素

> section元素用来对网站或应用程序中页面上的内容进行分块，一个section元素通常由**内容**及其**标题**组成。

#### **作用**：

对页面上的内容进行分块，或者说对文章进行分段

#### **使用注意：**

- 不要将`section`元素用作设置样式的页面容器，因为那是`div`元素的工作
- 如果`article`元素、`aside`元素或`nav`元素更符合状态，不要使用`section `
- 不要为没有标题的内容区块使用`section`元素

```
<article>
    <h1>苹果</h1>
    <p><b>苹果</b>植物类水果，多次花果...("苹果"文章正文)</p>
    
<!--    使用section对文章进行分段-->
    <section>
<!--        section中一般带标题-->
        <h2>红富士</h2>
        <p>红富士是从普通红富士的芽选育出来的。。。</p>
    </section>
    
    <section>
        <h2>国光</h2>
        <p>国光苹果xxxxxxxxxxxxx</p>
    </section>
</article>
```

### `nav`元素

> nav元素可以用作页面导航的链接组，其中的导航元素链接到其他页面或者当前页面的其他部分，并不是所有的链接组都要放进nav元素，只需将主要的，基本的链接组放进nav元素即可

```
<h1>技术资料</h1>
<!--只将主要链接放入nav元素中-->
<nav>
    <ul>
        <li><a href="/">主页</a></li>
        <li><a href="/event">开发文档</a></li>
    </ul>
</nav>
<article>
    <header>
        <h1>HTML5与CSS3的历史</h1>
<!--         用来实现在这篇文章中的两个组成部分的页内导航-->
        <nav>
            <ul>
                <li><a href="#HTML5">HTML5的历史</a></li>
                <li><a href="#CSS3">CSS3的历史</a></li>
            </ul>
        </nav>
    </header>
    <section id="HTML5">
        <h1>HTML5的历史</h1>
        <p>讲述HTML5的历史正文</p>
    </section>
    <section id="CSS3">
        <h1>CSS3的历史</h1>
        <p>讲述CSS3的历史的正文</p>
    </section>
    <footer>
        <p>
            <a href="?edit">编辑</a>
            <a href="？delete">删除</a>
            <a href="？rename">重命名</a>
        </p>
    </footer>
</article>
<footer><p><small>版权所有：xxxx</small></p></footer>
```

#### 使用场合

- 传统导航条
- 侧边栏导航
- 页内导航
- 翻页操作：多个页面的前后页或者博客网站的前后篇文章的滚动中
- 也用在其他所有你觉得重要的、基本的导航链接组中

#### 注意：

html5中不要使用`menu`元素代替`nav`元素。`menu`元素是被用在一系列发出命令的菜单上的，是一种交互性的元素

### `aside`元素

> 用来表示当前或文章的附属信息部分，它可以包含与当前页面或主要内容相关的引用、侧边栏、广告、导航条以及其他类似的有别于主要内容的部分

#### 使用方法

1.  包含在article元素中作为主要内容的附属信息部分，其中的内容可以是与当前文章有关的参考资料、名词解释等。

   ```
   <header><h1>F#入门</h1></header>
   <article>
       <h1>此法闭包</h1>
       <p>lambda表达式可以创建词法闭包。。。（文章正文）</p>
       <aside>
   <!--        因为这个aside元素被放置在一个article元素内部,
   所以分析器将这个aside元素的内容理解成是和artice元素的内容相关的资料-->
           <h1>名词解释</h1>
           <dl>
               <dt>F#</dt>
               <dd>f#为.net2010中引入的新型函数型编程语言</dd>
           </dl>
           <dl>
               <dt>此法闭包</dt>
               <dd>词法闭包是指，将创建lambda表达式时的环境保存起来...</dd>
           </dl>
       </aside>
   </article>
   ```

2. 在article之外元素使用，作为页面或站点全局的附属信息部分。最典型的形式是侧边栏，其中的内容可以是友情链接、博客中的其他文章列表或者广告单元等。

   ```
   <aside>
       <nav>
           <h2>评论</h2>
           <ul>
               <li><a href="http://blog.sina.com.cn/1683">erway</a></li>
               <li>
                   <a href="http://blog.sina.com.cn/1683">太阳雨</a>
                   <a href="http://blog.sina.com.cn/1683">太阳雨</a>
               </li>
               <li>
                   <a href="http://blog.sina.com.cn/1683">新人</a>
                   <a href="http://blog.sina.com.cn/1683">恭喜成功开通了博客</a>
               </li>
           </ul>
       </nav>
   </aside
   ```

### time元素与微格式

微格式：利用html的class属性来对网页添加诸如新闻事件发生的日期和时间、个人电话号码、企业邮箱之类的附加信息的方法，但是在使用过程中日期和时间的机器码会出现一些问题，编码会产生一些歧义

`time`元素代表24小时中的某个时刻或某个日期，表示时刻时允许带时差

```
<!--datetime属性中日期与时间之间要用"T"文字分割，"T"表示时间-->
<time datetime="2010-11-13">2010年11月13日</time>
<time datetime="2010-11-13">11月13日</time>
<time datetime="2010-11-13">我的生日</time>
<time datetime="2010-11-13T20:00">我生日的晚上8点</time>
<time datetime="2010-11-13T20:00Z">我生日的晚上8点</time>
<time datetime="2010-11-13T20:00+09:00">我生日的晚上8点的美国时间</time>

```

### `pubdate`属性

一个可选的boolean值的属性，它可以被应用到article元素中的time元素上，意思是time元素代表了文章（article元素的内容）或整个网页的发布日期，pudate属性的具体使用方法

```
<article>
    <header>
        <h1>关于 <time datetime="2010-10-29">10月29日</time>的舞会</h1>
        <p>发布日期：
            <time datetime="2010-10-11" pubdate>2010年10月11日</time>
        </p>
    </header>
    <p>xxxxxxxxxxxxxxxxxx（关于舞会的通知）</p>
</article>
```



## 新增非主体结构元素

除来以上几个主要的结构元素之外，html5内还增加了一些表示逻辑结构或附加信息的非主体结构元素

### `header`元素

header元素是一种具有引导和导航作用的结构元素，通常用来放置整个页面或页面内的一个内容区块的标题

一个网页内并不限制只能有一个header元素，可以拥有多个，可以为每个内容区块加一个header元素

```
<header>
    <hgroup>
        <h1>IT新技术</h1>
        <a href="http://blog.sina.com.cn/itnewtech">http://blog.sina.com.cn/itnewtech</a>
        <a href="#">[订阅]</a>
        <a href="#">[手机订阅]</a>
    </hgroup>
    <nav>
        <ul>
            <li>首页</li>
            <li><a href="#">博文目录</a></li>
            <li><a href="#">图片</a></li>
            <li><a href="#">关于我</a></li>
        </ul>
    </nav>
</header>
```

### `footer`元素

footer可以作为其上层父级内容区块或一个根区块的脚注。footer通常包括其相关区块的脚注信息，入作者、相关阅读链接以及版权信息等。

```
<footer>
    <ul>
        <li>版权信息</li>
        <li>站点地图</li>
        <li>联系方式</li>
    </ul>
</footer>
```

### `address`元素

用来在文档中呈县联系信息，包括文档作者或文档维护者的名字、文档作者或文档维护者网站链接、电子邮箱、真实地址、电话号码等

```
<footer>
    <div>
        <address>
            <a href="#" title="文章作者：xxxx"></a>
            发表于 <time datetime="2010-10-04">2010年10月4日</time>
        </address>
    </div>
</footer>
```

### ` main`元素

表示网页中的主要内容。主内容区域指与网页标题或应用程序中本页面主要功能直接相关或进行扩展的内容。该区域应该为每一个网页中所特有的内容，不能包含整个网站的导航条、版权信息、网站Logo、公共搜索表单等整个网站内部的共同内容

每个网页内部只能放置一个main元素，不能将main元素放置在任何article、aside、footer、或nav元素内部







































