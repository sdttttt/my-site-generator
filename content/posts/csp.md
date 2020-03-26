---
title: CSP并发模型
weight: 1
date: 2020-03-04T15:11:55+08:00
tags: ["golang"]
quote: "I'm creator of Hugo. #metadocreference"
---

# CSP 并发模型

CSP 模型是上个世纪七十年代提出的，用于描述两个独立的并发实体通过共享的通讯 channel(管道)进行通信的并发模型。 CSP 中 channel 是第一类对象，它不关注发送消息的实体，而关注与发送消息时使用的 channel。

## Golang CSP

Golang 就是借用 CSP 模型的一些概念为之实现并发进行理论支持，其实从实际上出发，go 语言并没有，完全实现了 CSP 模型的所有理论，仅仅是借用了 process 和 channel 这两个概念。process 是在 go 语言上的表现就是 goroutine 是实际并发执行的实体，每个实体之间是通过 channel 通讯来实现数据共享。

## Channel

Golang 中使用 CSP 中 channel 这个概念。channel 是被单独创建并且可以在进程之间传递，它的通信模式类似于 boss-worker 模式的，一个实体通过将消息发送到 channel 中，然后又监听这个 channel 的实体处理，两个实体之间是匿名的，这个就实现实体中间的解耦，其中 channel 是同步的一个消息被发送到 channel 中，最终是一定要被另外的实体消费掉的，在实现原理上其实是一个阻塞的消息队列。

## Goroutine

Goroutine 是实际并发执行的实体，它底层是使用协程(coroutine)实现并发，coroutine 是一种运行在用户态的用户线程，类似于 greenthread，go 底层选择使用 coroutine 的出发点是因为，它具有以下特点：

- 用户空间,避免了内核态和用户态的切换导致的成本
- 可以由语言和框架层进行调度
- 更小的栈空间允许创建大量的实例

可以看到第二条 用户空间线程的调度不是由操作系统来完成的，像在 java 1.3 中使用的 greenthread 的是由 JVM 统一调度的(后 java 已经改为内核线程)，还有在 ruby 中的 fiber(半协程) 是需要在重新中自己进行调度的，而 goroutine 是在 golang 层面提供了调度器，并且对网络 IO 库进行了封装，屏蔽了复杂的细节，对外提供统一的语法关键字支持，简化了并发程序编写的成本。

## Goroutine 调度器

上节已经说了，golang 使用 goroutine 做为最小的执行单位，但是这个执行单位还是在用户空间，实际上最后被处理器执行的还是内核中的线程，用户线程和内核线程的调度方法有：

- N:1 多个用户线程对应一个内核线程

![n1](/n1.png)

- 1:1 一个用户线程对应一个内核线程

![11](/11.jpg)

- M:N 用户线程和内核线程是多对多的对应关系

![MN](/MN.png)

- golang 通过为 goroutine 提供语言层面的调度器，来实现了高效率的 M:N 线程对应关系

![go_MN](/go_MN.png)


- M：是内核线程
- P : 是调度协调，用于协调 M 和 G 的执行，内核线程只有拿到了 P 才能对 goroutine 继续调度执行，一般都是通过限定 P 的个数来控制 golang 的并发度
- G : 是待执行的 goroutine，包含这个 goroutine 的栈空间
- Gn : 灰色背景的 Gn 是已经挂起的 goroutine，它们被添加到了执行队列中，然后需要等待网络 IO 的 goroutine，当 P 通过 epoll 查询到特定的 fd 的时候，会重新调度起对应的，正在挂起的 goroutine.

Golang 为了调度的公平性，在调度器加入了 steal working 算法 ，在一个 P 自己的执行队列，处理完之后，它会先到全局的执行队列中偷 G 进行处理，如果没有的话，再会到其他 P 的执行队列中抢 G 来进行处理。

## 总结

Golang 实现了 CSP 并发模型做为并发基础，底层使用 goroutine 做为并发实体，goroutine 非常轻量级可以创建几十万个实体。实体间通过 channel 继续匿名消息传递使之解耦，在语言层面实现了自动调度，这样屏蔽了很多内部细节，对外提供简单的语法关键字，大大简化了并发编程的思维转换和管理线程的复杂性。
