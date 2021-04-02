---
title: Hexo多种部署方式
date: 2021-02-04 00:43:35
subtitle: hexo-aliyun
tags:
  - Hexo
categories: [项目部署]
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
vercel 不论是和 Github的契合度，还是国内的镜像的加速，都是比较好用的，具体项目的部署，可以看 [vercel](/vercel) 的部署。

## 总结
虽然介绍了两种的部署方式但是其如果依照结果来看如果要托管博客，其方式太多太多，除此之外肯定还有很多的方法都能达成相同的目的，这里就当是抛砖引玉了，最后附带上[个人的博客](https://bipch.cn/)。