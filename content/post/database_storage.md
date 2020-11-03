---
title: "Database Storage"
date: 2020-06-02T19:51:50+08:00
languages: Chinese
author: sdttttt
draft: false
---

**CMU Database System 15-445/645** 储存 Part 1

数据库存储的数据在 FS(File System) 中是以 **块(Block)** 的方式表示的.

实际上你很可能已经见到过了,在MySQL中的数据库就是以一切Block文件的方式存储的.

这篇文章会告诉你目前常见的数据库存储方式.

---

最开始用**Tuple Storage**来尝试改善数据库的存储结构.

![](https://imgkr.cn-bj.ufileos.com/0029ea52-6d5b-4989-a8e0-a7dec2e0d49c.png)

它的工作原理比较简单, 每一个**Page**维护一个**Header**,
Header中会包含一些Page的元数据,以及被存储数据的偏移值.

每当插入一个Tuple,我们就会Update Header中的偏移值.

这个设计中存在比较大的问题, 如果我们删除了底下Tuple,就不得不移动所有Tuple.
如果不移动数据, 那我们也要花费高昂的代价去维护Header中Page的meta数据.

---

目前最常见的就是**Slotted Pages**的方式去存储数据.
在不同数据库中的实现细节可能不同,但是从高级层面来讲,大多数数据库系统,
用的都是这种方式去存储数据.

![](https://imgkr.cn-bj.ufileos.com/a47909a8-e0e6-48ea-a0b7-e3e327d7fdf2.png)

每个Page中有三个部分:

- **Header**: 保存最基本的matedata, 还包含一些checksum和访问时间之类的.
- **SlotArray**: 将每一个特定的Slot映射到对应Tuple的偏移值上.
- **TupleArray**: 储存每一个Tuple.

在这个结构中Header后面紧接这SoltArray, 而Tuple是从Page的尾部开始存储的.
每个Page存储的Tuple的个数是固定的.

如果Tuple被删除,我们也只需要删除固定的Solt就行. 
空出来的空间碎片,可以由数据库的空间整理功能去完成.
维护每个Tuple的成本也比较小.只需要改变Solt就可以.

---

最后讲一个Demo来演示数据库的工作过程.

假如我想要找一个叫A的人,我会先去查找索引.
从索引里我知道A的Page是123, Solt是2.
我去找管理Pages的人,让他把Page123的指针给我,
然后拿着Page的指针,找到Solt2中的偏移地址,找到了A这个人.