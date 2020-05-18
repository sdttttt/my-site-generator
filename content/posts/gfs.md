+++
date = 2020-05-09T13:00:00Z
lastmod = 2020-05-09T13:00:00Z
author = "sdttttt"
title = "GFS"
subtitle = "Suggested 25 words / 125 chars. Used in metadata, and content summaries."
+++

这是 `MIT 6.824` 课程`GFS`部分的一些总结.

GFS (Google File System) 是Google为了管理海量数据而开发的一个分布式文件系统.

直接进入正题.

在GFS中文件是以`Chunk`的形式存储。所谓的`Chunk`是一个储存块。一个Chunk的大小为64MB.一个文件会分为多个Chunk.储存在不同的服务器里。当然也会有2-3份`Chunk`的拷贝。

GFS中还存在一个`Master`，Master收集所有文件的metadata, 保存在一张表中。

下面简单的解释一下读操作的交互。

- `Client`指定的文件名和字节偏移转换成文件的一个块索引（`Chunk Index`）。
- 给`Master`发送一个包含文件名和块索引的请求。
- master回应对应的`Chunk Handle`(存储数据服务器以`Chunk Handle`标识`Chunk`)和副本的位置（多个副本）。
- `Client`以文件名和块索引为键缓存这些信息。（handle和副本的位置）
- `Client`向其中一个副本发送一个请求，很可能是最近的一个副本。请求指定了`Chunk Handle`和块内的一个字节区间。
- 除非缓存的信息不再有效（cache for a limited time）或文件被重新打开，否则以后对同一个块的读操作不再需要client和master间的交互。

