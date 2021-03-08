---
title: dva
subtitle: dva
tags:
  - React
  - 脚手架
categories: [web]
date: 2020-08-27 08:11:39
---
一款基于 [redux](https://github.com/reduxjs/redux) 和 [redux-saga](https://github.com/redux-saga/redux-saga) 基础上进行开发的数据流管理方案，并对其进内部行了封装，添加了一些代码约束。重点在于没有引入新的概念和语法，所以比较容易上手，只需明白其代码结果即可。

<!-- more -->
## dva-cli
首先通过npm安装 dva-cli 脚手架，帮助我们快速搭建项目：
```
npm install dva-cli -g
```
安装完成后使用`-v`查看安装版本：
```
dva -v
```
安装完成后，使用`new`命令生成项目：
```
dva new project
```
可以看项目代码和结构，已经帮我们省略许多的代码。
## 路由
由于其内置并封装了 [react-router](https://github.com/ReactTraining/react-router) 我们并不需要重新安装和配置依赖，只需根据其规则书写即可。
在 `/src/router.js` 添加下面代码：
```javascript
<Route path="/counter" exact component={CountPage} />
```
即可完成添加，但是项目的访问路径却是：/#/counter，这并不符合我们需求，需求是并不需要 #，我们需要把 # 去掉，那么问什么会出现这个符合呢？是因为 router 分为 `HashRouter` 和 `BrowserRouter`，那么这两个路由是有什么区别呢？

* `HashRouter`：是最基础的路由，不需要浏览器 web server 支持。原理为 URL 的hash，“#”代表网页中的一个位置。其右面的字符，就是位置的标识符。单界面应用正是通过hash实现 “界面跳转” 。
* `BrowserRouter`：H5 新增了history API，IE9及以下不兼容，需要由 web server 支持。可以通过 js解析、修改界面地址，达到渲染的效果。

而dva默认路由为 **HashRouter**，若想去掉 **#** 只需改为 **BrowserRouter**：

1. 安装history，因为 **BrowserRouter** 的核心为 **history**，所以一定要给项目添加 history：
   ```
   yarn add history
   ```
2. 添加 history，安装完成后，要在根文件(`/src/index.js`)里面配置：
```javascript
import createHistory from 'history/createBrowserHistory';
const app = dva({
    history: createHistory(),
});
```

这样路由就修改完成了，首页地址变为了：[http://localhost:8000/](http://localhost:8000/)。
## Model
dva 通过 Model 层将数据和逻辑连接在一起管理，包含同步更新 state 的 reducers，处理异步逻辑的 effects，订阅数据源的 subscriptions。下面介绍下Model里面的 5 个重要属性：
1. **namespace**
命名空间，为了防止 state 或者一些方法重复的属性，只能用字符串。
2. **state**
初始值，注意他的优先级低于创建dva时的 `opts.initialState` 属性。
   > 访问的时候前面要加上命名空间。

3. **reducers**
主要用于处理同步操作，**唯一** 可以修改 state 的地方。和 redux 中 reducer 非常相似。一般格式为：**(state, action) => newState**。
4. **effects**
主要用于处理异步操作，他不能直接修改 state。他也是由 action 触发，也可以触发 action、和服务器交互、获取全局 state 等等。
   > effects 和 reducers 属性里面的方法名不能相同，如果相同会两个都执行，然后陷入死循环。

5. **subscriptions**
主要用于监听一个数据源，数据源可以是当前的时间、服务器的 websocket 连接、keyboard 输入、geolocation 变化、history 路由变化等等。