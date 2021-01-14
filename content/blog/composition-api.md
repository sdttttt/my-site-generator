---
title: "Composition Api"
date: 2021-01-14T10:29:36+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: []
author: sdttttt
draft: false
---

最近一直在写 Vue, 在公司的项目里使用的是`Composition Api` + Vue2 的组合. *(因为公司里考虑到同事的技能树, 没有用vue3和Typescipt)*.

CA 是 Vue3 追加的全新 API. 用到 Vue2 里可能有点怪怪的.

不过 CA 是以 Vue-Plugin 的方式提供的 API, 所以使用起来非常方便.
同时也鼓励更多人使用这个API.

首先是关于这个API的使用方式, 以前的代码需要将方法卸载method区块中, 每个变量和方法之间的关系很模糊暧昧.\
需要开发者自己去找关于每个方法和变量之间的关系, 用CA之后可以写出类似ReactHook风格的代码.

```typescript
// OA (Option API 原版的API是这样称呼的)
{
    data: {
        count: 1
    },
    methods: {
        sub(num: number) {
            // ...
        },
        add(num: number) {
            // ...
        }
    }
}
// CA
const count = ref(1);
const { add, sub } = useCount();

add(1);
sub(2);

function useCount(count: Ref<number>) {
    function sub(num: number) {
            // ...
        },
    function add(num: number) {
        // ...
    }
}
```

我目前写CA大概就是这样编写的. 根据一个响应数据的关系编写改变它的一系列动作.
这样逻辑拆分的很清楚. 查看起来也比较方便.

---

不过这套API目前的缺点也比较明显, 在开发过程中从Vue2过来的用户很明显能感觉到,
在`setup()`由于不能使用`this`所以会有很多开发习惯上的麻烦.

**这里说个关于使用this上挂载对象的方法.** (ctx参数不说了)

- 首先就是CA的库中有一个函数,叫做`getCurrentInstall`. 可以通过该函数获得当前组件的实例. 使用该实例上代理的对象就能控制各种`this.$router`, `this.$refs`方法了.

- 第二种可以让你使用`this`, 把动作函数挂载到某个视图按钮上的时候, 在该动作函数里就可以使用`this`对象. 上面有正常OA可以使用的所有`this`上挂载的对象.

开发项目的时候还踩了很多坑, 不过都是一些智商问题... 比如JS的对象传递传递的是`Reference`, 基本类型是`Clone`. 因为这个原因有几个视图之间的数据没法实时同步, 害我浪费了一个下午.
