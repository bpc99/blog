---
title: redux-action
subtitle: react-redux-action
date: 2020-02-01 10:39:18
tags:
  - React
  - Redux
categories: [web]
---
虽然 react-redux 非常的强大，但是发送和处理 action，需要很多的冗余代码，如果项目过多冗余代码肯定会对打包和运行速度有所影响，这时我们便要对其代码进行简写和封装，为了避免重复的轮子，一般需要网上进行查找，而 redux-action 便可以很好的对 action 进行代码的简写。

<!-- more -->
## 传统的Redux
为了更方便其对 redux 的封装，我们将其和原本的代码进行比较。
### 默认的 Redux 代码
创建 actions：
```javascript
export const addGame = (game) => {
    return {
        type: 'ADD_GAME',
        game
    }
};
```
创建 reducer：
```javascript
const gameList = [];
const gameReducer = (state = gameList, action) => {
  switch (action.type) {
    case 'ADD_GAME':
      return [
           ...state,
          action.game
      ];
    default:
      return state;
  }
};
export default gameReducer;
```
组件中进行调用：
```javascript
import React from 'react';
import { connect } from 'react-redux';
import { addGame } from './actions';
import AddGame from './components/addGame';

/**
 * 使用
 */
class PageMain extends React.Component {
  render() {
    return (
      <AddGame addGame={this.props.addGame} />
    );
  }
}
export default connect((state) => {
  return {
    gameList: state.game,
  };
}, {
  addGame: addGame,
})(PageMain);
```

这样就完成调用了，子组件使用的时候调用父组件的 addGame 方法即可。

### 使用 redux-action 处理 action 与 reducer

redux-action 主要依靠提供的 **createAction**、**handleAction** 完成工作。我们可以依靠 `createAction` 来帮助我们进行对象的创建：
```javascript
import { createAction } from 'redux-actions';

export const addGame = createAction('ADD_GAME', game => {
  return game;
});
```
处理的时候也可以借助 `handleAction` 进行处理，防止出现 switch 等冗余的代码：
```javascript
import { handleAction } from 'redux-actions';
import {addGame} from './actions';

const gameList = [];
const gameReducer = handleAction('ADD_GAME', (state, action) => {
  return {
    ...state,
	action.game
  };
}, gameList);

export default gameReducer;
```
使用的方式和基础的一样，都需要通过 concat 高阶组件进行连接。主要是要熟悉 **createAction**、**handleAction** 两个API的用法：
- `createAction`: 创建一个 action 工厂的操作，主要用于返回一个 action 工厂。
  参数一：action 的 type。
  参数二：用于传递一些参数，方便 reducer 对数据进行处理。
- `handleAction`: 用于处理一些 action 请求，返回一个 reducer。
  参数一：需要处理的 action type。
  参数二：reducer 处理 store 的函数。
  参数三：用于初始化的 state 。

## createActions 与 handleActions
上述操作只能创建或处理一条 action 。而项目不可能只有一条 action，redux-action 不可能不处理这种情况，所以 redux-action 提供了 createActions 与 handleActions 用来处理多条 action。
使用`createActions`创建 action：
```javascript
import { createActions } from 'redux-actions';

export default createActions({
  ['ADD_GAME']: game => {
    return game;
  }
});
```
使用`handleActions`创建 reducers：
```javascript
import { handleActions } from 'redux-actions';

const gameList = [];
const gameReducer = handleActions({
  ['ADD_GAME']: (state, action) => {
      return {
          ...state,
          action.game
      };
  }
}, gameList);
export default gameReducer;
```
然后在使用的时候和以前一样调用即可：
```javascript
import actions from './actions';
import { addGame } from './actions';

export default connect((state) => {
	return {
        gameList: state.game
    };
}, {
    addGame: actions.addGame
})(...);
```

**handleActions** 返回一个对象，对象针对每个 action 创建了属于自己一些属性，使用的时候下划线去掉，然后采用驼峰式命名。而 **handleActions** 仍然返回一个 reducer 函数。
## 总结
redux-action 简写了 redux 发送和处理 action 的操作，并没有引入特别的一些语法和概念，如果项目中 action 和 reducer 冗余代码过多，可以考虑使用其减少代码的书写量。