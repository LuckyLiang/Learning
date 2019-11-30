---
layout:     post
title:      "MacOS安装SASS"
subtitle:   ""
description: "MacOS安装SASS记录"
excerpt: ""
date:       2017-01-15 19:30:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - web
URL: "/2017/01/15/web05/"
categories: [ web ]

---



## Homebrew安装 （推荐）

```
brew install sass/sass/sass
```

## NPM安装

```
npm install -g sass
```

**注：**国内 npm 建议使用淘宝镜像来安装，参考：[NPM 国内慢的问题解决](https://www.runoob.com/w3cnote/npm-slow-use-cnpm.html)

## ruby 安装

这个方法比较麻烦不推荐

### brew 安装ruby

没有安装homebrew可以看[官方文档](https://brew.sh/)很简单

Linux和OS系统自带了ruby

```
> ruby -v
ruby 2.3.7p456 (2018-03-28 revision 63024) [universal.x86_64-darwin16]
```

但是如果你直接使用gem(RubyGems是Ruby的一个包管理器)会报错

```
> gem install sass
ERROR:  While executing gem ... (Gem::FilePermissionError)
You don't have write permissions for the /Library/Ruby/Gems/2.3.0 directory.
```

尝试一下sudo命令 又会报错

```
> sudo gem install sass
Building native extensions.  This could take a while...
  ERROR:  Error installing sass: 
  ERROR: Failed to build gem native extension.

current directory: /Library/Ruby/Gems/2.3.0/gems/ffi-1.11.1/ext/ffi_c
...
...
```

截取了核心的错误提示。也就是错误提示里面：
**current directory: /Library/Ruby/Gems/2.3.0/gems/ffi-1.11.1/ext/ffi_c**
当然也可以设置写权限，使用系统自带ruby。但是存在破坏系统环境的危险而且不必要，我们完全可以配置一个Local环境用于开发。

### 配置PATH解决上述问题

在**/etc/paths**里面配置PATH

```
> sudo vi /etc/paths

/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
~
~
```

我们使用了vim打开这个文件，再按一下 **i** 代表insert，就可以插入我们的新路径啦～

```
/usr/local/opt/ruby/bin //插入的新路径
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
```

然后再看看

```
> ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin16]
```

ruby的版本号变了

现在就可以安装sass了

```
> gem install sass
...
Successfully installed sass-3.7.4
...
```





