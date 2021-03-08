---
title: Promise
subtitle: es6-promise
date: 2021-01-13 18:32:04
tags:
  - ES6
  - 异步
categories: [web]
---
Promise 是异步编程的一种解决方案，由 ES6 将其写进了语言标准，统一了用法，并原生提供了Promise 对象。Promise 要用于解决前端代码中异步操作的处理，可以将异步操作队列化，使其按照指定的顺序执行，可以很好的解决代码中出现`回调地狱`的问题。

<!-- more -->

## 回调地狱
主要前端代码需要处理多个函数，并且下一个函数的参数为前一个参数的返回值，这样便会造成回调地狱的问题。虽然看着定义有点绕，但是看下面代码就能看出回调地狱的问题了:
```javascript
startRequest1(url, (err1, res1) => {
  if(err1) return throw Error(err1.errorMsg);
  startRequest2(res1, (err2, res2) => {
    if(err2) return throw Error(err2.errorMsg);
      startRequest3(res2, (err3, res3) => {
        if(err3) return throw Error(err3.errorMsg);
        ....
      })
  })
})
```
这样嵌套下去，每一次都需要处理错误，然后处理下一个请求，一旦有一个请求错误，异常也很难处理，并且代码可读性非常的低、也极难维护。

## 特点和缺点
Promise可以链式的处理项目中的异步操作，并提供了一系列的API，可以设置成功、失败等时候的函数调用，这样使得控制异步操作更容易。
Promise主要有2个特点：
1. **对象状态不受外界影响**。Promise主要有3中状态 `Pending`(进行中)、`Fulfilled`(已执行)、`Rejected`(已拒绝)。只有处理异步操作的结果，可以决定是哪一种状态，任何操作都无法改变这个状态。
2. **状态修改后，就不会发送改变，任何时候都可以得到这个结果**。Promise的状态修改只有两种情况：
  1. 从Pending状态变为Resolved状态。
  2. 从Pending状态变为Rejected状态。

只有这两种情况，一旦修改状态便被锁定了，不会在发送变化了。

Promise也不是都是优点，虽然解决了`回调地狱`的问题，但是也是有一些缺点的:
1. Promise一旦创建便无法取消，只能一路走下去。
2. 如果不设置处理函数，无论成功、还是失败都不会返回到外部，换句话说Promise内的错误是无法在外面用 **try{...}catch(){...}** 捕捉的，只能在错误执行函数中执行错误。
3. 状态无法预测，无法得知异步操作具体执行到那一步了。
## 基本用法
一般 Promise 代码为下面的格式：
```javascript
let p = new Promise((resolve, reject) => {
  ...
  if(...){
  	// 成功
  	resolve(data);
  }else{
  	// 失败
  	reject(error);
  }
})
p.then(res => {
	// 请求成功
	...
}, err => {
	// 处理错误
	...
})
```
使用 Promise 对象创建一个 p，执行里面逻辑，然后注册 then 中的成功和失败事件。
### new Promise
- 构造函数接收一个函数作为参数。
- 创建 Promise 时，会自动执行。
- 参数函数主要有 resolve 和 reject 两个参数。
- 在Promise执行过程中调用 resolve 函数状态将变为 fulfilled，调用 reject 时状态变成 rejected，它们可以接收参数，相应的参数都会传递给下一个方法中。

### then
then 主要有两个参数，分别对应两种状态，接收的数据为上一个方法传递的数据：
- 当Promise的状态为 fulfilled 时，会执行第一个函数参数。
- 当Promise的状态为 rejected 时，会执行第二个函数参数。
## 解决回调地狱
上面介绍了一些地狱回调的问题，下面开始用 Promise 解决该问题：
```javascript
startRequest1()
.then(res => startRequest2(res))
.then(res => startRequest3(res))
.then(res => startRequest4(res))
.then(res => startRequest5(res))
...
```
对比下上面地狱回调代码，代码通过Promise会变得非常的简明。	
## 异步并发
如果多个并发的执行，只有获取全部完成后，才会返回结果。用普通的方式来编写那便是下面的代码：
```javascript
let tasks = [getData1, getData2, getData3, getData4, getData5];
let datas = [];

tasks.map(res => {
  res(data => {
  	datas.push(data);
  	if (datas.length === tasks.length) {
      // 已经全部请求完了，此时可以调用回调
    }
  })
})
```
上面通过编辑成功后通过回调传入，一旦执行完成便会进入if。很麻烦啊，Promise 提供更方便的 API：
```javascript
Promise.all([
  getData1,
  getData2,
  getData3,
  getData4,
  getData5
]).then(datas => {
  // 已拿到全部的data，可以处理了
})
```
对比很明显，Promise可以将我们的请求更清晰明了。

## API
### 实例方法
* `then`: 上面介绍了then用法，主要用于链式进行调用。
* `catch`: 主要用于捕获Promise里面的异常，应为Promise内的异常无法用 try 进行捕获。
* `finally`: 无论Promise对象最终是成功还是失败都会去执行其中方法。

### 静态方法
Promise除了提供一些实例方法，还提供了一些静态的方法：
* `all`: 主要处理并发请求。
* `race`: 和上面all相似，但是all是都成功才会调用回调，而race(赛跑)也是并发，但是一旦有一个请求完成，便会立即停止(不管结果本身是成功状态还是失败状态)。
* `resolve`: 返回一个状态为fulfilled的Promise对象，它的参数会传递给下面的回调函数中去。
* `reject`: 和上面的基本同理，只是Ppromise的状态不同。

# 总结
可以看到通过Promise创建实例，然后通过链式调用 .then.then.then 开始编码，这便是Promise的使用形式，可以看到它基本模式是：
* 可以将异步转换为Promise。
* 对象主要有3中状态(Pending(进行中)、Fulfilled(已执行)、Rejected(已拒绝))。
* 通过 .then 进行调用。
* 完成后触发相应的回调。