---
title: "Redis Compile"
date: 2020-11-11T16:43:06+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Log"]
author: sdttttt
draft: false
---

也不知道我发了什么疯, 在windows上编译了一遍redis. 事实上我找到的windows上最新的redis版本是3. 

这个版本以及相当老了. 目前最新的redis是在6. 我不想功能相差过大,就重新在windows上编译了一次.

中间捣鼓了很久. 由于redis是在unix环境上开发的, windows上编译还是很麻烦. 首先试了`cygwin`这个unix模拟环境可惜编译失败了. 后面我下载了`msys2`这个unix的工具套件. 这次很顺利. redis6的包我就放在[这里](https://github.com/adminwbb/adminwbb.github.io/releases/download/1/redis6.7z), 需要可以下载.
