---
title: HTTP缓存
subtitle: http-cache
date: 2021-03-25 14:04:53
tags:
  - http缓存
categories: [ http ]
---
前端的缓存大致分为两大类，一类是浏览器缓存、另一类为 http缓存。而 **http缓存** 虽然分为 `强缓存` 和 `协商缓存` 两种机制，但是其都是从客户端缓存中读取资源，主要区别为区别是 **强缓存不会发请求，协商缓存会发请求**。

<!-- more -->

## 什么是HTTP缓存 ？
每当浏览器向服务器端请求资源时，都会先抵达浏览器缓存，如果有需要请求资源缓存时，便从浏览器的缓存中获取该资源而不会从服务器重新提取资源。

当然请求资源的形式一般都为 **get** 方式，而对于其它方式请求的资源是无能为力的，所以下面的请求缓存都是在 **get** 请求下发生的。

在我们第一次请求服务器时，服务器返回资源，并在 **respone header** 头中回传资源的缓存参数。当再次请求该资源时，浏览器判断这些请求参数，命中强缓存就直接 200，否则就把请求参数加到 **request header** 头中传给服务器，看是否命中协商缓存，命中则返回 304，否则服务器会返回新的资源。

## 强缓存
在缓存数据未失效的情况下，会直接使用浏览器中的缓存数据，不会向服务器发送请求。我们可以在 chrome 控制台中 Network 选项中可以看出状态码都是200，并且 size 为 disk cache 或 memory cache：

![](https://img.bipch.cn/2021/03/27/e6a0785611a4a.png)

可以看出经过缓存的文件通过几十毫秒可以请求完成，而其余的即使再小也是几百毫秒，所以其对网站的性能和加载速度都有着很大提升，但是如果此时服务器端的资源修改了，页面上是拿不到最新的资源的，因为它不会再向服务器发请求了。

### header
1. **Pragma**
`该属性在 HTTP 1.1 之后便废弃了`，有且只有一个值：**no-cache**，虽然字面意义是 “无缓存”。但它实际上的机制是，仍然对资源使用缓存，但每次在使用缓存之前必须向服务器对缓存资源是否为最新进行验证。
2. **Cache-Control**
`该属性只适用于 HTTP 1.1 之后`，值可以为：
- **no-cache**：和上面的同理。
- **no-store**：不使用任何缓存。
- **max-age**：缓存时长，单位 s。(为 0 时会走 协商缓存)
- **public/private**：响应是否可以被多个用户使用。
- **must-revalidate**：和 **no-cache** 相似都是使用缓存之前必须向服务器对缓存资源进行验证。但不同的是：**no-cache** 并不会去管缓存时间是否过期，而 **must-revalidate** 如果缓存时间过期，是必须重新发起请求的。

	默认 **private**。
3. **Expires**
`过时的产物，它的存在只是一种兼容性的写法`，用于描述过期时间，浏览器再次加载资源时，如果在这个过期时间内，则命中强缓存。

虽然属性好像很多但是：`Expires`是过时的产物，其优先性是最低的。而`Pragma`则是`Cache-Control`在 HTTP 1.1 之前的兼容写法(因为 Cache-Control 是在 HTTP 1.1 之后推出的)，但是在 HTTP 1.1 中 `Pragma` 的优先级是高于`Cache-Control`的。

### Pragma 和 Cache-Control
我们可以使用 koa2 模拟下`Pragma`与`Cache-Control`的优先级，假设需要读取两个文件，我们使用 Node + koa 搭建服务路由：
```javascript
app.use((ctx) => {
  console.log(`Process ${ctx.request.method} url ${ctx.request.url}`);
  
  if (ctx.request.url === "/") {
    const html = fs.readFileSync(path.join(__dirname, "page/index.html"), "utf-8");
    ctx.type = "text/html;charset=utf-8";
    ctx.body = html;
  }
  
  if (ctx.request.url === "/script.js") {
    const script = fs.readFileSync(path.join(__dirname, "assets/script.js"), "utf-8");
    //? 配置 HTTP 缓存 Header
    ctx.set("Cache-Control", 'max-age=60');
    ctx.type = "text/javascript;charset=utf-8";
    ctx.body = script;
  }
  
  if (ctx.request.url === "/link.css") {
    const css = fs.readFileSync(path.join(__dirname, "styles/link.css"), "utf-8");
    //? 配置 HTTP 缓存 Header
    ctx.set('Pragma', 'no-cache');
    ctx.set("Cache-Control", 'max-age=60');
    ctx.type = "text/css;charset=utf-8";
    ctx.body = css;
  }
});
```
非常简单的一个 koa2 配置，没有任何其它插件，为两个文件各提供一种 http 缓存配置，其差别在于：JS 的缓存中没有配置 Pragma，而 css 中多一个`ctx.set('Pragma', 'no-cache')`的配置。
第一次打开界面会是这样的：

![](https://img.bipch.cn/2021/03/27/02456d6c127ed.png)

此时为第一次加载界面，并没有任何缓存，当我们 60s 内再次打开开该界面，就会出现：

![](https://img.bipch.cn/2021/03/27/6b2a395116a38.png)

可以明显看出 JS 已被缓存，但是 CSS 并未缓存，造成该问题主要原因便是 HTTP 1.1 中 `Pragma`与`Cache-Control`同时存在时，前者优先级高于后者，致使每次在使用缓存之前必须向服务器对缓存资源是否为最新进行验证。

### memory cache 与 disk cache
强缓存会出现两种情况：
1. **memory cache**：从内存中读取缓存，一般缓存更新频率较高资源。
2. **disk cache**：从磁盘中读取缓存，一般缓存更新频率较低的资源。

注意：这只是 chrome 浏览器的缓存策略，我们也不需要去配置什么，只适用于 chrome，其余浏览器只会标记出是否缓存，并没有相关的情况，例如 Firefox：

![](https://img.bipch.cn/2021/03/27/e5fb16f0cf80a.png)

## 协商缓存
第一次请求资源时，如果资源没有走强缓存，那么后面继续请求时会和服务器进行协商，判断资源是否已经更新，若资源没有更新服务器会返回 `304` 状态码，浏览器识别 304 使用缓存中的数据，这样减少了服务器压力，而如果更新则返回 `200` 状态码并将最新的资源一并返回。
### header
1. **ETag 和 If-None-Match**
Etag 表示资源请求时的**唯一标识**，默认使用 hash 算法，可精确判断资源是否被修改，服务器会在 **response header** 中返回，只要资源有变化，Etag 就会重新生成。
浏览器下次再次请求该资源时，会将上次的 Etag 值放到 **request header** 里的 If-None-Match 中。
服务器接受到 If-None-Match 的值后，会拿来跟该资源文件的 Etag 值做比较，如果相同，则表示资源文件没有发生改变，命中协商缓存。
2. **Last-Modified 和 If-Modified-Since**
Last-Modified 是该资源文件最后一次更改时间，服务器会在 **response header** 里返回。
浏览器下次再次请求该资源时，将值放到 **request headr** 里的 If-Modified-Since 中。
这样经过对比，如果相同则命中协商缓存。

> 在精确度上，Etag 要优于 Last-Modified，Last-Modified 的时间单位是秒，如果某个文件在1秒内改变了多次，那么他们的 Last-Modified 其实并没有体现出来修改，但是 Etag 每次都会改变确保了精度
> 在性能上，Etag 要逊于 Last-Modified，毕竟 Last-Modified 只需要记录时间，而 Etag 需要服务器通过算法来计算出一个hash值。
> 在优先级上，服务器校验优先考虑 Etag。
> 所以，两者各有长短，互补。

### 手动搭建
虽然看上去很麻烦，但实现起来很简单，我们只需记住：**ETag** 是资源的唯一标识，如果 response header 返回该字段，下次浏览器请求该资源自动在 request headr 上加上 **If-None-Match** 值便是该唯一标识，而 **Last-Modified** 和 **If-Modified-Since** 也是同样效果，如果后台经过对比认为资源没有改变则返回 `304`，否则返回`200`和新资源。

**注意：ETag 是文件唯一标识，默认为 hahs 算法，但是我们可以用任意算法替换，例如 md5，其不限制与一种算法。**

我们使用 koa2 可以很简单模拟出这种效果：
```javascript
app.use(async (ctx) => {
  console.log(`Process ${ctx.request.method} url ${ctx.request.url}`);
  
  if (ctx.request.url === "/") {
    const html = fs.readFileSync(path.join(__dirname, "page/index.html"), "utf-8");
    ctx.type = "text/html;charset=utf-8";
    ctx.body = html;
  }
  
  if (ctx.request.url === "/script.js") {
    const script = fs.readFileSync(path.join(__dirname, "assets/script.js"), "utf-8");
    // 使用 md5 生成 eTag
    const eTag = md5(script);
    // 判断 request headers 中是否包含 if-none-match，以及文件是否修改
    if (!!ctx.request.headers['if-none-match'] && ctx.request.headers['if-none-match'] === eTag) {
      ctx.status = 304;
    } else {
      ctx.set('ETag', eTag);
      ctx.body = script;
    }
  }
});
```
上述代码只是添加了 **ETag** 相关验证，并没有添加 **Last-Modified**验证，如果需要自行添加即可。
当第一次访问资源时会使用 md5 生成资源的 ETag，若再次访问该资源会自动携带 if-none-match 请求头，我们对其进行验证比对，若通过验证直接返回`304`状态码，否则返回`200`(默认)和资源。

第一次请求资源：

![](https://img.bipch.cn/2021/03/28/7a2ff71e43ac9.png)

可以看出 **第一次请求 size 大小为 `414kb`**，之后不修改资源，刷新界面进行下一次的请求：

![](https://img.bipch.cn/2021/03/28/e8706eb0abc70.png)

可以看出 **后面的请求 size 大小为 `90b`**，说明其明显降低了服务器的一些压力，而如果我们修改资源中的部分代码后刷新文件便会出现：

![](https://img.bipch.cn/2021/03/28/429821b06f850.png)

可以看出由于资源修改，其唯一标识符发生了变化，导致资源会被重新请求。

**注意：协商缓存`可能并不会`减少资源的访问速度，因为其内部包含着对于资源唯一标识以及修改时间的验证，这些无疑降低了访问的速度，但是`协商缓存可以有效的减小服务器返回资源的大小`，这无疑为服务器分摊了很多的压力。**

## 浏览器缓存过程
1. 首次资源加载服务器返回 `200` 状态码和资源，浏览器将资源文件从服务器上请求下载下来，并把 **response header** 中的数据(Cache-Control、Expires、ETag...)一并缓存；
2. 再次请求该资源时，先判断是否含有强缓存，将当前请求和上一次该资源 `200` 请求时间差与Cache-Control 中的 max-age 对比，若没有过期，命中强缓存，不发请求直接从本地缓存读取该文件。而若含有 Expires 属性则就算命中强缓存，也会向服务器验证资源是否为最新；
3. 如果时间过期，则向服务器发送 header 带有 If-None-Match 和 If-Modified-Since 的请求；
4. 服务器收到请求后，优先对比 Etag，若经过比对发现资源没有修改，则命中协商缓存，返回 `304`；否则：返回新的资源带上新的 Etag 值并返回`200`；
5. 如果服务器收到的请求没有 Etag 值，则以 If-Modified-Since 进行比对，一致则命中协商缓存，返回304；否则：返回新的 last-modified 和文件并返回`200`；

## 如何不使用缓存
1. **ctrl+F5**
强制刷新，跳过强缓存和协商缓存，直接从服务器拉取资源。
2. **Cache-Control**
缓存相关的配置，如果禁止缓存，可以将其设置为 `no-store` 表示禁止一切缓存。
3. **Expires**
上面介绍过，其表示缓存过期时间，但是此值已被遗弃，如果您项目支持此值，可以将其设置为历史时间，但需要注意其优先度极低，很容易被覆盖。
4. **hash 或 随机数**
缓存会先判断该资源是否被请求过，而如果我们在每个资源后面都加上 hash 值 或 随机数，这样缓存也是无效的。

## 用户对地址栏的控制
### 输入 url 访问
此种方式属于正常的用户行为，将会触发浏览器缓存机制【浏览器发起请求，按照正常流程，本地检查是否过期，或者服务器检查新鲜度，最后返回内容】
### F5
浏览器会设置max-age=0，跳过强缓存判断，会进行协商缓存判断，也就意味着其结果要么是`304`或者`200`(资源存在)。
### ctrl+F5
跳过任何缓存，重新拉取最新的资源。返回的结果一定为 200(资源存在)。

## 总结
这便是 HTTP 缓存相关的知识，不管是 强缓存 还是 协商缓存 都各有特点：
- 强缓存虽然可以不去请求服务器获取资源，但是若服务器资源改变其不会加载到最新的数据。
- 协商缓存 虽然可以降低服务器中响应资源的大小，但其内涵了大量的判断，有时起不到优化作用。

所以真正使用时还需要相互配合。

## 参考资料
- [一文读懂http缓存](https://www.jianshu.com/p/227cee9c8d15)
- [HTTP 缓存机制](https://zhuanlan.zhihu.com/p/58685072)