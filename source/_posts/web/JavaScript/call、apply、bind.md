---
title: call、apply、bind区别
subtitle: call-apply-bind
date: 2019-12-13 11:48:10
tags:
  - call
  - apply
  - bind
categories: [web]
---
**call**、**apply**、**bind** 三个函数在 JS 中都可以用来修改函数的上下文对象，并且三个方法作用相同，但使用方式却各不相同。那么它们的区别是什么？以及怎么实现的呢？

<!-- more -->
## 相同和区别
### 相同
它们都是用来改变函数的上下文，也就是`this`指向。
### 不同
`fn.call`：立即调用，返回函数指向结果，`this`指向第一个参数，后面可以有更多的参数，并且这些都是 fn 函数的参数。
`fn.apply`：立即调用，返回函数指向结果，`this`指向第一个参数，第二个参数是个数组，这个数组内容是 fn 函数的参数。
`fn.bind`：不会立即调用，而是返回一个绑定后的新函数，一个典型的 `柯里化` 函数。

## 柯里化
如果一个函数接收多个参数，我们可以把这个函数转化为每次只接收一部分参数的多次调用形式，这就是函数的柯里化。
听着定义很难懂，但是我们看代码就很简单了。首先如果我们有下面的函数：
```javascript
function add(a, b, c){return a + b + c};
```
我们可以将上面函数柯里化，那么函数定义为：
```javascript
// 普通的函数定义
function add(a){
  return function(b, c){
    return a + b + c;
  }
}
// 也可以使用es6方式定义
const add = (a) => (b, c) => (a + b + c);
// 使用
add(1)(2, 3);
```
项目中还是有些常用的，具体就不介绍了，我们可以总结下柯里化的 4 种功能：
1. 性能优化。
2. 代码复用。
3. 使代码清晰，更难以理解。
4. 扩展JS能力。

## call
call 函数接收第一个参数作为上下文，其余参数传递给需要执行的函数。那么我们在调用 call 到底发生了什么：

1. 改变 this 的指向，指向第一个参数。
2. 执行相应的函数。

我们把上面执行逻辑转换为代码：
```javascript
// call 的 “this” 默认值为 window
Function.prototype.myCall = function(thisObj = window){
  // 这里的 this 指向 调用的函数(也就是bar)
  thisObj.fn = this;
  // 处理 arguments 参数，去除第一个(第一个参数为 this)
  let arg = [...arguments].slice(1);
  // 把参数传递给，调用的函数，并修改 this 的指向
  let result = thisObj.fn(...arg);
  // 已经构建完成，删除多余的参数
  delete thisObj.fn;
  // 返回修改后的对象
  return result;
}
```
我们使用代码进行验证：
```javascript
let foo = {
  value: 1
};
function bar(name, age) {
  console.log(name);
  console.log(age);
  console.log(this.value);
}
// 最后得出下面的输出: kevin 18 1
bar.myCall(foo, 'kevin', 18);
```
完成 call 函数。
## apply
这个和上面的 call 非常的相似，只是参数的传递并不相同：
```javascript
// call 的 “this” 默认值为 window，arr 为参数列表
Function.prototype.myApply = function(thisObj = window, arr){
  thisObj.fn = this;
  let result;
  if(!arr){
    result = context.fn();
  } else {
    result = context.fn(...arr);
  }
  delete context.fn;
  return result;
}
```
这样也可以实现 apply 和上面的 call 及其相似，只是多了一个参数 arr。
## bind
这个和上面的两个(call、bind)都不相同，其创建后不会第一时间执行，还需要用户手动调用：
```javascript
Function.prototype.myBind = function(thisObj){
  // 只有函数类型才能继续执行
  if(typeof this !== 'function'){
    throw new TypeError('must be a function');
  }
  // 这里的 this 指向 调用的函数
  let self = this;
  // 参数，去掉第一个 this
  let argsArr = [...arguments].slice(1);
  // 注意，bind 和 call 参数相似，但是 bind 返回一个函数
  return function(){
    // 第二次传递的参数
    let bindFuncArg = [...arguments]
    // 因为是执行了两次，需要进行数据合并
    let totalArgs = argsArr.concat(bindFuncArg);
    // 借助上面定义的 apply 实现
    return self.apply(thisObj, totalArgs)
  }
}
```
上面便借助了 call 实现了 bind。

## 总结
call、apply、bing 各有各的特点，虽然功能相似但却各有各的长处，如果正常使用还是 `call` 比较的常用，当然这也是依靠个人的编程习惯。