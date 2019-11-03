---
layout:     post
title:      "NASM 环境搭建"
subtitle:   ""
description: "mac平台 nasm 汇编器环境搭建"
excerpt: ""
date:       2018-02-11 09:32:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - nasm
URL: "/2018/02/11/nasminstall/"
categories: [ 汇编 ]

---

一. 安装NASM

NASM网站： https://www.nasm.us/ 点击Downloads 到下载页面，下载最新安装包

![1](/img/asm/asm1.png)

点击展开包，点击x x x.tar.gz包 下载

![2](/img/asm/asm2.png)

1. 双击下载的包解压，

2. 打开Temier 进入到解压后的文件内

3. 输入**./configure** 执行脚本

4. 输入**make**编译nasm

5. 输入**sudo make install** 会将编译后的nsam项目拷贝到 /usr/bin/nasm 位置, 如果报错 权限不足 要修改电脑权限如下

   1. 重启电脑 按住command+R 不放， 直到出现选择语言的界面，选择简体中文进入一个界面
   2. 打开左上角的 **实用工具** 选择**终端**然后输入 **csrutil disable** 会提示修改成功，然后再重启电脑即可

6. 输入：sudo nano /etc/paths 编辑路径， 在弹出编辑界面中将**/usr/bin/nasm**. 加入到最后然后control+X 退出 输入 y 保存，然后一直return 就成功

   ![3](/img/asm/asm3.png)

7.  输入 nasm -v 查看版本

```shell
adminMacBook:~ admin$ cd /Users/admin/Downloads/nasm-2.14.02 
adminMacBook:nasm-2.14.02 admin$ ./configure
.....执行脚本
adminMacBook:nasm-2.14.02 admin$ make
...... 编译nasm
adminMacBook:nasm-2.14.02 admin$ sudo make install
Password: xxxx输入电脑密码 + return键
mkdir -p /usr/bin
/usr/bin/install -c nasm /usr/bin/nasm
/usr/bin/install -c ndisasm /usr/bin/ndisasm
mkdir -p /usr/share/man/man1
/usr/bin/install -c -m 644 ./nasm.1 /usr/share/man/man1/nasm.1
/usr/bin/install -c -m 644 ./ndisasm.1 /usr/share/man/man1/ndisasm.1
adminMacBook:nasm-2.14.02 admin$ sudo nano /etc/paths
adminMacBook:nasm-2.14.02 admin$ nasm -v
NASM version 2.14.02 compiled on Aug 21 2019
adminMacBook:nasm-2.14.02 admin$ 


```

二、hello world Nasm

编写.asm文件

```asm
    global    start
    section   .text
start:
    mov       rax, 0x02000004
    mov       rdi, 1
    mov       rsi, message
    mov       rdx, 13
    syscall
    mov       rax, 0x02000001
    xor       rdi, rdi
    syscall 
    section   .data
message:  
    db        "Hello, World", 10
```

编译为 Mach-O 64bit 可执行文件

```shell
nasm -f macho64 hello_world.asm
```

链接 -o 表示 对链接生成的可执行文件重命名

```asm
gcc hello1.o -o hello_world
```

执行

```asm
./hello_world
```























