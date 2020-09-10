---
title: "GoSyncPool"
date: 2020-09-03T17:06:04+08:00
languages: Chinese
tags: ["Golang"]
featured: "/me.jpg"
author: sdttttt
draft: false
---

今天在看Sentinel-golang源码的时候发现sentinel在内部使用了sync.Pool该结构体.看到Sync和Pool的我第一反应想到应该是线程池之类的东西.在实际看过原理之后发现并不是这样的.

---

sync.Pool 的目的是为了利用对象的复用来减小GC压力.但是开销比较高.要斟酌使用.

Pool和golang的GMP协程模型的关系比较大.
sync.Pool对每一个P(系统线程)都分配了一个本地池.

本地池中有2个属性，分别是private和share。
private只能被当前P访问，share可以被不同的P访问.

在执行Get or Put的时候.会对应当前执行P的本地池.

#### Get

1. 尝试从本地P对应的那个本地池中获取一个对象值, 并从本地池冲删除该值。
2. 如果获取失败，那么从共享池中获取, 并从共享队列中删除该值。
3. 如果获取失败，那么从其他P的共享池中偷一个过来，并删除共享池中的该值(p.getSlow())。
4. 如果仍然失败，那么直接通过New()分配一个返回值，注意这个分配的值不会被放入池中。New()返回用户注册的New函数的值，如果用户未注册New，那么返回nil。

#### Put

1. 如果放入的值为空，直接return.
2. 检查当前goroutine的是否设置对象池私有值，如果没有则将x赋值给其私有成员，并将x设置为nil。
3. 如果当前goroutine私有值已经被设置，那么将该值追加到共享列表。