---
title: 虚拟DOM
subtitle: virtual-dom
date: 2021-03-23 20:03:49
tags:
  - Virtual DOM
categories: [web]
---
虚拟DOM 并不是什么新鲜得定义，简单说便是使用 JavaScript 描述 DOM 节点。因为频繁的 DOM 操作效率低下且速度慢，而虚拟 DOM 却并不存在这样的问题。

那么 虚拟DOM 如何实现呢？

为什么使用 虚拟DOM 呢？

是什么让直接操作 DOM 速度变慢了？

<!-- more -->

## 虚拟DOM 如何实现
虚拟DOM 便是通过 JavaScript 代码，描述 DOM 节点，例如下面的 HTML DOM 节点：
```htmlbars
<span class="fruits">orange</span>
```
这是一个最为常见的节点了，那么我们用 JS 描述此节点为：
```javascript
// Virtual DOM
var a = document.createElement('span');

a.setAttribute('class', 'fruits');
a.appendChild(document.createTextNode('orange'));
```
这便是 虚拟DOM 节点。而所有 HTML DOM 节点都是 JavaScript 中的一种结构，例如我们执行`console.dir(document.body)`可以看出 body 的结构。

而不论是 React 还是 Vue 都引入了 虚拟DOM 概念，例如 React 中的`React.createElement`方法：
```jsx
var a = React.createElement('span', {
  class: 'fruits'
}, 'orange');
```
参数分别为 元素名、元素属性、子元素，这样便将 虚拟DOM 创建完成了，而 React 中的 JSX 语法便是通过 babel 转换为此种方式，例如可以在 [babel官网测试](https://www.babeljs.cn/repl) ：

![](https://img.bipch.cn/2021/03/25/586c5c64d4ac6.png)

## 浏览器的工作流程
如果想要明白 **是什么让直接操作 DOM 速度变慢**，那么必须先明白浏览器渲染 DOM 的流程：

这里以 webkit 引擎为主，当然浏览器内核不同流程知识稍微不同，下面是网络上出现较多的流程图：

![](https://img.bipch.cn/2021/03/25/d1807e6b57915.png)

其步骤大致分为 5 步：创建DOM tree --> 创建Style Rules --> 构建Render tree --> 布局(Layout ) --> 绘制(Painting)。

第一步：浏览器接收 HTML 文件，使用渲染引擎解析，创建一个 DOM 节点树。
第二步：同时，解析CSS文件的样式以及内联样式，并将解析之后的内容构建另一棵树，称为渲染树。
第三步：通过将上面的 DOM树 与 渲染树，关联起来，构建一颗Render树，而这一过程称之为 "Attachment" 。每个 DOM 节点都含有 attach 方法，其接受样式信息，返回一个 render 对象(renderer)。这些 render对象 最终会被构建成一颗 Render tree。
第四步：有了 Render tree 后，浏览器开始布局，会为每个Render树上的节点确定一个在显示屏上出现的精确坐标值。
第五步：Render tree 有了，节点显示的位置坐标也有了，最后就是调用每个节点的 paint 方法，让它们显示出来。

所以当我们以普通的方式操作 DOM 时，从创建渲染树(包括元素属性以及样式都需要重新计算，也就是从第一步开始)开始，再到绘制步骤，都将重做。

所以综上如果项目内涵了大量且频繁的 DOM 操作，这就意味着必须经过多个计算步骤，这些步骤使得整个项目效率变得低下。

而此时便突出了 虚拟DOM 真正闪耀的地方，如果视图发生了改变，所有需要发生在 真实DOM 上的修改，都会以 虚拟DOM 的形式进行，完毕后形成最终的 虚拟DOM，经过指定算法( diff )对比 真实DOM 与 虚拟DOM，从而将修改的内容减值最少，进而减少了所涉及以下计算步骤的数量。这就是虚拟DOM抽象真正闪耀的地方；当视图改变后，所有假定要在 真实DOM 上进行的更改，首先在 虚拟DOM 上进行，完毕之后将 虚拟 和 真实DOM 合并形成最终渲染内容，从而减少了所涉及的以下计算步骤的数量。

## 参考资料
- [Why Virtual DOM（作者：Sai Kishore Komanduri）](https://hashnode.com/post/the-one-thing-that-no-one-properly-explains-about-react-why-virtual-dom-cisczhfj41bmssp53mvfwmgrq)
- [虚拟DOM介绍](https://www.jianshu.com/p/616999666920)