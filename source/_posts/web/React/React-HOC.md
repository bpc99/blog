---
title: React-HOC
date: 2020-09-29 17:58:01
subtitle: react-hoc
tags:
  - React
  - 高阶组件
categories: [web]
---
**HOC 是一种很好的设计模式，而不是针对某些技术的API**，这种设计模式在很多 React 库中证明了其价值，并且通过它我们可以很好的复用 React 组件中代码逻辑。

<!-- more -->
## 高阶组件是什么?
高阶组件简称HOC，它和高阶函数非常的相似，简单可以概况为：**它是接受了一个组件，返回一个新的组件的纯函数**。我们也可以将它理解为一个类工厂，它被传入了一个组件，然后返回一个经过加工的新组件。
## 解决什么问题?
React 在开始时并不是使用 HOC 解决逻辑复用的问题，而是靠 Mixin 解决，虽然他非常的强大。但是它还具有非常大的隐患，让我们看下 Mixin 造成的问题：

1. **破坏组件封装性**: 如果我们组件中引用 Mixin 方法会为我们组件带来不可见的属性(props)和状态(state)。并且每个 Mixin 也可能相互依赖，相互耦合，非常不利于维护。
2. **命名冲突**: 不同 Mixin 的属性方法和组件中的属性方法都可能相互覆盖相互冲突。
3. **雪球效应**: 例如我们一个组件使用了一个 Mixin，但是 Mixin 会被多个组件引用，也就是说可能存在一个需要使 Mixin 添加更多属性或方法的组件，这样一直新增便会增加维护成本。

综上所述 Mixin 具有很高的侵入性，这种代码都具有很高的隐患，所以为了解决上述问题，React 改用了 HOC。
## 如何去实现？
高阶组件主要有两个实现的方式，分别为 **属性代理(Props Proxy)**、**反向继承(Inversion inherit)**。但是我们无论使用那种方法都可以操作 WrappedComponent。下面主要看下如何去实现HOC。
### Props Proxy
我们先使用一个最简单代码实现这个功能：
```javascript
import React from 'react';

export function propsProxyHoc(WrappedComponent) {
  return class proopProxy extends React.Component {
    componentDidMount() {
      console.log('props proxy 模式 HOC');
    }
    render() {
      return <WrappedComponent {...this.props } user = "props-prosy" />
    }
  }
}
```
上述代码非常像`柯里化`的函数，这里主要是 HOC 接收了一个组件然后返回一个新的组件，并且新组件 render 也是返回了一个 WrappedComponent 的 React 元素。我们将传入的 props 收集出来，然后传入新的组件，这便是属性代理名称的由来。
那么我们到底使用`Props Proxy`可以做些什么?下面开始分析：
#### 操作 props
我们可以修改、读取、删除、编辑传递给 WrappedComponent 组件的数据。但是我们需要小心它并没有为我们提供相关的命名空间，所以属性随时可能会发送覆盖。
例如我们可以在给 WrappedComponent 传递一些数据：
```javascript
import React from 'react';

export function propsProxyHoc(WrappedComponent) {
  return class proopProxy extends React.Component {
    componentDidMount() {
      console.log('props proxy 模式 HOC');
    }
    render() {
      return <WrappedComponent {...this.props } user = "props-prosy" />
    }
  }
}
```
这样我们就可以在 WrappedComponent 组件中使用 `this.props.user` 来获取传递的数据。
#### 通过 Refs 访问组件实例
使用属性代理还是可以很简单的获取 WrappedComponent 的实例引用(`ref`)，例如我们这样写:
```javascript
import React from 'react';

export function propsProxyHoc(WrappedComponent) {
  return class proopProxy extends React.Component {
    componentDidMount() {
      console.log('props proxy 模式 HOC');
    }
    render() {
      return <WrappedComponent {...this.props } ref = {ref => this.res = ref} />
    }
  }
}
```
这样渲染完成后，我们便可以通过 proopProxy 很简单的获取到 WrappedComponent 组件的实例。
#### 提取 state
属性代理情况下，我们可以将 WrappedComponent 组件的状态提取到包裹组件里，有一个常见的例子就是可以实现**不受控组件**到**受控组件**的转换。
```javascript
// 典型的不受控组件
class WrappedComponent extends React.Component{
	render(){
		return <input name="name" {...this.props.name} />
	}
}

// HOC 工厂
export function propsProxyHoc(WrappedComponent) {
  return class proopProxy extends React.Component {
  	constructor(props) {
      super(props)
      this.state = {
        name: ''
      }
      this.onNameChange = this.onNameChange.bind(this);
    }
    onNameChange(event) {
      this.setState({
        name: event.target.value
      })
    }
    render() {
      const newProps = {
        name: {
          value: this.state.name,
          onChange: this.onNameChange
        }
      }
      return <WrappedComponent {...this.props } {...newProps} />
    }
  }
}
```
通过上面代码我们可以通过 HOC 将不受控组件转换为了受控组件。其实也是通过 props 进行传输。
#### 添加元素包裹
我们使用 HOC 时还可以对 WrappedComponent 封装一些其它的 DOM 元素，例如：
```javascript
import React from 'react';
export function propsProxyHoc(WrappedComponent) {
  return class propsProxy extends React.Component {
  	render(){
      return (
        <div> <WrappedComponent {...this.props } /> </div>
      )
  	}
  }
}
```

### Inversion inherit
当然除了我们使用 `属性代理` 的方式来实现HOC，还可以使用另一项技术来实现。看下下面的代码：
```javascript
function iInheritHOC(WrappedComponent) {
  return class iInherit extends WrappedComponent {
    render() {
      return super.render()
    }
  }
}
```
`反向继承` 指的就是 **HOC 返回的新组件去继承 WrappedComponent**，因为继承关系是反着进行的，所以我们将其称为 **反向继承**。
它和属性代理不同的便是，它继承了 WrappedComponent，这就意味着它可以访问到**state**、**props**、**组件生命周期**、**render** 等方法。
但是虽然它能够访问 WrappedComponent 的生命周期等，但是这些尽量不要去修改，我们因该尽量保持 WrappedComponent 的完整性。

那么我们可以使用它来做些什么呢？下面进行分析：

#### 渲染劫持(Render Highjacking)
之所以称之为渲染劫持是因为由完全由 HOC 控制 WrappedComponent 渲染输出，进而完成控制渲染的结果。
例如我们可以根据参数判断渲染那部分组件，或者不进行渲染:
```javascript
function iInheritHOC(WrappedComponent) {
  return class iInherit extends WrappedComponent {
    render() {
      if (this.props.isRender) {
        return super.render();
      } else {
        return null;
      }
    }
  }
}
```
甚至我们可以组件返回 render 的内容。例如我们 WrappedComponent 组件内容是这样的：
```javascript
class WrappedComponent extends React.Component{
  render(){
    return(
      <input value={'Hello World'} />
    )
  }
}
export default iInheritHOC(WrappedComponent)
```
我们在 HOC 中控制 WrappedComponent 中 render 的内容：
```javascript
function iInheritHOC(WrappedComponent) {
  return class iInherit extends WrappedComponent {
    render() {
      const elementsTree = super.render();
      let newProps = {};
      if (elementsTree && elementsTree.type === 'input') {
        newProps = {value: 'may the force be with you'};
      }
      const props = Object.assign({}, elementsTree.props, newProps);
      const newElementsTree = React.cloneElement(elementsTree, props, elementsTree.props.children);
      return newElementsTree;
    }
  }
}
```
这样我们根据 WrappedComponent 克隆了一个新的组件，它的内容基本一样，但是我们将 value 的值修改为: may the force be with you。最后我们可以看下 `elementsTree` 与 `newElementsTree` 的区别：

![wrappedComponent.png](https://img.bipch.cn/2021/02/03/9b18e9faf35c3.png)

在反向继承中，由于是继承我们可以修改 WrappedComponent 的 state、props、render、钩子函数等。
但是他有一个非常重要的问题就是：React元素(Element) 决定了 React 界面到底渲染为什么，而 React 元素有两种类型：**字符串** 和 **函数**。字符串类型的 React元素 代表DOM节点。函数 类型代表 React组件。而函数类型的 React组件 最终会被解析为一个完全由 字符串类型React元素树。这就意味着**反向继承不能保证完整的子组件树被解析**，也就是说我们不能操作 WrappedComponent 中的子组件了，这就是所谓的**不能完全解析**。
例如我们有下面的代码：
```javascript
// 定义 WrappedComponent 组件
class WrappedComponent extends Component{
  render(){
    return (
      <>
        <div>Hello World</div>
        <MyComponent />
      </>
    )
  }
}
export default propsProxyHoc(propsProsyHoc);

// 定义 MyComponent 组件
class MyComponent extends Component{
  render(){
    return (
      <div>Hello World</div>
    )
  }
}
// HOC封装
export function propsProxyHoc(WrappedComponent) {
  return class propsProxy extends WrappedComponent {
    render() {
      const elementsTree = super.render();
      console.log(elementsTree)
      return elementsTree;
    }
  }
}
```
最后得到下面的结果：

![wrappedComponent.png](https://img.bipch.cn/2021/02/03/c85fd0df5f38f.png)

最后分析我们的组件返回的 element tree，最后发现 <> 组件下 **div** 被完全解析了，但是 **MyComponent** 是组件类型的，其子组件并没有完全被解析的。
#### 操作 state
HOC 还可以进行读取、编辑、删除 WrappedComponent 实例的 state，但是我们最后不要去操作原组件的属性，不然很容易搞混，破坏掉一些逻辑。添加 WrappedComponent 实例的 state 时，也需要注意一些变量覆盖的问题，添加一些 state 命名空间，避免一些属性混在一起。
例如我们可以通过 `柯里化` 添加一些 state 初始值：
```javascript
const propsProxyHoc = (...params) => {
    //?可以做一些改变 params 的事
    return (WrappedComponent) => {
        return class propsProxy extends WrappedComponent {
            render() {
                return super.render();
            }
        }
    }
}
```
然后我们赋初始值便可以这些写：
```javascript
export default propsProxyHoc({data: '柯里化传参'})(propsProsyHoc);
```
这样 propsProsyHoc 组件中 state 便被 HOC 设置了一些初始值。
## 命名
因为 HOC 是包裹 WrappedComponent 组件，返回新的组件这就使 WrappedComponent 失去了原先的名称，这样不利于开发或者进行调试。 
我们通常可以在 WrappedComponent 名称前面添加一些前缀作为 HOC 返回的组件名称，例如 React-Redux：
```javascript
HOC.displayName = `HOC(${getDisplayName(WrappedComponent)})`
```
然后其 `getDisplayName` 的实现也很简单：
```javascript
function getDisplayName(WrappedComponent) {
  return WrappedComponent.displayName ||
         WrappedComponent.name ||
         ‘Component’
}
```
## HOC 封装注意
我们不管使用那种方式去实现 HOC 都有下面几条事项，需要去注意：
### 修改原始组件
例如这样去封装组件：
```javascript
function logProps(InputComponent) {
  //?通过修改prototype来修改组件
  InputComponent.prototype.componentDidMount = function() {
    console.log('componentDidMount');
  };
  //?此处已经被修改了
  return InputComponent;
}

//!组件调用
const EnhancedComponent = logProps(InputComponent);
```
通过这种直接去修改组件源代码的方式是不推荐的，应该尽量规避，我们可以使用 HOC 添加一些属性对 WrappedComponent 组件进行相应的扩展：
```javascript
export function propsProxyHoc(WrappedComponent) {
  return class propsProxy extends WrappedComponent {
    componentDidMount(){
      console.log('componentDidMount');
    }
    render() {
      return super.render();
    }
  }
}
```
### 多个 HOC 结合使用
HOC 是在 WrappedComponent 组件的基础上添加一层逻辑封装，返回一个加强的新组件。但是如果一个组件需要不同维度的增强，那么就需要多次 HOC 嵌套使用：
```javascript
const EnhancedComponent = withRouter(connect(commentSelector)(WrappedComponent));
```
但是这样写代码可读性会非常低，维护成本也会增加。我们可以通过`compose`将上述代码改写为：
```javascript
const enhance = compose(
  withRouter,
  connect(commentSelector)
)
const EnhancedComponent = enhance(WrappedComponent)
```
## HOC 使用注意
在使用 HOC 时下面的几点需要注意不要出下面的问题：
### HOC 不能在 render 中使用
React的 `diff算法` 通过判断 component ID 来决定是否更新存在的子树或者删除的子树，并且重新加载一个新的。如果从 render 方法中返回返回组件(===)原来的渲染组件。但是 HOC 是一个函数，每次调用都会返回一个新的组件，所以 render 方法每次调用 diff处理。并将原有组件进行删除，重新加载一个新的组件。所以我们在 render 中不能使用 HOC。
### HOC 不包含 WrappedComponent 静态方法
我们实现 HOC 时，通过对原始组件的加强得到并返回一个新的组件。这就造成了新组件中没有原始组件的任何静态的方法，所以如果想要在新组件中使用该静态方法的话，就需要一些特别的处理：
```javascript
function enhance(WrappedComponent) {
  //?需要返回的组件
  class Enhance extends React.Component {/*...*/}
  //!定义静态方法
  Enhance.staticMethod = WrappedComponent.staticMethod;
  return Enhance;
}
```
通过这种方式之后 HOC 返回的组件才能使用那些静态方法。