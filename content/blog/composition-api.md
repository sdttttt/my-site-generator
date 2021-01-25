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

// 当然你也可以像ReactHook那样写， 完全没有问题，看你的个人口味
const { count, add, sub } = useCount(0);

add(1);
sub(2);

function useCount(count: number) {
    const count = ref(count);
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

### 关于 watchEffect

这个函数的实现和React Hook中的useEffect有异曲同工之妙,
监听回调函数内依赖的响应式数据的变化来执行回调函数.

对,没错, 它能监听函数内变化的响应数据并且自动执行回调函数! 是不是很魔法!
连反射都做不到监听函数内依赖的外部变量.

举个例子:

```javascript
const count = ref(0)
watchEffect(() => console.log(count))

// 当count数据发送变化的时候会执行watchEffect内的回调函数
```

还有一个watch函数也可以做到类似的操作, 不过需要手动在第一个参数指定监听的响应式数据.
watch的原理就比较容易懂了. 指定了依赖就可以通过挂钩子来实现监听变化执行回调了.

问题就在watchEffect是怎么做到不指定依赖就能知道回调内依赖了哪个响应式数据?并且自动执行的?

这个魔法的原理我想破头也没有想出来. 看了一些关于副作用的文章之后才开始理解这个魔法的本质.

`watch` 和 `watchEffect` 有一个区别就在于, watchEffect在页面渲染后会首次执行一次.
这个动作就是魔法的秘密了, 执行后watchEffect就能看到那些响应式数数据收到了回调的影响.(不一定是数据的变化)