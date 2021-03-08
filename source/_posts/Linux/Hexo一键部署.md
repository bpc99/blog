---
title: Hexo一键部署
date: 2021-01-27 15:23:10
subtitle: hexo-aliyun
tags:
  - Hexo
categories: [Linux]
---
使用 Hexo 搭建完成博客，平常会更新一些文章，但是其部署却十分的麻烦，由于 Hexo 是将 Mackdown 语法打包为 HTML 界面，每个文章对应着一个界面，这样部署起来很不方便，基本每次修改文章，都要重新登陆服务器覆盖，既然那么多重复步骤，那么 Hexo 可不可以一行命令帮我们将博客部署到服务器上呢？这是肯定的，Hexo 也给出了[相应的配置](https://hexo.io/zh-cn/docs/one-command-deployment)。

<!-- more -->

## 服务器端配置
### 安装git
git 为不可或缺的工具，并且大部分服务器都内置了 git，虽然版本有一些老，但是不影响使用，执行`git --version`查询是否安装，如果没有执行：`yum install git`安装。
### 创建用户(可选)
除了 root 用户以外，为了安全起见，要可以创建一个管理 blog 的用户 hexo：
```javascript
useradd hexo
```
修改用户的权限：
```javascript
chmod 740 /etc/sudoers
vi /etc/sudoers
```
搜索`root	ALL=(ALL) 	ALL`(可能由于缩减的原因搜索不到，建议搜索 ALL=(ALL)，Linux vim搜索执行为先按下**Esc**进入命令模式，然后收入**/content**回车搜索)，找到后在下面添加这样一段话：
```javascript
hexo ALL=(ALL) 	ALL
```
![](https://img.bipch.cn/2021/02/03/73359bbec9dd5.png)

然后输入`:wq`保存完成权限分配，权限分配后，需要设置下用户密码：
```javascript
passwd hexo
```

> 创建用户时可能会出现`adduser：警告：此主目录已经存在。`的错误，这是因为用户已经存在，我们可以使用 **userdel -rf grid** 命令删除指定的用户。
### 创建 Git 配置
用户创建完成后，需要创建一个 Git 配置仓库，里面主要存放该 git 的配置，执行下面命令创建：
```javascript
mkdir /var/repo/
```
创建完成后，需要对该目录和其子目录分配 hexo 用户的访问权限。执行下面命令：
```javascript
chown -R hexo /var/repo/
chmod -R 755 /var/repo/
```
这样仓库创建完成，我们还需要使用 git 命令初始化空仓库：
```javascript
cd /var/repo/
git init --bare hexo_static.git
```
这样便初始化完成，并且 hexo 用户具有访问其子目录的权限。
### 文件仓库
git 配置文件处理完成后，我们还需要一个地址用于存放客户端上传的文件：
```javascript
mkdir -p /var/www/blog
```
同样该文件也需要 git 访问权限：
```javascript
chown -R hexo /var/www/blog
chmod -R 755 /var/www/blog
```
之后我们还需安装一些依赖：
```javascript
yum install -y pcre pcre-devel
yum install -y zlib zlib-devel
yum install gcc-c++
yum install -y openssl openssl-devel
```
但是这样依赖服务器也有一些内置安装的。然后便须安装 Nginx 进行界面托管，Linux 下载 Nginx 方法实在太多了，也就不细说了。安装完成后编辑指定的配置，例如我的配置：
```javascript
server {
  listen 80;  // 端口
  server_name www.bipch.cn;  // ip 或者 域名
  index index.html index.htm index.php;  // 默认首页文件
  root  /var/www/blog;  // 项目根目录
  location /{
  }
}
```
一个很简的配置，完成后执行`nginx -s reload`重启，然后可以再`/var/www/blog`中新增一个 HTML 类型的文件，输入路径是否可以访问，如果可以便是 Nginx 配置成功，否则表示配置有问题，或者服务器安全组没有开放默认的 80 端口。

### 配置 Git 钩子
git 仓库和文件仓库都配置完成了，我们还需告诉 git 配置让其将客户端上传的文件传入到指定仓库，也就是上面的 **/var/www/blog**。
新建 git 钩子文件：
```javascript
vim /var/repo/hexo_static.git/hooks/post-receive
```
添加后，再文件中输入下面的代码(注意文件路径)：
```javascript
#!/bin/bash
git --work-tree=/var/www/blog --git-dir=/var/repo/hexo_static.git checkout -f
```
保存完成后，将该文件变为可执行文件：
```javascript
chmod +x /var/repo/hexo_static.git/hooks/post-receive
```
配置完成后，服务器端配置结束，下面配置客户端 Hexo 即可。

## Hexo 配置
Hexo 配置基本都是再根目录下的`_config.yml`文件，首先我们先配置项目地址：
```json
url: "http://www.bipch.cn/"
```
然后，我们还需要配置 deploy 属性：
```json
deploy:
  type: git
  repo: hexo@47.110.125.228:/var/repo/hexo_static.git
  branch: master
```
配置其提交的信息，然后还需要安装一个 Hexo 包，负责将打包后的内容发送到指定的服务器上：
```javascript
cnpm install hexo-deployer-git --save
```
这样 Hexo 配置完成，我们再 package.json 中添加一行命令：
```json
"scripts": {
  "build": "hexo clean && hexo g -d && hexo deploy"
},
```
这样基本我们运行`yarn build`，然后输入密码等信息，就可以直接一键将我们博客通过 Git 上传到服务器了。

## 总结
上面通过 git 将本地文件上传至服务器只是众多方式之一，除此之外还有很多的方法都能达成相同的目的，最后附带上[个人的博客](http://www.bipch.cn/)。