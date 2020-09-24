---
title: "Kratos 初始化流程源码解析"
date: 2020-03-31T20:17:28+08:00
languages: Chinese
draft: false
tags: ["microservice","Source code analysis"]
---

**Kratos** 是bilibili开源的一套Go微服务框架，包含大量微服务相关框架及工具。

> 名字来源于:《战神》游戏以希腊神话为背景，讲述由凡人成为战神的奎托斯（Kratos）成为战神并展开弑神屠杀的冒险历程。

好！开始吧！

*小提示：阅读源码时请保持清醒。*

首先是按照Kratos tool 生产的工程目录。

```
├── CHANGELOG.md 
├── OWNERS
├── README.md
├── api                     # api目录为对外保留的proto文件及生成的pb.go文件
│   ├── api.bm.go
│   ├── api.pb.go           # 通过go generate生成的pb.go文件
│   ├── api.proto
│   └── client.go
├── cmd
│   └── main.go             # cmd目录为main所在
├── configs                 # configs为配置文件目录
│   ├── application.toml    # 应用的自定义配置文件，可能是一些业务开关如：useABtest = true
│   ├── db.toml             # db相关配置
│   ├── grpc.toml           # grpc相关配置
│   ├── http.toml           # http相关配置
│   ├── memcache.toml       # memcache相关配置
│   └── redis.toml          # redis相关配置
├── go.mod
├── go.sum
└── internal                # internal为项目内部包，包括以下目录：
│   ├── dao                 # dao层，用于数据库、cache、MQ、依赖某业务grpc|http等资源访问
│   │   ├── dao.bts.go
│   │   ├── dao.go
│   │   ├── db.go
│   │   ├── mc.cache.go
│   │   ├── mc.go
│   │   └── redis.go
│   ├── di                  # 依赖注入层 采用wire静态分析依赖
│   │   ├── app.go
│   │   ├── wire.go         # wire 声明
│   │   └── wire_gen.go     # go generate 生成的代码
│   ├── model               # model层，用于声明业务结构体
│   │   └── model.go
│   ├── server              # server层，用于初始化grpc和http server
│   │   ├── grpc            # grpc层，用于初始化grpc server和定义method
│   │   │   └── server.go
│   │   └── http            # http层，用于初始化http server和声明handler
│   │       └── server.go
│   └── service             # service层，用于业务逻辑处理，且为方便http和grpc共用方法，建议入参和出参保持grpc风格，且使用pb文件生成代码
│       └── service.go
└── test                    # 测试资源层 用于存放测试相关资源数据 如docker-compose配置 数据库初始化语句等
    └── docker-compose.yaml
```

## Entry

入口在`cmd/main.go`下，我们进去看看。

```go
func main() {
    // 没什么好说的，参数解析
	flag.Parse()
	log.Init(nil) // debug flag: log.dir={path}
	defer log.Close()
	log.Info("kratos-demo start")
	// -conf 参数的解析
    paladin.Init()
	// 这里是 `深坑的入口`
	// 一会分析
	_, closeFunc, err := di.InitApp()
	if err != nil {
		panic(err)
    }
    // os.Signal 是一个系统信号接收channel
    c := make(chan os.Signal, 1)
    // syscall 都是一些系统信号
	signal.Notify(c, syscall.SIGHUP, syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT)
	for {
        // 一旦有信号进来了，看下面的代码逻辑，八成是关闭这个应用。
		s := <-c
		log.Info("get a signal %s", s.String())
		switch s {
		case syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT:
			closeFunc()
			log.Info("kratos-demo exit")
			time.Sleep(time.Second)
			return
		case syscall.SIGHUP:
		default:
			return
		}
	}
}

```

## Initializer

接下来我们去看`di.InitApp()`里做了什么。

这个方法是通过`github.com/google/wire`来生成.

如果你不知道`wire`可以参考下面的官方原话：

> Wire is a code generation tool that automates connecting components using dependency injection. Dependencies between components are represented in Wire as function parameters, encouraging explicit initialization instead of global variables. Because Wire operates without runtime state or reflection, code written to be used with Wire is useful even for hand-written initialization.

> 简单来说就是Golang的依赖注入代码生成器, 它不使用反射.由Google提供.

不过`Wire`不是我们的重点, 我们接着回到`di.InitApp()`去。

```go
// Injectors from wire.go:
func InitApp() (*App, func(), error) {

    // 基本上就是创建一个个实例，和善后它们的函数
    // 如果途中创建出问题就全体下葬（触发善后函数）.

	// Redis实例，善后函数
	redis, cleanup, err := dao.NewRedis()
	if err != nil {
		return nil, nil, err
	}

	// memcache实例，善后函数
	memcache, cleanup2, err := dao.NewMC()
	if err != nil {
		cleanup()
		return nil, nil, err
	}

	// 看起来只支持MySQL，善后函数
	db, cleanup3, err := dao.NewDB()
	if err != nil {
		cleanup2()
		cleanup()
		return nil, nil, err
	}

	// 把上面所有的模型对象做一个DAO层封装
	daoDao, cleanup4, err := dao.New(redis, memcache, db)
	if err != nil {
		cleanup3()
		cleanup2()
		cleanup()
		return nil, nil, err
	}

    // 这个是个重点，`service`是你的gRPC服务.
	// 一会我们去分析他
	serviceService, cleanup5, err := service.New(daoDao)
	if err != nil {
		cleanup4()
		cleanup3()
		cleanup2()
		cleanup()
		return nil, nil, err
	}

    // 有人会好奇Kratos是怎么把gRPC和Gin融合在一起的
    //（没错Bilibili的web框架是Gin, 不过这个Gin的一部分核心代码已经被魔改过了， 在Engine初始化的时候会多加入一个链路追踪的Middleware, 还有一堆路由...）
    // 秘密就在这里，等会我们再看
	engine, err := http.New(serviceService)
	if err != nil {
		cleanup5()
		cleanup4()
		cleanup3()
		cleanup2()
		cleanup()
		return nil, nil, err
    }
    
    // gRPC的初始化的常规操作
	server, err := grpc.New(serviceService)
	if err != nil {
		cleanup5()
		cleanup4()
		cleanup3()
		cleanup2()
		cleanup()
		return nil, nil, err
    }
    
    // 把上面的服务，engine,gRPC服务,整一块
	// 善后函数
	// 后面稍微分析一下
	app, cleanup6, err := NewApp(serviceService, engine, server)
	if err != nil {
		cleanup5()
		cleanup4()
		cleanup3()
		cleanup2()
		cleanup()
		return nil, nil, err
    }
    
    // 你可以走了.
	return app, func() {
		cleanup6()
		cleanup5()
		cleanup4()
		cleanup3()
		cleanup2()
		cleanup()
	}, nil
}

//以上代码全是自动生成，冗余很正常
```

接下来我们首先看看`serviceService`是个什么东西.*(这是什么魔鬼命名)*

进到`Service.New(dao)`

```go

// Service service.
type Service struct {
    // 配置文件映射的Map (这个命名就nm离谱)
    ac  *paladin.Map
    // 字面意思
	dao dao.Dao
}

// New new a service and return.
func New(d dao.Dao) (s *Service, cf func(), err error) {
    // 初始化～～～
	s = &Service{
		ac:  &paladin.TOML{},
		dao: d,
	}
    // 一个关闭的钩子
    cf = s.Close

	// 热加载 application.toml 配置文件
	// 原理是使用fsnotify监听文件变更
    err = paladin.Watch("application.toml", s.ac)
	return
}

// -------------- 下面都是你的gRPC业务逻辑-------------

// SayHello grpc demo func.
func (s *Service) SayHello(ctx context.Context, req *pb.HelloReq) (reply *empty.Empty, err error) {
	reply = new(empty.Empty)
	fmt.Printf("hello %s", req.Name)
	return
}

// SayHelloURL bm demo func.
func (s *Service) SayHelloURL(ctx context.Context, req *pb.HelloReq) (reply *pb.HelloResp, err error) {
	reply = &pb.HelloResp{
		Content: "hello " + req.Name,
	}
	fmt.Printf("hello url %s", req.Name)
	return
}

// Ping ping the resource.
func (s *Service) Ping(ctx context.Context, e *empty.Empty) (*empty.Empty, error) {
	return &empty.Empty{}, s.dao.Ping(ctx)
}

// Close close the resource.
func (s *Service) Close() {}
```

哇哦，现在我们知道了，`Service`是由一些`gRPC`方法，配置项，模型层组成的。

好，乘胜追击我们再看一看`engine, err := http.New(serviceService)`做了什么。

```go
var svc pb.DemoServer

// New new a bm server.
func New(s pb.DemoServer) (engine *bm.Engine, err error) {
	var (
		cfg bm.ServerConfig
		ct  paladin.TOML
	)
	// 读取你的配置文件
	if err = paladin.Get("http.toml").Unmarshal(&ct); err != nil {
		return
	}
	// 得到http.toml的Server字段
	if err = ct.Get("Server").UnmarshalTOML(&cfg); err != nil {
		return
	}
	svc = s

	// 做一个新 engine 
	// (engine 是 Gin 里的模块，这里我就不分析Gin的源码了)
	engine = bm.DefaultServer(&cfg)

	// 将gRPC服务注册到engine, 这个代码注册代码是bm自己生成的
	// 一会我们分析
	pb.RegisterDemoBMServer(engine, s)

	// 把你的路由搞进去
	initRouter(engine)

	// 开始跑
	err = engine.Start()
	return
}

// 路由在这里登记！
func initRouter(e *bm.Engine) {
	e.Ping(ping)
	g := e.Group("/kratos-demo")
	{
		g.GET("/start", howToStart)
	}
}

func ping(ctx *bm.Context) {
	if _, err := svc.Ping(ctx, nil); err != nil {
		log.Error("ping error(%v)", err)
		ctx.AbortWithStatus(http.StatusServiceUnavailable)
	}
}

// example for http request handler.
func howToStart(c *bm.Context) {
	k := &model.Kratos{
		Hello: "Golang 大法好 !!!我好你个头！",
	}
	c.JSON(k, nil)
}

```

如果你使用过`gin`这个web框架, 上面的代码你一定很熟悉，对吧？
`bm`就是`gin`，只是部分代码被Bilibili魔改了，整体架构是不变的。

OK，我们看看`RegisterDemoBMServer`里做了什么.

```go
// DemoBMServer is the server API for Demo service.
type DemoBMServer interface {
	Ping(ctx context.Context, req *google_protobuf1.Empty) (resp *google_protobuf1.Empty, err error)

	SayHello(ctx context.Context, req *HelloReq) (resp *google_protobuf1.Empty, err error)

	SayHelloURL(ctx context.Context, req *HelloReq) (resp *HelloResp, err error)
}

// 我们写的gRPC服务
var DemoSvc DemoBMServer
// ------------------------------------------------

// 我们仔细分析这些方法不难发现
// 他们都会调用 `BindWith` 和对应的gRPC方法

// 先使用BindWith: 将request中的`Body` 转化为go中的 `struct`
// 然后使用gRPC方法处理请求数据
// 最后返回

// 本质就是通过http调用gRPC服务

func demoPing(c *bm.Context) {
	p := new(google_protobuf1.Empty)
	if err := c.BindWith(p, binding.Default(c.Request.Method, c.Request.Header.Get("Content-Type"))); err != nil {
		return
	}
	resp, err := DemoSvc.Ping(c, p)
	c.JSON(resp, err)
}

func demoSayHello(c *bm.Context) {
	p := new(HelloReq)
	if err := c.BindWith(p, binding.Default(c.Request.Method, c.Request.Header.Get("Content-Type"))); err != nil {
		return
	}
	resp, err := DemoSvc.SayHello(c, p)
	c.JSON(resp, err)
}

func demoSayHelloURL(c *bm.Context) {
	p := new(HelloReq)
	if err := c.BindWith(p, binding.Default(c.Request.Method, c.Request.Header.Get("Content-Type"))); err != nil {
		return
	}
	resp, err := DemoSvc.SayHelloURL(c, p)
	c.JSON(resp, err)
}
//-------------------------------------

// RegisterDemoBMServer Register the blademaster route
func RegisterDemoBMServer(e *bm.Engine, server DemoBMServer) {
	// server 是我们之前编写的gRPC服务
	DemoSvc = server
	
	// 将一些方法注册到路由里去 
	e.GET("/demo.service.v1.Demo/Ping", demoPing)
	e.GET("/demo.service.v1.Demo/SayHello", demoSayHello)
	e.GET("/kratos-demo/say_hello", demoSayHelloURL)
}
```

哇，原来只是把一些gRPC的服务绑定到`gin`的路由里了呀。
借用`gin`来调用gRPC.

`grpc.New()`就不分析了。

然后是`AppNew()`

```go
//go:generate kratos tool wire
type App struct {
	svc  *service.Service
	http *bm.Engine
	grpc *warden.Server
}

func NewApp(svc *service.Service, h *bm.Engine, g *warden.Server) (app *App, closeFunc func(), err error) {
	app = &App{
		svc:  svc,
		http: h,
		grpc: g,
	}

	// 一个关闭context的回调
	closeFunc = func() {
		ctx, cancel := context.WithTimeout(context.Background(), 35*time.Second)
		if err := g.Shutdown(ctx); err != nil {
			log.Error("grpcSrv.Shutdown error(%v)", err)
		}
		if err := h.Shutdown(ctx); err != nil {
			log.Error("httpSrv.Shutdown error(%v)", err)
		}
		cancel()
	}
	return
}
```

到这里初始化是结束了。

# Summary

`kratos`的初始化流程:

- 读取配置文件
- 实例化Dao层
- 实例化gRPC服务
- 实例化gin的engine
- 注册gPRC到engine
- 启动engine
- 启动gRPC服务端
- 获得整个程序关闭的回调

我分得应该还是比较细的。

后面应该还会分析`warden`，它是`Kratos`在`grpc`原版上的一个封装版本。

溜了溜了...