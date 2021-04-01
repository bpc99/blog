---
title: Next.js
date: 2021-01-27 23:29:22
subtitle: react-next
tags:
  - React
  - 服务端渲染
categories: [web]
---
一款轻量级的 React 服务端渲染框架，[社区](https://github.com/vercel/next.js) 的活跃度也不错，如果需要使用 React 做一个轻量级的 SSR 类型的项目是个不错的选择(比如个人博客)，其使用起来也是非常的简便。

<!-- more -->

## SSR
将组件或页面由服务端解析，服务端请求数据并填充得到最终的 html 字符串返回客户端。

这样做优势在于：
1. 利于SEO：平常界面信息都是通过客户端 JS 动态拼接生成的，需要服务端返回相应的数据才能正确显示，但浏览器爬虫并不会等界面完全加载之后才会抓取。而服务端渲染则更便于爬虫抓取整个网页的信息。
2. 前端资源占用较少：因为服务端渲染完全由服务端返回客户端 HTML 字符串，客户端不再需要另外解析文件，这样前端消耗资源更少。

当然其也不是全是优点，缺点也非常多：
1. 服务器压力大：本来属于客户端的工作，现在统一交给服务端去做，如果出现高并发会对服务器造成不小负担。
2. 首屏加载速度较慢：由于解析大部分文件都需要首屏进行加载，所以首次加载会比较慢的，并且界面跳转由于都靠后台解析界面，所以可能会出现暂时的白屏界面。

## hello world
空文件下安装开发闭包插件：
```javascript
yarn add react react-dom next
```
修改`package.json`中的命令：
```json
"scripts": {
  "dev": "next",
  "build": " next build",
  "start": "next start"
}
```
3 个命令每个都有着自己作用，后面会介绍，新建一个文件：
```javascript
function Home(){
  return (
    <div>hello world</div>
  )
}
export default Home;
```
执行`yarn dev`运行项目，运行成功后，直接输入：**http://localhost:3000/home** 即可访问界面，不需再需要路由相关的封装，`page`下的所有文件都会自动创建路由。

## create-next-app
使用脚手架初始化项目可以更好的为我们组织代码，执行命令安装：
```javascript
yarn global add create-next-app
```
安装完成后，直接创建即可：
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
React 中跳转界面主要用 react-router-dom 等框架实现，但是 Next.js 并不需要在安装 react-router-dom 插件，我们跳转界面需要在 Next.js 中引入：
```javascript
import Link from 'next/link'

export default ()=>(
  <>
    ...
    <Link href="/"><a>首页</a></Link>
  </>
)
```
这样便可以实现界面跳转了，但是 `<Link />` 组件，只能接收一个组件。除了组件跳转，我们也可以通过 JS 代码进行跳转：
```javascript
import { useRouter } from "next/router";

export default ()=> {
  const router = useRouter();
  
  return (
    <>
      ...
      <button onClick={()=>{router.push('/home')}}>home</button>
    </>
  )
}
```
## 静态生成 or SSR
这一点非常重要，Next 为界面提供了两种渲染的方式：
1. 静态生成：只有构建(build)时才获取数据，之后每次引用都是构建的数据。
2. SSR：每次请求界面都会生成新的 html。

我们可以为每个界面选择一个渲染方式，两种区别便是获取数据的时机，具体结合实际使用，当然处于性能考虑最优选肯定为 **静态生成** 的方式。

## 数据获取
根据不同的渲染方式获取数据的策略也不同，官网为我们提供了三个获取数据的方法：

1. `getStaticProps`(**静态生成**)：构建(build)时获取界面数据。
2. `getStaticPaths`(**静态生成**)：构建(build)时根据数据渲染界面动态路由。
3. `getServerSideProps`(**SSR**)：每次界面请求都获取数据。

### getStaticProps
根据介绍很容易发现其作用，为我们的静态生成界面获取数据，默认格式如下：
```javascript
export async function getStaticProps(ctx) {
  // TODO: Logic processing
}
```
直接导出该方法即可，方法中可以进行逻辑处理，例如可以这样写：
```javascript
export async function getStaticProps({ params }) {
  //? 获取数据
  const detailedSource = await postDetails(params.id);
  //? 返回数据
  return {
    props: {
      detailed: detailedSource
    },
  };
}
```
可以看出在`ctx.params`可以获取到动态路由的传参，然后利用`async/await`处理异步逻辑获取数据，最后 return 数据即可，组件中直接通过 props 即可获取到最后的数据。
如果您熟悉一些 Next.js 可执行`next build`然后在`.next/server/pages`可以找到该文件，例如：

![静态生成](https://img.bipch.cn/2021/03/09/8a7d8db3f0681.png)

可以看出，当我们 build 时，其自动把含有`getStaticProps`界面和数据结合形成最终形成 html 静态界面，就算以后数据变化其也不会改变，除非重新 build 生成新的静态 html 界面。

### getStaticPaths
此方法只适用于含有动态路由的界面，例如一个界面的路径为`pages/detailed/[id].jsx`，转换为路由为：`detailed/***`，这是必须有一个`getStaticPaths`方法，表示那些 **id** 才能访问该界面。
默认的格式为：
```javascript
export async function getStaticPaths() {
  return {
    paths: [
      { params: { ... } } // See the "paths" section below
    ],
    fallback: true or false // See the "fallback" section below
  };
}
```
其两个熟悉必须按照指定格式返回：
- `paths`：表示那些路径可以访问该界面。
- `fallback`：表示如果界面查找不到会不会生成备用界面(一般设置为 false 展示 404 界面)。

例如我们接口返回下面的数据：
```
[
  {id: 1, title: 'Next入门', ....},
  {id: 2, title: 'Next踩坑', ....}
]
```
那么只有访问`detailed/1`和`detailed/2`才能访问`pages/detailed/[id].jsx`界面，否则例如`detailed/3`都跳转至 404 界面，那么我们可以这样写：
```javascript
export async function getStaticPaths() {
  // 获取数据
  const source = await posts();
  const paths = source.data.map((post) => `/detailed/${post.id}`);
  return { paths, fallback: false };
}
```
执行接口获取数据，然后拼接 paths 数据，最后将拼接后的数据返回给 Next 完成，这样只有指定的路由才能访问该界面其余的都会到 404 界面。
当然我们也可以使用 build 打包，然后我们可以看到另一个由于的现象，也是在`.next/server/pages`目录下，我们动态路由 detailed 目录下：

![](https://img.bipch.cn/2021/03/09/b8edfa7b95d9f.png)

可以清除看到`getStaticPaths`返回的每个数据都会生成一个 html 静态界面，开始有那味了。

### getServerSideProps
SSR 渲染时会执行的函数，其使用和上面的`getStaticProps`非常相似，但由于其是服务端渲染，每次请求都触发而不是静态生成界面，所以其有着更多的属性和配置，可以看下其 [官网的介绍](https://www.nextjs.cn/docs/basic-features/data-fetching#getserversideprops-server-side-rendering) 这里不多介绍了，其使用方式也是老一套。

## 自定义Head
界面的标题一般都需要虽然界面的跳转进行着修改，我们可以使用 `<Head />`轻松做到这样的事情：
```javascript
import Head from 'next/head';
const Home = () => {
  return (
    <div>
      <Head>
        <title>首页</title>
      </Head>
      ...
    </div>
  )
}
```

## 打包
其部署也是非常的简单粗暴，我们可以看下其 webpack 提供的命令：

```json
"scripts": {
  "dev": "next dev",
  "start": "next start",
  "build": "next build",
  "export": "next build && next export"
}
```
这里的`export`命令是本人添加的，正常只有前三个：
- `dev`：项目的运行命令，进行本地开发使用的命令。
- `start`：启动打包之后代码的命令，Next build之后的代码必须依靠 start 才能启动，启动时也必须确保根目录下含有`.next`文件夹。
- `build`：上面多次提及此命令，其会将项目进行打包，生成`.next`文件夹，以供 start 命令运行。

当然除了上述命令，其还未我们推出了`export`命令，其也必须依靠`.next`文件夹，运行之后可将`.next`文件转换为任何地方都可部署的静态文件，默认输出到`out`文件夹下，我们可以拿其和`.next`下的文件做一个对比：

![out](https://img.bipch.cn/2021/03/09/ac4f4b9724ae7.png)

可以看出其完全是静态界面，我们可以任意将其部署到任意服务器上。

## 部署
Next 的部署方式也有多种多样。

### Node
官方对这种方式也有 [介绍](https://www.nextjs.cn/docs/deployment#nodejs-%E6%9C%8D%E5%8A%A1%E5%99%A8)，使用起来也是最为方便的一种，直接使用`build`命令进行打包，然后使用`start`命令运行其打包的内容，成功之后，我们将端口的安全组进行配置便可以公网访问。
### pm2
虽然 Node 可以直接托管项目，但是不管项目的管理，还是维护都并不是很方便，所以便有了 Node 的服务管理工具 pm2，其目的便是为了托管 Node 服务。
安装成功后，在项目的根目录下执行：
```
pm2 start npm --name "next" -- run start
```
这样也就相当于`npm run start`了，按照正常逻辑是可以执行的，但是由于 Node 可能无法找到 npm 具体的路径，所以会报出：
```
Created by npm, please don't edit manually.
```
该错误表示 npm 具体路径可能无法访问，我们修改其启动命令为：
```
pm2 start npm-cli.js绝对路径 --name "next" -- run start
```
这样便能指定 npm 运行了。
### vercel
由原班人马打包的部署的工具，同时也是官网比较推荐的，[vercel](/vercel)中进行了一些简单的部署介绍，也可以看其 [Github](https://github.com/vercel/vercel) 提供了更详细的部署。