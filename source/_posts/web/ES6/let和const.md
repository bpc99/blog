---
title: let 和 const
date: 2020-09-06 18:26:06
subtitle: es6-let-const
tags:
  - ES6
categories: [web]
---
Es6 不仅添加一些常用的方法、对象，还对 JavaScript 的基本变量进行了扩展，在原先 var 的基础上又提出了 **let** 和 **const** 关键字。那么这两个关键字到底有什么作用，到底解决了什么问题呢？

<!-- more -->

## 为什么要有它们
在 ES6 之前项目中是没有 **let** 和 **const** 关键字的，定义变量都是需要通过 **var** 来完成，但是由于 **var** 并没有作用域等概念，所以变量会比较混乱，并且如果变量定义过多也会出现一些意想不到的错误，比如下面的问题：
### 变量提升
就是变量可以在声明前被使用，值为 undefined ，比如下面代码：
```javascript
// 输出 undefined
console.log(a);
var a = 2;
```
这明显不是我们想要的，如果变量未声明便去使用，要抛出`ReferenceError`异常。
### 暂时性死区
其实造成这个的原因便是上面的问题，例如我们有下面代码：
```javascript
var a = 123;
if(true){
  a = 456;
  let a;
}
```
上述代码回抛出 `ReferenceError` 异常，是因为在块级区域声明 a，那么该区域便会和这个变量进行绑定(binding)，而你在定义变量上面进行赋值，由于此时还未能声明所以对为声明变量赋值回抛出一个异常。
### 重复声明
var 支持变量的重复声明，一个变量名，可以进行很多次的声明：
```javascript
var a = 123;
if (true) {
  var a = 12;
  var a = 123;
}
```
### 作用域
var 中并没有什么作用域划分，常用的变量全靠覆盖，比如：
```javascript
if (true) {
  var a = 10;
}
// 正常输出 10
console.log(a);
```
基于上面问题，ES6为了规范代码，提出了 let 和 const。

## 块级作用域和函数声明
**函数可以在块级作用域之中声明吗？**
ES5中规定，函数只能在顶层作用域和函数作用域中声明，不能在块级作用域声明。
```javascript
// 情况一
if(true){
  function f(){}
}

// 情况二
try{
  function f(){}
}
```
上面函数声明在ES5中都是非法的。
但是浏览器没有遵守该规定，为了兼容旧代码，还是支持在块级作用域之中声明函数，因此上面代码都能运行并不会报出错误。ES6则引入了块级作用域，明确允许在块级作用域中声明函数。ES6规定在块级作用域之中，函数声明语句类似于let，在块级之外不能使用。
```javascript
function f(){console.log('I am outside!');}

(function(){
  if(false){
    function f(){console.log('I am inside!');}
  }
  f();
}())
```
上述代码在浏览器中回报出错误`TypeError`，因为上述代码会被编辑为：
```javascript
function f() {
  console.log('I am outside!');
}
(function () {
  if (false) { var f; }
  f();
})();
```
因为 var 没有作用域的划分，所以 f() 会抛出错误。而在ES6则会编译为下面的代码：
```javascript
function f() {
  console.log('I am outside!');
}
(function () {
  if (false) { var _f; }
  f();
})();
```
可以正常打印出 `I am outside!`。

## const
用于定义一个常量，定义之后常量指向的内存地址不能发送改变，并且定义时一定要赋上初始值。注意是指向内存地址不能改变，不是数据不能改变：
```javascript
const f = {};

// 并没有改变指向，可以成功
f.a = 123;

// 但是数据被冻结，严格模式下会报错
const foo = Object.freeze({});
foo.prop = 123;
```
常量 foo 指向一个冻结的对象，所以添加熟悉时不起作用。除了将对象本身冻结，也可以将对象彻底冻结：
```javascript
var constantize = (obj) => {
  Object.freeze(obj);
  Object.keys(obj).forEach((key, i) => {
    if(typeof obj[key] === 'object'){
      constantize(obj[key]);
    }
  });
}
```