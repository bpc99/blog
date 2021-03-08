---
title: pm2 + Nginx 部署 Koa2
date: 2021-01-31 02:10:03
subtitle: linux-pm2-nginx-Koa2
tags:
  - Nginx
  - Koa2
  - pm2
categories: [Nginx]
---

因为自己需要空闲的时候总结一些个人项目等，之前通过 hexo 搭建的博客，但是接触了 koa2 决定使其搭建一个后台接口服务，为前端界面提供相应数据。

本篇主要讲解客户端一键将 koa2 项目部署到服务器，服务器端使用 pm2 管理 koa2 服务及 Nginx 反向代理服务到另一个接口。

首先网站大致为：koa2 默认占用本地`6060`端口，然后通过 nginx 反向代理到`80`端口，同时 nginx 将`80`端口转发到`443`强制使用 https 协议。

<!-- more -->

## 服务器
本人服务器系统为`CentOS7.0`，系统不同执行的命令也会有些许差别。部署之前要安装必备的软件：`Node`、`npm`、`pm2`、`Nginx`。安装的方法这里就不多说了，其方式有太多。

**下面的配置都是为了服务器安全，如果不需要可以不用配置。后面用户直接设置为 root 即可**。

### 创建新用户(可选)
为了服务器的安全起见，不推荐用 root 用户管理所有权限，只有需要 root 权限时，在使用`su`切换为 root。
创建一个新用户：
```
useradd bpc
```
对新用户初始化密码：
```
passwd bpc
```
将该用户添加到`wheel`组中，设置为管理员用户：
```
usermod -aG wheel bpc
```
### 关闭 root 用户访问 ssh(可选)
为了服务器的安全，我们也需要关闭 root 的 ssh 访问权限。
打开配置文件：
```
vi /etc/ssh/sshd_config
```
找到下面配置，并将 yes 修改为 no：
```
PermitRootLogin no
```
保存文件后，重启sshd服务：
```
service sshd restart
```
这样 root 用户便不能直接登陆了，我们退出服务，使用新用户登陆，当权限不足时使用`su`切换到指定用户即可。

### 文件读写权限(可选)
因为我们自定义了用户进行管理，其并不会向 root 一样有着所有文件的读写权限，我们需要对指定路径设置新用户的访问权限。
比如我在服务器中将最终代码放置在 **/var/api/blog** 路径下，那么我们通过下面方式分配权限：
```
chown -R bpc /var/api
chmod -R 755 /var/api
```
这样通过`chown`命令分配指定用户权限，通过`chmod`分配给文件夹详细权限(755表示拥有者有读、写、执行权限；而属组用户和其他用户只有读、执行权限)。

## Github 仓库
客户和服务器端同步代码需要建立一个 github 的私人仓库，我的命名为 react_blog_api。

### 设置密钥
由于需要使用 ssh 读写私人仓库内容，所以需要配置私人仓库中的 **Deploy keys**。这就需要我们在客户端和服务器端生成`id_rsa.pub`(默认名称)文件，并查询其内容：

首先我们查看是否已经生成该文件：
```
cat ~/.ssh/id_rsa.pub  # cat 命令查看文件
```
当然如果`cat`命令没有查找文件，那么可以使用下面命令生成：
```
ssh-keygen -t rsa -C "你的个人邮箱"
```
复制成功后，将内容粘贴到私人仓库中的 **Deploy keys** ：

![](https://img.bipch.cn/2021/02/06/c05da0bf0d3e6.png)

并将 Allow write access 勾选上添加即可。

### 提交代码
私人仓库配置完成后，我们便有权限操作私人仓库了，我们将客户端代码传入到仓库中：
```
git init
git remote add origin https://github.com/bpc99/blog_api.git
git add .
git commit -m "项目初始化"
git push -u origin master
```
这样便将客户端代码提交至 Github 私人仓库。

## pm2 配置
使用 pm2 可以使 node 程序永远保持活动状态，无需停机便可以重新加载它们，并简化常见的任务管理。并且其还为我们提供了 deploy 配置，可以让我们在本地一键将项目部署到服务端。

### 同步代码
关于 pm2 的基本操作和配置这里就不介绍了，具体可以查看其[官方文档](https://github.com/Unitech/pm2)，当 koa2 本地运行无误时，我们需要配置 pm2 中的`deploy`属性，其默认的模板文件为：
```javascript
module.exports = {
  apps : [...],
  deploy : {
    production : {
      user : "node",
      host : "212.83.163.1",
      ref  : "origin/master",
      repo : "git@github.com:repo.git",
      path : "/var/www/production",
      "post-deploy" : "npm install && pm2 startOrRestart ecosystem.config.js --env production"
    }
  }
}
```
一些基础的配置，其各个属性也都很简单：
```json
"production": {
  "user": "登录远程服务器的用户名(例如 root)",
  "host": "IP",
  "ref": "远端名称及分支名",
  "repo": "git仓库地址",
  "path": "远程服务器部署目录，需要填写user具备写入权限的目录",
  "post-deploy" : "部署后需要执行的命令"
}
```
我们根据自己服务器的信息填入即可，最后贴出本人的配置：
```javascript
module.exports = {
  apps : [...],
  production: {
    user: "bpc",
    host: "47.110.125.228",
    ref: "origin/master",
    repo: "git@github.com:bpc99/blog_api.git",
    path: "/var/api/blog",
    "post-deploy": "npm install && pm2 startOrRestart ecosystem.config.js --env production"
  }
}
```
这样便完成了 pm2 的基本配置，贴出`ecosystem.config.js`所有配置：
```javascript
module.exports = {
  apps: [{
    name: 'api',
    script: './src/index.js',
    watch: true,
    ignore_watch: [ "node_modules" ]
  }],
  deploy: {
    production: {
      user: "bpc",
      host: "47.110.125.228",
      ref: "origin/master",
      repo: "git@github.com:bpc99/blog_api.git",
      path: "/var/api/blog",
      "post-deploy": "npm install && pm2 startOrRestart ecosystem.config.js --env production"
    }
  }
};
```
最后我们在根目录下，以`ecosystem.config.js`为配置文件，启动 pm2：
```
pm2 deploy ecosystem.config.js production setup
```
此时会出现一个错误：
> Host key verification failed.
> fatal: Could not read from remote repository.

主要是因为在远程服务器中，并未将 [github.com](https://github.com) 加入known_hosts，在服务器端通过如下命令设置：
```
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
```
如果成功，会在**/home/用户名/.ssh**目录下生成`known_hosts`文件。然后客户端重新执行部署的指令：
```
pm2 deploy ecosystem.config.js production setup
```
如果传输成功 pm2 便将 GitHub 私人仓库中的文件，都传输到了我们服务器指定路径下，我们打开指定文件夹，发现其多了 3 个文件夹：
- `current`：当前运行的文件夹。
- `source`：真正的项目源代码。
- `shared`：项目日志文件。

### 部署代码
当一键传输配置完成，客户端项目代码可以一键传输到服务器上，这样我们便可以开始部署服务器上的项目了。

在开始部署之前，我们需要确保本地和 Github 私人仓库代码的同步，先将本地文件同步到 Github：
```
# 和仓库代码同步
git pull
# 代码添加到暂存区
git add .
# 提交暂存区到仓库区
git commit -m "update ecosystem"
# 传本地指定分支到远程仓库
git push
```
这样提交完成后，在本地的根目录下执行命令，将代码向生产环境下部署：
```
pm2 deploy ecosystem.config.js production
```
如果项目部署成功，配置文件中的`post-deploy`中的命令会自动执行(当然运行速度慢了可以将 npm 切换为 cnpm 或 yarn)，那么便可以看出 pm2 给出的提示：
```
[PM2][WARN] Applications api not running, starting...
[PM2][WARN] Environment [production] is not defined in process file
[PM2] App [api] launched (1 instances)
┌─────┬────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name   │ namespace   │ version │ mode    │ pid      │ uptime │ ?    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ api    │ default     │ 1.0.0   │ fork    │ 9438     │ 0s     │ 0    │ online    │ 0%       │ 9.1mb    │ bpc      │ disabled │
└─────┴────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
  ○ successfully deployed origin/master
--> Success
```

这样便表示代码部署成功，我们可以在服务器上所有端口使用清空：
```
netstat -antp
```
可以查看端口开发情况，例如本人的6060端口：
```
tcp    0    0    127.0.0.1:6060    0.0.0.0:*    LISTEN    2657/node /var/www/
```
`注意`：此时端口为**127.0.0.1**表明局域网可以访问，公网是不能访问到的，我们还需要 nginx 进行代理。

## Nginx
上面基本运行完成，但是只有局域网可以访问，我们需要将其使用 nginx 代理至公网上，至于 nginx 下载和配置便不多提了，我们可以新建一个配置文件，最终贴出我的配置：
```
server
{
    listen 80;
    server_name api.bipch.cn;
    access_log  /www/wwwlogs/api.bipch.cn.log;
    error_log  /www/wwwlogs/api.bipch.cn.error.log;
    
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://127.0.0.1:6060;
        proxy_redirect off;
     }
}
```
其原理也很简单，其拦截了**80**端口，并代理到本地的**6060**，并配置了相应的域名，日志，端口等信息，配置完成后，使用`./nginx -s reload`重启服务。

最后如果配置正确，并且相应端口的安全组已经打开，那么我们便可以正常访问相应的API了。

### 配置 https
https 配置肯定需要相应的证书的，由于本人服务器为阿里云，免费证书申请可以看[这篇](/nginx-https)，申请成功后，修改我们的配置文件：
```
server
{
    listen 80;
    listen 443 ssl;
    server_name api.bipch.cn;
    access_log  /www/wwwlogs/api.bipch.cn.log;
    error_log  /www/wwwlogs/api.bipch.cn.error.log;
	
    # HTTP_TO_HTTPS_START
    if ($server_port !~ 443){
        rewrite ^(/.*)$ https://$host$1 permanent;
    }
    # HTTP_TO_HTTPS_END
	
    # HTTP_CONFIG_START
    ssl_certificate    /www/server/panel/vhost/cert/api.bipch.cn/fullchain.pem;
    ssl_certificate_key    /www/server/panel/vhost/cert/api.bipch.cn/privkey.pem;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    # HTTP_CONFIG_END
	
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://127.0.0.1:6060;
        proxy_redirect off;
     }
}
```
这样接口便强制使用 https 协议，其重点在于`ssl_certificate`和`ssl_certificate_key`分别指向两个证书的路径。当所有属性配置完成后，重启指定的 nginx 便完成了反向代理。
最后 pm2 便在本地`6060`运行，nginx 将`80`端口代理到`6060`端口，并且将`80`端口转发到`443`端口，使用 https 协议，这样便结合了 pm2 + nginx 完成了 node 项目的部署。