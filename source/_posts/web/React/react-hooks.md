---
title: react-hooks
date: 2020-05-18 08:20:34
subtitle: react-hooks
tags:
  - React
  - hooks
categories: [web]
---
hooks 是 React 16.8 引入的新特性，它可以使我们在不编写 class 组件的情况下可以去使用 state、生命周期函数、 和其他 React 功能。并且 hooks 可以从各个组件中提取状态逻辑，以便于代码的复用，这样组件之间共享数据就变得很简单。

<!-- more -->
## 为什么使用 hooks
项目组件起初很简单，但随着状态、逻辑、副作用的增多变为难以控制的混乱状态，每一个生命周期都包含着毫不相关逻辑代码的混合。比如我们的组件可能会在 `componentDidMount` 、`componentDidUpdate` 周期中获取处理数据，但是在同一个 `componentDidMount` 中还包含着其他的逻辑比如，注册事件的监听，最后需要在 `componentWillUnmount` 清除。这样我们毫不相连的代码就结合在了一起。这样就会导致一些逻辑的不一致。而 **Hook 将组件中相互关联的部分拆分成更小的函数。**
## State Hook
state hook 提供了在 function 组件中使用 state。并且可以抽取相同的 state 状态和逻辑是数据得到更好的复用。
下面举一个简单的例子：
```javascript
import React, {useState} from 'react';
function App() {
  // 赋值，初始值 0
  const [count, setCount] = useState(0);
  return (
    <div className="App">
      <header className="App-header">
        <p>num: {count}</p>
        <p onClick={() => setCount(state => state + 1)}>+</p>
        <p onClick={() => setCount(state => state - 1)}>-</p>
      </header>
    </div>
  );
}
```
上面只是调用了 `useState` 方法，**那么 useState 到底做了什么呢？** 它定义了一个变量`count`，这个名称可以是任意的，useState 返回值是个数组，我们可以使用任意名称接收。setCount 为修改数据需要调用的方法，它与 class 里的 `this.state` 提供的功能完全相同。但是函数中的变量退出后会消失，而 state 中的变量会在 React 中保留。
> useState 进行数据赋值是覆盖式更新，**并不会合并数据** 如果数据格式复杂注意不要覆盖一些变量。一些复杂的数据格式我们可以使用 es6 的扩展运算符帮助我们解决数据覆盖的问题，如 {...source, count: 1} 这样 count 就会覆盖 source 中的 count。

## Effect Hook
Effect Hook 可以让我们在函数组件中执行副作用操作，如果你熟悉 React class 的生命周期那么就可以将 Effect Hook 看作 `componentDidMount`， `componentDidUpdate`， `componentWillUnmount` 这三个函数的组合。我们可以在这个地方获取数据、设置订阅，手动的更改 DOM等操作，也可以在卸载一些订阅。
```javascript
import React, {useState} from 'react';
function App() {
  // 赋值，初始值 0
  const [count, setCount] = useState(0);
  useEffect(() => {
    document.title = `you clicked ${count} times`;
  }, [count]);

  return (
    <div className="App">
      <header className="App-header">
        <p>num: {count}</p>
        <p onClick={() => setCount(state => state + 1)}>+</p>
        <p onClick={() => setCount(state => state - 1)}>-</p>
      </header>
    </div>
  );
}
```
这样就会监听 count 的变化，如果 `[count]` 中的任意数据有所变化，便会执行相应的 `useEffect` 中的代码。
主要有下面几点需要说明：
1. `useEffect(callback: () => void，deps: array[])` 方法接收两个参数，第二个为选填参数。表示 Effect 更新需要依赖那些属性。
2. 由于一个组件可以有多个 Effect 所以我们有的 Effect 并不是有属性更新便会调用，而是具体指定 Effect 的依赖列表。
3. 第一个参数界面加载完成后便会执行相当于 `componentDidMount` ，如果有依赖列表数据变化，便会在执行该函数，这时相当于 `componentDidUpdate`，如果该函数返回了一个函数，则返回的函数会在组件卸载时调用，这时相当于 `componentWillUnmount`。
## useContext
```javascript
const value = useContext(MyContext);
```
接收一个 `Context` 对象(使用 React 提供的 **createContext** 创建)，并会寻找距离当前组件最近的一个 `Provider ` 的 value 值。
首先创建一个 context 对象：
```javascript
import { createContext } from 'react';

export const UserContext = createContext({});
```
这样 context 对象就被创建好了，下面在调用其 Provider 组件设置初始值：
```javascript
import React, { useState } from 'react';
import {UserContext} from './UserContext';
import UserInfo from './user';

const User = () => {
  const [user, setUser] = useState('blog');

  return (
    <UserContext.Provider value={ { user, setUser } }>
      <UserInfo />
    </UserContext.Provider>
  );
}

export default User;
```
这样 context 组件已经创建完成了，下面写子组件并使用 useContext 获取到设置的初始值即可：
```javascript
import React, { useContext } from 'react';
import {UserContext} from './UserContext';

export default () => {
  const { user, setUser } = useContext(UserContext);
  return (
    <div>
      <p>{user}</p>
      <button onClick = {() => setUser('123123')}>
        set name
      </button>
    </div>
  )
}
```
这样我们就通过 context 完成了组件之间数据的传输。
## useMemo
用于缓存组件中一些方法计算的结果，比如组件中的某一数据需要复杂计算而来，为了节约性能可以通过缓存计算结果并在下一个操作中重新使用缓存来加速查找费时的操作。而 useMemo 就是使用 `memoization` 来提升组件的性能，这里不过多介绍。这里我们需要传给它一个依赖列表，它的值会作为 key，如果 key 值不变函数只会执行第一次后面便会从缓存获取，只有 key 修改才会进行重新计算。
修改下上面组件代码：
```javascript
import React, { useState } from 'react';
import UserInfo from './user';

const User = () => {
  const [user, setUser] = useState({
    name: 'blog',
    other: 1
  });

  return (
    <UserInfo user={user} setUser={setUser} />
  );
}
  
export default User;
```
修改子组件代码：
```javascript
import React, {memo, useMemo} from 'react';

export default memo(
  ({user, setUser}) => {
    const {name, other} = user;
    const useOther = useMemo(() => {
      // 复杂的逻辑
      //...
      console.log('没有缓存');
      return other;
    }, [other]);
    return (
      <div>
        <p>name: {name}</p>
        <p>other: {useOther}</p>
        <button onClick = {() => setUser({
          ...user,
          name: '123123'
        })}>
            set name
        </button>
        <button onClick = {() => setUser({
            ...user,
            other: 0
        })}>
            set other
        </button>
      </div>
    )
  }
)
export default User;
```
这样只有 useMemo 函数中依赖项中的数据变化，才会执行函数中的值，否则会在缓存中进行获取。这样就极大提升了程序的性能。
> 注意 `useMemo` 函数会在渲染期间执行。不要在该函数内部执行与渲染无关的操作，如果需要添加一些副作用函数要在 `useEffect` 而不是 `useMemo`。


### useCallback
该函数的作用和上面的 `useMemo` 作用非常的相似，但是它返回的是一个缓存函数。比如我们和上面一样也做一个测试:
```javascript
import React, { useState, useCallback } from 'react';

const set = new Set();
const Count = () => {
    const [count, setCount] = useState(1);
    const [val, setVal] = useState('');

    const callback = useCallback(() => {
        console.log(0);
        return count;
    }, [count]);
    set.add(callback);
    console.log(set);
    return (
        <div>
            <h4>size: {set.size}</h4>
            <h4>count: {count}</h4>
            <h4>val: {val}</h4>
            <button onClick={() => setCount(count + 1)}>+</button>
            <input value={val} onChange={event => setVal(event.target.value)} />
        </div>
    );
}
export default Count;
```
可以看到如果依赖项 count 不改变，set 集合大小就不会改变。打印出的 set 集合存放的各种缓存函数。其实 `useCallback(fn， deps)` 和 `useMemo(() => fn， deps)` 作用是相同的。
比如我们有一个父组件，包含一个子组件，子组件接收一个函数作为props。这样无论父组件那个数据修改了，子组件便会执行更新，但是有很多情况下更新是没有必要的，我们可以借助 `useCallback` 和 `memo` 一起避免不必要的更新。
```javascript
import React, { useState, useCallback } from 'react';
import ViewCount from './viewCount';

const Count = () => {
    const [count, setCount] = useState(1);
    const [val, setVal] = useState('');

    const callback = useCallback(() => {
        return count;
    }, [count]);

    return (
        <div>
            <ViewCount callback={callback} />
            <button onClick={() => setCount(count + 1)}>+</button>
            <input value={val} onChange={event => setVal(event.target.value)} />
        </div>
    );
}
export default Count;
```
编写子组件，需要结合 `memo` 避免重复渲染。
```javascript
import React, { useState, useEffect, memo } from 'react';

const viewCount = memo(({ callback }) => {
    const [count, setCount] = useState(() => callback());
    console.log(0);
    useEffect(() => {
        setCount(callback());
    }, [callback]);

    return <p> { count } </p>
})
export default viewCount;
```
这样只有子组件数据改变才会重新进行渲染。

> 无论是`useCallback`还是`useMemo`避免子组件重复渲染都需要`memo`的配合，不然不仅不会提示性能，还是对程序性能造成一些影像。

## memo
避免一些组件重复的渲染，比如下面会造成很大的资源浪费，简单修改下上面写的组件:
```javascript
import React, { useState, useCallback } from 'react';
import {UserContext} from './UserContext';
import UserInfo from './user';

const User = () => {
  const [user, setUser] = useState('blog');
  const [count, setCount] = useState(0);
  return (
    <UserContext.Provider value={ { user, setUser } }>
      <UserInfo user={user} setUser={setUser} />
      <p>{count}</p>
      <button onClick={() =>  setCount(count + 1)}>
        +
      </button>
    </UserContext.Provider>
  );
}
export default User;
```
然后在子组件中添加一些渲染提示:
```javascript
import React, {memo} from 'react';

export default ({user, setUser}) => {
  console.log('assembly Rendering');
  return (
    <div>
      {user}<br />
      <button onClick = {() => setUser('123123')}>
        set name
      </button>
    </div>
  )
}
```
这样父组件中的 count 发送变化 user 子组件就会重新渲染。按照正常逻辑来讲，count 和 user 组件没有关系，count 无论怎么变化都不该将 user 组件重新渲染，如果 user 组件逻辑很复杂会造成很大的性能的浪费。我们可以使用 `memo` 解决这个问题:
```javascript
import React, {memo} from 'react';

export default memo(
    ({user, setUser}) => {
        console.log('assembly Rendering');
        return (
            <div>
                {user}<br />
                <button onClick = {() => setUser('123123')}>
                    set name
                </button>
            </div>
        )
    }
)
```
我们只需要使用 `memo` 包括函数，就会自动判断该组件依赖值是否改变，如果不改变便不会重新渲染。

> 如果使用 class 组件该怎么解决重复渲染的问题呢? 熟悉 React 应该了解 `PureComponent` 和  `Component` 区别，主要靠钩子函数 `shouldComponentUpdate` 来进行比对，如果返回 true，则表示重复渲染，如果返回 false 则不会重新进行渲染。

## useReducer
```javascript
const [state, dispatch] = useReducer(reducer, initialArg, init);
```
该方法为 userState 的替代方案。总共接收三个参数:
- **reducer**: 一个 reducer 函数，和以前的 redux 函数的 reducer 相同，主要根据发送过来的 Action 处理 state 数据。
- **initialArg**: 设置 useReducer state 的初始值。
- **init**: 惰性地创建初始 state。其是一个函数，该函数返回初始化后的状态。

如果您 state 逻辑较复杂且包含多个子值，或者下一个 state 依赖于之前的 state 等。这些情况都可以使用 useReducer 来替代 useState。并且使用 `useReducer` 还能给那些会触发深更新的组件做性能优化。
```javascript
import React, { useReducer } from 'react';

const initialState = {count: 0};

function reducer(state, action) {
  switch (action.type) {
    case 'add':
      return {count: state.count + 1};
    case 'reduce':
      return {count: state.count - 1};
    default:
      throw new Error();
  }
}
const Reducer = () => {
    const [state, dispatch] = useReducer(reducer, initialState);

    return (
        <div>
            <p>count: {state.count}</p>
            <p><button onClick={() => dispatch({type: 'add'})}>+</button></p>
            <p><button onClick={() => dispatch({type: 'reduce'})}>-</button></p>
        </div>
    );
}
export default Reducer;
```
这样就可以使用 useReducer 来替代 `userState` 进行组件间的 state 管理。如果需要和子组件共享数据，可以将 `useReducer` 和 `useContext` 结合起来，这样所有子组件都可以共享这些数据了。
### immer
既然我们已经开启了`useReducer`，那么结合`immer`可以使代码更整洁。由于 reducer 只能返回一个新的 state 并不能在老的 state 上进行修改，但数据格式复杂的时候，这种处理数据的方式会添加许多无用代码，而`immer`就是为了解决该问题。
```javascript
import React, { useReducer } from 'react';
import produce from 'immer';
const initialState = {count: 0};

function reducer(state, action) {
  switch (action.type) {
    case 'add':
      return produce(state, (defaultState) => {
        defaultState.count = defaultState.count + 1;
      });
    case 'reduce':
      return produce(state, (defaultState) => {
        defaultState.count = defaultState.count - 1;
      });
    default:
      return state;
  }
}
const Reducer = () => {
    const [state, dispatch] = useReducer(reducer, initialState);

    return (
        <div>
            <p>count: {state.count}</p>
            <p><button onClick={() => dispatch({type: 'add'})}>+</button></p>
            <p><button onClick={() => dispatch({type: 'reduce'})}>-</button></p>
        </div>
    );
}
export default Reducer;
```
这样只需我能用`produce`包裹就能之间操作 state。
### use-immer
上面说了`immer` 那么有没有针对`hooks`设计的该插件呢？有。[use-immer](https://github.com/immerjs/use-immer) 就是为 hooks 封装之后的一个插件。
``` Diff
import React from 'react';
- import produce from 'immer';
+ import { useImmerReducer } from 'use-immer';

const initialState = {count: 0};
function reducer(state, action) {
  switch (action.type) {
    case 'add':
-      return produce(state, (defaultState) => {
-        defaultState.count = defaultState.count + 1;
-      });
+      state.count = state.count + 1;
+      return;
    case 'reduce':
-      return produce(state, (defaultState) => {
-        defaultState.count = defaultState.count - 1;
-      });
+      state.count = state.count - 1;
+      return;
    default:
      return state;
  }
}
const Reducer = () => {
-   const [state, dispatch] = useImmerReducer(reducer, initialState);
+   const [state, dispatch] = useReducer(reducer, initialState);
    return (
        <div>
            <p>count: {state.count}</p>
            <p><button onClick={() => dispatch({type: 'add'})}>+</button></p>
            <p><button onClick={() => dispatch({type: 'reduce'})}>-</button></p>
        </div>
    );
}
export default Reducer;
```
只需这样修改`useImmerReducer`创建的对象我们可以直接在 reducer 中修改 state。这样就和`userState`很相似，第一个都为 state，第二个为修改 state 的对象。
## 自定义Hook
自定义 hooks 是代码逻辑复用的利器，比如以前组件逻辑复用只能用高阶组件实现，而自定义hooks可以在不添加组件的情况下实现同样的效果。
```javascript
import React, { useState } from 'react';
function useCount(defaultValue){
  const [count, setCount] = useState(defaultValue);
  const addCount = () => {
    setCount(count + 1);
  };
  const reduceCount = () => {
    setCount(count - 1);
  };
  return [
    count,
    {
      addCount, reduceCount
    }
  ]
}

const Reducer = () => {
  const [count, setCount] = useCount(0);
  return (
      <div>
          <p>count: {count}</p>
          <p><button onClick={() => setCount.addCount()}>+</button></p>
          <p><button onClick={() => setCount.reduceCount()}>-</button></p>
      </div>
  );
}
export default Reducer;
```