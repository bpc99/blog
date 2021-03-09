---
title: Hexo多种部署方式
date: 2021-02-04 00:43:35
subtitle: hexo-aliyun
tags:
  - Hexo
  - 项目部署
categories: [Linux]
---
使用 Hexo 搭建完成博客，平常会更新一些文章，但是如果只是打包按照静态文件部署会显得非常的麻烦，并且每次修改文章，都要重新登陆服务器全部覆盖，这样每次都消耗大量的时间，为了简化文章的部署，也出现了很多中方法，这里记录下本人使用的两种。

<!-- more -->

## Git + Nginx
[官网介绍](https://hexo.io/zh-cn/docs/commands#deploy)，简单来说便是通过`deploy`指令读取配置文件(**_config.yml**)中的`deploy`属性配置，然后根据配置，将我们打包之后的静态文件推送到服务器中的 **Git钩子** 上，最后根据钩子的配置，将客户端与服务端代码合并，然后保存到服务端指定路径下，最后通过 Nginx 对指定的路径进行反向代理，即可使用命令将代码合并，并自动完成代码部署的功能。

通过上面描述，大致对 Hexo deploy 指令有了些大致印象，其关键的一步便是在服务端建立 **Git钩子** 以响应客户端的代码提交。我们可以这么做：
### 建立 Git 钩子
首先创建钩子文件夹，并分配 755 类型权限：
```javascript
mkdir /var/repo/
chown -R hexo /var/repo/
chmod -R 755 /var/repo/
```
创建完成后，我们还需要初始化钩子文件：
```
cd /var/repo/
git init --bare hexo_static.git
```
名称可以随意，初始化完成后，执行：
```
vim /var/repo/hexo_static.git/hooks/post-receive
```
打开文件之后，保存下面的内容：
```javascript
#!/bin/bash
git --work-tree=/var/www/blog --git-dir=/var/repo/hexo_static.git checkout -f
```
请注意上面的路径，保存完成后。只需把该文件变为可执行文件：
```javascript
chmod +x /var/repo/hexo_static.git/hooks/post-receive
```
这样基本的 Git钩子 便建立完成了，当客户端提交代码向该钩子时，便会将代码传输到指定的路径下。
### deploy 配置
我们只需在配置文件(**_config.yml**)中编辑`deploy`属性，便能很简单的完成一键部署：
```
deploy:
  type: git
  repo: hexo@47.110.125.228:/var/repo/hexo_static.git
  branch: master
```
这样只需把属性的 **repo** 字段指向刚刚创建的 Git钩子 即可。当然 Hexo 还需要一个依赖，执行下面命令按照依赖：
```
cnpm install hexo-deployer-git --save
```
按照完成后 Hexo 配置完成，为了简便我们可以在 package.json 中添加一行命令：
```json
"scripts": {
  "build": "hexo clean && hexo g -d && hexo deploy"
},
```
这样运行`yarn build`，便会将代码提交到服务端的配置文件下，然后通过 Nginx 反向代理便能完成了一键部署。

## vercel 
学习 Next.js 时意外发现的部署网站，竟然意外的好用，和 Github 的契合度非常之高，并且支持 Hexo 类型的项目，部署起来更加的轻松。
首先我们将代码上传至 Github 的本人仓库中，然后再 vercel 注册登陆后，选择导入 Github 仓库：

![](https://img.bipch.cn/2021/03/09/ad9cc13670fed.png)

然后选择到需要部署的仓库即可，然后其会自动判断项目类型，确认无误为 Hexo 之后可以配置**打包命令(Build and Output Settings)**、**项目根目录(ROOT DIRECTORY)**、**环境变量(Environment Variables)**等当然这些一般为默认：

![](https://img.bipch.cn/2021/03/09/11f1beab57f78.png)

配置完成后会根据配置和 Github 仓库代码、以及项目类型自动构建我们的项目，当全部部署完成后便可以直接访问，其会为我们自动分配一个域名(当然并不好用)，我们可以再 **View Domains** 修改项目属性，当然也可以修改域名，但是域名必选要经过 CNAME 解析，不然无法添加：

![](https://img.bipch.cn/2021/03/09/cd27435497ac9.png)

根据提示很容易便能解析完成，并且解析后，会自动为我们的域名申请 SSL 证书，将项目使用 https 协议，当然由于要设置域名等字段，所以修改之后，一般需要等待 2~3 分组生效，等项目部署完成后，由于其和 Github 高度契合，我们可以看到我们每次界面的提交和修改，并可以看到我们的操作日志、运行状态、运行时间等信息。

## 总结
虽然介绍了两种的部署方式但是其如果依照结果来看如果要托管博客，其方式太多太多，除此之外肯定还有很多的方法都能达成相同的目的，这里就当是抛砖引玉了，最后附带上[个人的博客](https://bipch.cn/)。