---
title: Docker
date: 2023-12-10 18:23:26
excerpt: Docker入门
index_img: /blogIndexImg/docker.png
tags: 部署
categories: 学习笔记
---


# <u>Docker</u>



## 一、安装



### 1. 安装docker



**进入官方文档**：[Docker Install](https://docs.docker.com/engine/install/centos/)



- 安装之前卸载已有文件

```sh
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```



- 设置存储库

```sh
sudo yum install -y yum-utils

#注意这里使用国内源
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```



- 安装最新版docker引擎
```sh
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```



- 启动并验证

```sh
sudo systemctl start docker

docker version

#测试运行hello-world镜像
sudo docker run hello-world

#查看已有镜像
docker images
```



### 2. 配置阿里云镜像加速器

首先登录阿里云，找到镜像服务 -> 镜像加速器

```sh
mkdir -p /etc/docker

#注意此处镜像地址用自己阿里云当中的
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://zwx0tf4k.mirror.aliyuncs.com"]
}
EOF

systemctl daemon-reload

systemctl restart docker
```



## 二、常用命令

**详细信息参阅官方文档**：[Reference documentation | Docker Docs](https://docs.docker.com/reference/)

### 1. 帮助命令

```sh
#查看版本信息
docker version

#显示系统信息
docker info

#帮助命令
docker --help
```



### 2. 镜像命令

- `docker images [选项]`：查看本机镜像
  - `-a`：列出所有镜像
  - `-q`：只显示镜像id



- `docker search [选项] 镜像名`：搜索镜像
  - `--filter=[条件]`：过滤查询

```sh
#搜索收藏量大于300的mysql镜像
docker search mysql --filter=STARS=300
```




- `docker pull 镜像名:标签`：下载镜像

```sh
#下载mysql镜像
#默认下载最新版
docker pull mysql

#下载5.7版本（注：这里的版本需要在镜像仓库中存在）
docker pull mysql:5.7
```

镜像仓库：[Docker Hub | MySQL](https://hub.docker.com/search?q=mysql)

- `docker rmi -f [镜像id][][]...`：删除指定镜像
  - `-f ${docker images -q}`：删除所有镜像



### 3. 容器命令

有了镜像才能创建容器

==容器相当于在现有镜像上在加一层可写层在镜像顶部==

- `docker run [选项] 镜像名`：新建容器并启动

  - `--name="名称"`：设置容器名称

  - `-d`：后台方式运行

  - `-it`：使用交互方式运行

  - `-p `：指定容器端口
    
    - `-p ip:主机端口:容器端口`
    - `-p 主机端口:容器端口`：常用
    - `-p 容器端口`
    - `容器端口`
    
  - `-P`：随机指定端口

  - `-v `：容器数据卷挂载目录，数据同步

    - `-v 容器内路径`：匿名挂载

    - `-v 卷名:容器内路径`：具名挂载

      > docker中卷都在 **`/var/lib/docker/volumes`** 目录中
      >
      > 可以通过 **`docker volumes inspect 卷名`** 查看卷的详细信息

    - `-v 宿主机目录:容器内目录`：指定路径挂载

    > 容器的持久化和同步操作，将容器内的目录挂载到容器外，使数据同步，容器之间也可以数据共享
    
  - `--volumes-from 容器id`：实现数据同步，链式结构头容器为父容器与宿主机挂载，保证数据不丢失

- 限制容器内存

  ![memory](https://s2.loli.net/2023/12/01/35ZaMPcA1gKDtm7.png)

  - 未启动容器

    ```sh
    docker run -m 4g --memory-swap -1  
    ```

  - 已启动容器

    ```sh
    docker stop containerId
    docker update containerId -m 4g  --memory-swap -1
    docker start containerId
    ```

  **注意事项**

  ```sh
  --memory  或  -m  限制容器的内存使用量（如10m,200m等）
  --memory-swap # 限制内存和 Swap 的总和，不设置的话默认为--memory的两倍
  
  如果只指定了 --memory 则 --memory-swap 默认为 --memory 的两倍
  如果 --memory-swap 和 --memory 设置了相同值，则表示不使用 Swap
  如果 --memory-swap 设置为 -1 则表示不对容器使用的 Swap 进行限制
  如果设置了 --memory-swap 参数，则必须设置 --memory 参数
  
  后期 update --memory 时数值不能超过 --memory-swap 的值，
  否则会报错 Memory limit should be smaller than already set memoryswap limit
  ```

```sh
# 终端交互模式
docker run -it centos

# 后台运行模式
docker run -d centos 

# 在挂载卷后加  ro 或 rw 表示指定容器内的目录的权限，ro为只读则容器内该目录只读，默认为rw读写
docker run -d -v /home/dkh:/home:ro centos

#退出容器
exit

#退出并后台运行
Ctrl + P + Q
```

 

- `docker ps [选项]`：查看当前运行的容器

  - `-a`：列出所有运行过的容器
  - `-q`：只显示容器id

 

- `docker rm [选项] 容器id`：删除容器

  - `-f`：强制删除

  ```sh
  #删除所有容器
  docker rm -f ${docker ps -aq}
  
  docker ps -aq | xargs docker rm
  ```

- `docker start 容器id`：启动容器
- `docker restart 容器id`：重启容器
- `docker stop 容器id`：停止容器
- `docker kill 容器id`：强制停止容器



- `docker commit [选项] 容器id 新镜像名:TAG`

  - `-a="作者"`
  - `-m="提交信息"`

  ```sh
  docker commit -a="kongke" -m="设置tomcat主页" tomcat01 tomcat02:1.0
  ```

  > commit指令可以保存当前容器的状态，类似于虚拟机快照，提交变成新的镜像

### 4. 其他常用命令



- `docker logs [选项] 容器id`：查看日志

  - `-tf`：显示日志并带上时间戳
  - `--tail 数字`：显示日志条数

  ```sh
  #查看该容器的最后5条日志，并监控最新日志
  docker logs -tf --tail 5 aas12sdas
  ```

  

- `docker top`：查看容器内进程

- `docker inspect 容器id`：查看容器所有信息(元数据)



- `docker exec -it 容器id bashShell`：进入正在运行的容器(在容器中开启一个新的终端)
- `docker attach 容器id`：进入容器正在执行的终端



- `docker cp 容器id:容器内路径 目的主机路径`：从容器中复制文件到主机上

```sh
docker cp 8150473976e6:/home/test.txt /home
```



## 三、常用镜像安装



### 1. Nginx安装



- 搜索nginx镜像

  ```sh
  docker search nginx
  ```

- 下载

  ```sh
  docker pull nginx
  ```

- 启动nginx容器

  ```sh
  # 给镜像命名为nginx01 ，设置端口映射
  docker run -d --name nginx01 -p 3344:80 nginx
  ```

  > 注意此处需要打开防火墙3344端口

- 查看启动情况

  ```sh
  docker ps
  ```

- 访问nginx

  ```sh
  curl localhost:3344
  ```

- 进入容器

  ```sh
  docker exec -it nginx01 /bin/bash
  ```



### 2. Tomcat安装



- 查找并下载tomcat镜像

  ```sh
  docker pull tomcat:9.0
  ```

- 启动

  ```sh
  docker run -d --name tomcat01 -p 3355:8080 tomcat:9.0
  ```

- 进入容器

  ```sh
  #因为镜像为精简版，运行成功后没有主页，但主页相关文件在webapps.dist中，将其复制到webapps中则可访问
  docker exec tomcat01 /bin/bash
  
  cp -r webapps.dist/* webapps/
  ```

- 访问

  ```
  curl localhost:3355
  ```



### 3. ElasticSearch安装



- 查找并下载

  ```sh
  docker pull elasticsearch:7.6.2
  ```

- 配置容器

  ```sh
  docker run -d --name es01 -p 9200:9200 -p 9300:9300 \
  # 设置集群模式
  -e "discovery.type=single-node" \
  # 限制内存
  -e ES_JAVA_OPTS="-Xms64 -Xmx512m" \
  elasticsearch:7.6.2
  ```

- 访问

  ```sh
  curl localhost:9200
  ```

- 查看内存占用情况

  ```sh
  docker stats
  ```



### 4. Mysql安装

> mysql安装需要保证数据同步

- 查找并下载镜像

  ```sh
  docker pull mysql:5.7
  ```

- 启动并配置镜像

  ```sh
  docker run -d \
  -p 3307:3306 \
  # 此处为数据卷挂载
  -v /home/dkmysql/conf:/etc/mysql/conf.d \
  -v /home/dkmysql/data:/var/lib/mysql \
  # 设置mysql的密码
  -e MYSQL_ROOT_PASSWORD=123456 \
  --name mysql01 \
  mysql:5.7
  ```

- 利用三方软件登录测试





## 四、DockerFile

> DockerFile 就是用来构建 docker 镜像的**命令脚本**



### 1. DockerFile指令



**常用指令**：

- `FROM`：指定基础镜像
- `MAINTAINER`：备注镜像作者 姓名+邮箱
- `RUN`：构建是需要执行的命令
- `ADD`：添加文件到镜像内，例如：压缩包
- `WORKDIR`：镜像的工作目录
- `VOLUME`：挂载的目录
- `EXPOSE`：暴露的端口
- `CMD`：容器启动时需要运行的命令，只有最后一个会生效，会被覆盖
- `ENTRYPOINT`：容器启动时需要运行的命令，命令可以追加
- `ONBUILD`：当构建一个被继承 DockerFile 时 会触发onbuild的指令
- `COPY`：类似ADD 将文件复制到镜像中
- `ENV`：构建时配置环境变量



> CMD 与 ENTRYPOINT 的区别对比

**测试CMD**

```sh
# 在cmd中，执行构建好的镜像时，不能追加命令，只能覆盖命令
] vim dkfile-cmd

FROM centos:7
CMD ["ls","-a"]

] docker build -f dkfile-cmd -t cmdtest .
# 此时如果在指令后追加指令例如入下想达到 ls -al的功能则会报错
] docker run cmdtest -l
#此处报错称 -l 不是命令，因为此处 -l 会覆盖掉dkfile-cmd中最后一个cmd的命令 【ls -a】

#但如果将命令写为
] docker run cmdtest ls -al
#则会正确执行ls -al，因为ls -al 覆盖掉了dkfile-cmd中的【ls -a】
```

**测试ENTRYPOINT**

```sh
# 与上述环境相同
# 在ent中，执行构建好的镜像时,能追加命令
] vim dkfile-ent

FROM centos:7
ENTRYPOINT ["ls","-a"]

] docker build -f dkfile-ent -t enttest .
# 此时如果在指令后追加指令 【-l】
] docker run enttest -l
#此处会正确运行 【ls -al】指令，【-l】成功追加到 【ls -a】后
```



### 2. 编写简单文件



- 构建自定义centos

  ```dockerfile
  # 注意此处需要指定版本，因为默认centos8  不再维护，官方镜像源中已移除
  FROM centos:7
  MAINTAINER kongke<2843732083@qq.com>
  
  ENV MYPATH /usr/local
  WORKDIR $MYPATH
  
  RUN yum -y install vim
  RUN yum -y install net-tools
  
  EXPOSE 80
  
  CMD echo $MYPATH
  CMD echo "----end----"
  CMD /bin/bash
  
  ```


- 构建文件

  ```sh
  # 注意最后的点表示在当前目录的上下文关系
  docker build -f mydkfile-ct -t mycentos:0.1 .
  ```

- 查看构建过程

  ```sh
  docker history mycentos:0.1
  ```



### 3. 编写Tomcat镜像

创建镜像目录，结构为

```
--dkbuild
	--dktomcat
		--Dockerfile
		--readme.txt
		--test
		--dklogs
```

- 编写Dockerfile

  ```dockerfile
  FROM centos:7
  MAINTAINER kongke<2843732083@qq.com>
  
  COPY readme.txt /usr/local/readme.txt
  
  ADD jdk-8u202-linux-x64.tar.gz /usr/local
  ADD apache-tomcat-9.0.80.tar.gz /usr/local
  
  
  ENV MYPATH /usr/local
  WORKDIR $MYPATH
  
  ENV JAVA_HOME /usr/local/jdk1.8.0_202
  ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
  ENV CATALINA_HOME /usr/local/apache-tomcat-9.0.80
  ENV CATALINA_BASH /usr/local/apache-tomcat-9.0.80
  ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/lib
  
  EXPOSE 8080
  
  CMD /usr/local/apache-tomcat-9.0.80/bin/startup.sh
  
  ```

- 构建镜像

  ```sh
  # 此处因为文件名为Dockerfile且在当前目录，所以不用指定文件
  ] docker build -t mytomcat .
  ```

- 运行镜像

  ```sh
  ] docker run -it -p 9090:8080 --name mytomcat01 \
  # 此处将项目目录挂载
  -v /home/dkbuild/dktomcat/test:/usr/local/apache-tomcat-9.0.80/webapps/test \
  # 将日志目录挂载
  -v /home/dkbuild/dktomcat/dklogs:/usr/local/apache-tomcat-9.0.80/logs \
  mytomcat /bin/bash
  ```



## 五、发布镜像到远程仓库



### 1. 发布到DockerHub

- 登录DockerHub账号

  ```sh
  ] docker login -u kongke7
  password: #输入密码
  登录成功！
  ```

- 更改镜像命名

  > 因为发布镜像的规范为 用户名/镜像名:版本号 例如 -> kongke7/mytomcat:1.0
  >
  > 否则无法推送

  ```sh
  ] docker tag 42c1543f639b kongke7/mytomcat:1.0 
  ```

- 推送镜像

  ```sh
  ] docker push kongke7/mytomcat:1.0
  ```

  



### 2. 发布到阿里云镜像仓库

- 登录阿里云Docker Registry

```sh
$ docker login --username=kongke registry.cn-hangzhou.aliyuncs.com
```

> 用于登录的用户名为阿里云账号全名，密码为开通服务时设置的密码。
>
> 您可以在访问凭证页面修改凭证密码。

- 从Registry中拉取镜像

```sh
$ docker pull registry.cn-hangzhou.aliyuncs.com/kongke7/kongke7-test:[镜像版本号]
```

- 将镜像推送到Registry

```sh
$ docker login --username=kongke registry.cn-hangzhou.aliyuncs.com
$ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/kongke7/kongke7-test:[镜像版本号]
$ docker push registry.cn-hangzhou.aliyuncs.com/kongke7/kongke7-test:[镜像版本号]
```

> 请根据实际镜像信息替换示例中的[ImageId]和[镜像版本号]参数。

- 选择合适的镜像仓库地址

> 从ECS推送镜像时，可以选择使用镜像仓库内网地址。推送速度将得到提升并且将不会损耗您的公网流量。
>
> 如果您使用的机器位于VPC网络，请使用 registry-vpc.cn-hangzhou.aliyuncs.com 作为Registry的域名登录。

- 示例

> 使用"docker tag"命令重命名镜像，并将它通过专有网络地址推送至Registry。

```sh
$ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/kongke7/kongke7-test:[镜像版本号]
```

> 使用 "docker push" 命令将该镜像推送至远程。

```sh
$ docker push registry-vpc.cn-hangzhou.aliyuncs.com/acs/agent:0.7-dfb6816
```





## 六、Docker网络

> 当我们安装了Docker，就会多一个**Docker0**网卡，使用**桥接模式**连接网络
>
> Docker每启动一个容器，都会为容器分配一个ip地址

### 1. Docker0

> Docker0使用的**veth-pair**技术为容器间通信

- 使用  `ip addr`  命令查看地址，当启动了一个容器则会出现下图的网卡（75: veth2f50f93@if74）

![ipaddr](https://s2.loli.net/2023/11/02/rMhz57yaNFJSgCe.png)

- 每当增加一个容器，则会对应多一对网卡（77: veth407b0c8@if76）

![ipaddr2](https://s2.loli.net/2023/11/02/8UsuB9qpiIKc7gC.png)

> 则一对一对的网卡，就是veth-pair技术
>
> veth-pair就是一对虚拟设备接口，一端连接协议，一端彼此相连
>
> 正因如此，veth-pair 充当一座桥梁，连接各种虚拟设备

- 如图所示，veth-pair连接的原理

![vethpair](https://s2.loli.net/2023/11/02/1tjQLpTMIv29rXH.png)



### 2.自定义网路

- **网络模式**

  | 模式      | 介绍                             |
  | --------- | -------------------------------- |
  | bridge    | 桥接模式，docker默认             |
  | host      | 主机模式，与宿主机共享网路       |
  | none      | 不配置网络                       |
  | container | 容器网络连通（不常用，局限性大） |

- **查看docker网络信息**

  - `docker network ls`：查看网络信息 （其中bridge为Docker0）

    ![network](https://s2.loli.net/2023/11/02/rJ3XF8b1EHfz94p.png)

  - `docker network inspect 网络id `：查看某个网络的具体信息

- **创建自定义网络**

  - `--driver`：网络模式，默认bridge
  - `--subnet`：子网（划分网段）
  - `--gateway`：网关（通常为当前网段的第一个ip）

  ```sh
  [root@localhost ~]  docker network create \
  --driver bridge --subnet 192.168.0.0/16 --gateway 192.168.0.1 mynet
  
  4a17ecbfac448947ed9c0711ed291b3a63049832f8d23c3722e238bae15accc9
  [root@localhost ~]  docker network ls
  NETWORK ID     NAME      DRIVER    SCOPE
  f26af714313b   bridge    bridge    local
  50828ab4f805   host      host      local
  4a17ecbfac44   mynet     bridge    local
  e412b2fb7593   none      null      local
  ```

- **将容器运行到指定网络**

  ```sh
  [root@localhost ~] docker run -d -name tomcat-net-01 --net mynet tomcat
  ```

- 此时自定义网络内的容器可以通过容器名相互访问

  ```sh
  [root@localhost ~] docker exec -it tomcat-net-01 ping tomcat-net-02
  ```
  
- **网络连通**

  > 因为网络之间相互隔离，正常情况下一个网络中的容器无法连通另一网络中的容器，
  >
  > 但是，通过将容器与另一网络相连则可实现网络连通
  >
  > 即，一个容器两个ip

  ```sh
  ] docker network connect mynet tomcat01
  ```



## 七、实战部署



### 1. Redis集群部署



- 创建redis节点并启动各节点容器

  **编写shell脚本执行任务**

  ```shell
  #!/bin/bash
  
  for port in $(seq 1 6);
  do
  # 创建节点
  
          mkdir -p /mydata/dkredis/node-${port}/conf
          touch /mydata/dkredis/node-${port}/conf/redis.conf
          cat << EOF >/mydata/dkredis/node-${port}/conf/redis.conf
  port 6379
  bind 0.0.0.0
  cluster-enabled yes
  cluster-config-file nodes.conf
  cluster-node-timeout 5000
  cluster-announce-ip 172.38.0.1${port}
  cluster-announce-port 6379
  cluster-announce-bus-port 16379
  appendonly yes
  EOF
  
  #启动节点容器
  docker run -p 637${port}:6379 -p 1637${port}:16379 --name redis-${port} \
  -v /mydata/dkredis/node-${port}/data:/data \
  -v /mydata/dkredis/node-${port}/conf/redis.conf:/etc/redis/redis.conf \
  -d --net redis-net --ip 172.38.0.1${port} redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf;
  
  done
  
  ```

- 创建redis集群

  ```sh
  # 进入redis-1节点容器
  # 创建redis集群
  ] redis-cli --cluster create 172.38.0.11:6379 172.38.0.12:6379 172.38.0.13:6379 \
  172.38.0.14:6379 172.38.0.15:6379 172.38.0.16:6379 --cluster-replicas 1
  ```

  ![redis-jq](https://s2.loli.net/2023/11/02/TWvGdbUDK3C6OYk.png)

- 进入redis-1节点查看集群信息

  ```sh
  # 进入节点
  /data ] redis-cli -c
  ```

  ```sh
  # 查看集群信息
  127.0.0.1:6379> cluster info
  ```

  <img src="https://s2.loli.net/2023/11/02/KDZoRQU4PInavCW.png" alt="info" style="zoom:67%;" />

  ```sh
  # 查看节点信息
  127.0.0.1:6379> cluster nodes
  ```

  ![nodes](https://s2.loli.net/2023/11/02/SxQhXfvFdaiwN24.png)

- **部署成功**



```
        _ _                /\/|
       (_) |              |/\/ 
  _ __  _| |__   __ _  ___     
 | '_ \| | '_ \ / _` |/ _ \    
 | | | | | | | | (_| | (_) |   
 |_| |_|_|_| |_|\__,_|\___/    
                               
                               
```





### 2. 部署Springboot项目

- 编写简单springboot项目，并打成  `jar包` 

- 编写Dockerfile

  ```dockerfile
  FROM java:8
  
  MAINTAINER kongke<2843732083@qq.com>
  
  COPY *.jar /app.jar
  
  CMD ["--server.port=8080"]
  
  EXPOSE 8080
  
  ENTRYPOINT ["java","-jar","/app.jar"]
  ```

- 将`jar包`和`Dockerfile`上传至虚拟机

- 构建镜像

  ```sh
  ] docker build -t javawebtest:1.0 .
  ```

- 启动容器

  ```sh
  ] docker run -d -p 8080:8080 --name javaweb javawebtest:1.0
  ```

- 测试接口

  ```sh
  ] curl localhost:8080/hello
  ```

  ![res](https://s2.loli.net/2023/11/02/VuQXjskAnGywmE4.png)

- **部署成功！**
