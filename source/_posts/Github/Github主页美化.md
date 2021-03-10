---
title: Github主页美化
date: 2021-03-10 13:22:15
subtitle: use-github-styles
tags:
  - 美化
categories: [Github]
---
Github 默认展示仓库和提交信息等字段，却没有汇总或一些自定义连接功能，不过其提供了创建同名仓库的形式自定义主页。比如我的用户名为 bpc99，那么我们只需新建一个相同名的仓库即可。下面便通过此仓库中的 README 文件，自定义 Github 的主页。
那么 README 能玩出什么花样呢？

<!-- more -->

## 装修效果
首先贴出本人的个人主页修改后的样式：

![](https://img.bipch.cn/2021/03/10/627185a4aa616.png)

## 数据统计
最上面中的数据统计和评分都是依靠外部的一个服务，我们只需要调用相应服务即可：
```
<img src="https://github-readme-stats.vercel.app/api?username=bpc99&show_icons=true" alt="logo" height="160" align="right" style="margin: 5px; margin-bottom: 20px;" />
```
当然需要把上面的`username`字段修改为自己 Github 的用户名，这样才能正确的统计自己本人的仓库信息。

## 自动更新博客列表
例如上面最终展示的 5 条最先的文章，并不是写死的，而是由 Github 每个一段时间自动统计文章中最新的 5 篇。
当然如果你也需要该功能，可以将 README 添加下面的代码：
```markdown
## Latest Blog Posts

<!-- BLOG-POST-LIST:START -->
<!-- BLOG-POST-LIST:END -->
```
其实只是一个标题，和一些代码的注释声明，之后 Github 统计的数据会自动统计到注释代码块中，也就是`可以通过修改注释的位置，可以将其放置到任意位置`。
当然我们还需要实现一个`每段时间自动统计的功能`，该功能才是重中之重，我们需要 Github 的 Github Action 来进行实现。

点击下面的按钮，可进行添加操作：

![](https://img.bipch.cn/2021/03/10/3740e196f980b.png)

然后我们将下面内容粘贴进去：
```
name: Blog Posts

on:
  # Run workflow automatically
  schedule:
    # Runs every hour, on the hour
    - cron: "0 * * * *"

jobs:
  update-readme-with-blog:
    name: Update this repo's README with latest blog posts
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: gautamkrishnar/blog-post-workflow@master
        with:
          # comma-separated list of RSS feed urls
          feed_list: "https://bipch.cn/atom.xml"
```
当然上面的`cron: "0 * * * *"`表示多长时间执行一次，这里为每小时 0 分的时候去执行，所以执行整点我们才能看到结果，当然事件可能有几分钟的延迟，所以耐心等待一段时间即可。
另一个关键的字段为`feed_list`文章的 RSS 订阅地址，多个的话后面使用逗号分割，所以使用该功能一定要拥有文章的 RSS 地址，如果并没有或者忘记都不能使用该功能，由于本人博客是使用 Hexo 生成的，所以根据文章生成 RSS 非常简单，当然如果是其它的肯定也有方法，根据技术的不同，生成的方式也不会相同，这里就不多叙述了，大家可以去网上查阅。

## 完整源代码
当然上面只是一些简单的功能，但是其是 Mackdown 类型的文档，我们可以任意添加一些自己需要的代码。

最后贴出本人的仓库地址：[https://github.com/bpc99/bpc99](https://github.com/bpc99/bpc99)

大家也可以根据自己需求去添加，最后祝大家都有一个高大上的 Github 主页。