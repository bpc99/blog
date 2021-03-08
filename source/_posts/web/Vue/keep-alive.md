---
title: keep-alive
date: 2020-09-15 00:08:49
subtitle: vue-keep-alive
tags:
  - Vue
categories: [web]
---
keep-alive 是一个由 Vue 提供的一个抽象组件，可以用来对指定的组件进行缓存，从而避免组件重写渲染影响使用体验、以及多次重复渲染降低程序性能。而 keep-alive 组件可以将组件缓存下来，避免造成上面的那些问题。

<!-- more -->
## 使用场景
在不使用 keep-alive 组件时，我们界面进行回退是会刷新界面的，会触发相应的生命周期函数，这时用户体验并不好(例如: 我们从列表跳转到详情界面，再从详情返回列表，这时列表默认会进行刷新)，但是如果我们引入 keep-alive 组件不但会减少项目的网络请求，还可以显著的提升用户的体验。
## 生命周期
keep-alive 具有 activated 和 deactivated 两个生命周期。
- **activated:** 界面第一次进入，钩子触发的顺序为：**create** -> **mounted** -> **activated**。
- **deactivated:** 界面退出时触发 deactivated。

> 界面每次进入都会触发 activated，而如果只需要触发一次那就放在 mounted 钩子中。

## props
keep-alive 提供了一些组件属性：

- **include：** 类型为 string 或 正则，只有组件名称匹配会进行缓存。
- **exclude：** 类型为 string 或 正则，匹配到的不会进行缓存。
- **max：** 最多可以缓存多少组件实例。
- activated 和 deactivate 生命周期钩子。
## 缓存界面
我们可以结合 router 缓存部分的项目界面。我们可以这样配置项目的路由：
```javascript
reoters: [
  {
    path: '/',
    name: 'Home',
    meta: {
      // 缓存配置，开启
      keepAlive: true
    }
  }
]
```
这样便配置了项目路由，我们要根据 keepAlive 字段，判断是否需要对路由进行缓存，修改 router-view 组件代码：
```javascript
<keep-alive v-if="$route.meta.keepAlive">
  <router-view></router-view>
</keep-alive>
<router-view v-else></router-view>
```
这样便根据项目路由配置，动态判断缓存是否缓存界面。
## beforeEach
它一般需要和 beforeEach 进行结合使用，删除一些无用的数据缓存。例如我们有 list 界面开启了前端缓存，那么可以看下这么问题：

- 当我们进入 list 界面，然后退出，此时再次进入 list 界面，此时因为界面缓存是不会进行刷新的，这明显不符合我们需求，我们要如果退出 list 再次进入，需要重新刷新界面。
分析下上面的功能:
- 入口进入 list 界面需要重新刷新。
- 详情界面进入 list 需要进行缓存不能刷新。

为了处理上面的问题，我们需要借助 beforeEach 钩子：
```javascript
// 入口进入列表。不要缓存，进去要刷新界面
to.meta.keepAlive = false;
next();

// 详情回退列表，不要刷新
to.meta.keepAlive = true;
next();
```
