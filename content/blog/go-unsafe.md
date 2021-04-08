---
title: "Go Unsafe"
date: 2021-04-08T17:26:07+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Go"]
author: sdttttt
draft: false
---

看了一些关于unsafe包的文章,长话短说:

unsafe.Pointer就是一个纯指针, 它很聪明, 如果对象改变了地址它也会自动改变.并且保持对对象的引用, 这样对象不会被回收.

uintptr就是一个比较大的整型, 能容下任何指针地址, 但是这个不会跟随对象改变地址...而且对象还会被回收...