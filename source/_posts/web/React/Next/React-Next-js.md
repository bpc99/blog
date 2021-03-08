---
title: React-Next.js 介绍
date: 2021-01-27 23:29:22
subtitle: react-next
tags:
  - React
  - 脚手架
  - 服务端渲染
categories: [web]
---

Next.js 是一个轻量级的 React 服务端渲染(SSR)框架，其主要目的便是为了让 React 轻松的完成服务端的渲染，从而提升首屏打开的速度、并且更利于SEO。当然服务端渲染不是只有好处也有着许多的局限。

<!-- more -->
## SSR
服务器端渲染的检查，是完全由服务器告诉客户端渲染为什么，服务器生成 html 字符串，传递给客户端，客户端经过渲染展示给用户。

其优势在于：
1. 利于SEO：不论是 React 项目还是 Vue 等项目，界面信息都是通过客户端 JS 动态生成的，需要服务端返回相应的数据才能正确显示，但是浏览器爬虫并不会等界面完全加载之后才会抓取。而服务端渲染则是完全由服务端生成最终展示的代码，更便于爬虫抓取整个网页的信息。
2. 利于首屏渲染：因为服务端渲染完全由服务端返回客户端 HTML 字符串，客户端不需要解析 js 等文件，这样首屏的速度高于普通的方式。

当然其也不是全是优点，缺点也非常多：
1. 服务器压力大：本来属于客户端的公主，现在统一交给 Node 服务端去做，如果出现高并发会对服务器造成不小负担。
2. 开发条件受限：由于解析文件交给了服务端，所以一些代码的用法和以前有所区别。

所以项目是选用普通方式渲染还是服务端渲染都不是一概而论的，只能根据现实条件决定，而服务端渲染中较为突出的框架便为 [Next.js](https://github.com/vercel/next.js) 了。
## 手动创建项目
手动创建项目配置更灵活，项目初始化完成后，首先其是基于 React 的，所以要先安装 React 相关的依赖：
```javascript
yarn add react react-dom next
```
然后修改`package.json`中的命令：
```json
"scripts": {
  "dev": "next",
  "build": " next build",
  "start": "next start"
}
```
然后再根目录新建`pages`文件夹，新建`home.jsx`：
```javascript
function Home(){
  return (
    <div>Hello Next.js</div>
  )
}
export default Home;
```
然后执行`yarn dev`运行项目，运行成功后，直接输入：**http://localhost:3000/home** 即可访问界面，不需再需要路由相关的封装，`page`下的所有文件都会自动创建路由。
## create-next-app
除了上面手动搭建项目，还可以使用脚手架快速搭建项目，因为其能更好的帮助我们组织代码，并添加了一些项目默认配置。
执行命令安装脚手架：
```javascript
yarn global add create-next-app
```
安装完成后，执行下面的命令创建项目：
```javascript
create-next-app project-name
```
完成后执行`yarn dev`启动，启动完成后可以看到默认界面。

### 基础架构
项目创建完成后，默认有些项目的配置：

- **components**：也其它的项目基本一样，也是用于存放组件的地方。
- **pages**：所有的前端界面，该目录下的所有界面都会自动生成相应的路由。
- **pages/api**：项目中所有网络请求
- **public**：项目静态文件，可以用于存放不需要打包的文件，里面的文件打包时都会复制到另一个目录，不会经过打包处理。
- **styles**：为项目提供初始化或界面的样式。
- **.gitignore**：再向 Git 提交代码时，忽略一些文件。

很轻便的一种前端结构，并没有太复杂的配置。
## 界面跳转
在原本的 React 中，跳转界面主要用 react-router-dom 等框架实现，但是 Next.js 并不需要在安装 react-router-dom 插件，我们跳转界面需要在 Next.js 中引入：
```javascript
import Link from 'next/link'

export default ()=>(
  <>
    ...
    <Link href="/"><a>首页</a></Link>
  </>
)
```
这样便可以实现界面跳转了，但是 `<Link />` 组件，只能接收一个组件，例如下面写法是错误的：
```javascript
import Link from 'next/link'

export default ()=>(
  <>
    ...
    <Link href="/">
      <a>首页</a>
      <a>分类</a>
    </Link>
  </>
)
```
这样是不行的，但是我们可以添加父元素便可以了。
当然除了组件跳转，我们也可以通过 JS 代码进行跳转：
```
import Router from 'next/router';

export default ()=>(
  <>
    ...
    <button onClick={()=>{Router.push('/home')}}>home</button>
  </>
)
```
也是可以执行一段逻辑之后再进行跳转。
## 参数传递
当列表数据，进入详情界面，一般都需要通过路径将关键信息传递过去，然后进行数据查询，所以项目中路径传参的形式还是很常见的，但是**由于 Next 路径都是根据文件名自动生成的，所以暂时还只支持 query 形式的传递**。
我们通常的情况下可以这样写：
```javascript
import Link from 'next/link'

export default ()=>(
  <>
    ...
    <Link href="/details?id=" + id><a>详情</a></Link>
  </>
)
```
当然 href 也可接收一个对象：
```javascript
import Link from 'next/link'

export default ()=>(
  <>
    ...
    <Link href={{pathname:'/details',query:{id: id}}}><a>详情</a></Link>
  </>
)
```
当然通过函数式编程，使用 Router 也可以通过这种方式跳转：
```javascript
 function getDetails(data){
    Router.push({
      pathname:'/details',
      query: data
    })
  }
```
## getInitialProps
Next.js 为每个组件都提供了`getInitialProps`的静态方法，我们可以在该方法中获取路径传入的数据、发送网络请求等。
例如通过 url 传输的数据可以通过下面方式接收并使用：
```javascript
const Detailed = ({id}) => {
  
}
Detailed.getInitialProps = (context) => {
  let id = context.query.id;
  return {
    id
  }
}
```
这样通过参数可以直接获取到传输的数据，并且使用 return 可以将数据返回给组件，组件中通过 props 直接获取到数据即可完成参数的传递，并且我们还可以在该方法里面发送网络请求获取数据，比如：
```javascript
Detailed.getInitialProps = (context) => {
  fetch({url: ''})
  .then(res => {
    return {
      data: res
    }
  })
}
```
这样只有执行到 return 才会渲染界面，否则界面不会进行渲染，我们可以适当的为其添加 loading 界面。
## 路由钩子
Next.js 为用户封装了 六 个路由相关的钩子，当触发一定的条件后，钩子中的逻辑代码便会被执行，虽然还是不如 vue-router 中的导航守卫灵活和使用，但是比较有剩余无。

钩子分别为下面的六个：

### routeChangeStart
当路由发生变化时便可以监听到，使用需要对 Router 中的 events 使用 on 命令绑定钩子函数，比如我们可以这样去监听：
```javascript
 Router.events.on('routeChangeStart', (...args)=>{
  console.log('routeChangeStart -> 路由开始变化,参数为:',...args)
})
```
路由一旦变化，便会立即执行绑定的钩子函数。
### routerChangeComplete
路由变化结束之后，触发的事件为 routerChangeComplete，绑定方式和前面一样，但是其实路由改变完成后才触发的：
```javascript
 Router.events.on('routerChangeComplete', (...args)=>{
  console.log('routerChangeComplete -> 路由变化完成,参数为:',...args)
})
```
### beforeHistoryChange
history 是 H5 新增的 API，而 Next.js 默认便是 history 类型的 url，即路径后面没有 # 号。而该钩子便是 history 改变之前触发。
```javascript
 Router.events.on('beforeHistoryChange', (...args)=>{
  console.log('beforeHistoryChange -> history改变之前,参数为:',...args)
})
```
### routeChangeError
顾名思义，当路由出现错误的时候执行的钩子函数：
```javascript
 Router.events.on('routeChangeError', (...args)=>{
  console.log('routeChangeError -> 路由错误,参数为:',...args)
})
```
### hashChangeStart
hashChangeStart 是针对 hash 改变之前触发的钩子：
```javascript
 Router.events.on('hashChangeStart', (...args)=>{
  console.log('hashChangeStart -> hash改变之前,参数为:',...args)
})
```
### hashChangeComplete
hashChangeComplete 也是针对 hash 的特定钩子，表示 hash 方式的路由改变之后触发的钩子：
```javascript
 Router.events.on('hashChangeComplete', (...args)=>{
  console.log('hashChangeComplete -> hash改变之后,参数为:',...args)
})
```
## 模块懒加载
这一块内容便属于内容的优化，如果需要优化项目的运行和渲染速度，可以先从这方面入手。
Nxt.js 提供了 `LazyLoading`主要目的便是优化项目的加载，其主要提供了模块和组件的按需加载，它们在使用时会有些不同。
### 懒加载模块
日常开发过程中经常在项目中添加一些其它模块，例如`Moment.js`、`Lodash.js`等，这些都是常用的模块，可以提高项目的开发速率，比如这样使用：
```javascript
import React, {useState} from 'react'
import _ from 'lodash‘

function Home
  const [list, setList] = useState([]);
  
  const uniqList = () => {
    return _.uniq(list);
  }
  
  return (
    <>
      {list.map(item => (...))}
    </>
  )
}
export default Home
```
这样虽然很方便，但是这样也会导致如果首页没有引入相关插件，但是 webpack 依然会将其打包进 js 中，这样便造成了不必要的加载，造成资源的浪费。而如果我们需要只有使用某些模块才去加载，那么我们就可以这样写：
```javascript
const uniqList = () => {
  const _ = await import('lodash');
  return _.uniq(list)
}
```
这样引入只有调用相应的方法，才会去加载该模块。
### 懒加载组件
Next.js 也提供了组件懒加载的方法，使用其包装组件后，可以只有在 jsx 代码中使用了该组件，否则不会去加载该组件，可以对加载速度进行一定的优化。
比如我们有这样一个组件：
```javascript
const Component = () => {
    return (
        <div>components</div>
    )
}
export default Component;
```
我们使用的时候只需封装一下：
```javascript
...
import dynamic from 'next/dynamic';

const Component = dynamic(import('../components/index'))
```
这样只有使用 `<Component />`组件，里面代码才会被只需，不过这一点项目中并不会太常用，因为`React.lazy`可能会是更好的选择。
## 自定义Head
由于 Next.js 最大的特点还是服务端渲染，用户选用它目的便是利于SEO优化。为了更便于搜索引擎的检索，其还为我们提供 `<Head />` 组件，我们可以使用其轻松设置界面的 Head：
```javascript
import Head from 'next/head';

const Home = () => {
  return (
    <div>
      <Head>
        <title>www.bipch.cn</title>
      </Head>
      ...
    </div>
  )
}
```
这样网站的 Head 便设置完成了。
## 打包
项目线上部署的时候是需要经过打包之后，部署打包之后的代码，为了安全不能够部署源代码，Next.js 打包也为我们提供了相关的命令：

- 打包：next build
- 运行：next start

首先执行`next build`命令对项目进行打包，打包完成后，可以运行`next start`运行项目，查看打包是否有误。