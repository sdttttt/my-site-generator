---
title: "RocketMQ 3.3.4 Broker"
date: 2020-10-13T16:56:11+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Java"]
author: sdttttt
draft: false
---

差不多可以看消息队列的源码了。
在下从gitee上找到了rocketmq的早期版本（3.2.2），
坏消息是这个2014年的项目里没有单元测试极少, 调试会比较困难.
好消息是这个时候的RocketMQ还没开源多久，里面有很多中文注释。看起来会很舒服。

我们从Broker开始涂鸦。关于RocketMQ中每个角色的作用这里不再陈述：

先从初始化开始：

```Java
    public static void main(String[] args) {
        start(createBrokerController(args));
    }
```

rocketmq是从`commandline`启动的，`createBrokerController`函数比较长，
会有很多额外的逻辑干扰你，我这里直接说重点：

- 读取环境变量，没有就用默认值。
- 解析命令行参数。
- 初始化配置类。
- 打印默认配置内容。
- 检查NameServer地址设置是否正确。
- 检查broker的类型（master，slave）
- 初始化日志配置类。
- 再次打印。
- 初始化服务控制对象.
- 最后增加一个关闭Broker时触发的hook.

> 服务控制对象： Broker各个服务控制器，包括存储层配置，配置文件版本号，消费进度存储，Consumer连接、订阅关系管理等等。

以上就是`createBrokerController`的内容，函数虽然长，但是并不复杂。

下面为`start`函数的内容, 在`main`中的`start`函数实际上是去委托了`BrokerController`去执行.

```java
    public void start() throws Exception {

        // 启动Broker的各层服务

        if (this.messageStore != null) {
            this.messageStore.start();
        }

        if (this.remotingServer != null) {
            this.remotingServer.start();
        }

        if (this.brokerOuterAPI != null) {
            this.brokerOuterAPI.start();
        }

        if (this.pullRequestHoldService != null) {
            this.pullRequestHoldService.start();
        }

        if (this.clientHousekeepingService != null) {
            this.clientHousekeepingService.start();
        }

        if (this.filterServerManager != null) {
            this.filterServerManager.start();
        }

        // 启动时，注册该Broker的信息到所有的NameServer
        this.registerBrokerAll(true);

        // 定时注册Broker到Name Server
        this.scheduledExecutorService.scheduleAtFixedRate(() -> {
            try {
                this.registerBrokerAll(true);
            } catch (Exception e) {
                log.error("registerBrokerAll Exception", e);
            }
        }, 1000 * 10, 1000 * 30, TimeUnit.MILLISECONDS);

        if (this.brokerStatsManager != null) {
            // 看起来就是一些数据统计线程
            this.brokerStatsManager.start();
        }

        // 删除多余的Topic
        this.addDeleteTopicTask();
    }
```

整个Borker的流程差不多就是这样.代码里并没有什么亮点说实话.
