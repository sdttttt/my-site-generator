---
title: "Red Black Tree"
date: 2020-05-25T19:27:28+08:00
tags: ["Data Structure"]
draft: false
---

半年前在研究`HashMap`的时候已经学习过红黑树的规则原理了.
不过现在又遇到就忘记是怎么实现的了.(只知道这玩意是用来平衡树的)
这次就把这个数据结构做一个了断.

### 性质

- 性质1：每个节点要么是黑色，要么是红色。
- 性质2：根节点是黑色。
- 性质3：每个叶子节点（NIL）是黑色。
- 性质4：每个红色结点的两个子结点一定都是黑色。
- 性质5：任意一结点到每个叶子结点的路径都包含数量相同的黑结点。

满足这5个性质就能保证红黑树是平衡的.

### Insert

插入的节点默认是红色的.因为这样可以最大限度满足红黑树的5个性质.

请试想一下.如果插入的节点是红色:
- 性质1可以满足.
- 性质2可以满足.
- 性质3可以满足(插入红色节点后自动衍生出2个黑色的NIL节点).
- 性质4可能没法满足(新插入的节点的父节点也是红色).
- 性质5可能没法满足(父节点是黑色时就不行).

然后是红黑树节点的左右旋.

![](https://gitee.com/sdttttt/images/raw/master//1323444-ff870251222c460e.gif)

![](https://gitee.com/sdttttt/images/raw/master//1323444-3f68be339d2a3983.gif)

看懂没? 节点的旋转大概就是这样。

然后就是要分插入的情况了.

- 第一种：根节点为空。这种情况，将node的颜色改为黑色即可.

- 第二种: node的父节点为黑色。这种情况不需要做修改.

- 第三种: node的父节点为红色 (根据性质3，N的祖父节点必为黑色). 这种情况和变换规则都比较多.下面细说...

    - node的叔父节点为红色。这种情况，将N的父节点和叔父节点的颜色都改为黑色，若祖父节点是跟节点就将其改为黑色，否则将其颜色改为红色，并以祖父节点为插入的目标节点开始重新递归修复红黑树.
        
    ![](https://gitee.com/sdttttt/images/raw/master//Red-black_tree_insert_case_3.png)

    - node的叔父节点为黑色，且node和node的父节点在同一边 (即父节点为祖父的左儿子时，N也是父节点的左儿子。父节点为祖父节点的右儿子时。N也是父节点的右儿子)。以父节点为祖父节的左儿子为例，将父节点改为黑色，祖父节点改为红色，然后以祖父节点为基准右旋。(N为父节点右儿子时做相应的左旋)

    ![](https://gitee.com/sdttttt/images/raw/master//Red-black_tree_insert_case_5.png)

    - node的叔父节点为黑色，且node和node的父节点不在同一边 (即父节点为祖父的左儿子时，N是父节点的右儿子。父节点为祖父节点的右儿子时。N也是父节点左右儿子)。以父节点为祖父节点的左儿子为例。以父节点为基准，进行左旋，然后以父节点为目标插入节点进入情况3的b情况进行操作。

    ![](https://gitee.com/sdttttt/images/raw/master//Red-black_tree_insert_case_4.png)

### Delete

这个以后再说.

### Search

红黑树算是搜索二叉树的一个子集，`Search`方法是相同的。