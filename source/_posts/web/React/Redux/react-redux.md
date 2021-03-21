---
title: react-redux
subtitle: react-redux
date: 2020-01-28 12:57:53
tags:
  - React
  - Redux
categories: [web]
---

由于在 React 中数据流都是单向的，即只能父组件 -> 子组件，但是开发过程中单向数据流面临着很多问题，所以需要一个框架为我们管理项目的数据流，Redux 便出现了，其主要目的便是管理项目中的数据流。但是我们也有明白 **React 项目并不是一定要用 Redux、而 Redux 也不一定要在React 上使用**。

<!-- more -->
## 你可能不需要它
这一点官网说的很清楚，Redux 只是一个很好的项目数据流管理工具，但不是非用不可。因为如果不设计到过多的数据需要维护，那么只用 React 就足够了，就算有很多状态需要我们维护，我们也可以使用 Mobx。
换句话说如果 UI 层很简单，或者没有太多的数据交互那么便可以放弃使用 Redux，否则只会增加项目难度。
但是如果出现下面情况，我们可以考虑进行使用：
1. 一些组件的数据需要共享给其它组件。
2. 一些值比较重要，需要在任何组件都可以访问到。
3. 一个组件需要改变其它组件的状态。

出现这种情况，我们可以考虑使用 Redux 进行状的管理。
## 三大原则
Redux 可以用这三个基本原则来描述：
1. `单一数据源`：整个项目有且只有一个Store。
2. `State是只读的`：唯一改变State的方法就是触发`action`，action是用来描述发生事件的普通对象。
3. `使用纯函数进行修改`：Reducer 根据 action 覆盖 state。Reducer 必须是一个纯函数，它接收先前的 state 和 action，并返回新的 state。

## API

### Store
主要用于维护应用中的所有的 **state树** 的对象，改变其的唯一方法只能依靠 `dispatch` 发送 action 对象。
但有一点需要注意：**整个项目有且只能有一个 Store**，创建时需要通过 `createStore` 方法，生成 Store：
```javascript
import { createStore } from 'redux';
const store = createStore(reducer);
```
很简单的方式，但是项目中不可能只有 1 个  Reducer，那么如果有多个 Reducer 怎么办呢？这就需要 React 提供的另外一个方法 `combineReducers` 来拆分 Reducer：
```javascript
import {combineReducers} from 'redux';
import user from './user';

export default combineReducers({
    user
})
```
很简单便将 Reducer 进行了拆分，使用的时候，添加 key 进行访问即可。

### State
state 是项目的主要数据，我们可以通过 `store.getState()` 来获取项目中的 state 状态树。它与 reducer 的返回值相同。
调用方式如下：
```javascript
import { createStore } from 'redux';

const store = createStore(reducer);
const state = store.getState();
```
调用也很简单。

### Action
准确来说它并不是特定的格式，只是大多数这么写，便默认了其默认的格式。其主要用于描述动作类型。
基本格式如下所示：
```javascript
const action = {
  type: 'ADD_TODO',
  data: ''
};
```
也就是一个普通的 JavaScript 的对象。Reducer 会判断类型，然后根据参数，返回新的 state 进行数据的覆盖。

### store.dispatch
`store.dispatch()` 项目中发送 action 的唯一途径：
```javascript
import { createStore } from 'redux';

const store = createStore(reducer);
store.dispatch({
  type: 'ADD_TODO',
  data: ''
});
```
可以很简单的将一个 action 发送出去。

### Reducer
Redux 接收到新的 Action 以后，经过 Reducer 处理之后，返回新的 state，覆盖项目的 store，形成行动 store，最后通知界面视图进行更新。
基本格式如下：
```javascript
const defaultState = {};
const reducer = function (state = defaultState, action) {
  // ...
  return state;
};
```
基本格式如上，Reducer 会使用 `switch` 判断发送的 action 的 type，执行不同的逻辑，而返回不同的 state。
## 结合 React
上面介绍了 Redux 的简单 API，但是还没有和 React 结合使用，和 React 结合其实很简单，但是还需要借助 `react-redux` 来帮助。
项目整理完成后，第一步创建 Store，这是项目的唯一数据源：
```javascript
import {combineReducers} from 'redux';
import user from './user';

export default combineReducers({
    user
})
```
这样 Store 便创建完成了，然后我们需要将数据注入到组件中，默认如下：
```javascript
...
import Store from './reducer/store';
import {Provider} from 'react-redux';

ReactDOM.render(
    <Provider store={Store}>
      <App />
    </Provider>
  , document.getElementById('root')
);
```
这样便通过 react-redux 提供的组件，将 Store 成功的注入。数据成功注入后需要在相应的组件中进行调用，主要依靠 react-redux  提供的 connect 高阶函数
```javascript
...
import {connect} from 'react-redux';

class App extends React.Component{
	render(){
		return (....)
	}
}

const mapStateToProps = (state) => {
  return {
    ...
  }
};
const mapDispatchToProps = (dispatch) => {
  return {
    ....
  }
}
export default connect(mapStateToProps, mapDispatchToProps)(App);
```
这样在组件中不论是 state 中定义的变量，还是 dispatch 都能操纵了。