---
layout:     post
title:      "Siwft 小技巧记录"
subtitle:   ""
description: "记录在Swift开发中常用的小技巧，方便忘记的时候查阅"
excerpt: ""
date:       2018-04-18 19:22:00
author:     "Cheng"
image: "https://img.zhaohuabing.com/in-post/2018-04-11-service-mesh-vs-api-gateway/background.jpg"
published: true
tags:
    - IOS
    - Swift
URL: "/2018/04/18/swiftTipsRecord/"
categories: [ IOS ]

---

### Swift 记录

1. 通过字符串初始化类

   比如有个类名为`URLSessionViewController`，在Swift中通过字符串来初始化

   ```swift
   ///规则：项目名.类名 (注意：如果项目名有特色字符是不能用该方法)
   let vcClassType = NSClassFromString("SwiftRequestDemo."+itemModel.vcString) as? URLSessionViewController.Type
   if let vcClass = vcClassType {
       let vc = vcClass.init()
       self?.navigationController?.pushViewController(vc, animated: true)
   }
   ```

   