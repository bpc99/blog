---
title: Error-first
subtitle: error-first
date: 2021-01-17 01:50:47
tags:
  - error-first
categories: [Node]
---
在 Node 这么火的今天，其成功离不开内部高效的事件循环以及异步I/O，整个 Node 的设计从上到下都遵循着异步的概念。而 Node 处理异步指定的标准便是`error-first`也被称之为`错误优先`。
<!-- more -->

## error-first
因为 Node 中存在大量的异步，而处理异步最多的还是传入callback，对于异步任务，必须要指定任务完成后需要执行的回调函数，才能准确的接收到异步任务的执行结果。而随着callback回调越来越多，其传参也越来越多样化，Node 觉得必需对callback指定一个标准，这个标准便是`error-first`：

1. callback函数的第一个参数为 error 对象保留。如果发生异常，异常信息会被放在第一个 err 参数返回。
2. callback函数的第二个参数保留给成功的响应数据。如果没发生异常，err参数会传递 null，第二个参数为成功后的返回数据。

具体代码，可以看 Node fs 提供的回调方式：
```javascript
fs.readFile('/foo.txt', function(err, data) {
    // TODO: Error Handling Still Needed!
    console.log(data);
});
```
我们在使用一些 Node 异步的时候也需要注意其规范，这样才能正常接收数据和处理错误。