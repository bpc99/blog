---
title: react-context
subtitle: react-context
date: 2020-01-14 14:38:41
tags:
  - React
categories: [web]
---
由于 React 的数据流都是 **单向传递** 的，只能由父级组件定义数据子组件使用，但是只能嵌套一层，如果涉及到多层嵌套，便只能层层向下传递。而 `Context` 的存在提供了另外一种数据的传输方式，可以在父级定义上下文对象，所有子组件都能获取到上下文对象，从而避免了在每一个层级手动的传递 props 属性。

<!-- more -->
## API
我们可以看下官网提供的 [资料](https://zh-hans.reactjs.org/docs/context.html#gatsby-focus-wrapper)，其为我们提供了很多常用的方法。
### React.createContext
我们需要在父组件中使用 `React.createContext(defaultValue)` 方法创建 `Context`对象，defaultValue 表示默认需要共享的数据。
```javascript
import React from 'react';
// 通过createContext方法创建
const { Provider, Consumer } = React.createContext();
```
### Context.Provider
`Context` 所返回的对象中包含一个 `Provider` 组件，该组件包含一个 `value` 属性，该值可以被所有子组件直接获取，这样就可以避免 props 向深层级的组件传递的问题了，并且当 `Context` 的值放生变化的时候组件会自动重新render。
```javascript
<Provider value={/*共享的数据*/}>
    { this.props.children }
</Provider>
```
简单来说：该组件相当于一个生产者，供所有子组件使用。

### Context.Consumer
`Consumer` 组件可以帮助我们获取 `Provider` 里的数据，`Consumer` 组件的子组件是一个函数，这个函数的第一个参数就是共享的值，函数的返回值必须是一个 React元素。
```javascript
<Consumer>
    { (state) => <...  /> }
</Consumer>
```
我们可以简单的理解它为消费者，我们可以借此来获取 `Provider` 中的数据。
## 结合  React
上面简单的介绍了一些常用的 API，下面主要还是和 React 简单的结合一起使用。
### 整理项目
首先在项目中新建一个 **contexts** 文件夹，里面放入我们需要的 `Context`，这样更适合我们维护项目。
### 创建一个简单的Context
创建一个简单的 `Context`，方便后面继续使用：
```javascript
import React, { Component } from 'react';
// 导出 Context 方便后面调用其 API
export const UserContext = React.createContext();

// 父组件使用
export class UserProvider extends Component {
    state = {
        user: {
            name: 'blog',
            age: 23
        }
    };
    render() {
        return (
            <UserContext.Provider value={this.state.user}>
                { this.props.children }
            </UserContext.Provider>
        );
    }
}
```
### 子元素获取数据
任何子元素获取上下文对象中的数据，必须依靠 `Consumer` 组件：
```javascript
import App from './App';
import React from 'react';
import ReactDOM from 'react-dom';
import * as serviceWorker from './serviceWorker';
import { UserContext } from './contexs/userContext';

ReactDOM.render(
    <UserContext.Consumer>
        // 通过这种方法传递给需要的子组件
        {({user}) => <App user={user} />}
    </UserContext.Consumer>
, document.getElementById('root'));
```
这样我们就获取到了 `Context` 的数据，并通过 props 传递给子组件，子组件通过 props 获取即可。
## 总结
所以结合上面我们可以得出下面步骤：
- 就是需要创建一个一个 `Context`。
- 创建 `Provider`，提供需要共享的数据，剩余交给 `Context`。
- 子组件通过 `Consumer` 进行访问 `Context` 管理的数据，但是需要注意函数的返回值必须是一个 React元素。
