---
title: MongoDB安装和常用方法
date: 2020-10-20 14:20:30
subtitle: linux-software
tags:
  - MongoDB
categories: [数据库]
---
一种非关系型的数据库，由于其高性能、易部署、易使用，并且可以通过 Mongoose 和 Node.js 完美结合起来使用，可以很方便的为 web 应用提供一种高效的存储方案，详情可以去[官网](https://www.mongodb.com/)查看。

<!-- more -->

## 下载
我的服务器操作系统为 centos，请根据操作系统进行安装。首先我们要去复制压缩包的下载的链接：

![MongoDB DownLoad](https://img.bipch.cn/2021/02/03/36e0894477c7d.png)

按照自己的系统拷贝相应的链接，这里贴出我的链接：
```
https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-amazon-4.4.3.tgz
```
拷贝完成后需要放置到服务器，一般我会放置在 **/usr/local/** 路径下：
```
cd /usr/local
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-amazon-4.4.3.tgz
```
等待文件下载完成后，我们需要对其解压：
```
tar -zxvf mongodb-linux-x86_64-amazon-4.4.3.tgz
mv mongodb-linux-x86_64-amazon-4.4.3 mongodb-linux
rm mongodb-linux-x86_64-amazon-4.4.3.tgz
```
这样通过`tar`命令进行解压，通过`mv`命令进行重命名，然后通过`rm`将压缩包删除，因为解压之后，压缩包已经失去了价值。
这样基本项目已经下载完成，我们还需要手动创建日志文件目录、数据库文件目录：
```
cd mongodb-linux
mkdir db logs
```
**mongodb-linux** 根目录下新建了两个文件夹`db`、`logs`分别存放数据库和日志。
这样配置基本完成，我们只需告诉 Mongodb 文件位置即可，在`bin`目录下新建文件`mongodb.conf`文件：
```
cd bin
vi mongodb.conf
```
打开 vim 编辑文件，输入下面内容：
```
dbpath=/usr/local/mongodb-linux/db
logpath=/usr/local/mongodb-linux/logs/mongodb.log
port=27017
fork=true
```
一些基础配置：

- `dbpath`：数据库地址。
- `logpath`：日志地址。
- `port`：端口。
- `fork`：前台还是后台运行，true 表示后台运行，否则表示前台。

完成后，通过`:wt`命令退出 vim，这样基本配置完成，我们在 **bin** 目录下运行：
```
./mongod -f mongodb.conf
```
然后执行`./mongo`即可链接上 Mongodb，然后可以通过下面方式查看版本号：
```
db.version()
```
当然如果嫌每次执行都需进入**bin**目录，我们可以为其配置环境变量，修改`/etc/profile`配置：
```
vi /etc/profile
```
然后只需在最后添加下面两行代码：
```
# 安装路径
export MONGODB_HOME=/usr/local/mongodb-linux
# bin 目录
export PATH=$PATH:$MONGODB_HOME/bin
```
完成后，使用`source /etc/profile`命令重启即可。

## 数据库常用命令
上面已经将 Monsedb 安装完成，下面总结下其常用的命令方便以后的使用。
### 数据库列表
```
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
```
### 创建数据库
```
> use react_blog
switched to db react_blog
```
`use`命令创建时，如果数据库不存在会进行创建后进入，如果已经存在回切换到指定数据库，所以切换到执行数据库也是该命令。

> 新增的数据库使用 `show dbs` 是无法查询出的，我们只有新增数据之后才可以查询出。

### 当前数据库
```
> db
react_blog
```
### 删除数据库
```
> db.dropDatabase()  # 删除数据库
{ "ok" : 1 }
> db  # 查询当前数据库
react_blog
> show dbs  # 查询数据库列表
admin   0.000GB
config  0.000GB
local   0.000GB
> db.createCollection("user")  # 相当于创建一个数据库
{ "ok" : 1 }
> show dbs  # 在查询数据库列表
admin       0.000GB
config      0.000GB
local       0.000GB
react_blog  0.000GB
```
可以看出虽然执行`dropDatabase`删除了该数据库，但是其当前数据库并没有改变，尽管其已经被删除，使用`dbs`查询发现已经从列表中删除，但是如果我们此时新建 Collection(可以立即为数据库中的数据表)，该操作是执行成功的，并且数据库又能查询出来。所以可以很简单的得出结论：**`dropDatabase` 只是清空当前数据库的所有 Collection**。
### 查询所有集合
```
> show collections
user
```

## collection 常用命令
集合就相当于 Mysql 数据库中的数据表。
### 创建 collection
```
> db.createCollection("user")
{ "ok" : 1 }
```
该操作相当于在 Mysql 中的数据库新增一个数据表。
> 当一个数据库中包含一个集合时(哪怕只是一个空集合)，便能够使用`dbs`查询出来了。

### 删除 collection
```
> db.user.drop()
true
> show collections
```
### 重命名 collection
```
> show collections
user
> db.user.renameCollection("users")
{ "ok" : 1 }
> show collections
users
```
## 关闭 MongoDB
MongoDB 启动成功后需要以正确的方式进行关闭：
可以使用`Crtl + C`命令直接关闭，注意此时只是退出了 MongoDB，如果退出后在连接是可以正常连接的：
```
> ^C
bye
> ./mongo
```
这样做是完全没有问题的，如果要彻底关闭 MongoDB，排除强行关闭端口的情况下，还能使用`shutdownServer`，注意：**使用该方法时`必须`在 admin 下**，不然会给出下面的提示：
```
shutdown command only works with the admin database; try 'use admin'
```
这样去关闭：
```
> db
admin
> db.shutdownServer()
server should be down...
> exit
bye
```
因为`shutdownServer`不会关闭当前的服务，所以我们还要加上`exit`来退出。这样即使后面再使用`./mongo`也是无法连接的。
