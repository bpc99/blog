---
title: React-Render-Props
date: 2020-10-09 15:02:21
subtitle: react-redux-props
tags:
  - React
  - 高阶组件
categories: [web]
---

render props 的作用和 hoc 的作用基本相似，根据官网的介绍其主要 **用于使用一个值为函数的 prop 在 React 组件之间的代码共享**，这样说似乎难以理解我们可以这样说：其核心为通过函数将 class 组件的 state 作为 props 传递给函数组件。

<!-- more -->
##  为什么用 render props
学习技术之前一定要先明白它解决了什么样的问题，其实 render props 和 高阶组件hoc 作用一样，都是为了方便提取功能相似但逻辑有些不同的组件，可以对多个逻辑相同组件进行逻辑的提取，增加代码的灵活性。
## 例子
比如我们有这样一个需求：**一个按钮有该权限时展示否则隐藏**。
这种需求开发过程中还是很常见的，如果我们用普通的代码来写，便会出现下面的代码：
```javascript
import React from 'react';

class App extends React.Component{
  constructor(props) {
    super(props);
    this.state = {isLogin: true}
  }
  render(){
	/**逻辑判断*/
    return (
      <div className="App">
        {
          this.state.isLogin && <button>按钮</button>
        }
      </div>
    );
  }
}
export default App;
```
这样即使能完成我们的需求，但是代码中存在大量的逻辑判断，代码也有很大的耦合性，并且代码非常不灵活会显得很笨重，比如需求改变为当没有权限我们要跳转界面，这样就大量组件代码又需要修改，扩展性很差。
### 改造
这种代码显然不符合我们的心意，我们需要第一次对代码封装，修改后代码为：
```javascript
import React from 'react';

class DictionComponent extends React.Component{
  constructor(props) {
    super(props);
    this.state = {isLogin: true}
  }
  render(){
	/**逻辑判断*/
    return this.state.isLogin?<button>按钮</button>:'';
  }
}
class App extends React.Component{
  render(){
    return (
      <div className="App">
        <DictionComponent />
      </div>
    );
  }
}
export default App;
```
将逻辑判断封装为一个组件，使用的时候，引入相应组件。这样虽然可以简单的封装了，但是依然不够灵活，例如需求改变为权限不足时显示一行提示文字，此时上述代码已经不满足需求，只能修改组件或在封装一个组件，这就显得代码不够灵活，这时我们便要通过 `render props` 进行封装。

### render props
我们添加一个逻辑判断组件 `DictionProps` ，它能够动态的决定什么是需要渲染的，并能改变最终改变渲染的结果：
```javascript
import React from 'react';

class DictionProps extends React.Component{
  constructor(props) {
    super(props);
    this.state = {isLogin: true}
  }
  render(){
    /**逻辑判断*/
    return this.state.isLogin?this.props.success():this.props.error();
  }
}
class App extends React.Component{
  render(){
    return (
      <div className="App">
        <DictionProps success={() => <button>按钮</button>} error={() => ''} />
      </div>
    );
  }
}
export default App;
```
这样我们可以完全交由 `DictionProps` 决定到底需不需要渲染，渲染的最终结果等信息，而不是写死来决定最终内容，这样需要什么组件按需传入即可，这样代码会显得非常灵活。
结合上面代码来说：**render props 是一个用于判断最终渲染的内容的函数 prop。**