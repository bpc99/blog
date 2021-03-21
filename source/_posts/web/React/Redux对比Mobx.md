---
title: Redux对比Mobx
date: 2021-03-19 18:34:43
subtitle: redux-mobx
tags:
  - React
  - redux
  - mobx
categories: [web]
---
不管是 React 或 Vue 等 **单向数据流** 项目中，状态的管理一直是重中之重，因为其为单向数据流，若不使用插件，状态会变得及其难以维护，而在 React 中比较常用的便是 `Redux` 和 `Mobx` 两款。

不管是开发团队，还是代码书写的风格 `Redux` 也是非常的契合 React，但是由于其过多的 `Action` 和 `Reducer` 致使项目中代码冗余、繁琐，每次`dispatch`都需要书写很多代码，并且异步必须用中间件才能处理，比如`redux-thunk`和大名鼎鼎的`redux-saga`，所以 `Redux` 需要一些中间件才能真正发挥其性能，而 `Mobx` 则为 **观察者模式** 会大量减少书写的代码。

<!-- more -->

## 解决问题
不管是 `Redux` 还是 `Mobx` 都是解决单向数据流造成的一系列问题：

1. **状态难以跟踪**：其传递只能由父组件向子组件进行传递，而子组件不能反向传递，若设计多个组件嵌套，状态会非常难以跟踪和管理，因为无法确定数据来自那个父级组件。
2. **组件逻辑混乱**：原先组件只需包含本组件的逻辑，但是因为单向数据流中，子组件无法修改父组件任何数据，所以我们要一个类似于代理的功能，由子组件触发，父组件监听后修改数据，这就造成多个父组件逻辑重复，并且父组件很有可能包含着其它子组件逻辑，这是得代码更加难以维护。
3. **耦合增加**：这种数据传递必定大量的增加数据的耦合，致使大量逻辑彼此依赖，牵一发而动全身。

我们将代码分割为各个组件，但是要确定各个组件中的状态和逻辑不能互相依赖，可以想象每个组件都是一个独立的空姐。

## Redux
官网介绍根据`Flux`演变而来，所以如果要深入研究 Redux 那么`Flux`必不可少。也可以看下其 [官网的介绍](https://redux.js.org/introduction/)。

### 核心概念
Redux 主要由 3 部分组成：
1. **Store：**项目唯一数据源，整个项目有且只有一个数据源，我们可以设置需要共享的数据：
```javascript
const initialState = {
  avatar
};
```
2. **Reducer：**唯一一种修改 **Store** 的方式，我们需要在此返回新的 **State**，然后将新返回的 **State** 拼装为拼装为新的 **Store**，状态改变致使组件更新：
```javascript
const user = (state: userTypes | null = initialState, action: {
  type?: string,
  user?: userTypes
} = {}) => {
  switch (action.type) {
    case 'SET_USER':
      return action.user;
    case 'EMPTY_USER':
      return initialState;
    default: return state;
  }
};
```
3. **Actions：**普通的 JavaScript 对象，用于描述发生的动作，一般需要`type`用于描述动作，`data`用于描述数据：
```javascript
export const setGames = (dispatch, data) => {
  return dispatch({
    type: SET_GAMES,
    data
  })
};
```

### 异步
由于 Redux 所有状态的变更都必须通过发送`Action`来进行修改，但是由于异步任务并没有处理，如果`Action`中包含任何异步任务便会报出错误，而如果需要`Action`处理异步，那么我们便需要中间件处理，例如：**redux-thunk**、**redux-saga**。
使用 **redux-thunk** 很简单，在首页注册中间件，然后`Action`这样书写即可：
```javascript
export const fetchGames = () => {
  return dispatch => {
    fetch('/api/games', {
      method: 'POST',
    })
    .then(res => res.json())
    .then(data => setGames(dispatch, data.data))
  }
};
```
这样便处理了异步的`Action`。
### 数据流
其数据的流程如下所示：

![](https://img.bipch.cn/2021/03/21/d974485d6dc39.png)

### 优点
1. 代码和 React 结合性较高，比较符合 React 编程风格。
2. 提供了中间件功能，其扩展性较强，并且有大量优秀的中间件。
3. 可以很好追踪数据、BUG等，并且可以将数据和逻辑分离，可以帮助我们更好的维护项目。
4. 项目代码约束性较强，如果多人项目，使用其可以很好的规范项目代码。

### 缺点
1. 代码太冗余，项目中`Action`、`Reducer`都包含着大量的代码重复。
2. 异步`Action`无法处理，异步的代码无法直接处理，必须借助中间件。

## Mobx
 也是一款很好用的数据流管理库，即使前面有 `Redux` 这样优秀的库，也有着很多人使用，其使用 **观察者模式** 将状态管理变得异常简单，具体可以看其 [官方文档](https://cn.mobx.js.org/)。
 
### 核心概念
其核心主要由下面几部分：
1. **Observable state：**项目的可观察状态，将数据设置为可观察状态，这样一旦被观察数据改变便会进行界面更新，注意由于 Mobx 有多个数据源，所以使用的时候必须加上命名空间：
```javascript
import { observable, decorate } from 'mobx';

class UserStore {
    name = "";
}
// 将 name 标为被观察状态(observable)，这样在 name 有变动的时候，组件里才会更新，相当于react里调用了 setState()
decorate(UserStore, {
    name: observable
})
const store = new UserStore();
export default store;
```
2.  **Computed values：**`observable`的衍生数据，并且其是惰性求值，仅在基础被观察项之一发生更改时才重新计算，如果没有使用其是不会被计算的，使用方式很简单：
```javascript
import { observable, decorate, computed, toJS } from 'mobx';

class UserStore {
  name = "";
  love = [];
  get loveCount() {
    // toJS 是将被观察对象设置为普通对象
    return toJS(this.love).length;
  }
}
// 设置为衍生数据
decorate(UserStore, {
  name: observable,
  love: observable,
  loveCount: computed
})
const store = new UserStore();
export default store;
```
3. **Reactions：**和上面的`computed`非常的相似，单是其不会产生一个新的值，一般都是产生一些副作用，比如打印到控制台、网络请求等。使用方式和上面一样就不多介绍了。
4. **Actions：**描述要发生的动作，也是唯一一个修改`observable`的地方：
```javascript
import { observable, decorate, action } from 'mobx';
	
class UserStore {
  name = "";
  setName = (name) => {
    this.name = name;
  }
}
decorate(UserStore, {
  name: observable,
  setName: action
})
const store = new UserStore();
export default store;
```

### 数据流
通过上面概念理解有点抽象，但是我们若借用 Excel 表格来说，会很好理解：
	
![](https://img.bipch.cn/2021/03/22/5dc92f8e01b50.gif)

`observable`将单元格中的数据，设置为被观察，在组件中注入该数据，一旦组件内注入的数据发生改变，组件内容便会立即更新。

根据官网其数据流向为：

![](https://img.bipch.cn/2021/03/22/b7a828446c2fb.png)

### 优点
1. 学习成本较小，因为大部分逻辑都在内部进行了封装。
2. 代码更少、更简便，不需要 `Redux` 哪有很多重复代码。
3. 逻辑更清晰，可以很好的提取状态和逻辑，并且异步请求也不需要中间件。

### 缺点
1. 因为 Mobx 代码量进行了极大的缩减，但是代码的约束性会大量的降低，若多人使用代码风格会更难以统一。
2. 扩展性与可维护性和`Redux` 相差还是有些差距的，如果您希望项目更加具有扩展性、可维护性、以及代码风格的话，那么`Redux`可以说是一个不错的选择，因为其提供了中间件功能，可以极大提供项目扩展性，并且的代码风格也很容易规范，而反之需要更轻便、容易上手、代码量较少的话`Mobx`可以说是不二之选。

## 总结
`Mobx`与`Redux`各有长处，`Redux`写出的程序更加健壮、规范，但是其会造成大量代码的冗余，而`Mobx`会使代码更清晰明确、并且上手难度较低，但是其并没有太强的规范性，所以说使用那种框架需要从个人和团队的视角考虑，并没有那种框架适用于任何环境。