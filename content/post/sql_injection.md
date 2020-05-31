---
title: "SQL Injection"
date: 2020-04-10T10:54:47+08:00
tags: ["penetration test"]
draft: false
---

DVWA SQL Injection 过关秘籍.

### LOW

```PHP
if( isset( $_REQUEST[ 'Submit' ] ) ) {
    // Get input
    $id = $_REQUEST[ 'id' ];

    // Check database
    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
    // 并没有做什么注入防护
    // 尝试构造：
    // select first_name, last_name from from users where user_id = '1' and 1=1;
    // select first_name, last_name from from users where user_id = '1' and 1=2;
    // select first_name, last_name from from users where user_id = '1' or 1=1;

    $result = mysql_query( $query ) or die( '<pre>' . mysql_error() . '</pre>' );

    // Get results
    $num = mysql_numrows( $result );
    $i   = 0;
    while( $i < $num ) {
        // Get values
        $first = mysql_result( $result, $i, "first_name" );
        $last  = mysql_result( $result, $i, "last_name" );

        // Feedback for end user
        echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";

        // Increase loop count
        $i++;
    }

    mysql_close();
}
```

### Medium

```php
if( isset( $_POST[ 'Submit' ] ) ) {
    // Get input

    // 换成了Post 这也太普通了
    // 使用一些网络请求工具照样改，比如BurpSuite，PostMan，curl.
    $id = $_POST[ 'id' ];
    $id = mysql_real_escape_string( $id );
    // mysql_real_escape_string 可以对以下字符进行转义
    // \x00, \n, \r, \, ', " 和 \x1a.
    // 值得注意的是 mysql_real_escape_string 函数所在的MYSQL扩展在
    // PHP 5.5.0 起已废弃，并在自 PHP 7.0.0 开始被移除。

    // Check database
    $query  = "SELECT first_name, last_name FROM users WHERE user_id = $id;";
    // 尝试构造:
    // SELECT first_name, last_name FROM users WHERE user_id = 1 or 1=1;

    $result = mysql_query( $query ) or die( '<pre>' . mysql_error() . '</pre>' );

    // Get results
    $num = mysql_numrows( $result );
    $i   = 0;
    while( $i < $num ) {
        // Display values
        $first = mysql_result( $result, $i, "first_name" );
        $last  = mysql_result( $result, $i, "last_name" );

        // Feedback for end user
        echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";

        // Increase loop count
        $i++;
    }

    //mysql_close();
}

```

### High

```PHP
if( isset( $_SESSION [ 'id' ] ) ) {
    // Get input
    $id = $_SESSION[ 'id' ];

    // Check database
    // 看起来做了返回条目限制
    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id' LIMIT 1;";
    // 没什么套路
    // SELECT first_name, last_name FROM users WHERE user_id = '1' or 1=1 # ' LIMIT 1;

    $result = mysql_query( $query ) or die( '<pre>Something went wrong.</pre>' );

    // Get results
    $num = mysql_numrows( $result );
    $i   = 0;
    while( $i < $num ) {
        // Get values
        $first = mysql_result( $result, $i, "first_name" );
        $last  = mysql_result( $result, $i, "last_name" );

        // Feedback for end user
        echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";

        // Increase loop count
        $i++;
    }

    mysql_close();
}
```

### impossible

```PHP
if( isset( $_GET[ 'Submit' ] ) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Get input
    $id = $_GET[ 'id' ];

    // Was a number entered?
    if(is_numeric( $id )) {
        // Check the database
        // 这是！PDO!
        // PDO 是一种PHP中比较先进的面向对象形式的数据库访问技术
        // 不过即使是面向对象它还是事务脚本形式的。
        // 提供了防SQL注入的功能。
        $data = $db->prepare( 'SELECT first_name, last_name FROM users WHERE user_id = (:id) LIMIT 1;' );
        // 无法注入

        $data->bindParam( ':id', $id, PDO::PARAM_INT );
        $data->execute();
        $row = $data->fetch();

        // Make sure only 1 result is returned
        if( $data->rowCount() == 1 ) {
            // Get values
            $first = $row[ 'first_name' ];
            $last  = $row[ 'last_name' ];

            // Feedback for end user
            echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";
        }
    }
}

// Generate Anti-CSRF tsoken
generateSessionToken();
```


## Extension

**二次注入:**

网站有管理员`admin`.

一位恶意用户注册了`admin'#`用户.

恶意用户更新了自己的密码.

更新SQL:

> update from users 
> set password = '$password' 
> where 
> username = '$username' and password '$password'

替换为恶意用户写入的数据:

> update from users
> set password = #{password}
> where
> username = 'admin'#' and password = '$password'

注意`#` 后面的语句被注释掉了, 所以真正被执行的只有.

> update from users
> set password = #{password}
> where
> username = 'admin'

恶意用户可以无视管理员`admin`的密码验证，直接修改密码。