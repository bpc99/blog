---
title: Vue $set
date: 2021-01-14 18:25:49
subtitle: vue-set
tags:
  - Vue
categories: [web]
---
在 Vue 中其核心便是`数据劫持-数据订阅`，数据劫持主要劫持 data 对象的所有 property，并使用 `Object.defineProperty` 把所有 property 添加  getter/setter 方法。但是由于 Object.defineProperty 不能劫持整个对象，只能劫持对象的一个个属性，并且不能监听数组、对象属性等，所以在 Vue 中数组或者对象属性改变是监听不到的，而`$set`便是为了解决这些问题。

<!-- more -->
## defineProperty
Object.defineProperty 方法主要用于劫持 JavaScript 对象，当我们访问相应对象时，会执行相应的逻辑：
```javascript
let object1 = {name: '123'};

Object.defineProperty(object1, 'name', {
  get(){......},
  set(){......},
});

object1.name = 77;

console.log(object1.name);
```
通过上述代码便监听了 object1 的 name 属性，一旦修改或读取便会调用相应的 getter/setter 方法，一旦数据有修改 defineProperty 便会监听到，执行一系列逻辑。
## defineProperty 监听对象
在 Vue 官网却有着下面的一句话：**由于 JavaScript 的限制，Vue 不能检测数组和对象的变化。尽管如此我们还是有一些办法来回避这些限制并保证它们的响应性。**
造成该问题的原因便是因为 defineProperty 不能监听整个对象，只能遍历对象的各个属性，例如我们有下面的数据：
```javascript
let object1 = {
  name: '123', 
  age : 123
};
```
监听这种数据，只能递归调用：
```javascript
// 递归，确保每个属性都被监听
function Observer(data) {
  if (!data || typeof data !== 'object') {
    return;
  }
  Object.keys(data).map(key => {
    defineReactive(data, key, data[key]);
  });
}

// 监听指定数据
function defineReactive(data, key, val) {
  // 确保子元素监听
  Observer(val);
  // 开启监听
  Object.defineProperty(data, key, {
    // 可枚举
    enumerable: true,
    // 不可删除
    configurable: false,
    get: function () {
      return val;
    },
    set: function (newVal) {
      console.log('我捕获到了数据变化: ', val, ' --> ', newVal);
      val = newVal;
    }
  });
}

// 监听的数据
const obj = {
  name: '123', 
  age : 123
};
Observer(obj);
```
这样递归才能实现对象的监听，但是这样也造成了：**数组** 和 **对象** 新增属性都是无法触发 setter 的(除了数组的 `push`、`pop`、`shift`、`unshift`、`splice`、`sort`、`reverse` 因为它们都修改原数据)。
而 Vue 并不会去解决这个问题，因为这是 defineProperty 方法的特性，刻意解决只会造成性能的浪费，而为了解决这个问题，便提出了 `$set` 方法。
## $set
因为 Vue 提倡使用`$set` 进行数组等数据的修改，其主要接收 3 个参数：

1. `target`：需要添加属性的对象，也就是我们要在那个对象上面添加属性。
2. `key`：新增属性的 key，也就是我们新增属性的索引。
3. `val`：新增属性的值，我们要添加进的值。

我们打开其源码，位于：**src/core/observer/index.js**
```javascript
function set(target: Array < any > | Object, key: any, val: any): any {
    // 主要用于判断是不是基本数据类型
  if (process.env.NODE_ENV !== 'production' &&
    (isUndef(target) || isPrimitive(target))
  ) {
    warn(`Cannot set reactive property on undefined, null, or primitive value: ${(target: any)}`)
  }

  // 数组的处理
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    target.length = Math.max(target.length, key)
        // 利用  splice 实现数组替换
    target.splice(key, 1, val)
    return val
  }

  // 对象，并且该属性原来已存在于对象中，则直接更新
  if (key in target && !(key in Object.prototype)) {
    target[key] = val
    return val
  }
  // vue给响应式对象(比如 data 里定义的对象)都加了一个 __ob__ 属性，
  // 如果一个对象有这个 __ob__ 属性，那么就说明这个对象是响应式对象，我们修改对象已有属性的时候就会触发页面渲染。
  // 非 data 里定义的就不是响应式对象。
  const ob = (target: any).__ob__
  if (target._isVue || (ob && ob.vmCount)) {
    process.env.NODE_ENV !== 'production' && warn(
      'Avoid adding reactive properties to a Vue instance or its root $data ' +
      'at runtime - declare it upfront in the data option.'
    )
    return val
  }
  // 不是响应式对象
  if (!ob) {
    target[key] = val
    return val
  }
  // 是响应式对象，进行依赖收集
  defineReactive(ob.value, key, val)
  // 触发更新视图
  ob.dep.notify()
  return val
}
```
总结下上面的流程大致如下：

1. 首先判断数据是否为**对象**类型，如果是普通类型的属性，则会抛出异常。
2. 判断是否为**数组**，并且 key 值是否为有效的，如果成功则选择数组长度和 key 值获取最大的数值，作为数组新的 length 值，并且使用 splice 方法进行替换。
3. 判断数据值是否为响应的 _ob_：
	- 如果是 Vue实例，直接不行，抛出错误。
	- 如果不是响应数据，就是普通的修改数据对象操作。
	- 如果是响应数据，那就通过 Object.defineProperty 进行数据的劫持。
4. 通知 DOM 进行数据更新。
