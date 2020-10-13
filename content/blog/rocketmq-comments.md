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
在下从gitee上找到了rocketmq的早期版本（3.3.4），
坏消息是这个2014年的项目里没有单元测试极少，唯一有的几个还没法直接跑通。
好消息是这个时候的RocketMQ还没开源多久，里面有很多中文注释。看起来会很舒服。

我们从Broker开始涂鸦。关于RocketMQ中每个角色的作用这里不再陈述：

先从初始化开始：

```Java
    public static void main(String[] args) {
        start(createBrokerController(args));
    }
```

rocketmq是从命令行启动的，`createBrokerController`函数比较长，
会有很多额外的逻辑干扰你，我这里直接说重点：

- 读取环境变量，没有就用默认值。
- 解析命令行参数。
- 初始化配置类。
- 打印默认配置内容。
- 检查NameServer地址设置是否正确。
- 检查broker的类型（master，slave）
- 初始化日志配置类。
- 再次打印。
- 初始化服务控制对象
- 最后增加一个关闭Broker时触发的hook.

> 服务控制对象： Broker各个服务控制器，包括存储层配置，配置文件版本号，消费进度存储，Consumer连接、订阅关系管理等等。

以上就是`createBrokerController`的内容，函数虽然长，但是并不复杂。

接下来我们看`start`函数，这个函数比较段，直接发出来吧：

```Java
    public static BrokerController start(BrokerController controller) {
        try {
            // 启动服务控制对象
            controller.start();
            String tip =
                    "The broker[" + controller.getBrokerConfig().getBrokerName() + ", "
                            + controller.getBrokerAddr() + "] boot success.";

            if (null != controller.getBrokerConfig().getNamesrvAddr()) {
                tip += " and name server is " + controller.getBrokerConfig().getNamesrvAddr();
            }

            // 打印日志，没了
            log.info(tip);
            System.out.println(tip);

            return controller;
        }
        catch (Throwable e) {
            e.printStackTrace();
            System.exit(-1);
        }

        return null;
    }
```
