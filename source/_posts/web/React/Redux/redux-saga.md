---
title: redux-saga
subtitle: react-redux-saga
date: 2021-01-26 18:56:17
tags:
  - React
  - Redux
categories: [web]
---
`redux-saga` 是一个用于管理应用程序副作用的 redux 中间件，它的目标是让副作用集中处理，然后方便以后的维护和扩展。它和其他解决异步中间件不同，它像进程一样可以主应用程序启动，暂停和取消，也能访问完整的 redux state、dispatch、redux action。

<!-- more -->
## 流程
redux-saga 通过监听 action，只需我们发送了指定的 action，便会进行拦截。转换为流程图如下：

![redux-saga流程图.JPG](https://cdn.jsdelivr.net/gh/bpc99/assets@master/redux/flow/redux-saga.jpg)

基本可以把 saga 分解为 Worker 和 Watcher：`Saga = Worker + Watcher`。

## 简单的Hello Word
虽然上面说的很难理解，但是通过下面代码可以很好的理解：
### 创建 Store 添加中间件
```javascript
// 引入saga中间件
import createSagaMiddleware from 'redux-saga';
// 创建saga
const sagaMiddleware = createSagaMiddleware();
// 项目添加 saga 中间件
const store = createStore(
    reducer,
    composeWithDevTools(
        applyMiddleware(sagaMiddleware)
    )
);
```
### 创建监听
redux-saga 主要工作方式便是监听指定的 action，这一步还是比较重要：
```javascript
import { takeEvery, put, delay } from 'redux-saga/effects';
// 创建新的任务
function* incrementAsync() {
    yield delay(2000);
    yield put({ type: 'INCREMENT' })
}
// 创建监听函数
export function* watchIncrementAsync() {
    // 监听 INCREMENT_ASYNC ，派发到 incrementAsync 任务
    yield takeEvery('INCREMENT_ASYNC', incrementAsync);
}
```
### 启动监听
简单创建完成后，需要在根目录启动 redux-saga 的监听：
```javascript
// 收集到所有的监听
import { all, fork } from 'redux-saga/effects';
import * as userSagas from './user';

export default function* rootSage() {
    yield all([
        ...Object.values(userSagas)
    ].map(fork));
}

// 根目录启动监听
sagaMiddleware.run(rootSaga);
```

## es6 Generator
主要解决异步执行造成的 `地狱回调` 问题，可以暂时让函数的执行流挂起。

在线验证工具：[jsbin](https://jsbin.com/?js,console)

### 例子
简单的一个示例了解下 Generator 执行过程：
```javascript
function* Generator(){
  yield 'start';
  yield 'hello word';
  return 'end';
}
let Gen = Generator();
console.log(Gen.next());
console.log(Gen.next());
console.log(Gen.next());
```
其打印结果为：
```javascript
{done: false, value: "start"}
{done: false, value: "hello word"}
{done: true, value: "end"}
```
可以看到当我们创建函数时不会立即执行，当我们调用 `next` 方法时，函数会开始执行，一直到`yield` 暂停执行，挂起函数，直到下次调用 `next` 方法。函数运行返回值为一个json，done 表示是否结束，value 是返回值。

### 传递参数和接收参数
当我们代码为下面样子时：
```javascript
function* Generator(){
  let name = yield 'start';
  console.log(name);
  let age = yield 'hello word';
  console.log(age);
  return 'end';
}
let Gen = Generator();
console.log(Gen.next());
console.log(Gen.next('blog'));
console.log(Gen.next(23));
```
其打印结果为：
```javascript
{done: false, value: "start"}
"blog"
{done: false, value: "hello word"}
23
{done: true, value: "end"}
```
可以看到 `next` 方法参数传递给 **上一个** `yield` 中，达到赋值的效果。
   
### 异步转同步
那么我们为什么要使用 Generator，其实主要便是为了解决项目中异步代码很容易造成`地狱回调`，而我们使用 Generator 可以很好的处理异步：
```javascript
function *gen() {
    var posts = yield fetch("https://jsonplaceholder.typicode.com/posts");
    console.log('posts', posts[0].title);
    var users = yield fetch("https://jsonplaceholder.typicode.com/users");
    console.log('users', users[0].name);
}
function run(generator) {
	var myGen = generator();
	function handle(yielded) {
        if (!yielded.done) {
            yielded.value.then(function(response){
                return response.json();
            }).then(function(json) {
                return handle(myGen.next(json));
            })
        }
	}
	return handle(myGen.next());
}
run(gen);
```

## API
### takeEvery
很基础的一个方法，用来监测监听 action，每次发送 action 都会进行监听，拦截指定的 action 并分配新的任务：
```javascript
import { takeEvery } from 'redux-saga/effects';
export function* watchIncrementAsync() {
    // 监听拦截 INCREMENT_ASYNC action，派发新的任务
    yield takeEvery('INCREMENT_ASYNC', incrementAsync);
}
```
### put
用来发送新的 action 请求，内部是对 Redux 中 dispath 的一个封装，也是需要接收一个 action 参数：
```javascript
import { put } from 'redux-saga/effects';
function* incrementAsync() {
    yield put({ type: 'INCREMENT' })
}
```
### delay
将程序延迟指定时间后执行，相当于一个延迟函数：
```javascript
import { put, delay } from 'redux-saga/effects';

function* incrementAsync() {
    yield delay(2000);
    yield put({ type: 'INCREMENT' })
}
```
这样任务延迟 2 秒后会执行 put 发送一个 action。
### takeLatest
和上面的 `takeEvery` 基本相同，但是 `takeEvery` 如果这次异步还没有结束，此时若发送下一次请求，`takeEvery` 会累计放入执行队列中依次执行，而 `takeLatest` 不是，它会以取消前面的action，以最后一次发送的 action 为准：
```javascript
import { takeLatest } from 'redux-saga/effects';
export function* watchIncrementAsync() {
    yield takeLatest('INCREMENT_ASYNC', incrementAsync);
}
```
使用方式和 `takeEvery` 基本相同。
### call
主要是为了帮我们的函数参数作为 call 的参数传入，返回值是一个 js对象。call 作用主要是为了方便我们测试代码，和规范我们项目代码：
```javascript
import axios from 'axios';
import { takeLatest, put, call } from 'redux-saga/effects';
function* incrementAsync() {
    // 普通的函数
    const a = yield axios.get("https://jsonplaceholder.typicode.com/users");
    // 使用call后
    const b = yield call(axios.get, "https://jsonplaceholder.typicode.com/users");
    yield put({ type: 'INCREMENT' });
}
```

### All
all 给我们提供了一种并发执行多个异步请求的操作。如果我们接口需要并发执行，则需要使用这个方法：
```javascript
function* fetchUser() {
    const user = yield call(axios.get, "https://jsonplaceholder.typicode.com/users");
    console.log(user);
}
function* incrementAsync() {
    yield all([
        fetchUser(),
        fetchUser(),
    ]);
    yield put({ type: 'INCREMENT' });
}
```
### fork
非阻塞式调用：上面介绍了 call 的使用方式，但是相对于 generator 来说，**call是阻塞式** 的，只有上一个 promise 返回才会执行下一个。而 **fork是非阻塞式** 的，是并发执行所有任务，不用等到上一个任务的promise：
```javascript
import { takeLatest, put, call, fork } from 'redux-saga/effects';
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
function* incrementAsync() {
    yield fork(delay, 2000);
    yield put({ type: 'INCREMENT' });
}
```
根据结果可以看出程序并不会延迟 2 秒后发送 action，而是延迟和发送并发执行，当我们把fork变为call时：
```javascript
yield call(delay, 2000);
```
程序会等待2秒后会发送请求。
### cancel
用于取消 fork 还未结束的任务，防止 fork 任务等待时间过长引起其他一些不必要的错误：
```javascript
function* increment () {
    while(true){
        console.log('11111');
        yield delay(1000);
        console.log('22222');
    }
}
function* incrementAsync() {
    const task = yield fork(increment);
    yield cancel(task);
    yield put({ type: 'INCREMENT' });
}
```
### race
当我们需要并发执行多个任务，并不一定需要等待所有操作完成，只需有一个操作完成即可继续执行下面的方法。这就是race方法的用处，它可以并发执行多个请求，只要有一个请求返回，race就正常返回请求，并且取消其余的请求：
```javascript
const { a, b } = yield race({
    a: call(axios.get, 'https://jsonplaceholder.typicode.com/users'),
    b: call(axios.get, 'https://jsonplaceholder.typicode.com/todos')
});
console.log(a, b);
```
## 总结
redux-saga 最为 redux 一个非常优秀的中间件，可以为 redux 解决很多问题，包括异步 action、分离逻辑等，在开发中还是很好用的。