---
title: "节流与防抖"
date: 2021-01-18T16:49:35+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Javascript"]
author: sdttttt
draft: false
---

闲来无事在网上翻一些关于 Javascript 的一些搞基技巧，就发现了节流与防抖这两种设计模式。

上个星期在编写搜索框的时候就已经写过类似的代码 _（搜索框输入关键词会实时去服务器上搜索，考虑到服务器压力就把代码加了限制，每 500ms 最多搜索一次，实际上这就是类似防抖的设计，只是我还不知道这个叫防抖...）_

下面是搜索框的限制代码：

```javascript
watch(searchText, (newVal) => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(
        () => //...需要限制的逻辑
            ),
        500
    );
});
```

原理非常简单，通过定时器实现，一旦现有状态改变就说明有新的输入，然后清除老的定时器，新设置定时器。

---

今天在网上冲浪又学到了一种新的设计：**节流**

直接看代码吧：

```javascript
watch(searchText, (newVal) => {

    if(isStop) {
        return
    }

    isStop = true;

    setTimeout(
        () => {
            //...需要限制的逻辑
            isStop = false
        }
    ),
    500
);
```

emmm，一开始看了半天，实际上看懂之后节流比防抖更加简单 _（好吧，看了几遍其实发现差不多）_

原理还是一样简单，计数器结束将标志位设置为 false，这样新来的计时器就能通过，如果没到限制时间就进入这个函数会被标志位拦住，直接返回。

节流主要作用就是限制执行频率。

硬要说防抖和节流的区别。。。emm我也说不上来，看应用场景吧。