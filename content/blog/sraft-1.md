---
title: "Sraft (一)"
date: 2020-09-21T11:29:51+08:00
description: "算是开发日志吧."
featured: "me.jpg"
languages: Chinese
tags: ["Log"]
author: sdttttt
draft: false
---

今天开始算是正式编写Sraft这个库, 开发的原因有两个:

- 我需要通过这次开发来熟悉Raft这个协议.~~(以后面试或者和人攀谈也更有底气)~~
- 我的微服务框架的服务中心需要一个能达成分布式一致性的功能.

语言采用的是Go, 目前的编程模型大概也完成了, 下面我来介绍:

> 本人喜欢简单并且高效的设计, 对于设计复杂难以实现的东西会感到不适(脑子不够用),

### Raft Kernel

整个编程模型会有比较多的模块, 整体采用的是微核架构, `Raft Kernel`会协调各个模块之间的工作.

模块之间的通信由`Raft Kernel`来完成. 通信方式采用`Channel`异步非阻塞的形式.

### Exchange Network

外部通信从这里进入, 由`Exchange Network`将通信内容封装为事件, 发送给`Raft Kernel`.

或者`Raft Kernel`传递事件给`Exchange Network`, 再由`Exchange Network`执行外部通信.

### State Machine

Raft协议的核心实现, 状态机会在`Leader`, `Follower`, `Candidate`三种角色之间自动切换, 
每一角色处理的事件都是一样的, 但是具体过程是不一样的. (这个部分的密度会比较大)

### Data Log Synchronizer

负责同步数据的模块, 采用的是日志提交形式.

---

以上的我目前已经构思出的编程模型, 但是为暂定. 实际的编写模型肯定会有少许修改.

PROJECT: github.com/sdttttt/sraft
