---
title: SpringCloud
date: 2023-12-11 15:22:09
index_img: /blogIndexImg/springcloud.png
excerpt: SpringCloud,SCAlibaba,入门笔记
tags: 微服务
categories: 学习笔记
---
# SpringCloud

## 一、微服务介绍

### 1. **什么是微服务**

- 微服务是一种架构风格
- 一个应用拆分为一组小型服务
- 可独立部署和升级
- 服务之间使用轻量级HTTP交互
- 服务围绕业务功能拆分
- 可以由全自动部署机制独立部署
- 去中心化，服务自治

### 2. **技术架构**

> **SpringCloud=分布式微服务架构的站式解决方案，是多种微服务架构落地技术的集合体，俗称微服务全家桶**

![sp](https://s2.loli.net/2023/12/11/dojxUBtal79WVAq.png)



- **服务调用 、服务降级、服务注册与发先、服务熔断、负载均衡、服务消息队列、服务网关**
- **配置中心管理、自动化构建部署、服务监控、全链路追踪、服务定时任务、调度操作**



### 3. **相关技术栈**

![jsz](https://s2.loli.net/2023/11/02/iTdp3XvHRWlGSgj.png)

![jsz2](https://s2.loli.net/2023/11/02/fMnNkGVXWCaxqcD.png)

### 4. **版本选择**

- **[官方匹配查询](https://start.spring.io/actuator/info)**
- **[官网](https://spring.io/projects/spring-cloud)**





## 二、服务注册与发现

### 1. CAP理论

#### 1) CAP

![cap](https://s2.loli.net/2023/11/02/hNo95wxpbCmUtrB.png)

**C：Consistency (强一致性)**

**A：Availability (可用性)**

**P：Partition tolerance （分区容错性)**

> 最多只能同时较好的满足两个



**CAP理论的核心**

> 一个分布式系统不可能同时很好的满足**一致性**，**可用性**和**分区容错性**这三个需求。

> 因此，根据CAP原理将其分成了满足CA原则、满足CP原则和满足AP原则三大类

- **CA** - 单点集群，满足—致性，可用性的系统，通常在可扩展性上不太强大。
- **CP** - 满足一致性，分区容忍必的系统，通常性能不是特别高。
- **AP** - 满足可用性，分区容忍性的系统，通常可能对一致性要求低一些。





#### 2) AP架构

**Eureka**

![ap](https://s2.loli.net/2023/11/02/jnbge6NWMxSmG97.png)



当网络分区出现后，为了保证可用性，系统B可以返回旧值，保证系统的可用性。

**结论：**违背了一致性C的要求，只满足可用性和分区容错，即AP





#### 3) CP架构

**ZooKeeper/Consul**

![cp](https://s2.loli.net/2023/11/02/TVDpvlzOIKXGZ93.png)

当网络分区出现后，为了保证一致性，就必须拒接请求，否则无法保证一致性。

**结论：**违背了可用性A的要求，只满足一致性和分区容错，即CP。



**CP 与 AP 对立的矛盾关系。**



#### 4) 三个注册中心异同点

| 组件名    | 语言 | CAP  | 服务健康检查 | 对外暴露接口 / Spring Cloud集成 |
| --------- | ---- | ---- | ------------ | ------------------------------- |
| Eureka    | Java | AP   | 可配支持     | HTTP                            |
| Consul    | Go   | CP   | 支持         | HTTP/DNS                        |
| Zookeeper | Java | CP   | 支持客户端   | 已集成                          |




### 2. Eureka

**Eureka**

![erka](https://s2.loli.net/2023/11/02/mg6czilGsZ3BYtr.png)

#### 1) **Eureka的两个组件**

**Eureka Server 和 Eureka Client**

- **Eureka Server**提供服务注册服务

  各个微服务节点通过配置启动后，会在Eureka Server中进行注册，

  这样Eureka Server中的服务注册表中，将会存储所有可用服务节点的信息，

  服务节点的信息可以在界面中直观看到。

  ```xml
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
  </dependency>
  ```

  **yml**

  ```yaml
  eureka:
    server:
  #    关闭自我保护机制
  #    enable-self-preservation: false
  #    设置定期清理过期服务的间隔时间
  #    eviction-interval-timer-in-ms: 2000
    instance:
      hostname: eureka7001.com
    client:
  #    表示不向注册中心注册自己
      register-with-eureka: false
  #    表示自己就是注册中心，不需要检索自己的服务
      fetch-registry: false
  #    设置与eureka交互的地址
      service-url:
  #      集群
        defaultZone: http://eureka7002.com:7002/eureka/
  ```

  **主类添加注解激活**

  ```Java
  @EnableEurekaServer
  @SpringBootApplication
  public class EurekaMain7001 {
  
      public static void main(String[] args) {
          SpringApplication.run(EurekaMain7001.class , args);
      }
  }
  ```

  

- **Eureka Client**通过注册中心进行访问

  它是一个Java客户端，用于简化Eureka Server的交互，

  客户端同时也具备一个内置的、使用轮询(round-robin)负载算法的负载均衡器。

  在应用启动后，将会向Eureka Server发送心跳(默认周期为30秒)。

  如果Eureka Server在多个心跳周期内没有接收到某个节点的心跳，

  Eureka Server将会从服务注册表中把这个服务节点移除（默认90秒)

  ```xml
  <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
  </dependency>
  ```

  **yml**

  ```yaml
  eureka:
    instance:
      instance-id: payment8001
  #    访问路径显示ip
      prefer-ip-address: true
  #    向服务端发送心跳的时间间隔，单位为秒（默认是30秒）
  #    lease-renewal-interval-in-seconds: 1
  #    表示服务的存活时间，单位为秒（默认是90秒）超时未收到心跳则剔除服务
  #    lease-expiration-duration-in-seconds: 2
    client:
      register-with-eureka: true
  #    表示是否向注册中心查询自己的注册信息，默认为true，单点可以不配，集群必须配置为配合Ribbon实现负载均衡
      fetchRegistry: true
      service-url:
  #      集群
        defaultZone: http://eureka7002.com:7002/eureka,http://eureka7001.com:7001/eureka
  ```



#### 2) 集群与负载均衡

**注：集群环境时修改主机ip映射便于区分**

- 找到   `C:\Windows\System32\drivers\etc`   路径下的   `hosts`  文件，修改映射配置添加进hosts文件

```
127.0.0.1 eureka7001.com
127.0.0.1 eureka7002.com
```



**配置文件**

- **server**

  > 多台eureka相互注册

  ```yaml
  eureka:
    instance:
      hostname: eureka7001.com
    client:
      service-url:
  #      集群
        defaultZone: http://eureka7002.com:7002/eureka/
  ```

- **client**

  > 将服务注册到每一台eureka中
  >
  > 并且相同的服务，同一服务名不同id

  **cloud-payment-service**

  ```yaml
  eureka:
    instance:
      instance-id: payment8001
  #    访问路径显示ip
      prefer-ip-address: true
    client:
      register-with-eureka: true
  #   表示是否向注册中心查询自己的注册信息，默认为true，单点可以不配，集群必须配置为配合Ribbon实现负载均衡
      fetchRegistry: true
      service-url:
  #     集群
        defaultZone: http://eureka7002.com:7002/eureka,http://eureka7001.com:7001/eureka
  ```

  ```yaml
  eureka:
    instance:
      instance-id: payment8002
  #    访问路径显示ip
      prefer-ip-address: true
    client:
      register-with-eureka: true
      fetchRegistry: true
      service-url:
  #      集群
        defaultZone: http://eureka7002.com:7002/eureka,http://eureka7001.com:7001/eureka
  ```



**开启负载均衡**

- **RestTemplate**

  ```java
    @Configuration
    public class ApplicationContextConfig {
    
        @Bean
        @LoadBalanced //使用@LoadBalanced注解赋予RestTemplate负载均衡的能力
        public RestTemplate getRestTemplate(){
            return new RestTemplate();
        }
    
    }
  ```

- **Controller**

  ```java
  public class OrderController {
  //    private static final String PAYMENT_URL = "http://localhost:8001";
  //    修改为服务名，开启集群访问
      private static final String PAYMENT_URL = "http://CLOUD-PAYMENT-SERVICE";
  ```

  

#### 3) 自我保护

> 保护模式主要用于一组客户端和Eureka Server之间存在网络分区场景下的保护。
>
> 一旦进入保护模式，Eureka Server将会尝试保护其服务注册表中的信息，
>
> 不再删除服务注册表中的数据，也就是不会注销任何微服务。

1. 某时刻某一个微服务不可用了，Eureka不会立刻清理，依旧会对该微服务的信息进行保存。

2. 属于CAP里面的AP分支。

3. 自我保护机制∶默认情况下Eureka Client定时向Eureka Server端发送心跳包



**关闭自我保护**

- **server**

  ```yaml
  eureka:
    server:
  #    关闭自我保护机制
      enable-self-preservation: false
  #    设置定期清理过期服务的间隔时间
      eviction-interval-timer-in-ms: 2000
  ```

- **client**

  ```yaml
  eureka:
    instance:
  #    向服务端发送心跳的时间间隔，单位为秒（默认是30秒）
      lease-renewal-interval-in-seconds: 1
  #    表示服务的存活时间，单位为秒（默认是90秒）超时未收到心跳则剔除服务
      lease-expiration-duration-in-seconds: 2
  ```

  

#### 4) 服务发现

**DiscoveryClient**

> 开启服务发现，可获取eureka服务器上的所有的已注册服务

```Java
	/**
     * 引入spring的
     */
    @Resource
    private DiscoveryClient discoveryClient;


    @GetMapping("/discovery")
    public Result aboutMe(){
//        获取注册中心已注册的服务
        List<String> list = discoveryClient.getServices();
        List<List<ServiceInstance>> res =
                list.stream().map(serverName -> discoveryClient.getInstances(serverName))
                        .collect(Collectors.toList());

        return Result.success(200,"成功",res);
    }
```



### 3. Zookeeper

> zookeeper是临时节点，属于CAP中的CP分支

#### 1) 配置

**pom**

> 注意版本问题

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
</dependency>
```

**yml**

```yaml
#8004表示注册到zookeeper服务器的支付服务提供者端口号
server:
  port: 8004

#服务别名----注册zookeeper到注册中心名称
spring:
  application:
    name: cloud-provider-payment
  cloud:
    zookeeper:
      connect-string: 127.0.0.1:2181

```

**zookeeper客户端**

> 注册成功则在services中出现服务名

```bash
[zk: localhost:2181(CONNECTED) 0] ls /
[services, zookeeper]
[zk: localhost:2181(CONNECTED) 1] ls /services/cloud-provider-payment
[a4567f50-6ad9-47a3-9fbb-7391f41a9f3d]
[zk: localhost:2181(CONNECTED) 2] get /services/cloud-provider-payment/a4567f50-6ad9-47a3-9fbb-7391f41a9f3d
{"name":"cloud-provider-payment","id":"a4567f50-6ad9-47a3-9fbb-7391f41a9f3d","address":"192.168.199.218","port":8004,"ss
lPort":null,"payload":{"@class":"org.springframework.cloud.zookeeper.discovery.ZookeeperInstance","id":"application-1","
name":"cloud-provider-payment","metadata":{}},"registrationTimeUTC":1612811116918,"serviceType":"DYNAMIC","uriSpec":{"pa
rts":[{"value":"scheme","variable":true},{"value":"://","variable":false},{"value":"address","variable":true},{"value":"
:","variable":false},{"value":"port","variable":true}]}}
[zk: localhost:2181(CONNECTED) 3]

```

**Controller**

```Java
@RequestMapping("/consumer")
@RestController
public class OrderZkController {

    private static final String INVOKE_URL = "http://cloud-provider-payment";
```



### 4. Consul

> Consul是一套开源的分布式服务发现和配置管理系统，由HashiCorp 公司用Go语言开发。

#### 1) 启动

**官网下载后启动exe文件**

```bash
// 开发者模式启动
consul agent -dev
```

![consul](https://s2.loli.net/2023/11/02/xX185E3wjOrQpql.png)

**访问8500端口进入可视化界面**

![consul2](https://s2.loli.net/2023/11/02/NjVenXyGA1JkzwQ.png)

#### 1) 配置

**pom**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-consul-discovery</artifactId>
</dependency>
```



**yml**

```yaml
###consul服务端口号
server:
  port: 8006

spring:
  application:
    name: consul-provider-payment
####consul注册中心地址
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        service-name: ${spring.application.name}
```



**Controller**

```Java
@RequestMapping("/consumer")
@RestController
public class OrderConsulController {

    private static final String INVOKE_URL = "http://consul-provider-payment";

```



**配置成功则可在可视化面板看到服务信息**

![consul3](https://s2.loli.net/2023/11/02/kDIzsBbpEldQ157.png)







## 三、服务调用

### 1. ~~Ribbon~~

> 已淘汰

Spring Cloud Ribbon是基于Netflix Ribbon实现的一套**客户端负载均衡的工具**。



#### 负载均衡

**Load Balance**

> 简单的说就是将用户的请求平摊的分配到多个服务上，从而达到系统的HA (高可用)。
>
> 常见的负载均衡有软件Nginx，LVS，硬件F5等。



**集中式LB**

即在服务的消费方和提供方之间**使用独立的LB设施**(可以是硬件，如F5, 也可以是软件，如nginx)，由该设施负责把访问请求通过某种策略转发至服务的提供方;



**进程内LB**

将LB逻辑**集成到消费方**，消费方从服务注册中心获知有哪些地址可用，然后自己再从这些地址中选择出一个合适的服务器。



**Ribbon就属于进程内LB**



#### Ribbon默认自带的负载规则

![ribbon](https://s2.loli.net/2023/11/02/TvzRFHcI9KDjg3t.png)





### 2. Open Feign

> **Feign**是一个**声明式WebService客户端**
>
> **Feign**集成了**Ribbon**
>
> **OpenFeign**是Spring Cloud在Feign的基础上**支持了SpringMVC的注解**



#### 配置

**pom**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

**启动类上激活**

```Java
@EnableFeignClients
@SpringBootApplication
public class OrderFeignMain80 {
    public static void main(String[] args) {
        SpringApplication.run(OrderFeignMain80.class,args);
    }
}
```

**业务类**

```Java
@FeignClient("CLOUD-PAYMENT-SERVICE")
public interface PaymentFeignService {

    @GetMapping("/payment/get/{id}")
    Result<Payment> getPayment(@PathVariable("id") Long id);

    @GetMapping(value = "/payment/feign/timeout")
    String paymentFeignTimeout();
}
```



#### 日志增强

**日志级别**

- **NONE**：默认的，不显示任何日志;
- **BASIC**：仅记录请求方法、URL、响应状态码及执行时间;
- **HEADERS**：包含BASIC，还有请求和响应的头信息;
- **FULL**：包含HEADERS，还有请求和响应的正文及元数据。



**配置日志Bean**

```Java
@Configuration
public class FeignConfig {

    @Bean
    Logger.Level feignLoggerLevel()
    {
        return Logger.Level.FULL;
    }
}
```



```yaml
logging:
  level:
#    配置feign日志的级别以及监控的接口
    com.kongke.springcloud.service.PaymentFeignService: debug
```





## 四、服务控制



### 1. ~~Hystrix~~

> 已淘汰

Hystrix是一个用于处理分布式系统的**延迟**和**容错**的开源库，

在分布式系统里，许多依赖不可避免的会调用失败，

比如超时、异常等，Hystrix能够保证在一个依赖出问题的情况下，

**不会导致整体服务失败，避免级联故障，以提高分布式系统的弹性**。



#### 服务降级

**哪些情况会出发降级**

- 程序运行导常
- 超时
- 服务熔断触发服务降级
- 线程池/信号量打满也会导致服务降级



#### 服务限流

> 秒杀高并发等操作，严禁一窝蜂的过来拥挤，大家排队，一秒钟N个，有序进行



#### 服务熔断

> **类比保险丝**达到最大服务访问后，直接拒绝访问，然后调用服务降级的方法



**熔断机制**

是应对雪崩效应的一种微服务**链路保护机制**。

当扇出链路的某个微服务出错不可用或者响应时间太长时，会进行服务的降级，

进而熔断该节点微服务的调用，快速返回错误的响应信息。

**当检测到该节点微服务调用响应正常后，恢复调用链路**。



![rd](https://s2.loli.net/2023/11/02/itsTqpYybPM4Fxv.png)

**熔断类型**

- **熔断打开**：

  >  请求不再进行调用当前服务，内部设置时钟一般为MTTR(平均故障处理时间)，
  >
  >  当打开时长达到所设时钟则进入半熔断状态。

- **熔断关闭**：

  >  熔断关闭不会对服务进行熔断。

- **熔断半开**：

  >  部分请求根据规则调用当前服务，
  >
  >  如果请求成功且符合规则则认为当前服务恢复正常，关闭熔断



**涉及到断路器的三个重要参数**：



- **快照时间窗**：`circuitBreaker.sleepWindowInMilliseconds`

  断路器确定是否打开需要统计一些请求和错误数据，

  而统计的时间范围就是快照时间窗，默认为最近的10秒。



- **请求总数阀值**：`circuitBreaker.requestVolumeThreshold`

  在快照时间窗内，必须满足请求总数阀值才有资格熔断。

  默认为20，意味着在10秒内，如果该hystrix命令的调用次数不足20次7,

  即使所有的请求都超时或其他原因失败，断路器都不会打开。



- **错误百分比阀值**：`circuitBreaker.errorThresholdPercentage`

  当请求总数在快照时间窗内超过了阀值，

  比如发生了30次调用，如果在这30次调用中，有15次发生了超时异常，

  也就是超过50%的错误百分比，在默认设定50%阀值情况下，这时候就会将断路器打开。



**流程**

- **服务的降级 -> 进而熔断 -> 恢复调用链路**





## 五、服务网关



![wg](https://s2.loli.net/2023/11/02/vcdVyn71JpTi6f4.png)



![wg2](https://s2.loli.net/2023/11/02/plM4WnkfLw5qzF8.png)



### 1. Gateway

> SpringCloud Gateway是基于**WebFlux**框架实现的，
>
> WebFlux是一个典型**非阻塞异步**的框架
>
> WebFlux框架底层则使用了高性能的**Reactor模式通信框架Netty**。



**Spring Cloud Gateway的目标**

提供统一的路由方式且基于 **Filter 链**的方式提供了网关基本的功能，

例如:安全，监控/指标，和限流。



#### **三大核心概念**

- **Route(路由)**

  路由是构建网关的基本模块

  **它由ID,目标URI,一系列的断言和过滤器组成**,如断言为true则匹配该路由



- **Predicate(断言)**

  参考的是Java8的java.util.function.Predicate，

  开发人员可以**匹配HTTP请求中的所有内容**(例如请求头或请求参数),

  如果请求与断言相匹配则进行路由



- **Filter(过滤)** 

  指的是Spring框架中GatewayFilter的实例,使用过滤器,

  **可以在请求被路由前或者之后对请求进行修改**


**工作流程**

![gzlc](https://s2.loli.net/2023/11/02/fIlB6A8pGYObL3e.png)



#### 配置



**pom**

```xml
<!--gateway-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<!-- gateway 包与一下包冲突 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```



**yml**

> 其中包含Gateway的路由配置

```yaml
server:
  port: 9527

spring:
  application:
    name: cloud-gateway
  #############################新增网关配置###########################
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true # 开启从注册中心动态注册路由
      routes:
      #路由的ID，没有固定规则但要求唯一，建议配合服务名
        - id: payment_routh #payment_route    
#          uri: http://localhost:8001          #匹配后提供服务的路由地址
          uri: lb://cloud-payment-service #匹配后提供服务的路由地址
          predicates:
            - Path=/payment/get/**         # 断言，路径相匹配的进行路由
        - id: payment_routh2 
#          uri: http://localhost:8001         
          uri: lb://cloud-payment-service 
          predicates:
            - Path=/payment/lb/**         
#            - After=2023-10-30T20:23:58.940+08:00[Asia/Shanghai]
#            - Cookie=username,aabb
####################################################################

eureka:
  instance:
    hostname: cloud-gateway-service
  client: #服务提供者provider注册进eureka服务列表内
    service-url:
      register-with-eureka: true
      fetch-registry: true
      defaultZone: http://eureka7001.com:7001/eureka

```





#### Route

**Bean方式配置路由**

```Java
@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator CustomRouteLocator(RouteLocatorBuilder builder) {

        RouteLocatorBuilder.Builder routes = builder.routes();
        routes.route("path_route_runoob",
                // 当访问网关的改路径时     
                r -> r.path("/runoob")
                         // Gateway会将其转发到已下路径 
                        .uri("https://www.runoob.com")).build();

        return routes.build();

    }
}
```



**配置动态路由**

```yaml
	routes:
        - id: payment_routh #payment_route    
          #uri: http://localhost:8001          
          uri: lb://cloud-payment-service #以服务名作为路由地址
```



#### Predicate

**示例**

```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: after_route
        uri: https://example.org
        predicates:
          # 这个时间后才能起效
          - After=2017-01-20T17:42:47.789-07:00[America/Denver]
          # 需带有以下的值
          - Cookie=username,aabb
```



#### Filter

**自定义过滤器**

```Java
@Slf4j
@Component
public class MyLogGatewayFilter implements GlobalFilter, Ordered {


    // 自定义条件
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

        log.info("=========come to MLGF "+ new Date());
        String uname = exchange.getRequest()
            .getQueryParams().getFirst("uname");

        if (uname == null){
            log.info("=========非法用户");
            exchange.getResponse().setStatusCode(HttpStatus.NOT_ACCEPTABLE);
            return exchange.getResponse().setComplete();
        }

        return chain.filter(exchange);
    }

    // 优先级
    @Override
    public int getOrder() {
        return 0;
    }
}
```





## 六、配置中心

**分布式系统面临的配置问题**

> 微服务意味着要将单体应用中的业务拆分成一子服务，每个服务的粒度相对较小，
>
> 系统中会出现大量的服务,由于每个服务都需要必要的配置信息才能运行，所以一套集中式的、动态的配置管理设施是必不可少的。



- SpringCloud提供了ConfigServer来解决这个问题



### 1. SpringCloud Config

> SpringCloud Config为微服务架构中的微服务提供**集中化**的外部配置支持，
>
> 配置服务器为各个不同微服务应用的所有环境提供了一个中心化的**外部配置**。





![config](https://s2.loli.net/2023/11/03/uxAc4VyNi1wIkQP.png)



**分为服务端和客户端**

- 服务端

  也称为分布式配置中心，是一个独立的微服务应用，用来连接配置服务器

  并为客户端**提供获取**配置信息，加密/解密信息等访问接口。

- 客户端

  是通过指定的配置中心来**管理**应用资源，以及与业务相关的配置内容，并在启动时从配置中心获取配置信息,

  配置服务器默认采用git来存储配置信息，这样有助于对环境配置进行版本管理，且可以通过git客户端工具来管理和访问配置内容。

#### 配置



**POM**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>
```

==注==：客户端还需要引入以下包

```xml
<!--     2020以上版本，需引入该包，才能正确引导bootstrap配置加载   -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bootstrap</artifactId>
</dependency>
```



**YML**  （总中心）application.yml

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: git@gitee.com:kongke7/springcloud-config.git # Gitee上面的git仓库名字
          # 搜索目录
          search-paths:
            - springcloud-config
          # 读取分支
          default-label: master
```



==注==：

- applicaiton.yml是用户级的资源配置项

- bootstrap.yml是系统级的，**优先级更高**

> Spring Cloud会创建一个Bootstrap Context，作为Spring应用的Application Context的父上下文。
>
> 初始化的时候，BootstrapContext从**外部源**加载配置属性并解析配置。这两个上下文共享一个从**外部获取**的Environment。
>
> Bootstrap属性有高优先级，默认情况下，**它们不会被本地配置覆盖。**
>
> Bootstrap context和Application Context有着不同的约定，
>
> 所以新增了一个bootstrap.yml文件，保证Bootstrap Context和Application Context配置的分离。



要将Client模块下的application.yml文件改为bootstrap.yml, 这是很关键的，

因为bootstrap.yml是比application.yml先加载的。bootstrap.yml优先级高于application.yml。


**YML**（客户端）bootstrap.yml

```yaml
spring:
  application:
    name: config-client
  cloud:
    #Config客户端配置
    config:
      label: master #分支名称
      name: config #配置文件名称
      profile: dev #读取后缀名称 -> http://config3344.com:3344/master/config-dev.yml
      uri: http://localhost:3344 #配置中心地址
      discovery:
        enabled: true
        service-id: cloud-config-center
```



**激活**（总中心）

```java
@EnableConfigServer
@SpringBootApplication
public class MainApplicationCenter3344 {
    public static void main(String[] args) {
        SpringApplication.run(MainApplicationCenter3344.class, args);
    }
}
```



**业务类**

```Java
@RefreshScope // 动态刷新
@RestController
public class ConfigClientController {

    @Value("${config.info}")
    private String configInfo;

    @GetMapping("/configInfo")
    public String getConfigInfo() {
        return configInfo;
    }

}
```



**读取规则**

- /{label}/{application}-{profile}.yml（推荐）

  ```
  localhost:3344/master/config-dev.yml
  ```



#### 动态刷新

> 避免每次更新配置都要重启客户端



**手动**

----

**POM**

> 引入actuator监控

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```



**YML**

> 添加暴露监控端口配置

```yaml
# 暴露监控端点
management:
  endpoints:
    web:
      exposure:
        include: "*"
```



**业务类**

```Java
@RefreshScope//<----- 
public class ConfigClientController
{

}
```



**刷新**

```bash
curl -X POST "http://localhost:3355/actuator/refresh"
```



**自动**

> SpringCloud Bus配合SpringCloud Config使用可以实现配置的动态刷新。



## 七、消息控制

**消息总线**

> 在微服务架构的系统中，通常会使用**轻量级的消息代理**来构建一个**共用的**消息主题,
>
> 由于该主题中产生的消息会被所有实例监听和消费，所以称它为**消息总线**。
>
> 在总线上的各个实例，都可以**广播**一些需要让其在该主题上的实例都知道的消息。



**基本原理**

ConfigClient实例都监听MQ中同一个topic(默认是Spring Cloud Bus)。

当一个服务刷新数据的时候，它会把这个信息放入到Topic中，这样其它监听**同一Topic**的服务就能得到通知，然后去更新自身的配置。


### 1. SpringCloud Bus

> Spring Cloud Bus是用来将分布式系统的**节点**与**轻量级消息系统**链接起来的框架
>
> 它整合了Java的事件处理机制和消息中间件的功能。
>
> Spring Clud Bus目前支持RabbitMQ和Kafka。

**作用**

Spring Cloud Bus能管理和传播分布式系统间的消息，就像一个分布式执行器，

可用于广播状态更改、事件推送等，也可以当作微服务间的通信通道。



1. 通知节点更新全局



![bus1](https://s2.loli.net/2023/11/03/nTA3ogz57ivBKjs.png)



2. 通知总中心更新全局

![bus](https://s2.loli.net/2023/11/03/bXx3KC6d1yFmUZR.png)

#### Bus配合RabbitMQ



**POM**（客户端 + 总中心）

```xml
<!--添加消息总线RabbitMQ支持-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
</dependency>
```



**YML**（客户端 + 总中心）

```yaml
spring:
  #rabbitmq相关配置 15672是Web管理界面的端口；5672是MQ访问的端口
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
```



**动态全局广播**

> 更新总中心,使全局更新

```bash
curl -X POST "http://localhost:3344/actuator/busrefresh"
```



**定点通知**

> 指定具体某一个实例生效

```bash
http://localhost:3344/actuator/busrefresh/{destination}

curl -X POST "http://localhost:3344/actuator/busrefresh/config-client:3355
```



### 2. SpringCloud Stream

> Spring Cloud Stream是一个构建消息驱动微服务的框架。
>
> 应用程序通过 inputs 或者 outputs 来与Spring Cloud Stream中binder对象交互。
>
> 通过我们配置来binding(绑定)，而Spring Cloud Stream 的binder对象负责与消息中间件交互。
>
> 通过使用Spring Integration来**连接消息代理中间件**以实现消息事件驱动。



Spring Cloud Stream为一些消息中间件提供了个性化的自动化配置实现

- 引用发布-订阅、消费组、分区的三个核心概念。

- 目前仅支持RabbitMQ、 Kafka。



**通过定义绑定器Binder作为中间层，实现了应用程序与消息中间件细节之间的隔离**。

**Binder**：

- INPUT对应于消费者
- OUTPUT对应于生产者



![stream](https://s2.loli.net/2023/11/03/RNZiYe7K8Wqj9ha.png)

#### 配置

**YML**（生产者）

```yaml
spring:
  cloud:
    stream:
      # 配置要绑定的rabbitmq的服务信息
      binders:
        # 表示定义的名称，用于于binding整合
        defaultRabbit:
          # 消息组件类型
          type: rabbit
          # 设置rabbitmq的相关的环境配置
          environment:
            spring:
              rabbitmq:
                host: localhost
                port: 5672
                username: guest
                password: guest
      # 服务的整合处理
      bindings:
        # 新版本固定格式  channel名字-{out/in}-{index}
        studyExchange-out-0:
          # 表示要使用的Exchange名称定义
          destination: studyExchange
          # 设置消息类型，本次为json，文本则设置“text/plain”
          content-type: application/json
```



**YML**（消费者）

```yaml
      # 服务的整合处理
      bindings:
        # 新版本固定格式  channel名字-{out/in}-{index}
        studyExchange-in-0:
          # 表示要使用的Exchange名称定义
          destination: studyExchange
          # 设置消息类型，本次为json，文本则设置“text/plain”
          content-type: application/json
          # 消息组
          group: AAA
```





**业务类**（生产者）

```Java
@Component
public class MessageProviderImpl implements IMessageProvider {

    @Resource
    private StreamBridge streamBridge;

    @Override
    public String send() {

        UUID uuid = UUID.randomUUID();
        streamBridge.send("studyExchange-out-0", MessageBuilder.withPayload(uuid).build());
        return uuid.toString();
    }
}
```



**业务类**（消费者）

```Java
@Service
public class MessageListener {

    @Value("${server.port}")
    private String serPort;


    @Bean
    public Consumer<String> studyExchange(){
        return msg -> System.out.println(msg + " | " + serPort );
    }
}
```





#### 重复消费和持久化

> 保证消息只会被消费一次
>
> 保证当客户端挂机重启后，仍能接收到挂机时生产者发送的消息



**使用Stream中的消息分组(group)来解决**



微服务应用放置于同一个group中，就能够保证消息只会被其中一个应用消费一次。

**不同的组**是可以重复消费的，**同一个组**内会发生竞争关系，只有其中一个可以消费。



有分组属性配置的客户端可以实现持久化



**YML**

```yaml
bindings:
   # 消息组
    group: AAA
```





## 八、链路跟踪

> 在微服务框架中，一个由客户端发起的请求在后端系统中会经过**多个不同的的服务节点**调用来协同产生最后的请求结果，每一个请求都会形成一条复杂的分布式服务**调用链路**，链路中的任何一环出现高延时或错误都会引起整个请求最后的失败。



### 1.SpringCloud Sleuth

![sleuth](https://s2.loli.net/2023/11/03/SkzvxjOTNP6b3nQ.png)



- Trace：类似于树结构的Span集合，表示一条调用链路，存在唯一标识
- span：表示调用链路来源，通俗的理解span就是一次请求信息



**Zipkin**

> SpringCloud已不需要自己构建Zipkin Server，只需调用jar包即可

[官网下载](https://dl.bintray.com/openzipkin/maven/io/zipkin/java/zipkin-server/)

**运行jar**

```bash
java -jar zipkin-server-2.12.9-exec.jar
```


**运行控制台**

运行控制台

```
http://localhost:9411
```





# SpringCloud Alibaba

> Spring Cloud Alibaba 致力于提供微服务开发的一站式解决方案



```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>版本</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

- **Sentine**l：流量控制、熔断降级、系统负载保护等，保护服务的稳定性。

- **Nacos**：动态服务发现、**配置管理**和**服务管理**平台。

- **RocketMQ**：分布式**消息系统**，基于高可用分布式集群技术，提供低延时的、高可靠的消息发布与订阅服务。

- **Dubbo**：一款高性能 Java **RPC 框架**。

- **Seata**：微服务分布式**事务解决方案**。

- **Alibaba Cloud OSS**: **对象存储**服务（简称 OSS），云存储服务。

- **Alibaba Cloud SchedulerX**: 分布式**任务调度**，提供任务调度服务。

- **Alibaba Cloud SMS**: **短信服务**

  

## 一、Nacos

> Nacos就是注册中心＋配置中心的组合 -> **Nacos = Eureka+Config+Bus**

**[官网下载]([home (nacos.io)](https://nacos.io/zh-cn/index.html))**

```bash
# 访问
localhost:8848/nacos
```

```xml
<!--SpringCloud ailibaba nacos -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
<!--	负载均衡	-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-loadbalancer</artifactId>
</dependency>
```



### 1. 注册中心



**YML**（生产者）

```yaml
server:
  port: 9001

spring:
  application:
    name: nacos-payment-provider
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 #配置Nacos地址

management:
  endpoints:
    web:
      exposure:
        include: '*'
```



**YML**（消费者）

```yaml
server:
  port: 83

spring:
  application:
    name: nacos-order-consumer
  cloud:
  # 开启负载均衡
    loadbalancer:
      nacos:
        enabled: true
    nacos:
      discovery:
        server-addr: localhost:8848
```





**启动类**

```Java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@EnableDiscoveryClient
@SpringBootApplication
public class PaymentMain9001 {
    public static void main(String[] args) {
            SpringApplication.run(PaymentMain9001.class, args);
    }
}
```



**消费者Rest**

```Java
@Configuration
public class ApplicationContextConfig {

    @LoadBalanced
    @Bean
    public RestTemplate getRestTemplate(){
        return new RestTemplate();
    }
}
```



### 2. 配置中心

![nacos](https://s2.loli.net/2023/11/05/CsmeJUZ7VY5gNfi.png)

**POM**

```xml
 <!--     2020以上版本，需引入改包，才能正确引导bootstrap配置加载   -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bootstrap</artifactId>
            <version>3.1.1</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
            <version>2022.0.0.0</version>
        </dependency>
```



**YML**

- bootstrap.yml

  ```yaml
  # nacos配置
  server:
    port: 3377
  
  spring:
    application:
      name: nacos-config-client
    cloud:
      nacos:
        discovery:
          server-addr: localhost:8848 #Nacos服务注册中心地址
        config:
          server-addr: localhost:8848 #Nacos作为配置中心地址
          file-extension: yaml #指定yaml格式的配置
  #        group: DEV_GROUP #分组
  #        namespace: a56da4e5-dd4c-4e92-92d3-d050386a0d2d #命名空间
  ```

  

- application.yml

  ```yaml
  spring:
   profiles:
    active: dev # 表示开发环境
  #  active: test # 表示测试环境
  #  active: info
  ```

  

- 在nacos上的配置文件命名规则为

  ```
  ${spring.application.name}-${spring.profile.active}.${spring.cloud.nacos.config.file-extension}
  ```

  例如上述配置，在注册中心读取的，配置文件命名为

  ```
  nacos-config-client-dev.yaml
  ```

  

**业务类**

```Java
@RefreshScope // nacos 动态刷新
@RestController
public class ConfigClientController {

    @Value("${config.info}")
    private String configInfo;

    @GetMapping("/config/info")
    public String getConfigInfo() {
        return configInfo;
    }
}
```





### 3. 集群部署

> Nacos采用了集中式存储的方式来支持集群化部署，目前只支持MySQL的存储。

![nacosJq](https://s2.loli.net/2023/11/05/5gsHoZLdTNDXPv4.png)

**数据库持久化**

1. 安装数据库，版本要求:5.6.5+
2. 初始化mysq数据库，数据库初始化文件: nacos-mysql.sql
3. 修改conf/application.properties文件，增加支持mysql数据源配置（目前只支持mysql)，添加mysql数据源的url、用户名和密码。

```properties
spring.datasource.platform=mysql

db.num=1
db.url.0=jdbc:mysql://IP:3306/nacos_devtest?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true
db.user=nacos_devtest
db.password=youdontknow
```



**Linux集群**



**配置Nacos**

- 下载安装

- 配置数据库

  ![NacosLinux](https://s2.loli.net/2023/11/05/UTCY1q8PMVWrZzx.png)





- 配置端口

  ![JqPz](https://s2.loli.net/2023/11/05/GDliIX7UdwBptvT.png)

  ```
  192.168.111.144:3333
  192.168.111.144:4444
  192.168.111.144:5555
  ```

- 配置启动文件

  ![QdPz](https://s2.loli.net/2023/11/05/kb85gUBRqDr4jIx.png)



​		![QdPz2](https://s2.loli.net/2023/11/05/iORBoVQZnDqtJYm.png)



- `startup.sh - p 端口号`：带端口启动



**配置Nginx**



- 修改配置文件

  ![nginx](https://s2.loli.net/2023/11/05/69sm8Vd4zraJohe.png)



​		![nginx2](https://s2.loli.net/2023/11/05/1g4XCJfEkj9sdFR.png)



- 启动nginx

  ![nginx3](https://s2.loli.net/2023/11/05/MagsTSGRtrWIV7D.png)







## 二、Sentinel

> 以流量为切入点，流量控制、熔断降级、系统负载保护等



**主要特征**

![sentinel](https://s2.loli.net/2023/11/08/5vlmSJxHwPuoed3.png)



**下载安装**

- **[GitHub下载](https://github.com/alibaba/Sentinel/releases)**
  下载到本地的jar包

  

- 运行命令

  8080端口不能被占用

  ```sh
  java -jar sentinel-dashboard-1.7.0.jar
  ```



- 访问Sentinel管理界面
  - localhost:8080
  - 登录账号密码均为sentinel



**POM**

```xml
		<!--SpringCloud Alibaba nacos -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>2022.0.0.0</version>
        </dependency>
        <!--SpringCloud Alibaba sentinel-datasource-nacos 后续做持久化用到-->
        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-datasource-nacos</artifactId>
            <version>1.8.6</version>
        </dependency>

        <!--SpringCloud Alibaba sentinel -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
            <version>2022.0.0.0</version>
        </dependency>
        <!--openfeign-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```



**YML**

```yaml
server:
  port: 8401

spring:
  application:
    name: cloudalibaba-sentinel-service
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 #Nacos服务注册中心地址
    sentinel:
      transport:
        dashboard: localhost:8080 #配置Sentinel dashboard地址
        port: 8719

management:
  endpoints:
    web:
      exposure:
        include: '*'

feign:
  sentinel:
    enabled: true # 激活Sentinel对Feign的支持
```





### 1. 流量控制



**界面**

![senLk](https://s2.loli.net/2023/11/08/46FhmTwe5NAzLrI.png)



- 资源名：唯一名称，默认请求路径。

- 针对来源：Sentinel可以针对调用者进行限流，填写微服务名，默认default（不区分来源）。

- 阈值类型/单机阈值：
  - QPS(每秒钟的请求数量)︰当调用该API的QPS达到阈值的时候，进行限流。
  - 线程数：当调用该API的线程数达到阈值的时候，进行限流。

- 是否集群：不需要集群。

- 流控模式：
  -  直接：API达到限流条件时，直接限流。
  -  关联：当关联的资源达到阈值时，就限流自己。
  -  链路：只记录指定链路上的流量（指定资源从入口资源进来的流量，如果达到阈值，就进行限流)【API级别的针对来源】。

- 流控效果：
  - 快速失败：直接失败，抛异常。
  - Warm up：根据Code Factor（冷加载因子，默认3）的值，从阈值/codeFactor，经过预热时长，才达到设置的QPS阈值。
  - 排队等待：匀速排队，让请求以匀速的速度通过，阈值类型必须设置为QPS，否则无效。



**预热**

> 即预热/冷启动方式。当系统长期处于低访问量的情况下，当流量突然增加时，可能瞬间把系统压垮。通过"冷启动"，让通过的流量缓慢增加，在一定时间内逐渐增加到阈值上限，给冷系统一个预热的时间，避免冷系统被压垮。

![warmUp](https://s2.loli.net/2023/11/08/BSGjdD7zMlLYAX1.png)

**排队等待**

> 会严格控制请求通过的间隔时间，也即是让请求以均匀的速度通过，对应的是漏桶算法。

注：阀值类型必须设成QPS，否则无效。

![pd](https://s2.loli.net/2023/11/08/LoHJF4KP2xCO5eQ.png)



### 2. 服务降级

> 对不稳定的**弱依赖服务调用**进行熔断降级，暂时切断不稳定调用，避免局部不稳定因素导致整体的雪崩。熔断降级作为保护自身的手段，通常在客户端（调用端）进行配置。



**慢调用比例 (SLOW_REQUEST_RATIO)**

- 选择以慢调用比例作为阈值，需要设置允许的慢调用 RT（即最大的响应时间），请求的响应时间大于该值则统计为慢调用。
- 当单位统计时长（statIntervalMs）内请求数目大于设置的最小请求数目，并且慢调用的比例大于阈值，则接下来的熔断时长内请求会自动被熔断。经过熔断时长后熔断器会进入探测恢复状态（HALF-OPEN 状态），若接下来的一个请求响应时间小于设置的慢调用 RT 则结束熔断，若大于设置的慢调用 RT 则会再次被熔断

**异常比例 (ERROR_RATIO)**

- 当单位统计时长（statIntervalMs）内请求数目大于设置的最小请求数目，并且异常的比例大于阈值，则接下来的熔断时长内请求会自动被熔断。
- 经过熔断时长后熔断器会进入探测恢复状态（HALF-OPEN 状态），若接下来的一个请求成功完成（没有错误）则结束熔断，否则会再次被熔断。异常比率的阈值范围是 [0.0, 1.0]，代表 0% - 100%。

**热点Key**

![rdKey](https://s2.loli.net/2023/11/08/9Fhdc3UevnVDNWP.png)

```Java
@RestController
@Slf4j
public class FlowLimitController
{

    ...

    @GetMapping("/testHotKey")
    @SentinelResource(value = "testHotKey",blockHandler/*兜底方法*/ = "deal_testHotKey")
    public String testHotKey(@RequestParam(value = "p1",required = false) String p1,
                             @RequestParam(value = "p2",required = false) String p2) {
        return "------testHotKey";
    }
    
    /*兜底方法*/
    public String deal_testHotKey (String p1, String p2, BlockException exception) {
        return "------deal_testHotKey,o(╥﹏╥)o";  //sentinel系统默认的提示：Blocked by Sentinel (flow limiting)
    }

}

```



- `@SentinelResource(value = "testHotKey")`：前台报出异常界面

- `@SentinelResource(value = "testHotKey", blockHandler = "dealHandler_testHotKey")`
  方法testHotKey里面第一个参数只要超过限流规则，马上降级处理
  异常用了我们自己定义的兜底方法


**参数例外项**

- 普通 - 超过1秒钟一个后，达到阈值1后马上被限流
- **我们期望p1参数当它是某个特殊值时，它的限流值和平时不一样**
- 特例 - 假如当p1的值等于5时，它的阈值可以达到200



![rdKey2](https://s2.loli.net/2023/11/08/tfkvCcnuqFlHrdJ.png)



**自定义限流处理类**

```Java
import com.alibaba.csp.sentinel.slots.block.BlockException;
import com.atguigu.springcloud.entities.CommonResult;
import com.atguigu.springcloud.entities.Payment;

public class CustomerBlockHandler {
    public static CommonResult handlerException(BlockException exception) {
        return new CommonResult(4444,"按客戶自定义,global handlerException----1");
    }
    
    public static CommonResult handlerException2(BlockException exception) {
        return new CommonResult(4444,"按客戶自定义,global handlerException----2");
    }
}
```

```Java
@RestController
public class RateLimitController {
	...

    @GetMapping("/rateLimit/customerBlockHandler")
    @SentinelResource(value = "customerBlockHandler",
            blockHandlerClass = CustomerBlockHandler.class,//<-------- 自定义限流处理类
            blockHandler = "handlerException2")//<-----------
    public CommonResult customerBlockHandler()
    {
        return new CommonResult(200,"按客戶自定义",new Payment(2020L,"serial003"));
    }
}
```





### 3. 服务熔断

> sentinel整合ribbon+openFeign+fallback



**POM**

```xml
		<!--负载均衡--> 		
		<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-loadbalancer</artifactId>
        </dependency>
        <!--SpringCloud Alibaba nacos -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>2022.0.0.0</version>
        </dependency>
        <!--SpringCloud Alibaba sentinel-datasource-nacos 后续做持久化用到-->
        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-datasource-nacos</artifactId>
            <version>1.8.6</version>
        </dependency>

        <!--SpringCloud Alibaba sentinel -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
            <version>2022.0.0.0</version>
        </dependency>
        <!--openfeign-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```



**无配置**

> 给用户error页面

```Java
@RestController
@Slf4j
public class CircleBreakerController {
    public static final String SERVICE_URL = "http://nacos-payment-provider";

    @Resource
    private RestTemplate restTemplate;
 
    @RequestMapping("/consumer/fallback/{id}")
    @SentinelResource(value = "fallback")//没有配置
    public CommonResult<Payment> fallback(@PathVariable Long id)
    {
        CommonResult<Payment> result = 
            restTemplate.getForObject(SERVICE_URL + "/paymentSQL/"+id,CommonResult.class,id);

        if (id == 4) {
            throw new IllegalArgumentException ("IllegalArgumentException,非法参数异常....");
        }else if (result.getData() == null) {
            throw new NullPointerException ("NullPointerException,该ID没有对应记录,空指针异常");
        }

        return result;
    }
    
}
```



**只配置fallback**

> fallback只负责业务异常

```java
@RestController
@Slf4j
public class CircleBreakerController {
    
    public static final String SERVICE_URL = "http://nacos-payment-provider";

    @Resource
    private RestTemplate restTemplate;
 
    @RequestMapping("/consumer/fallback/{id}")
    @SentinelResource(value = "fallback", fallback = "handlerFallback") //fallback只负责业务异常
    public CommonResult<Payment> fallback(@PathVariable Long id) {
        CommonResult<Payment> result = 
            restTemplate.getForObject(SERVICE_URL + "/paymentSQL/"+id,CommonResult.class,id);

        if (id == 4) {
            throw new IllegalArgumentException ("IllegalArgumentException,非法参数异常....");
        }else if (result.getData() == null) {
            throw new NullPointerException ("NullPointerException,该ID没有对应记录,空指针异常");
        }

        return result;
    }
    
    //本例是fallback
    public CommonResult handlerFallback(@PathVariable  Long id,Throwable e) {
        Payment payment = new Payment(id,"null");
        return new CommonResult<>(444,"兜底异常handlerFallback,exception内容  "+e.getMessage(),payment);
    }
    
}

```



**只配置blockHandler**

> blockHandler只负责**sentinel控制台配置违规**

```java
@RestController
@Slf4j
public class CircleBreakerController
{
    public static final String SERVICE_URL = "http://nacos-payment-provider";

    @Resource
    private RestTemplate restTemplate;

    @RequestMapping("/consumer/fallback/{id}")
    //blockHandler只负责sentinel控制台配置违规
    @SentinelResource(value = "fallback",blockHandler = "blockHandler") 
    public CommonResult<Payment> fallback(@PathVariable Long id)
    {
        CommonResult<Payment> result = 
            restTemplate.getForObject(SERVICE_URL + "/paymentSQL/"+id,CommonResult.class,id);

        if (id == 4) {
            throw new IllegalArgumentException ("IllegalArgumentException,非法参数异常....");
        }else if (result.getData() == null) {
            throw new NullPointerException ("NullPointerException,该ID没有对应记录,空指针异常");
        }

        return result;
    }

    //本例是blockHandler
    public CommonResult blockHandler(@PathVariable  Long id,BlockException blockException) {
        Payment payment = new Payment(id,"null");
        return new CommonResult<>(445,
                                  "blockHandler-sentinel限流,无此流水: blockException "
                                  +blockException.getMessage(),payment);
    }
}

```



**fallback和blockHandler都配置**

> 被限流降级而抛出BlockException时只会进入blockHandler处理逻辑

```java
@RestController
@Slf4j
public class CircleBreakerController
{
    public static final String SERVICE_URL = "http://nacos-payment-provider";

    @Resource
    private RestTemplate restTemplate;

    @RequestMapping("/consumer/fallback/{id}")
    @SentinelResource(value = "fallback",fallback = "handlerFallback",blockHandler = "blockHandler")
    public CommonResult<Payment> fallback(@PathVariable Long id)
    {
        CommonResult<Payment> result = 
            restTemplate.getForObject(SERVICE_URL + "/paymentSQL/"+id,CommonResult.class,id);

        if (id == 4) {
            throw new IllegalArgumentException ("IllegalArgumentException,非法参数异常....");
        }else if (result.getData() == null) {
            throw new NullPointerException ("NullPointerException,该ID没有对应记录,空指针异常");
        }

        return result;
    }
    //本例是fallback
    public CommonResult handlerFallback(@PathVariable  Long id,Throwable e) {
        Payment payment = new Payment(id,"null");
        return new CommonResult<>(444,"兜底异常handlerFallback,exception内容  "+e.getMessage(),payment);
    }
    //本例是blockHandler
    public CommonResult blockHandler(@PathVariable  Long id,BlockException blockException) {
        Payment payment = new Payment(id,"null");
        return new CommonResult<>(445,
                                  "blockHandler-sentinel限流,无此流水: blockException "
                                  +blockException.getMessage(),payment);
    }
}

```



**exceptionsToIgnore**

> 忽略指定异常

```java
@RestController
@Slf4j
public class CircleBreakerController    

    ...
    
    @RequestMapping("/consumer/fallback/{id}")
    @SentinelResource(value = "fallback",fallback = "handlerFallback",blockHandler = "blockHandler",
            exceptionsToIgnore = {IllegalArgumentException.class}) //<-------------
    public CommonResult<Payment> fallback(@PathVariable Long id)
    {
        CommonResult<Payment> result = 
            restTemplate.getForObject(SERVICE_URL + "/paymentSQL/"+id,CommonResult.class,id);

        if (id == 4) {
            //exceptionsToIgnore属性有IllegalArgumentException.class，
            //所以IllegalArgumentException不会跳入指定的兜底程序。
            throw new IllegalArgumentException ("IllegalArgumentException,非法参数异常....");
        }else if (result.getData() == null) {
            throw new NullPointerException ("NullPointerException,该ID没有对应记录,空指针异常");
        }

        return result;
    }

	...
}

```



### 4. 持久化

> 一旦我们重启应用，sentinel规则将消失，生产环境需要将配置规则进行持久化



将限流配置规则持久化进Nacos保存，只要刷新8401某个rest地址，sentinel控制台的流控规则就能看到，

只要Nacos里面的配置不删除，针对8401上sentinel上的流控规则持续有效。



**POM**

```xml
<!--持久化用到-->
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-datasource-nacos</artifactId>
</dependency>
```



**YML**

```yaml
spring:
  cloud:
    sentinel:
      datasource: #<---------------------------关注点，添加Nacos数据源配置
        ds1:
          nacos:
            server-addr: localhost:8848
            dataId: cloudalibaba-sentinel-service
            groupId: DEFAULT_GROUP
            data-type: json
            rule-type: flow
```



![cjh](https://s2.loli.net/2023/11/08/s4j3Hc6SEXRdrbZ.png)



**配置限流规则**

```json
[{
    "resource": "/rateLimit/byUrl",
    "limitApp": "default",
    "grade": 1,
    "count": 1, 
    "strategy": 0,
    "controlBehavior": 0,
    "clusterMode": false
}]
```

- resource：资源名称
- limitApp：来源应用
- grade：阈值类型，0表示线程数, 1表示QPS
- count：单机阈值
- strategy：流控模式，0表示直接，1表示关联，2表示链路
- controlBehavior：流控效果，0表示快速失败，1表示Warm Up，2表示排队等待
- clusterMode：是否集群





## 三、Seata

> 分布式事务解决方案



**分布式事务**

单体应用被拆分成微服务应用，原来的三个模块被拆分成三个独立的应用,分别使用三个独立的数据源，

业务操作需要调用三个服务来完成。此时**每个服务内部的数据一致性由本地事务来保证， 但是全局的数据一致性问题没法保证**。

![sw](https://s2.loli.net/2023/11/08/N9rZmgVq1TOCPwK.png)

**一次业务操作需要跨多个数据源或需要跨多个系统进行远程调用，就会产生分布式事务问题**。



**seata解决方案**

> 我们只需要使用一个 `@GlobalTransactional` 注解在业务方法上

![seata](https://s2.loli.net/2023/11/08/OoqyYLtQlb7PwxB.png)





**Seata的工作流程**



分布式事务处理过程的一ID+三组件模型：

- Transaction ID XID 全局唯一的事务ID

- 三组件概念
  - **TC** (Transaction Coordinator) - 事务协调者：维护全局和分支事务的状态，驱动全局事务提交或回滚。
  - **TM** (Transaction Manager) - 事务管理器：定义全局事务的范围：开始全局事务、提交或回滚全局事务。
  - **RM** (Resource Manager) - 资源管理器：管理分支事务处理的资源，与TC交谈以注册分支事务和报告分支事务的状态，并驱动分支事务提交或回滚。

- 处理过程：
  - TM向TC申请开启一个全局事务，全局事务创建成功并生成一个全局唯一的XID
  - XID在微服务调用链路的上下文中传播；
  - RM向TC注册分支事务，将其纳入XID对应全局事务的管辖；
  - TM向TC发起针对XID的全局提交或回滚决议；
  - TC调度XID下管辖的全部分支事务完成提交或回滚请求。

![seata](https://s2.loli.net/2023/11/08/nT7giZOw1SDsCYA.png)



### 1. 配置



- **file.conf**

  - service模块

    ```
    service {
        ##fsp_tx_group是自定义的
        vgroup_mapping.my.test.tx_group="fsp_tx_group" 
        default.grouplist = "127.0.0.1:8091"
        enableDegrade = false
        disable = false
        max.commitretry.timeout= "-1"
        max.ollbackretry.timeout= "-1"
    }
    ```

  - store模块

    ```
    ## transaction log store
    store {
    	## store mode: file, db
    	## 改成db
    	mode = "db"
    	
    	## file store
    	file {
    		dir = "sessionStore"
    		
    		# branch session size, if exceeded first try compress lockkey, still exceeded throws exceptions
    		max-branch-session-size = 16384
    		# globe session size, if exceeded throws exceptions
    		max-global-session-size = 512
    		# file buffer size, if exceeded allocate new buffer
    		file-write-buffer-cache-size = 16384
    		# when recover batch read size
    		session.reload.read_size= 100
    		# async, sync
    		flush-disk-mode = async
    	}
    
    	# database store
    	db {
    		## the implement of javax.sql.DataSource, 
    		## such as DruidDataSource(druid)/BasicDataSource(dbcp) etc.
    		datasource = "dbcp"
    		## mysql/oracle/h2/oceanbase etc.
    		## 配置数据源
    		db-type = "mysql"
    		driver-class-name = "com.mysql.jdbc.Driver"
    		url = "jdbc:mysql://127.0.0.1:3306/seata"
    		user = "root"
    		password = "你自己密码"
    		min-conn= 1
    		max-conn = 3
    		global.table = "global_table"
    		branch.table = "branch_table"
    		lock-table = "lock_table"
    		query-limit = 100
    	}
    }
    ```

    

- mysql5.7数据库新建库seata，在seata库里建表

  - 建表db_store.sql在\seata-server-0.9.0\seata\conf目录里面



- **registry.conf**

  ```
  registry {
    # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
    # 改用为nacos
    type = "nacos"
  
    nacos {
    	## 加端口号
      serverAddr = "localhost:8848"
      namespace = ""
      cluster = "default"
    }
    ...
  }
  ```

  

**YML**

```yaml
spring:
    alibaba:
      seata:
        #自定义事务组名称需要与seata-server中的对应
        tx-service-group: fsp_tx_group
```



### 2. 原理



**整体机制**

两阶段提交协议的演变：

- 一阶段：业务数据和回滚日志记录在同一个本地事务中提交，释放本地锁和连接资源。
- 二阶段：
  - 提交异步化，非常快速地完成。
  - 回滚通过一阶段的回滚日志进行反向补偿。



**一阶段加载**

> 在一阶段，Seata会拦截“业务SQL” 

- 解析SQL语义，找到“业务SQL" 要更新的业务数据，在业务数据被更新前，将其保存成"before image”

- 执行“业务SQL" 更新业务数据，在业务数据更新之后,

- 其保存成"after image”，最后生成行锁。

以上操作全部在一个数据库事务内完成, 这样保证了一阶段操作的原子性。


![styl](https://s2.loli.net/2023/11/08/CYMJWHKskquOF7l.png)



**二阶段提交**

二阶段如果顺利提交的话，因为"业务SQL"在一阶段已经提交至数据库，

所以Seata框架只需将一阶段保存的快照数据和行锁删掉，完成数据清理即可。

![styl2](https://s2.loli.net/2023/11/08/4EexJYUvTZKtcm6.png)



**二阶段回滚**

二阶段如果是回滚的话，Seata 就需要回滚一阶段已经执行的 “业务SQL"，还原业务数据。

回滚方式便是用"before image"还原业务数据；**但在还原前要首先要校验脏写**，对比“数据库当前业务数据”和"after image"。

如果两份数据完全一致就说明没有脏写， 可以还原业务数据，如果不一致就说明有脏写, 出现脏写就需要**转人工处理。**


![styl3](https://s2.loli.net/2023/11/08/Q2TZaFCOSjWnp7N.png)





**总结**

![styl4](https://s2.loli.net/2023/11/08/XIRVnQpPaksGeYO.png)