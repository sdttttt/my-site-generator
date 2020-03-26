---
title: Rails Development
---

### Webpacker

Rails 6版本开始依赖Webpacker，在运行之前必须先安装Webpacker这玩意。

```shell
rails webpacker:install
```

如果需要安装前端框架，请使用yarn来安装，这样部署的时候能享受到webpacker打包便利。

### production

Rails 6 启动时需要一串Key作为加密的salt，key不能随意生成。
生成key时，请删除config下的credentials.enc.yml 和 master.key 文件。
然后运行

```shell
rails credentials:edit
```

然后Rails访问静态资源，需要使用webpacker打包编译后的资产。
运行
```shell
rails assets:precompile
```

Rails 6 在生产环境下认为你使用 Apache 和 Nginx 缓存编译后的静态资产。如果你不使用他们，需要
```ruby
# config/environments/production.rb
config.public_file_server.enabled = true
```

 记住，打包之后的js以及css统一叫application.js/css 在view页面引用时需要引用application这个名字。其他的会报错