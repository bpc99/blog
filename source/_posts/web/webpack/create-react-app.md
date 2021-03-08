---
title: create-react-app
date: 2020-08-27 08:11:39
subtitle: create-react-app
tags:
  - React
  - 脚手架
categories: [web]
---

由于 webpack 的兴起，不少技术使用 webpack 都能很方便的进行开发，但是由于其需要过多的配置，这样便浪费很多的开发时间，于是前端便出现了一系列的 webpack 相关的脚手架，目的便是更方便的进行相关开发，而 React 作为前端非常火的技术脚手架的数量更是非同一般，这里只是简单总结下使用 create-react-app 在开发过程中经常遇到的问题。

<!-- more -->

## CSS Modules
CSS Modules 允许你在不同的文件中使用相同的 CSS classname，而无需担心命名冲突。
例如我们 css 样式为：
```css
.red {
    color: red;
}
```
默认情况编写 className 为 red 即可，而使用 CSS Modules 便可以这么写：
```javascript
import styles from '.....css';

function App() {
  return (
    <div>
      <p className={styles.red}>CSS Modules</p>
      <p className="red">classname</p>
    </div>
  );
}

export default App;
```
最后结果 styles.red 样式为红色，而 red 样式是空的。这便是 CSS Modules 它可以完美解决 css 样式覆盖的问题。而 create-react-app 默认便是支持 CSS Modules 的，但是只能是指定格式的文件名，例如如果文件名为：`index.css`，这样 CSS Modules 是不会生效的，只能为：`index.module.css`才能生效，根据官网的提示，命名规则必须为：`[name].module.css`否则都会无效的。

## proxy
随着前后端的分离，开发过程中跨域的情况是无法避免的，前端的请求接口如果不是在后台设置相应白名单的情况下大部分都会面临着跨域的问题，而前端解决这种问题的方式也很简单，大部分都是通过 proxy 去完成，而 React 默认情况下只能在 `package.json` 中 proxy 属性添加配置，例如：
```javascript
"proxy": "http://localhost:6060",
```
但是大部分情况下，我们需要更灵活的配置，例如：
```javascript
proxy: {
  '/api': {
    target: '******',
    ws: true,
    changeOrigin: true
  },
  '/searchData': {
    target: '******',
    ws: true,
    changeOrigin: true
  }
  ...
}
```
而它如果要实现这种情况只能借助一个插件`http-proxy-middleware`去完成。

## devtool
主要用于判断是否生成 source map，因为文件打包之后，和原本文件有着许多的差别，而为了方便调试找出错误，需要将打包之后的文件和源文件进行管理，此时一般需要 source map，虽然它很方便我们的代码调试，但是如果我们将打包放到生产环境下，会很容易保留我们项目的源码，例如下面情况：

而源码的暴露显然不符合我们的预期，所以我们要打包部署时关闭 devtool，防止源码暴露，但是 create-react-app 已经隐藏了 webpack 的配置，如需重新暴露，需要运行：`npm run eject`，但会暴露出全部配置，添加项目可阅读性，显然不是我们想要的，我们一般使用：`react-app-rewired` 或者 `craco` 去覆盖配置，但不论何种方法，我们需要覆盖 webpack devtool 配置：
```javascript
devtool: 'inline-source-map', // 调试代码用
```
覆盖为这样的值，便解决了这个问题。