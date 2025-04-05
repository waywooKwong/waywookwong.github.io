---
title: 实验室服务器Ubuntu无sudo权限配置Clash & Redis
date: 2024-07-07 18:00:00 +0800
categories: [Tutorial, Linux]
tags: [clash, redis]     # TAG names should always be lowercase
---
本文以实验室服务器（Linux Ubantu）为例，实现实验室服务器的代理服务配置

环境要求：vscode 连接服务器，在图形化界面进行操作

# 背景

实验室服务器分发的账号，通常没有 sudo 权限（ 非root ）

且可能不允许直接科学上网（ 直接访问 HugginFace、Llama）

但日常开发需求涉及： **安装配置软件环境** （conda、python、unzip）与可能涉及的**科学上网需求**

# 基本思路

不能使用使用 `sudo intall` 、`apt install` 等需要 sudo 权限的功能

这就需要**手动下载相关 软件/ 文件 的压缩包**

不把clash安装在根目录下，只安装在 **服务器个人文件夹** （`/home/username`）中

## 下载 Clash 文件

1. 服务器根目录创建并进入 clash 文件夹

```PowerShell
mkdir ~/clash 
cd ~/clash
```

2. 手动 /  使用命令 下载并解压目标文件的压缩包
   手动下载路径：https://github.com/Kuingsmile/clash-core/releases

   选择版本：clash-linux-amd64-v1.18.0.gz

   移动到文件夹 clash 中

```PowerShell
# 这里使用 wget 命令从指定路径获取下载路径，但由于Clash已经删库，路径不存在
# wget -O clash-linux-amd64-v1.6.5.gz https://github.com/Dreamacro/clash/releases/download/v1.6.5/clash-linux-amd64-v1.6.5.gz 
gzip -d clash-linux-amd64-v1.18.0.gz
```

3. 将文件变为可执行文件，然后将其重命名为 clash
   这通常用于简化对可执行文件的调用，使得以后可以直接运行 ' clash ' 而不需要指定完整的文件名

```PowerShell
chmod +x clash-linux-amd64-v1.18.0
mv clash-linux-amd64-v1.18.0 clash
```

## 配置 Clash

1. 在 ~/clash 文件夹中创建 config.yaml 配置文件

在 vscode 可视化界面中可以直接在文件中编辑，不在 nano 中编辑

```PowerShell
nano ~/clash/config.yaml
```

2. 将下述内容添加到 config.yaml

**注意：此处要完全换成本地代理服务的配置文件**

```PowerShell
mixed-port: xxx
allow-lan: true
bind-address: '*'
mode: xxx
log-level: info
external-controller: '127.0.0.1:9090'
dns:
    enable: true
    ipv6: false
    default-nameserver: [xxx.xx.xx.xx, xxx.xx.xx.xx]
    enhanced-mode: fake-ip
    fake-ip-range: xxx.x.x.x/xx
    use-hosts: true
    nameserver: ['https://xxx', 'https://xxx']
    fallback: ['https://xxx', 'https://xxx', 'https://xxx', 'tls://x.x.x.x:xxx']
    fallback-filter: { geoip: true, ipcidr: [xxx.x.x.x/x, x.x.x.x/xx] }
proxies:
    - { name: 'xxx', type: ss, server: xxx.com, port: xxxxx, cipher: xxx, password: xxx }
    - { name: 'xxx', type: ss, server: xxx.com, port: xxxxx, cipher: xxx, password: xxx }

rules:
    - 'DOMAIN,etcloud.top,DIRECT'
    - xxx
    ... ...
    - xxx
```

## 启动 Clash

```PowerShell
cd ~/clash
./clash -d .
```

出现下述描述说明运行正常

```PowerShell
INFO[0000] Start initial compatible provider Eternal Network 
INFO[0000] Start initial compatible provider 故障转移   
INFO[0000] Start initial compatible provider 自动选择   
INFO[0000] inbound mixed://:xxxx create success.  
INFO[0000] RESTful API listening at: xxx.x.x.x:xxxx   
```

出现下述报错

```PowerShell
INFO[0000] Can't find MMDB, start download: Clash 没有找到本地的 MMDB 文件，开始下载该文件。
```

通过下述路径下载 MMDB 文件 GeoLite2-Country.mmdb.gz，解压后放至 clash 文件夹中，并改名为Country.mmdb

https://github.com/wp-statistics/GeoLite2-Country/blob/master/GeoLite2-Country.mmdb.gz

```Python
gunzip GeoLite2-Country.mmdb.gz
改名为 Country.mmdb
```

## 设置临时路径

```PowerShell
# 根据配置文件 config.yaml 中的设置 mixed-port: xxx 设定路径 
export http_proxy=http://127.0.0.1:xxxx
export https_proxy=http://127.0.0.1:xxxx
```

## 测试连接

```PowerShell
curl -x http://127.0.0.1:7890 -I https://www.google.com
```

注意此处不可直接通过 `ping www.google.com` 进行测试：

* `curl` 使用的是 HTTP/HTTPS 协议，通过代理进行请求。
* `ping` 使用的是 ICMP 协议，通常无法通过 HTTP/HTTPS 代理进行。

出现下述提示说明运行连接成功

```PowerShell
HTTP/1.1 200 Connection established

HTTP/2 200 
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-nYhebZWWjOPTgygzcZQVcQ' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Sun, 07 Jul 2024 09:52:53 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Sun, 07 Jul 2024 09:52:53 GMT
cache-control: private
set-cookie: AEC=AVYB7coc0FgUqiFIhFCLSjWe-9kWVXqBT5A6JQSlYVeISxfeZZagNeC9MA; expires=Fri, 03-Jan-2025 09:52:53 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
set-cookie: NID=515=pbnXiWb2KIm3k1ZD4JwbOsHlNoKlH4EpTSpCxkvekZGeNkGqrzRCr9yjrC4zhLeOPS6OLzRdUx_C9icrxnyK62OgjlSPAQzuapHpZK9svlp-u6PAHOpz8LjuX07WhCa7MzGoDG7aM_fI6VwDYUab4IPIkM_TnpnB9xPOJKXGoGs; expires=Mon, 06-Jan-2025 09:52:53 GMT; path=/; domain=.google.com; HttpOnly
alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
```

# 无 sudo 安装 Redis

在没有 `sudo` 权限的情况下，你可以通过以下方式安装和使用 Redis 及其工具。

### 1. 安装 Redis 二进制文件

你可以直接从 Redis 官方网站下载预编译的二进制文件，并在用户目录下运行。

步骤：

1. **下载并解压 Redis 源码：**

   ```Bash
   wget http://download.redis.io/redis-stable.tar.gz
   tar xvzf redis-stable.tar.gz
   cd redis-stable
   ```
2. **编译 Redis：**
3. Redis 源码自带 `Makefile`，因此你可以使用 `make` 编译它。

   ```Bash
   make
   ```
4. **将编译好的文件移动到你的用户目录：**

   ```Bash
   mkdir -p ~/redis/bin
   cp src/redis-server src/redis-cli ~/redis/bin/
   ```
5. **更新 ****`PATH`**** 环境变量：**
6. 你需要将 Redis 的可执行文件路径添加到 `PATH` 中。你可以在 `~/.bashrc` 或 `~/.bash_profile` 中添加以下内容：

   ```Bash
   export PATH=$PATH:~/redis/bin
   ```

   然后重新加载文件：

   ```Bash
   source ~/.bashrc
   ```
7. **运行 Redis：**
8. 你可以通过以下命令启动 Redis：

   ```Bash
   redis-server
   ```

   然后通过 `redis-cli` 连接：

   ```Bash
   redis-cli
   ```

### 2. 使用 Conda 安装 Redis

如果你已经安装了 Anaconda 或 Miniconda，可以通过 Conda 来安装 Redis 和相关工具：

步骤：

1. **创建一个新的 Conda 环境（可选）：**

   ```Bash
   conda create -n redis_env python=3.8
   conda activate redis_env
   ```
2. **安装 Redis：**

   ```Bash
   conda install -c conda-forge redis-py
   ```
3. **运行 Redis：**
4. 使用 `redis-server` 和 `redis-cli` 命令即可。

### 3. 使用 Docker 安装 Redis

如果你的系统中安装了 Docker，并且你有权限使用 Docker，你可以通过 Docker 来运行 Redis。

步骤：

1. **拉取 Redis 镜像：**

   ```Bash
   docker pull redis
   ```
2. **运行 Redis 容器：**

   ```Bash
   docker run --name myredis -d redis
   ```
3. **连接到 Redis 容器：**

   ```Bash
   docker exec -it myredis redis-cli
   ```

通过这些方法，你可以在没有 `sudo` 权限的情况下安装和使用 Redis。

## 更新成永久路径

是的，通过命令 `export PATH=$PATH:~/redis/bin` 添加的路径是暂时的。它只会在当前的终端会话（shell session）中有效。一旦你关闭终端或注销当前会话，这个路径的更改就会消失。

### **如何使路径添加永久生效**

如果你希望 `~/redis/bin` 永久添加到 `PATH` 环境变量中，你需要将该命令添加到你的 shell 配置文件中。这样，每次启动一个新的终端会话时，系统都会自动应用这个路径。

**步骤：**

1. **编辑 shell 配置文件** ：
2. 如果你使用的是 `bash`，编辑 `~/.bashrc` 或 `~/.bash_profile`：

   ```Bash
   nano ~/.bashrc
   ```
3. 如果你使用的是 `zsh`，编辑 `~/.zshrc`：

   ```Bash
   nano ~/.zshrc
   ```
4. **在文件末尾添加以下行** ：

```Bash
   export PATH=$PATH:~/redis/bin
```

3. **保存并退出编辑器** ：
4. 在 `nano` 编辑器中，按 `Ctrl + O` 保存文件，然后按 `Ctrl + X` 退出编辑器。
5. **重新加载配置文件** ：
6. 如果你编辑的是 `~/.bashrc`，运行以下命令使更改立即生效：

   ```Bash
   source ~/.bashrc
   ```
7. 如果你编辑的是 `~/.bash_profile`：

   ```Bash
   source ~/.bash_profile
   ```
8. 如果你编辑的是 `~/.zshrc`：

   ```Bash
   source ~/.zshrc
   ```

### **验证路径是否永久添加成功**

你可以通过关闭当前终端并重新打开，运行以下命令来验证路径是否已成功添加：

```Bash
echo $PATH
```

# Redis

检查输出中是否包含 `~/redis/bin`。如果有，则表示路径添加已经永久生效。

```Python
redis-server --protected-mode no
```

```Plain
KEYS *

GET key 
or
SMEMBERS key
```

```Plain
FLUSHDB
```


# 附录

本文参考引用下述文章，对作者表示感谢

1. 《让你的 LINUX 云服务器也能科学上网！》

https://ry.huaji.store/2020/08/Linux-magic-network/

2. Linux Clash 文件获取来自仓库：
   https://github.com/Kuingsmile/clash-core/releases
3. GeoLite2-Country.mmdb.gz 文件的获取来自仓库：
   https://github.com/wp-statistics/GeoLite2-Country/blob/master/GeoLite2-Country.mmdb.gz


# 附录

本文参考引用下述文章，对作者表示感谢

1. 《让你的 LINUX 云服务器也能科学上网！》

https://ry.huaji.store/2020/08/Linux-magic-network/

2. Linux Clash 文件获取来自仓库：
   https://github.com/Kuingsmile/clash-core/releases
3. GeoLite2-Country.mmdb.gz 文件的获取来自仓库：
   https://github.com/wp-statistics/GeoLite2-Country/blob/master/GeoLite2-Country.mmdb.gz
