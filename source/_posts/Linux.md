---
title: Linux
date: 2023-12-11 15:09:05
excerpt: Linux入门笔记
index_img: /blogIndexImg/linux.png
tags: linux
categories: 学习笔记
---
# <u>Linux-CentOS</u>

***

## 一、初识

### 1.网络连接的三种模式

1. 桥接模式

   > 虚拟机能和外部网络通信，但是容易造成IP冲突
   >
   > 因为：桥接模式下，虚拟机生成与主机网络在同一网段下的IP

2. NAT模式

   > 网络地址转换模式
   >
   > 虚拟机能与外部通信
   >
   > 不会引起IP冲突

   <img src="https://s2.loli.net/2023/11/02/3Y7CTpAkERxL1rQ.png" alt="nat" style="zoom: 50%;" />

3. 主机模式

   > 独立的系统

   <img src="https://s2.loli.net/2023/11/02/bIl3vr6u7ZXRKse.png" alt="netImg" style="zoom:50%;" />

### 2. Linux的目录结构

Linux目录由  **`/`**  开始，向下发展分支



![linuxMenu](https://s2.loli.net/2023/11/02/iqMjACp1kFRohEZ.png)



- **/bin** 【常用】：（/usr/bin , /user/local/bin）, 是**Binary**的缩写，用来存放最经常使用的命令
- **/sbin** ：（/usr/sbin , /usr/local/sbin）, s 就是 Super User 存放系统管理员使用的系统管理程序
- **/home** 【常用】: 存放普通用户的主目录，在Linux 中每个用户都有自己的目录
- **/root** 【常用】：系统管理员的主目录
- **/lib** :系统所需的最基本的动态连接共享库 ， 其作用类似于Window 里的DLL文件，几乎所有的应用程序都需要使用到
- **/lost + found** : 这个目录一般是空的，当系统非法关机后，就存放了一些文件
- **/etc** 【常用】：所有系统管理所需要的配置文件和子目录
- **/usr** 【常用】：非常重要的目录，用户的很多应用程序和文件都放在此处，类似于win中的program files
- **/boot** 【常用】：存放启动Linux时使用的核心文件，包括连接和镜像文件
- **/proc** 【不能动】：是一个虚拟目录。他是系统内存的映射，访问这个目录来获取系统信息
- **/srv** 【不能动】：service 的缩写，该目录存放一些服务启动之后需要提取的数据
- **/sys** 【不能动】: 这是Linux 2.6内核的一个很大变化，安装了2.6内核中新出现的一个文件系统sysfs
- **/tmp** : 存放临时文件
- **/dev** : 类似于win中的设备管理器，把所有的硬件用文件的形式存储
- **/media** 【常用】：Linux 系统会自动识别一些设备，例如U盘，识别后会把设备挂载到这个目录下
- **/mnt** 【常用】：该目录让用户临时挂载别的文件系统，可以将外部存储挂载在/mnt/上，进入目录就能查看内容，例如共享文件夹
- **/opt** ：给主机额外安装软件的目录
- **/usr/local** 【常用】：这是另一个给主机安装软件的目录，一般是通过编译源码的方式安装的程序
- **/var** 【常用】：这个目录存放着在不断扩充的东西 ， 习惯将经常被修改的目录放在这个目录下，包括日志文件
- **/selinux [security-enhanced linux]** : SE-Linux 是一种安全子系统，能控制程序只能访问特定文件，有三种工作模式可以自行设置



### 3. vi与vim

**三种模式**：

- 正常模式

  > 刚进入vi / vim 的状态
  >
  > 在任何模式下输入esc 将进入正常模式

- 插入模式

  > 在正常模式下输入  ，i , o , a , r进入

- 命令行模式

  > 正常模式下输入 / 或者 :

<u>常用快捷键</u>

1. **`yy`** : 复制当前行，例如 5yy 复制光标以下5行，配合粘贴 **`p`** 使用
2. **`dd`** ：删除当前行，5dd 删除光标以下5行
3. **`/内容`** ：查找文件中的对应内容，输入**n** 就是查找下一个
4. **`:set nu 与 :set nonu`** : 显示文件的行号，取消显示
5. **`G 与 gg`**：移动光标到文件末尾，首行
6. **`u`**：撤销上一个操作，类似于win中的CTRL+ Z
7. **`行号 + shift + g`** : 将光标跳转到该行

<img src="https://s2.loli.net/2023/11/02/oZpHywznP3WeV8E.png" alt="vi&vim" style="zoom: 67%;" />



### 4. 关机 & 重启 & 运行

基本命令：

- `shutdown -h  now`  立刻关机
- `shutdown -h 1`         会给当前访问虚拟机的所有用户发送这一条消息通知一分钟后将关机
- `shutdown -r now`     立即重启
- `halt `                           关机，作用同上
- `reboot`                        立即重启
- `sync`                            把内存的数据同步到磁盘

**注：无论重启或关闭系统，首先要运行sync命令防止数据丢失**

**注：目前的shutdown/reboot/halt 等命令在关机前进行了 sync ，但最好每次都先执行 sync**



**运行级别**

1. 运行级别种类

   - 0：关机
   - 1：单用户【找回密码】
   - 2：多用户没有网络服务
   - 3：多用户有网络服务
   - 4：系统未使用保留给用户
   - 5：图形界面
   - 6：系统重启

   可以使用 `init[num]` 来切换运行级别。

2. 设置默认运行级别

   - `systemctl get-default`：查看当前默认运行级别
   - `systemctl set-default TARGET.target`：设置默认运行级别
     - multi-user.target : 3
     - graphical.target ：5



### 5. 用户登录与注销

**注意事项**：

- 登录时尽量少用root账号避免操作失误
- 用 `su - 用户名` 切换账户
- 用`logout`来注销用户



### 6. 帮助指令

- `main [命令或配置文件]`：获取帮助信息，例如：main ls , 查看ls的帮助信息
- `help [命令]`：获取shell内置命令的帮助信息



## 二、用户管理

### 1. 账号增删

**添加账户**

- `useradd 用户名`
- `useradd -d 指定目录 用户名` ： 给新用户指定home目录
- `passwd 用户名`：设置/修改 密码
- `whoami`：查看当前用户

**删除用户**

- `userdel 用户名` ： 删除用户，保留home目录（建议使用）
- `userdel -r 用户名` ： 删除用户及home目录

### 2. 用户组

**对类似的有共性的多个用户进行同一管理**

<u>当用户没有指定的组时，该用户的用户组就是他自己</u>

- `groupadd 组名` ：新增组
- `groupdel 组名` ：删除组
- `useradd -g 用户组 用户名`：增加用户时直接加上组
- `usermod -g 用户组 用户名`：修改用户组

 

**用户组相关文件**

- `/etc/passwd` ：用户（user）的配置文件，记录各种信息

  > 每行的含义：用户名：口令：用户标识号：组标识号：注释性描述：主目录：登录Shell

  ![etcPassword](https://s2.loli.net/2023/11/02/8UCfhAmlOJZDo95.png)

- `/etc/shadow`：口令配置文件

  > 每行的含义：登录名：加密口令：最后一次修改时间：最小时间间隔：最大时间间隔：警告时间：不活动时间：失效时间：标志

  ![etcShadow](https://s2.loli.net/2023/11/02/dxqMtOUyTCKcAsJ.png)

- `/etc/group`：组的配置文件，记录Linux包含的组的信息

  > 每行的含义：组名：口令：组标识号：组内用户列表

  ![etcGroup](https://s2.loli.net/2023/11/02/xy4Yc1sI98P5WuE.png)



### 3. 找回root密码

1. 启动系统，进入开机界面，按方向键移动高亮条，选中第一个，按 `e` 进入编辑界面

<img src="https://s2.loli.net/2023/11/02/RpsGcrwv5t8fIai.png" alt="backpd" style="zoom:50%;" />

2. 将光标移动至 `linux16`开头的行的结尾，输入 `init=/bin/sh` 后按 `ctrl + x` 启动虚拟机，进入单用户模式（1）

<img src="https://s2.loli.net/2023/11/02/RUim3q8p5OIyb6L.png" alt="back2" style="zoom: 67%;" />

3. 在光标处输入：`mount -o remount,rw /` 后按回车键`Enter`

4. 在新的一行输入passwd，回车后输入新密码，再次输入密码确认，密码修改成功！

![back3](https://s2.loli.net/2023/11/02/stuNXZmP296Kozb.png)

5. 继续输入 `touch /.autorelabel` 回车后 继续输入 `exec /sbin/init` 回车后稍等片刻，系统将会自动重启，密码修改生效！

![back4](https://s2.loli.net/2023/11/02/dJhfaWNyVe8qprA.png)



## 三、常用指令

### 1. 文件目录



- `pwd`：显示前工作目录的绝对路径

- `ls[选项][目录或文件]` ：选项可以组合使用，例如: -la 顺序不影响。

  - `-a`：显示目录所有的文件和目录，包括隐藏的
  - `-l`：已列表形式显示信息

- `cd [参数]`：切换到指定目录，注意参数是 绝对路径 或 相对路径

  - `~ 或 无参`：回到自己的家目录
  - `..`：回到该目录的上一级目录

  **例如：**

  >当前目录为：/home/user1
  >
  >使用相对路径切换到 /root 目录

```
  cd ../../root
```

- `mkdir [选项] 要创建的目录`：创建目录

  - `-p`：创建多级目录

- `rmdir [选项] 要删除的空目录`：删除空目录

- `rm [选项] 要删除的文件或目录`：移除文件或目录

  - `-r`：递归删除整个文件夹
  - `-f`：强制删除不提示

- `touch 文件名`：创建空文件

- `cp [选项] 指定文件 指定目录`：将文件复制到指定目录

  - `-r`：递归复制整个文件夹
  - `\cp`：如指定文件夹有同名文件，此命令则强制覆盖不提示

- `mv`：移动文件与目录 或 重命名

  - `mv 原文件名 新文件名`：重命名文件
  - `mv 原文件路径 指定路径`：移动文件

- `cat [选项] 文件`：查看文件内容

  - `-n`：显示行号

  >cat 可与  `|` 管道命令组合使用 
  >
  >以下表示将管道符前的命令结果交给管道符后的命令处理

  ```
  cat /etc/profile | more
  ```

  `more`指令的交互操作：

  <img src="https://s2.loli.net/2023/11/02/Hi74C6NfD8KsjqG.png" alt="管道符" style="zoom:67%;" />

- `less 文件`：查看文件内容，但并不是一次性将文件加载后显示，而是根据需要加载的内容

  <img src="https://s2.loli.net/2023/11/02/k2E39XhbPLf5pvJ.png" alt="less" style="zoom:67%;" />

- `echo [选项] [输出内容]`：将内容输出到控制台

- `head [选项] 文件`：显示文件的开头部分内容，默认显示前十行

  - `-n 数字`：查看文件前n行

- `tail [选项] 文件`：显示文件的结尾内容，默认显示后十行

  - `-n 数字`：查看文件的后n行
  - `-f` ：实时追踪文件的所有更新

- `> 与 >>`：

  - `内容 > 文件`：输出重定向，将内容覆盖写入文件中
  - `内容 >> 文件`：追加，将内容追加写入文件末尾

- `ln -s 原文件或目录 软连接名`：给文件创建一个软连接（类似于win的快捷方式）

  - 删除软连接则当成文件删除

- `history [数字]`：查看执行过的指令，输入数字n，则显示最近n条

  - `!n`：执行历史中编号为 n 的指令



### 2. 时间日期



- `date [选项]`：显示当前日期
  - `-s "yyyy-MM-dd HH:mm:ss" `：设置系统当前时间
  - `+%Y`：显示年份
  - `+%m`：显示月份
  - `+%d`：显示当前一天
  - `"+%Y-%m-%d %H:%M:%S"`：显示年月十分秒
- `cal [年份]`：显示日历，默认显示当前月份
  - `cal 2023`：显示2023年所有月份的日历

 

### 3. 搜索查找类



- `find [搜索范围] [选项]`：该指令将从指定目录向下递归的遍历其各个子目录，将满足条件的文件或目录显示在终端

  - `-name`：按照指定文件名查找文件

  - `-user`：查找属于指定用户名所有文件

  - `-size`：按照指定文件大小查找文件

    - `+n`：大于
    - `-n`：小于
    - `n`：等于

    **例如**：  查找整个系统下大于20k 的文件 单位：k ， M ， G

    ```
    find / -size +20k 
    ```

- `locate 文件`：可以快速定位指定文件路径

  > 该指令利用事先建立的系统中所有文件名及路径的locate数据库快速定位文件，无需遍历整个系统速度快
  >
  > 为了保证定位的准确度，管理员必须定期更新locate时刻

  - `updatedb`：更新locate数据库，在第一次locate前需要使用updatedb构建locate数据库

- `grep [选项] 查找内容 源文件`：过滤查找相关内容

  - `-n`：显示匹配行及行号
  - `-i`：忽略字母大小写

  **例如**：在hello.txt中查找”yes“所在行，并显示行号

  ```
  grep -n "yes" /home/hello.txt
  ```

  还能与 `|` 管道符配合使用，效果同上

  ```
  cat /home/hello.txt | grep -n "yes"
  ```



### 4. 压缩与解压



- `gzip ` 文件：压缩文件，将文件压缩为*.gz

- `gunzip 文件.gz`：解压缩文件

- `zip [选项] XXX.zip 文件或目录`：压缩文件或目录

  - `-r`：递归压缩，即压缩目录

  **例如**：将home目录压缩为名为myHome.zip的压缩文件

  ```
  zip -r myHome.zip /home/ 
  ```

- `unzip [选项] 要解压的文件`：解压缩文件

  - `-d <目录>`：将文件解压到指定目录

  **例如**：将/home下的myHome.zip文件解压到 /opt/tmp目录下

  ```
  unzip -d /opt/tmp /home/myHome.zip
  ```

- `tar [选项] XXX.tar.gz 打包的内容`：打包目录压缩后格式为tar.gz

  - `-c`：产生tar打包文件
  - `-v`：显示详细信息
  - `-f`：指定压缩后的文件名
  - `-z`：同时压缩文件
  - `-x`：解包.tar文件

  **例如**：

  1. 将多个文件打包压缩成pc.tar.gz

  ```
  tar -zcvf pc.tar.gz /home/pig.txt /home/tiger.txt
  ```

  2. 将/home文件夹压缩成myHome.tar.gz

  ```
  tar -zcvf myHome.tar.gz /home/
  ```

  3. 将myHome.tar.gz  ==解压到==  /opt/tmp 目录下

  ```
  tar -zxvf /home/myHome.tar.gz -C /opt/tmp
  ```



## 四、组管理与权限管理



### 1. Linux组



Linux中每个用户必须属于一个组，在Linux文件中，有所有者，所在组，其他组的概念

- 所有者：默认为文件的创建者

  - `chown 用户名 文件名`：改变文件的所有者

- 所在组：默认为所有者的所在组

  - `chgrp 组名 文件名`：修改文件、目录所在组

  同时改变所有者和所属组

  ```
  chown user1:group1 abc.txt
  ```

  改变目录下所以子目录或文件

  ```
  chown -R user1 abc.txt
  chgrp -R group1 abc.txt
  chown -R user1:group1 abc.txt
  ```

- 其他组：所有者所在组之外的组

  - `usermod -g 新组名 用户名`：改变用户所在组

  - `usermod -d 目录名 用户名`：改变用户登录的初始目录

    ==注意==：用户需要有进入该目录的权限 



### 2. 权限



**权限的基本介绍**

![qx](https://s2.loli.net/2023/11/02/AVhEGrkj9DzQwiB.png)

1. 图中第一段  **`drwxr-xr-x`**，由十位字符组成
   1. 第 **0** 位为文件类型
      - `-`：表示普通文件
      - `d`：表示目录
      - `c`：表示字符设备文件，例如，鼠标，键盘
      - `b`：表示块设备，例如，硬盘
   2. 第 **1-3** 位确定所有者对文件拥有的权限
   3. 第 **4-6** 位确定所属组对文件拥有的权限
   4. 第 **7-9** 位确定其他用户对文件拥有的权限

| 权限          | 作用到文件          | 作用到目录                           |
| ------------- | ------------------- | ------------------------------------ |
| r (read) 4    | 读取，查看          | 读取，ls查看内容                     |
| w (write) 2   | 修改，不能删除[^注] | 修改，对目录内创建，删除，重命名目录 |
| x (execute) 1 | 可以被执行          | 可以进入该目录                       |

[^注]: 删除文件的前提条件是，对该文件所在的目录有写权限，才能删除该文件

2. 图中第二段  **`2`** ，表示，文件：硬连接数 ， 目录：子目录数
3. 图中第三，四段 **`root root`**，表示所有者和所属组
4. 图中第五段 `4096` 表示文件大小（字节），如果是文件夹则显示4096
5. 图中第六段 **`11月 3 22：09`**表示最后修改时间
6. 图中第七段 **`home`** 表示文件名



**修改权限**

- `chmod <操作语句> 被修改的文件`：修改文件或目录的权限

  1.  `+ , - , =` 变更权限

      - `+`：增加权限
      - `-`：取消权限
      - `=`：赋予权限

  2.  `u , g , o , a` 表示角色

      - `u`：所有者
      - `g`：所属组
      - `o`：其他人
      - `a`：所有人

  **例如**：对于/home/abc文件

  1. 给所有者读写执行，给所属组读执行，给其他人读执行

  ```
  chmod u=rwx,g=rx,o=rx /home/abc.txt
  ```

  2. 给所有者取消执行，给所属组增加写

  ```
  chmod u-x,g+w /home/abc.txt
  ```

3. 可以使用数字代替字母

   - `r=4 w=2 x=1` 所以 `rwx = 7`

   **例如**：将文件abc的权限修改为 `rwxr-xr-x`

   ```
   chmod 755 /home/abc.txt
   ```

   

## 五、任务调度



### 1. **crond**任务调度



是指系统在某个时间执行的特定的命令或程序

分为：

1. 系统工作：有些重要的工作必须周而复始的执行，如病毒扫描秒
2. 个别用户工作：个别用户可能希望执行某些程序，如mysql数据库备份

- `crontab [选项]`：进行定时任务的设置

  - `-e`：编辑crontab定时任务
  - `-l`：查询crontab任务
  - `-r`：删除当前用户的所以crontab任务

  **例如**：设置个人任务调度

  ```
  # 指令编辑定时任务，将打开/etc/crontab文件
  crontab -e
  # 编写定时任务
  */1 * * * * ls -l /etc/ > /tmp/to.txt
  ```

- `*/1 * * * *`

  ![crontab](https://s2.loli.net/2023/11/02/FPcw8JoN9RDuHge.png)

  - `*`：表示时间

  - `*/n`：表示，每隔n个时间单位为周期
    - `*/1 * * * *`：表示每分钟都执行
  - `,`：表示不连续的时间
    - `0 8,12,16 * * *`：表示每天的8，12，16点都执行命令
  - `-`：表示连续时间范围
    - `0 5 * * 1-6`：表示周一到周六的凌晨5点执行


- 常见用法：

  ```
  # 每隔一分钟将时间数据追加到/home/mydate.txt文件中
  */1 * * * * date >> /home/mydate.txt
  
  #每天2点将时间数据覆盖到/home/mydate.txt文件中
  * 2 * * * date > /home/mydate.txt
  ```


  - 编写简单脚本任务,每分钟将日期和时间数据追加写入mydate.txt文件中

  ```
  # 新建脚本文件mdate.sh
  vim mdate.sh
  
  # 写入指令
  cal >> /home/mydate.txt
  date >> /home/mdate.sh
  
  # 赋予用户对该脚本文件的执行权力
  chmod u+x /home/mdate.sh
  
  # 添加任务调度
  crontab -e
  
  # 写入
  */1 * * * * /home/mdate.sh
  
  # 用tail监控执行结果
  tail -f /home/mydate.txt
  ```

  

### 2. at定时任务



​	at命令是==一次性==定时计划任务，at的守护进程atd会已后台任务运行，检查作业队列来运行

默认是每60s检查队列，如果与任务时间匹配则执行任务

**注意**：<u>在使用at命令时一定要保证atd进程的启动</u> ，一般使用 `ps-ef | grep atd`指令检查



- `at [选项] 时间`：注意输出完成之后，按两次 `Ctrl + D`结束输入

  ![at](https://s2.loli.net/2023/11/02/KctHluiCATyoszw.png)

  - at的时间格式

    - `hh:mm`：小时分钟，例如，04：00

    - 模糊词语:

      - `midnight`：深夜
      - `noon`：中午
      - `teatime`：喝茶时间（一般下午四点）
      - 等待

    - 十二小时制：

      - `am`：上午
      - `pm`：下午

    - 具体日期：

      - `month day`
      - `mm/dd/yy`
      - `dd.mm.yy`

      **注意**：指定日期必须在指定时间后，例如 04:00 2023-9-21

    - 相对计时：

      - `now + count 时间单位`：minutes ,  hours , days ,weeks

    - 指定时间：

      - `today`
      - `tomorrow`

- `atq`：查看任务队列

- `atrm 编号`：删除已设置任务

**案例**：

```
[root@xxx ~]# at 5pm + 2days
at> /bin/ls /home<EOT> 注：按两次CTRL + D会出现<EOT>表示输出结束
job 1 at Thu Sep 7 16:34:00 2023

[root@xxx ~]# atq
job 1 at Thu Sep 7 16:34:00 2023 a root
```

​    

## 六、磁盘相关



linux磁盘分为，IDE硬盘，SCSI硬盘，目前基本上是SCSI硬盘

- IDE硬盘：

  - `hdx~`：其中hd为设备类型，x为盘号 ， ~表示分区

    >a为基本盘，b为基本从属盘，c为辅助主盘，d为辅助从属盘

- SCSI硬盘：

- `sdx~`：sd为类型，其余同上

- `lsblk [选项]`：查看分区情况

  - `-f`：详细信息



### 1. 分区

- `fdisk 磁盘地址`

  <img src="https://s2.loli.net/2023/11/02/GLd6fS7CQJmpxYK.png" alt="fdisk" style="zoom: 67%;" />

  <img src="https://s2.loli.net/2023/11/02/3TtcFvIXxGPhC8u.png" alt="fq" style="zoom: 67%;" />

  - `n`：添加分区
  - `w`：写入并退出

  ![fqcz](https://s2.loli.net/2023/11/02/twszG9m8qhln7xu.png)

  > 前两个可自主配置，后面默认即可（回车）

- `mkfs -t 文件格式 磁盘地址`：格式化磁盘

  <img src="https://s2.loli.net/2023/11/02/zg2RA6UKtdFxS4W.png" alt="gsh" style="zoom:67%;" />

  ![gsh2](https://s2.loli.net/2023/11/02/iMJaO1TEgW2nBDv.png)

> 如图，格式化成功！



### 2. 挂载

==**注意：用命令行挂载磁盘重启后会失效**==

- `mount 磁盘地址 目标目录地址`  ：挂载磁盘
- `umount 磁盘地址 或 目录地址`：卸载磁盘

![gz](https://s2.loli.net/2023/11/02/nz2tViRF9KQf1DS.png)



==**永久挂载**==

​	通过修改  `/etc/fstab` 实现，修改后执行  `mount -a` 即刻生效

![fstab](https://s2.loli.net/2023/11/02/KyosYtR6MFS2q1I.png)



### 3. 磁盘情况



**查询**指定目录的磁盘占用情况

- `du [选项]`：默认为当前用户
  - `-s`：目录占用大小总汇
  - `-h`：带计量单位
  - `-a`：含文件
  - `--max-depth=n`：子目录深度为 **n**
  - `-c`：列出明细同时增加汇总值



**磁盘实用指令**

- 统计/opt下文件的个数

  ```
  ls -l /opt | grep "^-" | wc -l
  ```

- 统计/opt下目录的个数

  ```
  ls -l /opt | grep "^d" | wc -l
  ```

- 统计/opt下所以文件的个数（包括所有子目录）

  ```
  ls -lR /opt | gerp "^-" | wc -l
  ```

- 统计/opt下所有目录的数量（包括所有子目录）

  ```
  ls -lR /opt | grep "^d" | wc -l
  ```

> 指令中，grep 后为正则表达式，过滤 ls 的结果中符合首字母合格的数据，wc 为统计数据

- 目录树状显示

  - `tree 目录`：
    - 如没有 tree 指令，则使用 `yum install tree `安装

  <img src="https://s2.loli.net/2023/11/02/mcor4ONgGECBUQZ.png" alt="tree" style="zoom:67%;" />

  

  

  

  

## 七、网络配置



### 1. 修改IP地址

  固定NAT模式下的IP地址

    1. 修改配置文件

  ```
  vim /etc/sysconfig/network-scripts/ifcfg-ens33
  ```

  ![ipconfig](https://s2.loli.net/2023/11/02/mJOGZF1iN9YMKD7.png)



    2. 注意网关与子网ip在同一网段内

<img src="https://s2.loli.net/2023/11/02/RsPnDJCLBd1FaZy.png" alt="ip2" style="zoom: 67%;" />

3. 重启网络服务，或重启系统后生效
   1. `service network restart`：重启网络服务
   2. `reboot`：重启系统



### 2. 修改主机名

修改主机名方便记忆，便于区分不同的主机

- `hostname`：查看当前主机名
- `vim /etc/hostname`：在该文件中指定当前主机名

修改过后，重启生效



### 3. host映射

设置host映射，使用主机名即可访问主机

1. windows中：

   - 修改 `C:\Windows\System32\drivers\etc\hosts`文件，配置映射关系

2. Linux中：

   - 修改 `/etc/hosts`文件，配置映射关系

   

   

### 4. DNS

域名系统，在互联网上映射域名与IP的一个分布式数据库



**windows中**

- `ipconfig /displaydns`：查看DNS域名解析缓存
- `ipconfig /flushdns`：手动清理dns缓存
  - 防止域名劫持

![dns](https://s2.loli.net/2023/11/02/ulfT7gB4RZtNQpi.png)



### 5. 防火墙 ###

- `firewall-cmd`：操作端口
  - `--permanent`
    - `--add-port=端口号/协议`：打开端口
    - `--remove-port=端口号/协议`：关闭端口
  - `--reload`：重载端口，更新操作后，重载生效
  - `--query-port`=端口号/协议：查询端口是否开放
  - `--list-ports`：查看所有开放的端口



**监控网络状态**

- `netstat [选项]`

  - `-an`：按一定顺序排列输出
  - `-p`：显示哪个进程再调用

- `-ntlp`：查看正在使用的端口

  > 注意经常查看网络状态，防止木马程序





## 八、进程



 ### 1.查看进程

- `ps [选项]`：
  - `-a`：显示当前终端所有进程
  - `-e`：显示所有进程
  - `-u`：以用户的格式显示进程
  - `-f`：以全格式显示进程
  - `-x`：显示后台运行的参数

![jc](https://s2.loli.net/2023/11/02/8lRCnpoS5eNmkJ9.png)

![gc2](https://s2.loli.net/2023/11/02/zKJ9lPMq1VibLjC.png)

**如图所示，各列的含义为：**

- `USER`：进程执行用户
- `PID`：进程号
- `PPID`：父进程号
- `%CPU`：占用CPU的百分比
- `%MEM`：占用物理内存的百分比
- `VSZ`：占用虚拟内存的情况
- `RSS`：占用物理内存的情况
- `TTY`：终端信息
- `STAT`：运行状态
  - `S`：睡眠，`s`，表示会话的先导进程
  - `N`：表示比普通优先级更低的优先级
  - `R`：正在运行
  - `D`：短期等待
  - `Z`：僵死进程，已经结束但未释放内存
  - `T`：被跟踪或被停止
- `START`：执行的开始时间
- `TIME`：占用的CPU时间
- `COMMAND`：进程名，执行该进程的指令



**查看进程树**

- `pstree [选项]`：以树状形式查看进程
  - `-p`：显示进程的PID
  - `-u`：显示进程的所属用户



### 2. 终止进程



- `kill [选项] 进程号`：通过进程号终止一个进程
  - `-9`：强制终止
- `killall 进程名称`：通过进程名终止所有同类进程



**示例**：

1. 终止远程登录服务sshd，再重新启动sshd服务

```
# 首先查看sshd相关所有进程
ps -aux | gerp sshd

#找到对应进程号（/usr/sbin/sshd - D）
kill 进程号

#重启sshd服务
/bin/systemctl start sshd.service
```

2. 终止多个gedit进程

```
killall gedit
```

3. 终止一个终端

```
#查询终端进程
ps -aux | grep bash

#找到对应进程号，注意此处需要 -9 强制终止，终端会触发进程保护机制
kill -9 10487 
```

   ![zz](https://s2.loli.net/2023/11/02/HmjyftOM8zPArJu.png)

  

### 3. 服务管理

服务本质是进程，但是运行在后台，通常会监听某个端口，等待其他程序的请求，又称之为守护进程

- `service [选项] 服务`：管理指令

  - `start`：启动
  - `stop`：暂停
  - `restart`：重启
  - `reload`：重载
  - `status`：状态

  **注意：**在CentOS 7.0之后，很多服务==不在使用service，而是systemctl==

  > service管理的服务在 /etc/init.d/中查看

- `setup`：查看所有系统服务

- `chkconfig [选项]`：设置所管理服务的各个运行级别设置自启动 或关闭

  - `[服务名] --list`：查看服务
  - `--level 运行级别 服务名 on或of`：设置某服务在该运行级别上的自启动的状态

  > chkconfig重新设置服务后自启动或关闭，需要重启后生效



- `systemctl [选项] 服务` ：服务管理指令

  - `start |stop | restart | status`：作用同上

  > systemctl指令管理的服务在 /usr/lib/systemd/system

  设置服务自启动状态

  - `list-unit-files`：查看服务开机启动状态
  - `enable 服务名`：设置服务开机自启
  - `disable 服务名`：关闭服务开机自启
  - `is-enable 服务名`：查询某个服务开机自启状态






### 4. 动态监控

top指令实现对进程的动态监控，与ps不同的是执行一段时间后可以更新正在运行的进程



- `top [选项]`：
  - `-d 秒数`：指定top命令每个几秒更新，默认3秒
  - `-i`：时top命令不显示闲置或将死的命令
  - `-p id号`：通过指定进程ID来监视某个进程的状态
- 交互操作
  - `P`：以CPU使用率排序，默认选项
  - `M`：以内存使用率排序
  - `N`：以PID排序
  - `q`：退出top
  - `u`：再输入用户名，监控该用户的进程
  - `k`：再输入进程ID，结束该进程



## 九、包管理



### 1. rpm

rpm用于互联网下载包的打包及安装工具。生成具有.RPM拓展名的文件

- `rpm [选项]`
  - `-q 包名`：查询软件包是否被安装
    - `-i 包名`：查询软件包详细信息
    - `-l 包名`：查询软件包中的文件
    - `-f 包名`：查询该文件的所属软件包
    - `-a 包名`：查询所安装的所有的rpm软件包
  - `-e 包名`：删除软件包
    - 如果删除时报出警告，无法发删除，则可以添加 `--nodeps` 强制删除（谨慎使用）
  - `-ivh 软件包路径全名称`：安装软件包
    - `-i`：install 安装
    - `-v`：verbose 提示
    - `-h`：hash 进度条

### 2. yum

yum是一个shell前端包管理器，基于rpm包管理，能够从指定服务器自动下载rpm包并安装，自动处理依赖关系并安装

- `yum [选项]`
  - `install 软件名`：安装指定包名
  - `list 软件名`：在yum服务器上查询是否有该软件



## 十、搭建JavaEE环境



### 1. 安装JDK



**安装步骤**

1. `mkdir /opt/jdk`

2. 通过xftp6上传到 /opt/jdk 下 cd /opt/jdk

3. 解压tar -zxvf jdk-8u261-linux-x64.tar.gz

4. `mkdir /usr/local/java`

5. `mv /opt/jdk/jdki.8.0_261 /usr/local/java`配置环境变量的配置文件`vim /etc/profile`

   ```
   export JAVA_HOME=/usr/local/java/jdk1.8.0_261
   
   export PATH=$JAVA_HOME/bin:$PATH
   ```

6. `source /etc/profile`让新的环境变量生效]测试是否安装成功

7. 编写一个简单的Hello.java输出"hello,world!"





### 2. 安装tomcat



**步骤**

1. 上传安装文件，并解压缩到 `/opt/tomcat`
2. 进入解压目录`/bin`，启动`tomcat ./startup.sh`
3. 开放端口8080

4. 测试是否安装成功

5. 在windows、Linux下访问http://linuxip:8080
   ·



### 3. 安装MySQL

**步骤**：

1. 新建文件夹`/opt/mysql`，并cd进去

```
wget http://dev.mysql.com/get/mysql-5.7.26-1.el7.x86_64.rpm-bundle.tar，下载mysql安装包
```

> PS: centos7.6自带的类MySQL数据库是maria-db，会跟MySQL冲突，要先删除。

```
运行 tar -xvf mysq1-5.7.26-1.e17.x86_64.rpm-bundle.tar
```

```
运行rpm -qa | grep mari，查询mariadb相关安装包

运行rpm -e --nodeps mariadb-libs，卸载
```

![maria](https://s2.loli.net/2023/11/02/Pl4r29zoudjBLDH.png)

2. 然后开始真正安装mysql，依次运行以下几条

```
rpm -ivh mysql-community-common-5.7.26-1.el7.x86_64.rpm

rpm -ivh mysql-community-libs-5.7.26-1.el7.x86_64.rpm

rpm -ivh mysql-community-client-5.7.26-1.el7.x86_64.rpm

rpm -ivh mysql-community-server-5.7.26-1.el7.x86_64.rpm
```

```
运行systemctl start mysqld.service，启动mysql
```

![mysql3](https://s2.loli.net/2023/11/02/hvuT8g134Wc5Pt9.png)

3. 然后开始设置root用户密码

4. Mysql自动给root用户设置随机密码，

```
运行 grep "password" /var/log/mysqld.log 可看到当前密码
```

5. 运行`mysql -u root -p`，用root用户登录，提示输入密码可用上述的，可以成功登陆进入mysql命令行

![mysqlpd](https://s2.loli.net/2023/11/02/6XlyqaUY72WojOE.png)

6. 设置root密码，对于个人开发环境，如果要设比较简单的密码==(生产环境服务器要设复杂密码)==

![mysqlpd3](https://s2.loli.net/2023/11/02/ePAcqMhpROuHXyQ.png)


```
可以运行set global validate_password_policy=0;
```

7. 提示密码设置策略 ( validate_password_policy 默认值1,)

```
set password for 'root@'localhost'=password('12345678');
```

8. 运行`flush privileges;`使密码设置生效

![mysqlpd2](https://s2.loli.net/2023/11/02/jeq4mh7SsvcYzO9.png)



- `mysqldump`



## 十一、Shell编程



​	**Shell**是一个命令行解释器，他为用户提供一个向Linux内核发送请求以便运行程序的界面系统级程序，用户可以用Shell来启动，挂起，停止和编写一些程序



**简单示例：**

```shell
vim hello.sh

写入:
#!/bin/bash
echo "nihao~"

运行：
sh hello.sh
或
./hello.sh
```





### 1. Shell变量

Shell变量分为<u>系统变量</u>和<u>用户自定义变量</u>

系统变量：\$HOME , \$PWD , $SHELL ,\$USER等

使用  `set` 指令可显示当前所有变量



**Shell变量定义**

1. 定义变量：`变量名=值`
2. 撤销变量：`unset 变量名`
3. 声明静态变量：`readonly 变量名`

==注==：静态变量不能 unset



**输出变量**

- `$变量名`
- `$(指令)`：可以将指令的结果返回
- ``(指令) `\`：作用同上



**设置环境变量**

- `export 变量名=变量值`：将Shell变量输出为环境变量
- `source 配置文件`：让修改立即生效~
- `echo $变量名`：查看环境变量的值



**多行注释**

```shell
:<<!
内容
！
```



**位置参数变量**

当一个shell脚本需要获取命令行的参数信息时，就需要在shell脚本中设置位置参数变量

- `$n`：n表示数字，\$0 表示shell指令本身 ，从​\$1开始表示传入的参数，1代表第一个参数
- `$*`：代表命令行中传入的所有的参数，但该命令将所有参数视为一个整体
- `$@`：代表命令行中传入的所有的参数，但该命令将参数分为各个个体
- `$#`：代表命令行中传入参数的数量



**预定义变量**

是shell设计者事先已经定义好的变量，可以直接在shell脚本中使用

- `$$`：当前进程的进程号PID
- `$!`：后台运行的最后一个进程的进程号
- `$?`：最后一次执行的命令的返回状态
  - `0`：表示上一个命令正确执行
  - `非0`：表示上一个命令执行不正确



### 2. 运算符

- `$((运算式))`：返回计算值
- `$[运算式]`：返回计算值，==推荐==
- `expr m + n`：计算运算式，如需返回计算值则要在语句外用 **``**嵌套
  - `+ ，- ，\* ，/ ，%`：运算符，注意乘号要使用转义字符



### 3. 条件判断

- `=`：比较字符串
- 整数比较
  - `-lt`：小于
  - `-le`：小于等于
  - `-gt`：大于
  - `-ge`：大于等于
  - `-ne`：不等于
- 文件权限判断
  - `-r`：读权限
  - `-w`：写权限
  - `-x`：执行权限
- 文件类型判断
  - `-f`：存在并且是普通文件
  - `-e`：存在
  - `-d`：存在并且是目录



### 4. 流程控制



**if判断**

```shell
#第一种
if [ 23 -ge 22 ]
then
	echo "大于"
fi

#第二种
if [ $1 -ge 60 ]
then
	echo "及格了"
elif [ $1 -lt 60 ]
then
	echo "不及格"
fi
```

注意：if 后 条件判断式 `[ 语句 ]`语句==与中括号之间要有空格==



**case语句**

```shell
case $1 in
"1")
	echo "周一"
;;
"2")
	echo "周二"
;;
"3")
	echo "周三"
;;
*)
	echo "其他"
;;
esac
```



**for循环**

```shell
#第一种
for 变量 in 值1 值2 值3等等
do
	程序语句
done

#示例(此时$@将传入的所有参数视为单个个体)
for i in $@
do
	echo $i
done

#示例(此时$*将传入的所有参数视为一个整体)
for i in $*
do
	echo $i
done

#第二种
for ((初始值;循环控制条件;变量变化))
do
	程序语句
done

#示例(注意此处i不能使用整数运算符)
SUN=0
for (( i=1; i<=$1; i++ ))
do
	SUM=$[$SUM+$i]
done
echo $SUM
```



**while循环**

```shell
while [ 语句 ]
do
	程序语句
done

#示例(注意此处条件判断时使用的是[]，语句中不能使用 > , < ,= 。若需要使用，则将[]改为 (()) 即可 )
SUM=0
i=0
while [ $i -le $1 ]
do
	SUM=$[$SUM+$i]
	i=$[$i+1]
done
echo $SUM
```



###  5. read读取控制台

- `read [选项] 参数`
  - `-p`：提示符
    - `read -p "请输入" NUM`
  - `-t`：读取时的等待时间，超时自动往后执行
    - `read -t 10 -p "请输入" NUM`



### 6. 函数



**简单系统函数**

- `basename 路径 [后缀]`：获取文件名
  - 如果加上了后缀 `basename /home/jack/aa.txt .txt`,则只返回单纯文件名`aa`
- `dirname 路径`：获取目录的最后一个  `/` 之前的所有路径



**自定义函数**

```shell
#注意返回值，有就写上，没有就不用写
function 方法名(){
	方法体
	[return int;]
}
#调用(有参就写在后面，无参不用写)
方法名 参数1 参数2 
```





### 7. 综合案例-备份数据库



**完整代码**

```shell
#!/bin/bash

#数据库备份目录
BACKUP=/data/backup/db
#获取当前时间
DATETIME=$(date +%Y-%m-%d_%H%M%S)
#数据库地址
HOST=localhost
#数据库用户名
DB_USER=root
#数据库密码
DB_PW=12345678
#数据库名
DATABASE='test'

#1. 创建备份目录，如不存在则创建
[ ! -d "${BACKUP}/${DATETIME}" ] && mkdir -p "${BACKUP}/${DATETIME}"


#2. 执行备份操作
mysqldump -u${DB_USER} -p${DB_PW} --host=${HOST} -q -R --databases ${DATABASE} | gzip > ${BACKUP}/${DATETIME}/$DATETIME.sql.gz

#3. 将文件打包为tar.gz
cd ${BACKUP}
tar -zcvf $DATETIME.tar.gz ${DATETIME}

#4. 将对应文件夹删除
rm -rf ${BACKUP}/${DATETIME}

#5. 检查目录中是否存在超过十天的文件，有则删除
find ${BACKUP} -atime +10 -name "*.tar.gz" -exec rm -rf {} \;

echo "备份数据库 $DATABASE 成功！"
```

**创建定时任务**

```sh
crontab -e

#写入

30 2 * * * /usr/sbin/mysql_db_backup.sh
```



## 十二、日志

日志记录着许多重要系统事件，对于主机安全很重要，可以通过日志来检查错误的原因或攻击者的痕迹



![log](https://s2.loli.net/2023/11/02/zmteW6vZ1pD9iuP.jpg)

  

### 1. 日志管理服务rsyslogd



**检查Linux中的rsyslogd服务是否启动**

```sh
ps aux | grep "rsyslog" 
```

**查询rsyslogd的自启动自启动状态**

```sh
systemctl list-unit-files | grep "rsyslog"
```



- 配置文件：/etc/rsyslog.conf

  - 编辑文件时的格式为 *.\*  存放日志文件

    - 第一个* 代表日志类型

      - `auth`：pam产生的日志
      - `authpriv`：SSH，FTP等登录信息的验证信息
      - `cron`：时间任务相关
      - `kern`：内核
      - `lpr`：打印
      - `mail`：邮件
      - `mark(syslog)-rsyslog`：服务内部信息，时间标识
      - `news`：新闻组
      - `user`：用户程序产生的相关信息
      - `uucp`：UNIX to UNIX copy 主机之间的相互通信 
      - `local 1-7`：自定义的日志设备

    - 第二个*代表日志级别

      - `debug`：有调试信息的，日志通信最多
      - `info`：一般信息日志，最常用
      - `notice`：最具有重要性的普通条件的信息
      - `warning`：警告级别
      - `err`：错误级别，阻止整个功能或模块不能正常工作的信息
      - `crit`：严重级别，组织整个系统或软件不能正常工作的信息
      - `alert`：需要立刻修改的信息
      - `emerg`：内核崩溃等重要信息
      - `none`：什么都不记录

      > 从上到下，级别从低到高，记录信息越来越少



**自定义日志**

1. 进入 `rsyslog.conf` 配置文件
2. 添加配置，并指定输出文件

```sh
vim /etc/rsyslog.conf

#添加配置

*.*                                      /var/log/diylog.log
```

![diylog](https://s2.loli.net/2023/11/02/TqUJrE3pbLQHxSY.jpg)



###  2. 日志轮替

日志轮替就是把旧的日志文件移动并改名，同时建立新的空日志文件，当旧日志文件超出保存范围后就会进行删除



**轮替规则管理**

- 编辑 `/etc/logrolate.conf` 配置文件中 `dateext` 参数

  > 默认为全局日志轮替规则，也可单独为某个文件配置(如下图最后几行)

  ![logrolate](https://s2.loli.net/2023/11/02/jPMW5c7xUoFOXgC.png)

- 也可将某个日志轮替规则写到`/etc/logrolate.d/`中

  > 就是上图最后几行

- 参数说明

  - `daily`：轮替周期为天
  - `weekly`：轮替周期为周
  - `monthly`：轮替周期为月
  - `rotate 数字`：保留日志文件的个数，0指不备份
  - `compress`：日志轮替时，旧日志进行压缩
  - `create mode owner group`：建立新日志时，同时指定新日志的权限和所有者与所有组
  - `mail address`：当日志轮替时，输出内容通过邮件发送至指定邮箱
  - `missingok`：如果日志不存在，则忽略该日志的警告信息
  - `notifempty`：如果日志为空文件则不进行日志轮替
  - `minsize 大小`：日志轮替的最小值，只有当日志达到最小值才会轮替，否则时间到了也不会轮替
  - `size 大小`：日志只有大于指定大小才会轮替，而不是按照时间轮替
  - `dateext`：使用日期作为日志轮替文件的后缀
  - `sharedscripts`：在此关键字之后的脚本只执行一次
  - `prerotate/endscript`：在日志轮替之前，执行脚本命令
  - `postrotate/endscript`：在日志轮替之后，执行脚本命令



### 3. 查看内存日志

注意内存日志，**重启清空**

- `journalctl`：查看全部内存日志
  - `-n 数字`：查看最新n条
  - `--since 19:00 --until 19:10:10 `：查看从开始时间到结束时间内的日志
  - `-p err`：查看报错日志
  - `-o verbose`：日志详细内容
  - `_PID=1234 _COMM=sshd`：查看包含这些函数的日志



## 十三、备份与恢复



### 1. dump

dump支持分卷和增量备份（差异备份）

> 增量备份支持分区，不支持文件或目录

- `dump [-cu] [数字] [-f 备份后的文件名] [-T 日期] [目录或文件系统]`
  - `-c`：创建新的归档文件，并将由一个或多个文件参数所指定的内容写入归档文件的开头
  - `-数字`：备份的层级 0-9 ，0为完整备份，指定其他层级则为增量备份，到 9 后则再次从 0 开始
  - `-f 备份后的文件名`：指定备份后的文件名
  - `-j`：调用bzlib库压缩备份文件，压缩后为bz2格式，让文件更小
  - `-T 日期` ：开始备份的时间和日期
  - `-u`：备份完成之后在 /etc/dumpdates 中记录备份的文件系统，层级，日期，时间
  - `-t`：指定文件名，若该文件已存在备份文件中，则列出姓名
  - `-W`：显示需要备份的文件及最后一次备份的层级，时间日期
  - `-w`：与-W类似，但仅显示需要备份的文件

例如，将/boot分区的所有内容备份到 /opt/boot.bak0.bz2 文件中，备份层级为 0

```sh
xfsdump -0uj -f /opt/book.bak0.bz2 /boot
```

**注**：需要用 `df -TH` 查看分区的类型，并在dump前加上对应的类型



### 2. restore

restore用来回复已备份的文件，可以从dump生成的备份文件中回复原文件

- `restore [模式选项] [选项]`：四个选项每次只能指定一种

  - `-C`：对比模式，将备份文件与已存在文件相互对比

  - `-i`：交互模式，在进行还原操作时，restore指令将依序询问用户

  - `-r`：还原模式

  - `-t`：查看模式，查看备份文件中由哪些文件

  - `-f 备份文件`：从指定文件中读取备份数据，进行还原操作





