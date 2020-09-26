---
title: "GRC (一)"
date: 2020-09-26T14:49:17+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Log"]
author: sdttttt
draft: false
---

我真的没法忍受`git-cz`了.
每次运行都特别慢, 还依赖Node.js这个东西.
使用时也没有办法自定义type.

为了这个, 这两天我创建了一个新的项目,叫做GRC,
这个工具是为了我自己开发的, 当然, 我也希望能帮助到其他人.
GRC是用Rust编写的, 抛开Runtime的环境, 可以直接运行,
而且Rust是编译型语言, GRC的速度和`git-cz`相比也有着绝对的优势.

用法可以参考git-cz, 大部分操作都是一致的.
除了提交规范的Commit以外, 我也打算在GRC中加入一些其他的功能.
比如自动添加文件以及自动推送等等.

---

目前GRC的commit规范的功能已经完全实现了.
基本上已经和git-cz有着完全一致的功能.
我也已经把GRC发布在了crates.io网站上.
在crates.io上搜索grc就能看到.
同时我也在v2ex上写了关于GRC的文章.

开发也会继续进行, GRC会在以后为你提供更方便的功能.
我也期待有人能参与到这个项目中来.

希望GRC能帮助更多人.
