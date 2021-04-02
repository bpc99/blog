---
title: 函数柯里化
subtitle: currying
tags:
  - 柯里化
categories: [web]
date: 2019-10-27 15:36:34
---

函数的柯里化其实在开发中很常用，其能为我们节约开发的很多的代码，也可以更灵活的封装函数，或许代码中使用过，但并不知道其是柯里化。

<!-- more -->

## 柯里化是什么
柯里化(Currying)：就是把接收多个参数的函数变换成接收第一个参数的函数，并且返回接受余下的参数而且返回结果的新函数的技术。

定义非常的抽象，下面看下简单的一些使用：
```javascript
// 普通的函数
const plus = (a ,b) => a + b;
console.log(plus(1, 3)); // 4

// 柯里化后
const curryingPlus = a => b => a + b;
let currying = curryingPlus(1);
console.log(currying(3)); // 4
```
上面两个函数返回值相同的，就是**plus**函数 a,、b 两个参数，先接收第一个参数，然后返回一个函数去处理b这个参数。这思路就更清晰了，就是只传递一个第一参数来创建它，让它返回一个函数来处理下面的参数。

但是问题来了，这似乎并没有太大的作用，那包装这一层究竟有什么作用呢？那些技术大牛也不会闲着没事包装一层没有用的函数，下面看下Currying怎么使用。

## Currying好处
### 参数复用
函数的参数复用：
```javascript
// 普通的正则表达式匹配函数
const find = (replace, text) => replace.test(text);
console.log(plus(/a/, 'The best things in life are free!')); // true

// 柯里化后
const curryingFind = replace => text => replace.test(text);
let currying = curryingFind(/a/);
console.log(currying('The best things in life are free!')); // true
```
两次结果是一致的，但是柯里化后明显比第一个少定义了一次正则表达式。柯里化先用正则表达式创建一个函数，然后传入字符串给返回函数，这样就少定义正则表达式的代码。
### 延迟执行
柯里化的延迟执行为不断的传入参数，函数不断收集传入的参数，最后在执行函数。例如累加：
```javascript
function curryingPush(){
  let list = [...arguments];
  const _sum = function () {
      list = [...list, ...arguments];
      if(arguments.length <= 0){
          return list.reduce((a, b) => a + b);
      }else{
          return _sum;
      }
  };
  return _sum;
}

let currying = curryingPush(1);
currying(2);
currying(3);
console.log(currying()); // 6
```
上述例子函数不断收集参数，放入list中，直到我们传入空参数结束循环，最后累加我们的list返回相加的值，并结束柯里化的过程。
### Function.prototype.bind
`bind`函数在开发过程中很常见。那么看下bind怎么实现的：
```javascript
Function.prototype.bind = function (context) {
    var _this = this;
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return _this.apply(context, args)
    }
}  
```
很明显，bind也是通过Currying来实现的。
## 有趣的问题
实现下面的一种结果：
```javascript
console.log(add(1, 2, 3)); // 6
console.log(add(1)(2, 3)); // 6
console.log(add(1)(2)(3)); // 6
```
这就需要柯里化逐渐收集参数，满足需求后结束函数返回累加。
```javascript
function curryingPush(_sum){
    // props_len：需要收集的参数个数；props_list：收集参数列表
    let props_len = _sum.length, props_list = [];
    const _push = function () {
        props_len = props_len - arguments.length;
        props_list = [...props_list, ...arguments];
        if(props_len <= 0){
            props_len = _sum.length;
            return _sum.apply(undefined, props_list);
        }else{
            return _push;
        }
    };
    return _push;
}
let sum = (a, b, c) => a + b + c;
let currying = curryingPush(sum);
console.log(currying(1, 2, 3)); // 6
console.log(currying(1)(2, 3)); // 6
console.log(currying(1)(2)(3)); // 6
```

其实也很简单，也是通过柯里化逐渐收集参数，只是结束条件修改了一些，然后在结束的时候把`props_len` 拉回最初状态，以便于下次操作。

> 上述柯里化主要依靠`arguments`属性来实现，如果使用Es6的箭头函数，切记箭头函数里面无法调用`arguments`。