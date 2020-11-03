---
title: "Thread Pool Executor 运行细节"
date: 2020-08-25T17:29:15+08:00
languages: Chinese
author: sdttttt
tags: ["Java"]
draft: false
---

先说说线程池本身, 由于线程资源本身在计算机中比较昂贵, 创建和销毁都有相当的开销, 所以在一些处理简单但是并发量大的场景使用一个请求对应一个线程的是不明智的选择.

ThreadPoolExecutor是Java中线程池的一种实现. 构造函数如下:

```java
public ThreadPoolExecutor(int corePoolSize, // 核心线程数量
                              int maximumPoolSize, // 最大线程数量
                              long keepAliveTime, // 存活时间
                              TimeUnit unit, // 时间单位
                              BlockingQueue<Runnable> workQueue // 来个列队
                        ) {
        this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
             Executors.defaultThreadFactory(), defaultHandler);
    }
```

提交任务时的运行如下:

- 如果正在运行的线程数 < coreSize，马上创建线程执行该task，不排队等待；
- 如果正在运行的线程数 >= coreSize，把该task放入阻塞队列；
- 如果队列已满 && 正在运行的线程数 < maximumPoolSize，创建新的线程执行该task；
- 如果队列已满 && 正在运行的线程数 >= maximumPoolSize，线程池调用handler的reject方法拒绝本次提交。
- 从worker线程自己的角度来看，当worker的task执行结束之后，循环从阻塞队列中取出任务执行。