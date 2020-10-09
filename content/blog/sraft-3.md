---
title: "Sraft (三)"
date: 2020-10-09T10:52:24+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Log"]
author: sdttttt
draft: false
---

经过几天思考, 我决定稍微重新分配一下各个模块的密度.

`RaftKernel`中的`Solt`为本次的重点.对`RaftKernel`来说`Solt`为一个黑盒.`Solt`对外处理所有事件,但是不暴露实现.
内部的状态机转化也对`RaftKernel`进行隐藏.`RaftKernel`只要接受外界AE, 交给`Solt`, `Solt`反馈相应的事件, `RaftKernel`进行处理.

挖藕, 希望这次有效.![dc77f6e30c4b4dba807b4a84b29c74d4.jpg](https://idanmu.net/2020/10/c003543193753.jpg)