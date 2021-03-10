---
title: Es6-Es12新特性
date: 2021-03-10 18:44:41
subtitle: es6-es12
tags:
  - ES6
categories: [web]
---
自 2015 年推出 ES6 规则之后，每个一年几乎都会推出一些新增的特性，这些特性能为开发过程中提供许多的帮助，下面简单总结下自 Es6(2015)~Es12(2021) 推出的新特性，当然之后记录比较常用的，那些不常用的使用时再去查询也不迟。

<!-- more -->

## Es6
### 1. 类(class)
这里一定要注意，JS 并没有 Class 的概念，就算是 Es6 新增的其本质任然是 Function + 原型链。
使用方式如下：
```javascript
class Person{
  constructor( name ){
    this.name = name;
  }

  toString(){
    return 'My name' + this.name;
  }
}

const person = new Person('橙子');
person.toString();
```
### 2. let 和 const
```javascript
let name = '橙子';
const list = [];
```
### 3. Arrow
```javascript
const sum = (a, b) => a + b;
// 3
sum(1, 2);
```
### 4. Module
```javascript
// 导出
export const sum = (a, b) => a + b;
// 导入
import { sum } from '...';
// 3
console.log(sub(1, 2));
```
### 5. 模板字符串
```javascript
const name = '橙子';
const str = `Your name is ${name}`;
```
### 6. 解构赋值
```javascript
let [a, b] = [6, 9];
```
### 7. 参数默认值
```javascript
const sum = (a = 1, b = 2) => a + b;
// 3
sum();
```
### 8. 展开
```javascript
// [1, 2, 3]
console.log([1, ...[2, 3]]);
```
### 9. 数据简写
```javascript
const name='橙子',
const obj = { name };
```
### 10. Promise
```javascript
console.log(0);
new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve('橙子');
  }, 0);
}).then(result => { console.log(result); });
```
结果为 0、橙子，如果没有看出可以了解下微观和宏观任务。
### 11. symbol
Es6 新增的基本数据类型，它和 **let** 和 **const** 不同，其为一种基本数据类型，也是除了 String、Number、Boolean、undefined、Null、还新增了 Symbol  用于表示独一无二的。
例如：
```javascript
let sy = Symbol("KK");

// Symbol(KK)
console.log(sy);
// "symbol"
typeof(sy);
 
// 即使定义一样，也不可能相等
let sy1 = Symbol("kk"); 
// false
sy === sy1;
```

## Es7
### 1. Array.prototype.includes()
判断字符串是否包含指定的子字符串：
```javascript
var str = "I like oranges";
// true
var n = str.includes("oranges");
```
### 2. 指数运算
```javascript
// 8
2**3;
```

##Es8
### 1. async/await
异步化编程的解决方案，最终返回的为 Promise 对象。
```javascript
async queryPage(){
  // await 异步任务
  const res = await queryPage();
  //TODO: 逻辑处理
}
```
### 2. Object.values()
返回给定对象自身的所有可枚举属性值的数组：
```javascript
var obj = { love: 'orange', user: 'I' };
// ['orange', 'I']
console.log(Object.values(obj));
```
### 3. Object.entries()
返回一个给定对象自身可枚举属性的键值对数组：
```javascript
var obj = { love: 'orange', user: 'I' };
// [ ["love", "orange"], ["user", "I"] ]
console.log(Object.entries(obj));
```
### 4. String padding
在指定位置使用空格填充字符串：
```javascript
// padStart
'orange'.padStart(10); // "    orange"
// padEnd
'hello'.padEnd(10) "orange    "
```

## Es9
### 1. 异步并发
运行 await 和 for...of 联合使用，并发执行异步操作，说实话这功能是真的鸡肋：
```javascript
async function process(array) {
  for await (let i of array) {
    //TODO: 逻辑处理
  }
}
```
### 2. Promise.finally()
无论 Promise 成功与否都会去执行：
```javascript
Promise.resolve().then().catch(e => e).finally();
```

## Es10
### 1. Array.prototype.flat() 和 Array.prototype.flatMap()
作用都一样都是用于将数组展开，但不同的是两个实现方式。`flatMap()`方法首先使用映射函数映射每个元素，然后将结果压缩成一个新数组，而`flat()`方法创建一个新数组，其中所有子数组元素都以递归方式连接到该数组中，直到达到指定的深度为止。所以从实现方式来看`flatMap()`的效率更快。
```javascript
const arr1 = [0, 1, 2, [3, 4]];

// [0, 1, 2, 3, 4]
console.log(arr1.flat());
// [0, 1, 2, 3, 4]
console.log(arr1.flatMap(x => x));
```
### 2. String.trimStart() 和 String.trimEnd()
去除字符串首位空格，用处也不会有太大，个别情况下才会进行使用。

## ES11
### 1. globalThis
获取全局的 this 对象：
- 浏览器：window
- worker：self
- node：global

可能由于是近期推出的，至今都没有使用过。

## ES12
### 1. replaceAll
将字符串中的指定字符替换，返回新的字符串：
```javascript
const str = 'orange';
// range
str.replaceAll('o', '');
```
### 2. 数字分隔符
数字之间的间隔字符串，通过 _ 分割数字，可以添加数字的可读性：
```javascript
const money = 1_000_000_000;
// 作用是一样的
const money = 1000000000;
```