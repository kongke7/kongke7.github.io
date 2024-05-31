---
title: Dubbo
date: 2023-12-11 15:02:40
excerpt: Dubbo入门笔记
index_img: /blogIndexImg/dubbo.png
tags: 微服务
categories: 学习笔记
---
# Dubbo

> 轻量级 Java RPC框架

**RPC简单原理**

![rpc](https://s2.loli.net/2023/11/02/wqmc4uvfhapKYJj.png)

**Dubbo简单架构**

![dubbo](https://s2.loli.net/2023/11/02/2pSwDBltfOQPXI7.png)

## 一、安装与启动

### 1. 安装注册中心

**zookeeper**

> 一个树形目录服务，支持变更推送，适合作为Dubbo的注册中心

![zookeeper](https://s2.loli.net/2023/11/02/nCAO1FgZP86EWwa.png)

### 2. 安装Dubbo管理控制台

**进入GitHub下载压缩包**

[apache/dubbo-admin](https://github.com/apache/dubbo-admin)

**使用maven打包并运行**

![mvn](https://s2.loli.net/2023/11/02/slpoiUdnGkVqKIj.png)

- 找到 `pom`文件所在目录

  - 打开终端输入

    ```vbscript
    rem 跳过测试打包
    mvn clean package -Dmaven.test.skip=true
    ```

- 找到 `jar`包所在目录

  - 打开终端输入

    ```vbscript
    rem 启动jar包
    java -jar xxx.jar
    ```

- `ui`    则使用  ` npm`打包

  ``` bash
  # install dependencies
  npm install
  
  # serve with hot reload at localhost:8080
  npm run dev
  
  # build for production with minification
  npm run build
  
  # build for production and view the bundle analyzer report
  npm run build --report
  ```

- 启动完成

  > 默认进入localhost:38082端口访问
  >
  > 具体则在 ui 包中的 `vue.config.js` 文件中查找



### 3. 编写示例项目

**使用XML**

目录结构

├─**customer**
│  ├─src
│  │  ├─main
│  │  │  ├─java
│  │  │  │  │  AppC.java
│  │  │  │  │
│  │  │  │  └─service
│  │  │  │          OrderServiceImpl.java
│  │  │  │
│  │  │  └─resources
│  │  │          consumer.xml
├─**interface**
│  ├─src
│  │  ├─main
│  │  │  ├─java
│  │  │  │  ├─bean
│  │  │  │  │      User.java
│  │  │  │  │
│  │  │  │  └─service
│  │  │  │          OrderService.java
│  │  │  │          UserService.java
├─**provider**
│  ├─src
│  │  ├─main
│  │  │  ├─java
│  │  │  │  │  App.java
│  │  │  │  │
│  │  │  │  └─service
│  │  │  │          UserServiceImpl.java
│  │  │  │
│  │  │  └─resources
│  │  │          provider.xml

> - 接口放在 interface 中单独管理
> - 实现类各写在 消费者 与 提供者 中
> - 消费者通过 Dubbo 远程调用提供者的接口实现



- `provider.xml`

  ```xml
  <!--    指定当前服务的名字-->
      <dubbo:application name="user-service-provider"/>
  
  <!--    指定注册中心的位置-->
      <dubbo:registry protocol="zookeeper" address="127.0.0.1:2181"/>
  
  <!--    指定通信规则 (通信协议 ， 通信端口)-->
      <dubbo:protocol name="dubbo" port="20880"/>
  
  <!--    暴露服务 ref指向实现对象-->
      <dubbo:service interface="service.UserService" ref="userService"/>
  <!--    服务的实现对象-->
      <bean id="userService" class="service.UserServiceImpl"/>
  
  <!--    配置监控中心-->
      <dubbo:monitor protocol="registry"/>
  ```

  

- `consumer.xml`

  ```xml
  <!--    设置包扫描       -->
      <context:component-scan base-package="service"/>
  
      <dubbo:application name="order-service-consumer"/>
      <dubbo:registry address="zookeeper://127.0.0.1:2181"/>
  
  <!--    声明需要的接口服务-->
      <dubbo:reference id="userService" interface="service.UserService"/>
  <!--    配置监控中心	   -->
      <dubbo:monitor protocol="registry"/>
  ```



- 两者都在  `pom`  文件中导入接口

  ```xml
          <dependency>
              <groupId>org.dutest</groupId>
              <artifactId>interface</artifactId>
              <version>1.0-SNAPSHOT</version>
          </dependency>
  ```



- 提供者向注册中心 注册（暴露）提供的服务

  ```Java
  public class UserServiceImpl implements UserService{
      @Override
      public List<User> getUsers(String name) {
          User aa = new User("AA", 12);
          User bb = new User("BB", 12);
  
          List<User> list = new ArrayList<>();
          list.add(aa);
          list.add(bb);
          return list;
      }
  }
  ```

  ```Java
  public class App {
      public static void main(String[] args){
          ClassPathXmlApplicationContext ioc = new ClassPathXmlApplicationContext("provider.xml");
          ioc.start();
      }
  }
  ```

  

- 消费者向注册中心订阅（调用）提供者接口

  ```java
  @Service
  public class OrderServiceImpl implements OrderService {
  
      @Autowired
      UserService userService;
  
      @Override
      public List<User> initOrder(String name) {
          return userService.getUsers("AA");
      }
  }
  ```

  ```Java
  public class AppC {
      public static void main(String[] args) {
          ClassPathXmlApplicationContext ioc = new ClassPathXmlApplicationContext("consumer.xml");
          OrderService orderService = ioc.getBean(OrderService.class);
          orderService.initOrder("AA");
      }
  }
  ```

**使用Springboot**

> Springboot则使用注解与yml配置文件，配置注册中心 与暴露和需要的服务

- `yml`  

  - provider

  ```yaml
  dubbo:
    application:
      name: user-service-provider
    registry:
      address: 127.0.0.1:2181
      protocol: zookeeper
    protocol:
      name: dubbo
      port: 20880
    monitor:
      protocol: registry
  ```

  - consumer

  ```yaml
  dubbo:
    application:
      name: order-service-consumer
    registry:
      address: zookeeper://127.0.0.1:2181
    monitor:
      protocol: registry
  server:
    port: 8081
  ```



- 同样在pom文件中导入接口

  ```xml
  		<dependency>
              <groupId>org.dutest</groupId>
              <artifactId>interface</artifactId>
              <version>1.0-SNAPSHOT</version>
          </dependency>
  ```

  

- 提供者向注册中心 注册（暴露）提供的服务

  ```java
  @Service
  // 暴露服务
  @DubboService
  public class UserServiceImpl implements UserService {
      @Override
      public List<User> getUsers(String name) {
          User aa = new User("AA", 12);
          User bb = new User("BB", 12);
  
          List<User> list = new ArrayList<>();
          list.add(aa);
          list.add(bb);
          return list;
      }
  }
  ```

  ```Java
  @EnableDubbo // 启用Dubbo
  @SpringBootApplication
  public class ProviderssApplication {
  
      public static void main(String[] args) {
          SpringApplication.run(ProviderssApplication.class, args);
      }
  
  }
  ```



- 消费者向注册中心订阅（调用）提供者接口

  ```Java
  @Service
  public class OrderServiceImpl implements OrderService {
  
      // 从注册中心远程引用
      @DubboReference
      UserService userService;
  
      @Override
      public List<User> initOrder(String name) {
          List<User> list = userService.getUsers("AA");
          return list;
      }
  }
  ```

  ```Java
  @RequestMapping("/order")
  @RestController
  public class OrderController {
  
      @Autowired
      OrderService orderService;
  
      @RequestMapping("/init")
      public List<User> initOrder(@RequestParam("name") String name){
          return orderService.initOrder(name);
      }
  }
  ```

  ```Java
  @EnableDubbo
  @SpringBootApplication
  public class ConsumerApplication {
  
      public static void main(String[] args) {
          SpringApplication.run(ConsumerApplication.class, args);
      }
  
  }
  ```



## 二、配置

**配置关系**

![conf](https://s2.loli.net/2023/11/02/ewDPxYU2JlNOy84.jpg)



### 1. 启动检测

> spring 启动后会根据配置文件默认检查注册中心是否存在需要的服务，没有则报错

- 通过xml设置启动不检查

  ```xml
  <dubbo:reference id="userService" interface="service.UserService" 
                   check="false"/>
  ```

  **全局配置所有消费者**

  ```xml
  <dubbo:consumer check="false"/>
  ```

  **配置注册中心启动不检查**

  ```xml
  <dubbo:registry check="false"/>
  ```



### 2. 超时与重试

> 防止，由于网络或其他原因，使消费者请求长时间没有回应，造成线程阻塞
>
> - 默认值为 `1000ms`
>
> 优先级
>
> - 精确优先
> - 消费者优先

![timeout](https://s2.loli.net/2023/11/02/1HziMgd3Rk6nFw7.png)



**重试**

> 超时失败后重试次数

```xml
<dubbo:reference id="userService" interface="service.UserService" 
                 retries="3"/>
```

==**注：**==

- **幂等**操作**能**设置重试次数
  - 多次操作产生的结果一致
    - 查询
    - 删除
    - 修改
- **非幂等**操作**不能**设置重试次数
  - 多次操作产生的结果不一致
    - 新增





### 3. 多版本

> 一个接口的实现的不同版本

- provider

  ```xml
  <!--  v1		-->
  	<dubbo:service interface="service.UserService" ref="userService" version="1.0.0"/>
  <!--    服务的实现对象-->
      <bean id="userService" class="service.UserServiceImpl"/>
  
  <!--   v2  -->
      <dubbo:service interface="service.UserService" ref="userService2" version="2.0.0"/>
      <!--    服务的实现对象-->
      <bean id="userService2" class="service.UserServiceImpl"/>
  ```

- consumer

  ```xml
  <!--    指定需要的版本-->
      <dubbo:reference id="userService" interface="service.UserService" version="1.0.0"/>
  ```

  - 随机版本（灰度发布）

  ```xml
  <!--    指定需要的版本-->
      <dubbo:reference id="userService" interface="service.UserService" version="*"/>
  ```



### 4. 本地存根

> 消费者在调用远程接口前
>
> 存根可以先进行一些校验

- 在接口模块中新建存根类

  ```Java
  public class UserServiceStub implements UserService{
  
  //    构造器输入UserService
      private final UserService userService;
  
      /**
       * 传入的的是userService远程代理对象
       *
       * @param userService 用户服务
       */
      public UserServiceStub(UserService userService) {
          super();
          this.userService = userService;
      }
  
      @Override
      public List<User> getUsers(String name) {
          if (StringUtils.hasLength(name)) {
              return userService.getUsers(name);
          }
          return null;
      }
  }
  ```

- 在  `consumer.xml`中配置指定使用的存根

  ```xml
      <dubbo:reference id="userService" interface="service.UserService" version="1.0.0"
          stub="service.UserServiceStub"/>
  ```



## 三、高可用



### 1. Zookeeper宕机与Dubbo直连



**Zookeeper宕机**

![dj](https://s2.loli.net/2023/11/02/IhZDl37r6mG4t29.png)



**Dubbo直连**

- 绕过注册中心，直接连接远程服务

  ```Java
  @Service
  public class OrderServiceImpl implements OrderService {
  
  // 	从注册中心远程引用
  //    @DubboReference
    // Dubbo 直连  
      @DubboReference(url = "127.0.0.1:20880")
      UserService userService;
  
      @Override
      public List<User> initOrder(String name) {
          List<User> list = userService.getUsers("AA");
          return list;
      }
  }
  ```

  

### 2. 集群模式下的负载均衡



**Random LoadBalance**

![rlb](https://s2.loli.net/2023/11/02/NSLYuIabrPJyMiW.png)



**RandomRobin LoadBalance**

![rrlb](https://s2.loli.net/2023/11/02/GSQRj5bovgN9JPA.png)



**LeastActive LoadBalance**

![lalb](https://s2.loli.net/2023/11/02/SiZAmBdcnQarPbJ.png)



**ConsistentHash LoadBalance**

![chlb](https://s2.loli.net/2023/11/02/aQI5pidTjOlwSHy.png)

**服务端服务级别**

```xml
<dubbo:service interface="..." loadbalance="roundrobin" />
```

**客户端服务级别**

```xml
<dubbo:reference interface="..." loadbalance="roundrobin" />
```

**服务端方法级别**

```xml
<dubbo:service interface="...">
    <dubbo:method name="..." loadbalance="roundrobin"/>
</dubbo:service>
```

**客户端方法级别**

```xml
<dubbo:reference interface="...">
    <dubbo:method name="..." loadbalance="roundrobin"/>
</dubbo:reference>
```





### 3. 服务降级

> 当服务器压力剧增的情况下，根据实际业务情况及流量，对一些服务和页面有策略的不处理或换种简单的方式处理，
>
> 从而释放服务器资源以保证核心交易正常运作或高效运作。

**配置**

```xml
mock="[fail|force]return|throw xxx"
```

- fail 或 force 关键字可选，表示调用失败或不调用强制执行 mock 方法，如果不指定关键字默认为 fail
- return 表示指定返回结果，throw 表示抛出指定异常
- xxx 根据接口的返回类型解析，可以指定返回值或抛出自定义的异常



**例：**

```xml
<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" mock="return" />

<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" mock="return null" />

<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" mock="fail:return aaa" />

<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" mock="force:return true" />

<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" mock="fail:throw" />

<dubbo:reference id="demoService" interface="com.xxx.service.DemoService" 
                 mock="force:throw java.lang.NullPointException" />
```



**配合 dubbo-admin 使用**

- 应用消费端引入 [`dubbo-mock-admin`](https://github.com/apache/dubbo-spi-extensions/tree/master/dubbo-mock-extensions)依赖
- 应用消费端启动时设置 JVM 参数，`-Denable.dubbo.admin.mock=true`
- 启动 dubbo-admin，在服务 Mock-> 规则配置菜单下设置 Mock 规则

> 以服务方法的维度设置规则，设置返回模拟数据，动态启用/禁用规则



**注意事项**

>  Dubbo 启动时会**检查配置**，当 mock 属性值配置有误时会启动失败，可根据错误提示信息进行排查

- **配置格式错误**，如 `return+null` 会报错，被当做 mock 类型处理，`return` 后面可省略不写或者跟空格后再跟返回值
- **类型找不到错误**，如自定义 mock 类、throw 自定义异常，请检查类型是否存在或是否有拼写错误





### 4. 集群容错



**整合Hystrix**

- 导入依赖

  ```xml
  <dependency>
  	<groupld>org.springframework.cloud</groupld>
  	<artifactld>spring-cloud-starter-netflix-hystrix</artifactld>
      <version>1.4.4.RELEASE</version>
  </dependency>
  ```

- 在启动类激活

  ```Java
  @EnableDubbo(scanBasePackages = "com.example.providerss") // 启用Dubbo
  @EnableHystrix // 启用容错
  @SpringBootApplication
  public class ProviderssApplication {
  
      public static void main(String[] args) {
          SpringApplication.run(ProviderssApplication.class, args);
      }
  
  }
  ```

  ```Java
  @EnableDubbo
  @EnableHystrix
  @SpringBootApplication
  public class ConsumerApplication {
  
      public static void main(String[] args) {
          SpringApplication.run(ConsumerApplication.class, args);
      }
  
  }
  ```

- 在指定方法上加入Hystrix管理

  ```Java
  @Service
  // 暴露服务
  @DubboService
  public class UserServiceImpl implements UserService {
  
      @HystrixCommand(fallbackMethod = "hello")
      @Override
      public List<User> getUsers(String name) {
          User aa = new User("AA", 12);
          User bb = new User("BB", 12);
  
          List<User> list = new ArrayList<>();
          list.add(aa);
          list.add(bb);
          return list;
      }
  
      /**
       * 出错时调用
       */
      public List<User> hello(String name) {
          return Arrays.asList(new User("CC", 12), new User("DD", 12));
      }
  }
  ```

  


## 四、原理

### 1. RPC与Netty原理



**RPC**

![rpc](https://s2.loli.net/2023/11/02/wqmc4uvfhapKYJj.png)



**Netty**

> Netty是一个异步事件驱动的网络应用程序框架，用于快速开发可维护的高性能协议服务器和客户端。
>
> 它极大地简化并简化了TCP和 UDP套接字服务器等网络编程。



- **NIO**

  ![nio](https://s2.loli.net/2023/11/02/Bj5vWaTx4KQze6g.png)

- netty则是基于nio框架

  ![netty](https://s2.loli.net/2023/11/02/m5U3ZBSQCqYdzAs.png)



### 2. Dubbo框架

![kj](https://s2.loli.net/2023/11/02/cCtzSHhNbUIsy7d.png)