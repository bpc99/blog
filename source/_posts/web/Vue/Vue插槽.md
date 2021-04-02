---
title: Vue插槽
date: 2020-09-18 07:16:36
subtitle: vue-slot
tags:
  - Vue
  - 插槽
categories: [web]
---
Vue项目开发过程中，经常遇到多个组件它们基础功能大致一样，但又存在足够的差异性，比如 Button、滚动条、表单提交 等等都需要 **防抖** 处理，或者多个组件，有一些共用的属性或方法，但又存在足够的差异，我们便可以使用 Vue 提供的 **混入(mixin)** 来进行封装。下面分析下 [Mixins](https://cn.vuejs.org/v2/guide/mixins.html) 实现以及它的一些缺点。

<!-- more -->
## 匿名插槽
我们可以在子组件设置占位符，具体显示内容由父级决定。我们可以这样合成组件：
```html
<!-- 子组件 -->
<div>
  <p>我是子组件: </p>
  <slot></slot>
</div>
<!-- 父组件 -->
<Child>
  <p>slot</p>
</Child>
```
最后得出下面的HTML界面:
```html
<div>
  <p>我是子组件: </p>
  <p>slot</p>
</div>
```
这样便通过父组件默认替换了子组件中的`<slot>`。
## 编译作用域
如果我们需要在插槽中使用数据那么我们只可以使用本组组件的数据，例如我们子组件这个样子：
```html
<template>
  <div>
    <p>我是子组件: </p>
    <slot>我是默认的slot</slot>
  </div>
</template>
<script>
export default {
  name: 'slotComponents',
  data(){return {num: 0}}
}
</script>
```
而父组件我们这样写：
```html
<template>
  <div>
    // 这样 name 是可以获取到本组件 name 的
    <Child>子组件数据：num: {{name}}</Child>
    // 这样 获取子组件数据是不行的，虽然它会替换子组件
    <Child>子组件数据：num: {{num}}</Child>
  </div>
</template>
<script>
...
export default {
  name: 'list',
  data(){return {name: '李四'}},
  ...
}
</script>
```
这时Vue的一个规则，**父级模块的所有内容都是在父级作用域中编译的；子模板中的所有内容都是在子作用域中编译的**。
有的时候我们需要在父组件插槽内容中去访问子组件的数据，这时我们可以在子组件中把需要分享的数据，作为 `<slot>` 元素的一个 attribute 绑定上去。
例如子组件这样设置 <slot> 组件：
```javascript
// 界面
<slot :num='num'>我是默认的slot</slot>
// 数据
data(){
  reurn {
    num: 0
  }
}
```
这样绑定在 `<slot>` 元素上的 attribute 就被称为**插槽prop**，然后我们可以在父级组件中使用带值的 `v-slot` 来定义我们提供的插槽prop的名称：
```javascript
<Child>
  <template v-slot="childSource" >子组件数据：num: {{childSource.num}}</template>
</Child>
```
这样我们将包含所有的插槽prop的对象命名为`childSource`，我们可以使用其获取所有子组件提供的数据。
## 具名插槽
如果我们具有多个占位符，那这种情况怎么办呢? `<slot>`元素有一个特殊的attribute: `name`。这个属性可以用来定义额外的插槽:
```html
<div class="container">
  <header>
    <slot name="header"></slot>
  </header>
  <main>
    <slot></slot>
  </main>
  <footer>
    <slot name="footer"></slot>
  </footer>
</div>
```
一个不带`name`的`<slot>`会带默认的名称"default"。
向具名插槽提供的内容时，我们可以在`<template>`元素上使用`v-slot`指令，并以参数的形式提供其名称：
```html
<Child>
  <template v-slot:header>
    <h1>Here might be a page title</h1>
  </template>
  <p>A paragraph for the main content.</p>
  <p>And another one.</p>

  <template v-slot:footer>
    <p>Here's some contact info</p>
  </template>
</Child>
```
这样`<template>`元素中的所有内容都将会被传入相应的插槽。而没有被`<template>`包裹的内容都会被认为是默认插槽的内容，当然我们也可以使用`<template v-slot:default>`代表默认的分组。
因为它是一个指令，Vue的指令一般都有一个缩写的，在 2.6.0 新增了缩写`#`，例如以前遇到的`v-slot:header`都可以缩写为`#header`。
## 总结
我们总结下相应的插槽使用总结：
1. 有名称的父级填充内容如果指定到子组件没有对应名称的插槽，那么改内容`不会`被替换到任何插槽中。
2. 若子组件没有默认插槽，而父级如果插入默认的内容，那么这块默认的内容`不会`替换到任何一个插槽中。
3. 如果子组件有多个默认插槽，而父组件指定了默认的插入内容，将 `会` `全部` 替换到子组件的每个默认插槽中。

这里就先总结到这里，如果有不足，后面会进行补充。