---
title: vercel
date: 2021-03-09 17:29:56
subtitle: vercel
tags:
  - vercel
categories: [项目部署]
---
当项目完成后，最重要的便是部署了，一般需要挑选一个访问速度比较快的、花钱比较少的、部署比较方便...这些因素同时考虑比较好用的便是  GitHub Pages 了，但是其国内一般访问较慢，如果比较着重考虑国内访问的话，可以考虑另一款和 Github 比较契合的工具 [Vercel](https://github.com/vercel/vercel)。

<!-- more -->

## Why Vercel
Vercel 国内的访问速度也是比较快，而且无需科学上网，相同的项目对比 **Vercel 托管的程序(图左)** 和 **直接部署的程序(图右)** 的请求速度：

![对比](https://img.bipch.cn/2021/03/09/36debd291265f.png)

可以看到其速度加快了 2 倍多，并且 Vercel 和 Github 也是比较契合的，其还能直接导入 hexo、vue、next等项目，其会自动为我们构建。

## Github
我们可以在 Github 新增一个仓库，然后可以在 Vercel 设置该仓库，这样一旦仓库数据数据更新 Vercel 中的数据也会更新，并且可以查看仓库的操作日志等信息。
在 [vercel](https://vercel.com/) 新增 Project，然后选择 **Add Github Org or Account**：

![](https://img.bipch.cn/2021/03/09/ad9cc13670fed.png)

选中所需的仓库之后，会根据我们的项目自动判断项目的类型，例如我们导入 Hexo 项目：

![](https://img.bipch.cn/2021/03/09/11f1beab57f78.png)

可以看出其自动判断了项目类型，当然如果不准确可以自行修改，选择类型之后会自动生成**打包命令(Build and Output Settings)**、**项目根目录(ROOT DIRECTORY)**、**环境变量(Environment Variables)**等配置，根据需求配置完成后，会根据命令和项目类型自动部署，成功后可以看到下面界面：

![](https://img.bipch.cn/2021/03/09/9b2b1f25a9427.png)

这样便完成了部署，如果是其它类型的项目，那么部署方式也是同样的。

## 域名
项目部署成功后系统会自动为其分配一个域名，但是其并不是太好记，所以我们一般需要将自己域名设置为项目的访问路径。
进入项目的详情界面，点击 **View Domains** 可配置项目的各个属性，但是其域名必须经过 **CNAME** 解析，不然会报出下面的错误：

![](https://img.bipch.cn/2021/03/09/cd27435497ac9.png)

我们解析时添加解析，例如案例云的界面为：

![](https://img.bipch.cn/2021/03/09/9fc718e43ddc7.png)

这样即可添加域名，并且其添加成功后会自动为我们的域名申请 SSL 证书，并为项目使用 https 协议。
添加域名之后，可以在详情页查看其各个域名信息，与项目日志、启动时间等字段：

![](https://img.bipch.cn/2021/03/09/d2ed842120fe1.png)

## 总结
当然一个项目的部署方式有许多种的，而 Vercel 只是其中之一，并且开发中也不能拘束与一种部署方式，而是需要根据实际的情况选择不同的方式。