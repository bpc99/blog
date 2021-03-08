---
title: MobX
date: 2020-08-07 08:46:50
subtitle: react-introduce
tags:
  - React
  - Mobx
categories: [web]
---
和 redux 很相似的一种数据流管理框架，但是 redux 基于函数式编程，采用单一根节点，过多的API，以及冗余的代码等问题，造成其比较难以真正的掌握，往往学习到底都是一些皮毛。而 Mobx 主要基于 **观察者模式**，并且具有多节点数据，相较于 redux 更加容易的掌握。

<!-- more -->
## 简介
Mobx 的核心概念也很简单，简单一个案例便能看清楚，根据官网的介绍 Mobx 主要有 3 个要点：observable、observer、action。分别用于表示：
- `observable`：定义观察状态，将状态设置为可观察的。
- `observer`：将组件设置为可以响应状态的变化。
- `action`：严格模式下，修改数据的唯一途径。

三个核心的概念，用户操作视图发送 `action`，导致 `observable` 的状态发生了改变，状态改变后通过 `observer` 影响到最终展示的组件，最终用户看到的界面更新。一种挺常见的单向数据流，通过 **动作** 修改 **状态**，而状态更新影响**视图**，官网给的图例如下所示：

![官网图例](https://img.bipch.cn/2021/02/03/badd7c511c09e.png)

首先定义一个可观察的 Sotre 数据：
```javascript
import { observable, action } from 'mobx';

class NameStore {
    name = ''
    constructor() {
        this.name = 'blog';
    }
    setName= (name) => {
        this.name = name;
    }
}

// 将birds标为被观察状态，这样在birds有变动的时候，组件里才会更新
decorate(NameStore, {
    birds: observable,
    setName: action
})
const store = new NameStore();

export default store;
```
然后在需要定义一个观测状态的组件：
```javascript
import React, { Component } from 'react';
import {observer, inject} from 'mobx-react';

class App extends Component {
  render() {
    const{NameStore} = this.props;
    return <div onClick={() => NameStore.setName('action')}>
        {NameStore.name}
    </div>
  }
};

export default inject('NameStore')(observer(App));
```
这样一个观测组件便定义好了，下面只需在根组件注册 Store 数据即可：
```javascript
import React from 'react';
import { render } from 'react-dom';
import NameStore from './stores/NameStore';

render(
  <App NameStore={NameStore} />
  document.getElementById('root')
);
```
这样一个基本的 Mobx 的 demo 便完成了，使用 Mobx 可以很方便的将项目的逻辑和视图层进行分离，视图层只需获取指定数据，发送相对于的 action 即可。并且由于 Mobx 是使用观察者模式，状态改变后会自动判断哪有组件需要重新渲染，不需要用户在使用 shouldComponentUpdate 判断是否渲染，对性能有进一步的提升。
## observable
将数据设置为可观察数据，就是数据拦截，观察的数据一旦修改或者获取都会触发指定的拦截。
Observable 封装的数据类型可以有很多种，可以是基本类型、引用类型、普通对象、类、数组等，封装完成后 Mobx 会对数据进行微调，例如：
- 如果类型是 **Map**，那么会返回一个全新的 Observable Map 对象。
- 如果类型是数组，那么会返回一个全新的 Observable Array 对象。

...
虽然封装之后数据类型发生了改变，但是其相应的方法被没有改变，之前的方法还是能够正常的使用：
```javascript
const observableList =  mobx.observable([1,2,3]);

console.log(observableList[0]);
console.log(observableList.length);
```
都是可以正常访问的。其绑定的原理和 Vue 的双向绑定是相似的，都可以通过 `Object.defineProperty` 来实现：
```javascript
Object.defineProperty(object, key, {
  get : function(){        
    // 获取属性时进行拦截
    return value;
  },
  set : function(newValue){        
    // 设置属性的拦截
    value = newValue
  },
});
```
这样无论读取和设置都会调用相应的逻辑，一旦数据变化，便可以通知视图组件，进行相应的界面更新。
## observer
接收一个组件作为函数的参数，返回一个对变化响应式组件。
```javascript
import {observer, inject} from 'mobx-react';
class App extends Component {
  render() {
    ...
  }
};

export default inject('NameStore')(observer(App));
```
使用 `inject` 函数将指定数据，注入到组件数据中，通过 `observer` 将组件设置为可响应状态变化的组件，一般这两个方法需要进行配合的使用。
## action
严格的模式下 Mobx 只能通过 action 来修改项目的 Store，不能让项目任何情况下都可以更新数据，这样项目就会难以维护。
项目中修改 Store 一定要在 action 中进行：
```javascript
decorate(object, {
    setName: action
})
```
将方法设置为 action 类型，然后我们便可以在该方法里面更新数据了。action 可以很好的将我们的 Store 和逻辑代码分离，便于后面维护代码。
## 对比 Redux
Mobx 和 Redux 都是 React 中比较好的数据流管理工具，但是由于其核心不一样，所以两个框架还是有着很大区别的：
1. 单一数据源和多数据源，Redux 强调的便是单个 Store，而 Mobx 可以有多个 Store。
2. Reudx 只能通过手动处理数据，通过 shouldComponentUpdate 判断组件是否需要重新渲染，而 Mobx 通过 观察者模式 可以自动判断哪些组件需要重新渲染。
3. Redux 强调状态的不可变性，就算在 reducer 更新，但是只能返回新的 Store 覆盖，不能直接更新，而 Mobx 可以直接更新 Store。
4. 由于 Mobx 很多逻辑代码都是封装好的，调试比较困难，也更加难以预测，而 Redux 以纯函数的形式可以让调试更简单。
5. 虽然 Mobx 相对来说比较容易上手，因为其运用面向对象思维，引入一些抽象概念。而 Redux 通过函数式编程，同时借助一些中间件处理异步，所以上手难度略高于 Mobx。

但是这只是一个简单的对比，具体选用还是要看团队的技术，如果简单的话可以使用 Mobx 可以，但是如果项目有着复杂的 Store 结构，Mobx 不是不可以，但是 Redux 会可以更方便的调试。