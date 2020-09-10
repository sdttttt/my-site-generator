---
title: "MyBatis 源码分析"
date: 2020-09-10T22:15:42+08:00
description: ""
featured: "me.jpg"
languages: Chinese
tags: ["Java"]
author: sdttttt
draft: false
---

其实很早就想写一篇 iBatis 的源码分析了, 不过有段时间去学习 Go 了, Java 就放下了, 最近
重新捡起 Java 就把以前没填的坑,填一下.

# Init

现在开始正片.

首先是 iBatis 的初始化工作.我们看下面的代码:

```Java
// `BlogDataSourceFactory`的主要作用: 通过你的配置文件, 初始化一个DataSource
DataSource dataSource = BlogDataSourceFactory.getBlogDataSource();
// JdbcTransactionFactory一个New就能得到, 没什么依赖条件
TransactionFactory transactionFactory = new JdbcTransactionFactory();
// Environment要你交出数据源和事务工厂还有你的环境是开发还是生产
Environment environment = new Environment("development", transactionFactory, dataSource);
// Configuration有基本上你所有的配置
Configuration configuration = new Configuration(environment);
// 添加你的mapper到配置列表中, 等会我们去分析它
configuration.addMapper(BlogMapper.class);
// 通过你的配置类,让我们初始化一个SqlSessionFactory! 我们终于进入正题了!!
// 可能你觉得很快... 其实本人在这里面分析还是花了很长时间
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);
```

好, 上文有说`configuration.addMapper(BlogMapper.class)`这个方法, 现在我们来分析一下它.

```Java

    // 这个是Configuration中的方法, 它实际上是委托mapperRegistry去执行
    public <T> void addMapper(Class<T> type) {
        mapperRegistry.addMapper(type);
    }

    public <T> void addMapper(Class<T> type) {
        //mapper必须是接口
        if (type.isInterface()) {
        if (hasMapper(type)) {
            //如果重复添加了，报错
            throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
        }
        boolean loadCompleted = false;
        try {
            // 加入一个Mapper的代理生产工厂
            knownMappers.put(type, new MapperProxyFactory<T>(type));
            // It's important that the type is added before the parser is run
            // otherwise the binding may automatically be attempted by the
            // mapper parser. If the type is already known, it won't try.
            // 这个是通过注解来构建Mapper, 暂时不看
            MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
            parser.parse();
            loadCompleted = true;
        } finally {
            //如果加载过程中出现异常需要再将这个mapper从mybatis中删除
            if (!loadCompleted) {
            knownMappers.remove(type);
            }
        }
        }
    }
```

# SqlSessionFactory

既然有了 SqlSessionFactory，顾名思义，我们可以从中获得 SqlSession 的实例。
SqlSession 提供了在数据库执行 SQL 命令所需的所有方法。
你可以通过 SqlSession 实例来直接执行已映射的 SQL 语句。

```Java
try (SqlSession session = sqlSessionFactory.openSession()) {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  Blog blog = mapper.selectBlog(101);
}
```

好! 我们快进到~~曹丕~~sqlSessionFactory.openSession()

```Java
    public SqlSession openSession() {
        return openSessionFromDataSource(configuration.getDefaultExecutorType(), null, false);
    }

    private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
        // Transaction事务，包装了一个Connection, 包含commit,rollback,close方法
    Transaction tx = null;
    try {
      // 还记得么, environment里封装了我们的数据源;事务工厂;还有环境
      final Environment environment = configuration.getEnvironment();
      // 得到一个事务工厂, 如果env或者env里的事务工厂是空的就返回一个托管事务工厂
      // 托管事务工厂的特点就是每次执行完成SQL都会关闭连接, 如果你不希望关闭连接要在配置文件里设置它
      final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);
      //通过事务工厂来产生一个事务
      tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);
      //生成一个执行器(事务包含在执行器里)
      final Executor executor = configuration.newExecutor(tx, execType);
      //然后产生一个DefaultSqlSession
      return new DefaultSqlSession(configuration, executor, autoCommit);
    } catch (Exception e) {
      //如果打开事务出错，则关闭它
      closeTransaction(tx); // may have fetched a connection so lets call close()
      throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
    } finally {
      //最后清空错误上下文
      ErrorContext.instance().reset();
    }
  }
```

这样我们就得到了一个`SqlSession`.

(To be continued ... )
