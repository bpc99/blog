---
title: Nginx配置https
date: 2021-01-27 20:17:41
subtitle: nginx-https
tags:
  - https
categories: [Nginx]
---

项目部署的时候，默认遵守为 http 协议，也是应用最为广泛的一种网络协议，而 https 可以称之为安全版的 http，也就是 http + ssl，所以 https 安全的基础便是 ssl。而如果 http 请求需要添加 ssl 证书。

<!-- more -->

## 申请SSL证书
申请证书的方式有许多，包括阿里云、腾讯云、华为云等都能申请到SSL相关免费的证书。
例如申请阿里云免费SSL证书，首先进入**安全（云盾）---> SSL证书**界面：

![SSL证书](https://img.bipch.cn/2021/02/03/829bb4078a9b4.png)

选择购买证书，然后进入到证书资源包，依次进行选择：

![证书资源包](https://img.bipch.cn/2021/02/03/36be0cd0cd86b.png)

选择之后，20个资源包其费用为0，直接购买付款便可以，购买完成后，进入我们的SSL列表，便可以看到证书资源包数量以及变为20，点击左侧证书资源包，进行证书的申请：

![证书的申请](https://img.bipch.cn/2021/02/03/29c28a7e670e5.png)

因为我已经使用过两个，默认是空列表，我们点击头部按钮的证书申请，按照自己的信息，填入域名、个人信息、所在地等完成后，会进行审核，一般不到一分钟便能完成审核，完成后根据服务器类型下载相应的证书(例如Nginx)，得到其压缩包，解压后得到：`******.key`、`******.pem`两个文件，这两个便是我们所要的证书文件。

## Nginx 配置
上面得到SSL证书文件之后，使用起来也是很方便，在 Linux 中安装并配置完成 Nginx 配置后，就可以配置指定的端口为 https 协议：
```
server
{
    ...
	# HTTP_TO_HTTPS_START
    if ($server_port !~ 443){
        rewrite ^(/.*)$ https://$host$1 permanent;
    }
    # HTTP_TO_HTTPS_END
	
	# HTTP_CONFIG_START
	ssl_certificate    # *****.pem 文件路径;
    ssl_certificate_key     # *****.key 文件路径;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
	# HTTP_CONFIG_END
	...
}
```
这样也可以完成了SSL证书的配置，并强制使用 https 协议，注意便是`ssl_certificate`和`ssl_certificate_key`两个路径属性的配置，执行`nginx -s reload`重启 nginx 即可生效配置。生效后会代理 443 端口，然后进行请求转发。

## 宝塔配置Https
我们可以借助宝塔的 nginx 模块，很容易的对项目添加 https 协议，使用宝塔添加完成项目后，进入配置选择SSH，然后选择`其它证书`，将 .key 文件内容复制到**密钥(KEY)**，另一个内容复制到**证书(PEM格式)**中：

![其它证书](https://img.bipch.cn/2021/02/03/3de2d5793b07d.png)

输入后直接保存，即可自动完成项目的配置，并且还可以配置强制项目使用 https 协议，如果不是，也会定向到 https 协议中。

## 总结
通过上面的方法便能免费申请到阿里云的SSL证书资源包，但是其只能有20个，如果域名过多那便需要进行收费了。不过申请SSL证书的方法也要很多，并不是只有通过阿里云才能实现，这里就先抛砖引玉了。
