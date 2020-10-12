---
title: "MyBatis 源码分析"
date: 2020-09-10T22:15:42+08:00
description: "本文让你知道iBatis是怎么工作的, 以及一些你可能不知道的执行细节."
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

> 2020.10.12 继续更新

有了`SqlSession`之后我们就可以操作数据库了。

我们来看看MyBatis是怎么实现`session.selectOne("org.mybatis.example.BlogMapper.selectBlog", 101);`的。

```Java
  public <T> T selectOne(String statement, Object parameter) {
    // Popular vote was to return null on 0 results and throw exception on too many.
    //转而去调用selectList,很简单的，如果得到0条则返回null，得到1条则返回1条，得到多条报TooManyResultsException错
    // 特别需要主要的是当没有查询到结果的时候就会返回null。因此一般建议在mapper中编写resultType的时候使用包装类型
    //而不是基本类型，比如推荐使用Integer而不是int。这样就可以避免NPE
    List<T> list = this.<T>selectList(statement, parameter);
    if (list.size() == 1) {
      return list.get(0);
    } else if (list.size() > 1) {
      throw new TooManyResultsException("Expected one result (or null) to be returned by selectOne(), but found: " + list.size());
    } else {
      return null;
    }
  }

  // emm，这里其实啥都没有，我们去SelectList看看。

  // 在下来解释一下这三个参数：
  // statement 映射语句的位置，比如"org.mybatis.example.BlogMapper.selectBlog"
  // parameter SQL语句中的参数
  // RowBounds 分页限制，相当于SQL中的limit. 
  public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
    try {
      //根据statement id找到对应的MappedStatement
      MappedStatement ms = configuration.getMappedStatement(statement);
      //转而用执行器来查询结果,注意这里传入的ResultHandler是null
      // wrapCollection：如果参数是Collection类型，转换成Map，key为parameter的type.
      return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
    } catch (Exception e) {
        
      throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }


  // 接下来是执行器的部分
  public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler) throws SQLException {
    //得到绑定sql，就是将参数插入映射语句里，获得完整的SQL
    BoundSql boundSql = ms.getBoundSql(parameter);
    //创建缓存Key
    CacheKey key = createCacheKey(ms, parameter, rowBounds, boundSql);
    //查询
    return query(ms, parameter, rowBounds, resultHandler, key, boundSql);
 }

 // 执行查询
  public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql) throws SQLException {
    // ErrorContext 是每个线程单独使用的错误上下文，它是用ThreadLocal制作的.
    ErrorContext.instance().resource(ms.getResource()).activity("executing a query").object(ms.getId());
    //如果已经关闭，报错
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    //先清局部缓存，再查询.但仅查询堆栈为0，才清。为了处理递归调用
    if (queryStack == 0 && ms.isFlushCacheRequired()) {
      clearLocalCache();
    }
    List<E> list;
    try {
      //加一,这样递归调用到上面的时候就不会再清局部缓存了
      queryStack++;
      //先根据cachekey从localCache去查
      list = resultHandler == null ? (List<E>) localCache.getObject(key) : null;
      if (list != null) {
        //若查到localCache缓存，处理localOutputParameterCache
        handleLocallyCachedOutputParameters(ms, key, parameter, boundSql);
      } else {
        //从数据库查
        list = queryFromDatabase(ms, parameter, rowBounds, resultHandler, key, boundSql);
      }
    } finally {
      //清空堆栈
      queryStack--;
    }
    if (queryStack == 0) {
      //延迟加载队列中所有元素
      for (DeferredLoad deferredLoad : deferredLoads) {
        deferredLoad.load();
      }

      // issue #601
      //清空延迟加载队列
      deferredLoads.clear();
      if (configuration.getLocalCacheScope() == LocalCacheScope.STATEMENT) {
        // issue #482
    	//如果是STATEMENT，清本地缓存
        clearLocalCache();
      }
    }
    return list;
  }
```

