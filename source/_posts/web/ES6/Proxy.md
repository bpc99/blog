---
title: Proxy
subtitle: es6-promise
date: 2020-09-08 05:48:10
tags:
  - ES6
  - 代理
categories: [web]
---
ES6中推出了 proxy 对象，主要用于在对象外搭建一层拦截，外界对目标对象的某些操作时，必须通过这次拦截。它主要用于**改变某些操作的默认行为**，也可以理解为`Object.defineproperty()`方法的升级版。

<!-- more -->

## 创建
```javascript
var proxy = new Proxy(target, handler);
```
上面 Proxy 对象主要接收两个参数：
1. `target`: 参数表示所要拦截的对象。
2. `handler`: 也是一个对象，用来定制拦截行为。

我们可以通过下面的方式进行使用：
```javascript
let target = {
  name: 'poetries'
};
let logHandler = {
  get: function(target, key) {
    console.log(`${key} 被读取`);
    return target[key];
  },
  set: function(target, key, value) {
    console.log(`${key} 被设置为 ${value}`);
    target[key] = value;
  }
}
let targetWithLog = new Proxy(target, logHandler);
 
// 进入 Proxy,输出: name 被读取 
targetWithLog.name;
// 进入 Proxy,输出: name 被设置为 others
targetWithLog.name = 'others';
 
// 不会进入 Proxy,输出: others
console.log(target.name);
```
* `targetWithLog`读取属性的值时，实际调用`logHandler.get`，在控制台输出信息，并且读取被代理的对象`target`的属性。
* `targetWithLog`设置属性的值时，实际调用`logHandler.set`，也会在控制台输出信息，并且设置代理对象`target`的属性值。

## 实例方法
Proxy 还提供了一系列的操作方法，用于配置相应的拦截。
### apply
主要拦截函数的调用 **call** 和 **apply** 操作，`apply(target, object, args)`主要有3个参数，分别为：
* `target`：目标对象(也就是代理封装的函数)。
* `object`：目标对象上的上下文对象(this);
* `args`：目标对象的参数数组(参数，是个数组，当然也可以不用，使用 arguments 也行)。

例如下面代码：
```javascript
let twice = {
  apply(target, ctx, args) {
    return 'I am the proxy';
  }
};
let target = function() { return 'I am the target'; };

let proxy = new Proxy(target, twice);

// 下面代码都会进入代理，值都为 I am the proxy
proxy(1, 2);
proxy.call(null);
proxy.apply(null);
```
也可以计算一些数据，处理一些参数，例如：
```javascript
function sum(a, b) {
  return a + b;
}
const handler = {
  apply: function(target, that, argumentsList) {
    console.log(`Calculate sum: ${argumentsList}`);
    return target(argumentsList[0], argumentsList[1]) * 10;
  }
};
const proxy1 = new Proxy(sum, handler);
// 正常处理，输出3
console.log(sum(1, 2));
// 进入代理输出 Calculate sum: 1,2，并把结果 * 10返回
console.log(proxy1(1, 2));
```

### get
可以拦截读取的操作。对于不可配置(configurable)、不可写(writable)的属性，不能被代理，硬要通过 Proxy 代理会报错。
例如我们可以读取时，如果存在则返回，不存在则抛出异常：
```javascript
var person = {
  name: "张三"
};
var proxy = new Proxy(person, {
  get: function(target, property) {
    if (property in target) {
      return target[property];
    } else {
      throw new ReferenceError("Property \"" + property + "\" does not exist.");
    }
  }
});

// 正常返回张三
proxy.name
// 不存在,抛出异常
proxy.age
```
并且get方法是可以继承的：
```javascript
let proto = new Proxy({}, {
  get(target, propertyKey, receiver) {
    console.log('GET ' + propertyKey);
    return target[propertyKey];
  }
});

let obj = Object.create(proto);
// 输出GET foo
obj.foo
```
创建 Proxy 对象 proto，然后在通过`Object.create`根据 proto 创建一个新的对象 obj，通过obj访问是可以进入构造器的。
我们还可以读取通过get创建数组，让其读取负数索引(负数索引表示数据倒着数)：
```javascript
function createArray(...elements) {
  let handler = {
    get(target, propKey, receiver) {
      let index = Number(propKey);
      if (index < 0) {
         propKey = String(target.length + index);
      }
      return Reflect.get(target, propKey, receiver);
    }
  };
  return new Proxy(elements, handler);
}
let arr = createArray('a', 'b', 'c');
arr[-1];
```
通过 new Proxy 创建 了一个 Proxy，数据就是函数传输的，而 get 方法判断下标是否小于0，小于0则添加数组长度让其从右侧开始，否则直接反射。

> 上面的 ownKeys 是 es6 提出的反射机制。

### has
主要用于判断对象是否具有某个属性，和`in`操作非常的相似(也是用于判断对象是否包含某个key)。
如果原生对象不可配置、或者禁止扩展，是不能用 has 进行拦截的，不然会抛出异常。
我们可以使用 has 隐藏一些内部属性(一般都是"_"开始)，不被外面的 in 发现：
```javascript
// 代理
const handler1 = {
  has(target, key) {
    if (key[0] === '_') {
      return false;
    }
    return key in target;
  }
};
// 对象
const monster1 = {
   _secret: 'easily scared',
  eyeCount: 1
};
// 封装代理
const proxy1 = new Proxy(monster1, handler1);
// 代理开始查找，有改属性返回 true
console.log('eyeCount' in proxy1);
// 代理开始查找，内部属性被隐藏，查找不到，返回 false
console.log('_secret' in proxy1);
// 查找原生的，没有代理的，可以正常查找
console.log('_secret' in monster1);
```
该方法主要用于隐藏一些内部字段和敏感字段。

### set
拦截对对象属性进行赋值的操作，返回布尔值。如果有的值不能进行赋值、不可写等都不能进行配置。
比如我们有一些字段需要特定的值，需要先验证在赋值，验证失败直接抛出异常：
```javascript
let validator = {
  set: function (obj, prop, value) {
  	// 开启 age 属性的验证
    if (prop === 'age') {
	  // 不是数字
      if (!Number.isInteger(value)) {
        throw new TypeError('The age is not an integer');
      }
      // 数据过大
      if (value > 100) {
        throw new RangeError('The age seems invalid');
      }
    }
    // 成功赋值
    obj[prop] = value;
  }
};

let person = new Proxy({}, validator);

person.age = 60;
// 拿到 60
person.age
// 无法赋值，抛出 The age is not an integer
person.age = '张三';
// 无法赋值，抛出 The age seems invalid
person.age = 110;
```
一旦数据更新便会进入代理，我们可以更新视图数据，而 Vue 中的观察 + 数据拦截，在 Vue  3.0 便是通过 Proxy 替代 Object.defineProperty 进行数据代理。

## 总结
上面介绍了一些方法的简单使用，但是我们其实并不太需要这些的用法，因为有些 API 注定不会常用，只需有些印象，出现这种问题时，知道往那方面去学习。