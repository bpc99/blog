---
title: JavaScript原型链
date: 2021-03-11 16:19:23
subtitle: prototype-chain
tags:
  - JavaScript
categories: [web]
---
JavaScript 中数据类型基本分为基本类型与引用类型，基本类型包括 String、Number、Boolean、undefined、Null以及 ES6 中新提出的 Symbol，引用类型多为一些对象，比如 Object、Array、Function 等，在 ES6 中又添加了一个新的引用对象 **class** 对象，虽然使用方式与其它的语言十分的相似，但其内部还是通过 `Function` 实现，只是另外借助了`原型对象`、`原型链`两个概念。

<!-- more -->

## 普通对象与函数对象
在 JavaScript 中的数对象都可以分为可以分为 **普通对象** 和 **函数对象**，通过 Function 实例的对象均为函数对象，反之则为普通对象，但是 Object 和 Function 为函数对象。
```javascript
var o1 = {};
var o2 =new Object();
var o3 = new f1();

function f1(){};
var f2 = function(){};
var f3 = new Function('str','console.log(str)');

console.log(typeof Object); //function
console.log(typeof Function); //function

console.log(typeof f1); //function
console.log(typeof f2); //function
console.log(typeof f3); //function

console.log(typeof o1); //object
console.log(typeof o2); //object
console.log(typeof o3); //object
```

## 构造函数
每一个对象都内置一个 `constructor`属性，该属性指向创建其的函数对象。例如我们有下面的代码：
```javascript
function Person(name, age) {
  this.name = name;
  this.age = age;

  this.sayName = function () {
    alert(this.name)
  }
}
var person1 = new Person('world', 28);

// true
console.log(person1.constructor === Person);
```
所以我们便可以得出：`constructor 属性返回创建此对象的函数的引用`。

## 原型对象
JavaScript 中每一个 **函数对象** 都包含着一些预定义的属性，例如都内置一个 `prototype`属性，其会返回一个对象，而这个对象便称之为`原型对象`。
其实就是一个普通的 JS 对象，主要目的是保存着实例共享的方法，内置了两个属性：
1. `constructor`：指回构造函数。
2. `___proto___`：因为该属性一般指向构造函数的原型对象，所以这里指向`Object.prototype`。

注意：**`prototype.constructor 和上面的构造函数是不同的。`**
千万不要认为它两名字一样，就指向同一对象了，例如上面代码，最后添加一行：
```
Person.prototype.constructor === Person.constructor
```
结果一定为 false，主要是因为：**`prototype.constructor`返回当前函数引用，而`constructor`返回创建此对象的函数的引用**，所以将代码改为下面的代码是正确的：
```javascript
Person.prototype.constructor === person1.constructor
```
只有这样`prototype.constructor`和`constructor`才会同时指向`Person`。

## ___proto___
JavaScript 中任何的对象数据都会内置一个`___proto___`属性，其返回 **构造函数的原型对象**。
可能听着有些绕，但是明白了上面两个概念，其实很容易理解，例如上面代码中：
**person1** 有个内置 __proto__ 属性，而它的构造器返回 **Person** 对象，那么构造函数的原型对象是 **Person.prototype**，那么就可以写出 `person1.__proto__ === Person.prototype`。

其实到这一步以及可以发现以及应约见构建出一条链子出来了，而这条链，便是`原型链`。

## 原型链
上面以及介绍完原型链的定义了重要的定义，那么可以看下这些问题进行检测：
1.  **person1.__proto__** 等于什么？`person1.__proto__ === Person.prototype`。
2.  **Person.__proto__** 等于什么？`Person.__proto__ === Function.prototype`。
3.  **Person.prototype.__proto__** 等于什么？`Person.prototype.__proto__ === Object.prototype`。
4.  **Object.__proto__** 等于什么？`Object.__proto__ === Function.prototype`。
5.  **Object.prototype.__proto__** 等于什么？`Object.prototype.__proto__ === null`。

其实原型链就是一直深扒`__proto__`属性，一直到找到我们想要的或为 null。

例如我们需要`person1`中的`toString`方法，其回先找`person1.__proto__`也就是上面的`Person.prototype`发现其只有一个 **sayName** 没有我们找到，回继续探索`Person.prototype.__proto__`也就到了`Object.prototype`找到结束并返回，否则知道其为 null 为止。

## 总结
其实总结起来很简单：
1. 任何对象都拥有一个`__proto__`属性，该属性返回其构造函数的原型对象。
2. 只有函数对象`prototype`属性，目的就是为了属性共享，其返回了一个该属性的原型对象。

另外在网上发现这一张有趣的图片可以进行研究：

![](https://img.bipch.cn/2021/03/12/c2622471d05cc.jpg)