---
title: "Go的map的个什么结构"
date: 2020-11-13T15:31:53+08:00
description: "Go的map是怎么工作的。"
featured: "me.jpg"
languages: Chinese
tags: ["Go"]
author: sdttttt
draft: false
---

实际上`Go`的`map`和`Java7`之前的`HashMap`, 非常相似。都是`Array` + `LinkedTable`的结构。

### 结构

`map`数据结构由`runtime/map.go/hmap`定义:

```go

type hmap struct {
 count     int // 当前保存的元素个数
 ...
 B         uint8  // 指示bucket数组的大小
 ...
 buckets    unsafe.Pointer // bucket数组指针，数组的大小为2^B
 ...
}

```

`bucket`数据结构由`runtime/map.go/bmap`定义：

```go

type bmap struct {
 tophash [8]uint8 //存储哈希值的高8位
 data    byte[1]  //key value数据:key/key/key/.../value/value/value...
 overflow *bmap   //溢出bucket的地址
}

```

这里使用的数组对齐方式来存放数据。`overflow`指向下一个`bucket`.

### 工作流程

首先通过`key`计算Hash值，通过Hash的低位，计算出该元素需要存放在`buckets`中的哪一个`bucket`.
如果Hash冲突，也就是当前`bucket`已经有人进去了。那么就使用该`bucket`的`overflow`指向自己的`bucket`.

查找元素也是大同小异。
