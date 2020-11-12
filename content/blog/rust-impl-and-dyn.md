---
title: "Impl and Dyn on Rust"
date: 2020-11-12T09:46:53+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Rust"]
author: sdttttt
draft: false
---

这篇文章会讲解关于Rust中impl和dyn这两个关键词的作用. 帮助你更好的编写Rust程序.

我们先来看这样一段代码:

```rust

impl View for Button { ... }

impl View for Text { ... }

```

我们看到`Button`和`Text`都实现了`View`属性, 抽象是一种不错的设计程序的方法, 帮助我们透明化的使用外部提供的API. 然后我们可能会下意识的写出下面的代码:

```Rust

/// 这种代码实际上会让人感到疑惑. View究竟是个特性还是一个对象.
/// 这里的View是一个类型, 所以我们需要写成 `impl View`.
//  不过`impl View` 不能用于多个trait实现的返回. 但是可以作为入参.
pub fn something() -> View {
    if ... {
        Button { ... }
    } else {
        Text { ... }
    }
}

```

这段代码无法通过编译, 原因就是返回值`View`需要在编译器确认大小. 我们需要把它装成一个胖指针.

```rust

pub fn something() -> Box<View> {...}

```

嗯,这样就好很多. 但是编译器会爆种, 提出一个警告, 希望你把`Box<View>`改为`Box<dyn View>`.

这又是什么意思?

`dyn` 是动态的缩写, 意义其实很明显. 使用`dyn`修饰的类型, 会在程序执行期动态分发. 会有一定的RUNTIME开销.

```rust

pub fn something() -> Box<dyn View> {...}

```

现在我们把代码改成这样, 好多了.

接下来说说`impl`, 这个语法是个语法糖其实.怎么个语法糖呢?

```rust

fn something<T: View>(v: T) { ... }

// ------------- 用 impl 之后 ------------------

fn something(v: impl View) { ... }

```

真的就这么简单.

第二次说一遍, 这种`T(泛型)`写法在入参可以这么做, 但是返回值不行. 除非你的返回值只返回一个`T`实现. 两种以上请`重载 (我乱说的,rust可能不支持)`或者使用`dyn`.
