---
title: "记录一次Gradle构建的困难"
date: 2021-02-05T10:57:31+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["java", "build"]
author: sdttttt
draft: false
---

受@idiotc4t所托, 我拿到了一个Java项目, 目的是要把这玩意编译出来, 最初我还以为和以前的Java项目类似,
只要`mvn build` 就能一了百了, 没想到这次拿到的是一个使用gradle构建的项目.

> gradle的出现比maven晚, 它们都是用来构建运行在JVM上的应用使用的, gradle可以使用编程语言来自定义你的构建流程, 类似C的makefile(这个比喻不太好其实), 或者是JavaScript的gulp. gradle解决了maven的一些特点, 比如xml的配置繁琐, 看着就头大, 以及构建步骤的灵活控制. 总之很牛逼就是了, 也比较难上手.

由于我以前使用过一段时间的gradle, 所以我知道用gradle打jar包的困难. (gradle这个工具通常都是给Android开发者用的, 默认没有提供打成Jar包的选项, 所以打出来什么包, 得看缘分.)

当我运行`gradle build`后, **光速**构建完成, 我定神一看, 没有工程文件目录, 倒是有一个jar包 ,这个jar包就14KB, 好家伙, 肯定没构建成功. (正常的java程序绝对不会这么小, 一般肯定是1MB以上) 输入`java -jar`一看, 果然:

```
...jar: 没有主清单属性
```

总之我在网上查了半天都没发现解决方法. 最后把目光转向代码, 最后发现在代码中都没有声明包路径...

> (嘶....这厮在README里是怎么打包的???我怀疑有这B留了一手)

最后用宇宙第一IDE(IDEA)重构了整个包的代码, 补上了包路径. 再次尝试`gradle build`,终于看到了工程文件.

写完了, 摸了.
