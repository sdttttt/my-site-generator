---
title: "Log 5"
date: 2020-10-23T16:44:07+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Log"]
author: sdttttt
draft: false
---

今天写了一天的sraft. 本来是自信满满，但是有些地方的设计真的让我焦头烂额.

今天把sraft的rpc的网络通信部分换成了长连接。
但是写到节点发现的部分又有问题来了，我没有写关于处理节点发现之类的模块，
至今都是按照raft论文上的基础理论来实现的。

这一块又要怎么设计呢...
果然有些地方写的还是太复杂了么.
