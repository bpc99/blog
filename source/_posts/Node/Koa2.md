---
title: Koa2
subtitle: node-koa2
date: 2021-01-17 01:50:47
tags:
  - Koa2
categories: [Node]
---
一个非常流行的基于 Node 平台的 web 开发框架，优点便是非常小，但是扩展性却极其强。非常的干净利落。和另外一个比较的开发框架 Express 作用是相同的。

<!-- more -->

## koa2 和 express 的区别
虽然 koa2 和 express 作用是相同的，并且都是原班人马打造的，但是两者使用的区别还是很大的。
1. `集成度`：koa2 是一个非常轻量级的开发框架，里面并没有继承太多的插件，例如实现 Router 还需要安装`koa-router`、加载文件需要`koa-static`，而 express 内置了大量的插件，包括router、文件等插件都进行了内置。
2. `社区活跃度`：由于 express 是一款比较成熟的框架，其上手难度是比较小的，并且其社区活跃度远高于 koa2，截至本篇文章，在 npm 上对比其插件的数量如下：
	![express](https://img.bipch.cn/2021/02/03/9c0ccb441a373.png)
	![koa](https://img.bipch.cn/2021/02/03/4f5e28876c850.png)
	可以看出差别还是很大的。
3. `中间件`：express 的中间件是一款典型的线性模型，也就是自上而下依次去执行，而 koa 中间件是洋葱模型。

## 洋葱模型
关于 koa 中间件有一个很形象的图片：

![koa](https://img.bipch.cn/2021/02/03/9a9139039a0d4.png)

可以看出其开始的时候，是依次开始执行，执行到`next`便会执行下一个中间件，而结束的时候是像**栈**操作一样，先进入的是最后去执行的。
例如我们可以方便的添加日志，记录每个接口的请求信息与时间：
```javascript
const Koa = require('koa');
const app = new Koa();

// logger
app.use(async (ctx, next) => {
    console.log('第一层 - 开始');
    const start = Date.now();
    await next();
    const ms = Date.now() - start;
    console.log(`${ctx.method} ----------- ${ctx.url} ----------- ${ms}ms`);
    console.log('第一层 - 结束')
});

// response
app.use(async ctx => {
    console.log('第二层 - 开始')
    ctx.body = 'Hello World';
    console.log('第二层 - 结束')
});

app.listen(3000);
```
这样便通过第一个中间件打印日志信息，当执行到`next`方法时，会执行下一个中间件直到结束碰到`ctx.body`，然后进行出栈操作。所以上面代码执行后打印出下面信息：
```text
第一层 - 开始
第二层 - 开始
第二层 - 结束
打印第一次执行的结果： GET -------- / ------ 6ms
第一层 - 结束
```

## koa-router
由于 koa 并未内置是一款小型轻量级的开发框架，并未内置过多的插件，所以一些功能需要借助一些插件来完成，例如路由的实现可以依靠`koa-router`。

### get
get 方式比较方便，并且动态路由传递方式也很简单：
```javascript
const Koa = require('koa');
const router = require('koa-router')();
const app = new Koa();

// logs
app.use(async (ctx, next) => {
    console.log(`Process ${ctx.request.method} url ${ctx.request.url}`);
    await next();
});

// post router
router.get('/:name', ({params}) => {
    ctx.body = 'Hello ' + params.name;
});

// add router middleware
app.use(router.routes());

app.listen(3000);
```
这样可以直接 get 方式请求 http://localhost:3000/koa2 最后可以返回正确的数据。

### koa-bodyparser
上面的形式只能处理简单的路径传参，但是参数复杂或者通过别的形式传参，就需要通过`koa-bodyparser`中间件处理传递过来的数据了：
```javascript
const app = new Koa();
const Koa = require('koa');
const router = require('koa-router')();
const bodyParser = require('koa-bodyparser');

// add koa-bodyparser middleware
app.use(bodyParser());

// logs
app.use(async (ctx, next) => {
    console.log(`Process ${ctx.request.method} url ${ctx.request.url}`);
    await next();
});

// post params
router.post('/', async (ctx) => {
    const params = ctx.request.body;
    ctx.response.body = `<h1>post，${params.name}</h1>`;
});

// get params
router.get('/', async (ctx) => {
    const params = ctx.request.query;
    ctx.response.body = `<h1>get，${params.name}</h1>`;
});

// add router middleware
app.use(router.routes());

app.listen(3000);
console.log('app started at port 3000...');
```
使用`Insomnia`可以测试我们的接口：

![koa-bodyparser](https://img.bipch.cn/2021/02/08/c48f8de1480bf.png)

可以看出接口返回了正确的数据。

### 中间件应用
项目中会有些接口是需要一定的权限或者登陆后才能进行访问的，有些接口一些字段是不能重复的，但是如果将代码都重新写一遍会消耗大量的时间，同时也不利于维护，而解决方式便可以使用中间件去解决。
例如：一些接口需要登陆之后才能继续访问，否则返回前端`401`，那我们只需判断前端是否传入 token 和其正确性即可：
```javascript
// 定义
const checkUserMiddleware = async (ctx, next) => {
    if (ctx.request.headers["authorization"]) {
         // TODO: Authentication is also required
        await next()
        return
    }
    // 登陆失败，禁止继续执行，所以不需要执行 next()
    ctx.body = {
        status: 401,
        msg: 'token 失效'
    }
}
export default checkUserMiddleware;

// 使用
router.post('/info', checkUserMiddleware, async (ctx, next) => {
    ....
})
```
这样没有接口需要登陆拦截，添加上述中间件即可。

## 部署
API 开发完成后，可以直接再服务器通过 Node 运行项目完成部署，但是由于 Node 即不容易管理，并且相关 doc 窗口关闭服务便会停止，所以我们需要一个 Node 的服务管理工具，这里推荐 [pm2](https://pm2.keymetrics.io/)。
启动命令很简单：
```
pm2 start 启动文件
```
也可以通过下面方式查看所有托管的服务：
```
pm2 list
```
也可以使用`pm2 init`生成默认的配置文件 **ecosystem.config.js**，也可以配置启动命令，例如贴出我的简单配置：
```javascript
module.exports = {
  apps: [{
	// 启动名称
    name: 'api',
	// 启动文件
    script: './src/index.js',
	// 监听改变
    watch: true,
	// 忽略监听
    ignore_watch: [ "node_modules" ]
  }],
  // 部署配置
  deploy: {...}
};
```
这样一个简单的 pm2 配置便完成了，然后使用下面命令启动：

```
pm2 start ecosystem.config.js
```
即可完成服务托管。