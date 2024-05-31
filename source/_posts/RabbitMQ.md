---
title: RabbitMQ
date: 2023-12-11 15:16:40
index_img: /blogIndexImg/rabbitmq.png
excerpt: RabbitMQ学习笔记
tags: MQ
categories: 学习笔记
---
# RabbitMQ

> MQ(message queue)，本质是个队列，FIFO 先入先出。是一种跨进程的通信机制，用于上下游传递消息
> “逻辑解耦+物理解耦” 的消息通信服务



## 一、MQ的介绍



### 1. 简单作用



- **流量消峰**

  电商系统在高峰期，短时间**大量访问无法处理**，只能限制订单超过规定值后，不允许用户下单。
  但用消息队列做缓冲，可以**把订单分散**成一段时间来处理， 这时用户可能在下单十几秒后才能收到下单成功通知。

  

- **应用解耦**

  在电商应用中，多系统功能结构如果耦合 ，则任何一个子系统出了故障，都会造成下单操作异常。
  当转变成基于 消息队列的方式后，如物流系统因为发生故障，需要几分钟来修复。
  在这时，物流系统要处理的数据**被缓存在消息队列**中，下单操作可以正常完成。
  当系统恢复后，会继续处理订单信息，提升系统的可用性。

  ![jieo](https://s2.loli.net/2023/12/08/Ise9NAaGWzTpyEP.png)



- **异步处理**

  有些服务间调用是异步的，例如 A 调用 B，B 需要花费很长时间执行，但是 A 需要知道 B 什么时候可以执行完。

  以前一般有两种方式：

  - A 过一段时间去调用 B 的查询 api 查询。

  - A 提供一个 callback api， B 执行完之后调用 api 通知 A 服务。

  如使用消息总线，可以很方便解决这个问题

  ​	A 调用 B 服务后，**只需要监听** B 处理完成的消息，
  ​	当 B 处理完成后，会发送一 条消息给 MQ，MQ 会将此消息转发给 A 服务。
  ​	这样 A 服务既不用循环调用 B 的查询 api，也不用提供 callback api。
  ​	同样B 服务也不用 做这些操作。A 服务还能及时的得到异步处理成功的消息。



![async](https://s2.loli.net/2023/12/08/I2XUcVuQ8EOyiAf.png)

### 2. RabbitMQ的特性

> 是一个在AMQP(高级消息队列协议)基础上完成的，可复用的企业消息系统

- 由 **erlang** 语言开发，具有高并发特性，性能较好

- 万级吞吐量，MQ 功能比较完备,健壮、稳定、易用、跨平台

- 支持多种语言 如：Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP 等
- 如果**数据量没有那么大**，优先选择功能比较完备的 RabbitMQ

注：运行RabbitMQ需要有erlang语言环境

**[RabbitMQ | 官网](https://www.rabbitmq.com/news.html)**



## 二、安装

> 在 Linux Centos7 环境下进行

- 版本选择
  - erlang-21.3.8.21-1.el7.x86_64.rpm
  - rabbitmq-server-3.8.8-1.el7.noarch.rpm

- **[下载地址](https://packagecloud.io/rabbitmq/rabbitmq-server/packages/el/7/rabbitmq-server-3.8.8-1.el7.noarch.rpm)**

### 1. 部署与启动



**安装Erlang**

```sh
# -ivh 显示进度安装
rpm -ivh erlang-21.3.8.21-1.el7.x86_64.rpm
```



**安装RabbitMQ**

```sh
# 安装依赖包
yum install socat -y
rpm -ivh rabbitmq-server-3.8.8-1.el7.noarch.rpm
```



**安装Web端管理插件**

```sh
rabbitmq-plugins enable rabbitmq_management
```



**启动MQ服务**

```sh
# 启动服务
systemctl start rabbitmq-server
# 查看服务状态
systemctl status rabbitmq-server
# 开机自启动
systemctl enable rabbitmq-server
# 停止服务
systemctl stop rabbitmq-server
# 重启服务
systemctl restart rabbitmq-server
```



### 2. 使用Web界面



**开启防火墙端口**

- RabbitMQ默认端口

  - `5672`：

    用于 RabbitMQ 服务器的主要通信。客户端可以使用该端口连接到 RabbitMQ 服务器，
    并通过 AMQP 协议进行消息发布、消费和管理队列等操作。

  - `15672`：Web端默认端口

  - `25672`：与客户端之间的通信端口，用于建立 AMQP 连接和传输消息

```sh
# 开启端口
firewall-cmd --permanent --add-port=5672/tcp
# 重载配置
firewall-cmd --reload
# 查看开放的端口
firewall-cmd --list-ports
```



**添加Web端账号**

> 默认账号只能在本机登录，无法远程登录

```sh
# 创建账号和密码 （如果是云服务器，则密码尽量复杂）
rabbitmqctl add_user admin 123456

# 设置用户角色
rabbitmqctl set_user_tags admin administrator

# 为用户添加资源权限 设置不限ip访问  添加配置、写、读权限
# set_permissions [-p <vhostpath>] <user> <conf> <write> <read>
rabbitmqctl set_permissions -p "/" admin ".*" ".*" ".*"
```

**用户级别**

- `administrator`：可以登录控制台、查看所有信息、可以对 rabbitmq 进行管理

- `monitoring`：监控者 登录控制台，查看所有信息

- `policymaker`：策略制定者 登录控制台，指定策略

- `managment`：普通管理员 登录控制台



**相关命令**

- 关闭应用：`rabbitmqctl stop_app`

- 重置：`rabbitmqctl reset`

- 重新启动：`rabbitmqctl start_app`



## 三、入门案例

> 使用Java编写一个生产者，消费者，使消费者接收生产者的消息

**流程图**

图中红色方块为消息队列

![lct](https://s2.loli.net/2023/12/08/XYfbxpijTqZr1Fz.png)



### 1. 创建POM模块



**POM**

```xml
<dependencies>
        <!--rabbitmq 依赖客户端-->
        <dependency>
            <groupId>com.rabbitmq</groupId>
            <artifactId>amqp-client</artifactId>
            <version>5.8.0</version>
        </dependency>
        <!--操作文件流的一个依赖-->
        <dependency>
            <groupId>commons-io</groupId>
            <artifactId>commons-io</artifactId>
            <version>2.6</version>
        </dependency>
        <!--日志-->
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.3.0-alpha5</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>2.0.0-alpha1</version>
        </dependency>

    </dependencies>

    <!--指定 jdk 编译版本-->
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>8</source>
                    <target>8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
```



**生产者**

```Java
public class provider {

    public static final String QUEUE_NAME = "Hello";

    public static void main(String[] args) throws Exception {
//        创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();

        factory.setHost("服务器IP地址");
        factory.setUsername("admin");
        factory.setPassword("@123@");

//        创建连接
        Connection connection = factory.newConnection();
//        创建信道
        Channel channel = connection.createChannel();
//        创建队列
        /*
         * 1.队列名称
         * 2.持久化
         * 3.是否一个消费者独有
         * 4.自动删除
         * 5.其他参数
         */
        channel.queueDeclare(QUEUE_NAME,false,false,false,null);
//        发送消息
        String msg = "Hello RabbitMQ!";
        channel.basicPublish("",QUEUE_NAME,null,msg.getBytes());

    }
}
```



**消费者**

```Java
public class consumer {
    public static void main(String[] args) throws Exception {
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("服务器IP地址");
        factory.setUsername("admin");
        factory.setPassword("@123@");

        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

//        消费者接收到消息时的回调
        DeliverCallback deliverCallback = (String consumerTag, Delivery message) ->
                System.out.println("消费者接收到消息：" + new String(message.getBody()));

//        消费者取消的回调
        CancelCallback cancelCallback = consumerTag -> System.out.println("消费者取消消息 : " + consumerTag);

//        接收消息
        /*
        1. 队列名称
        2. 成功后是否自动应答
        3. 消费者接收到消息时的回调
        4. 消费者取消的回调
         */
        channel.basicConsume(QUEUE_NAME, true, deliverCallback, cancelCallback);
    }
}
```

**消费者成功接收**

![qd](https://s2.loli.net/2023/12/08/gvCminqLxU2cXfO.png)



### 2. 轮巡分发

> RabbitMQ默认为轮巡分发

**创建连接工具类**

```Java
public class RabbitMQUtil {

    public static Channel getChannel() throws Exception{
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("服务器IP地址");
        factory.setUsername("admin");
        factory.setPassword("@123@");

        Connection connection = factory.newConnection();
        return connection.createChannel();
    }
}
```



**生产者**

```Java
public class provider {
    public static void main(String[] args) throws Exception{
        // 获取信道
        Channel channel = RabbitMQUtil.getChannel();
		// 生成队列
        channel.queueDeclare(QUEUE_NAME,false,false,false,null);
        // 发送消息
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()){
            String msg = scanner.next();
            channel.basicPublish("",QUEUE_NAME,null,msg.getBytes());
            System.out.println("发送完成" + msg);
        }
    }
}
```



**消费者**

```Java
public class Consumer {
    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMQUtil.getChannel();

        // 消费者接收到消息时的回调
        DeliverCallback deliverCallback = (String consumerTag, Delivery message) ->
                System.out.println("消费者接收到消息：" + new String(message.getBody()));

        // 消费者取消的回调
        CancelCallback cancelCallback = consumerTag -> System.out.println("消费者取消消息 : " + consumerTag);

        // 接收消息
        System.out.println("C1_等待接收消息......");
        channel.basicConsume(QUEUE_NAME, true, deliverCallback, cancelCallback);
    }
}
```



**开启多个消费者**

![duokai](https://s2.loli.net/2023/12/08/gs7uWPEKQpjnGFZ.png)



**启动**

![fs](https://s2.loli.net/2023/12/08/WH6TYftErJV2ZQM.png)

![c1](https://s2.loli.net/2023/12/08/zonYUgKt9u8JmRh.png)

![c2](https://s2.loli.net/2023/12/08/TVgncL8BaNUQskY.png)



### 3. 消息应答

> 消费者在接收到消息并且处理该消息之后，告诉 rabbitmq 处理完成，mq则将消息删除。防止未处理的消息丢失



**自动应答**

消息发送后**立即被认为已经传送成功**，这种模式需要在**高吞吐量和数据传输安全性方面做权衡**
这种模式消息在接收到之前，消费者**宕机或关闭**，消息就会丢失，
当然这种模式消费者可以接收过载的消息，**没有对传递的消息数量进行限制**，
不过这样有可能使得消费者这边，产生来大量不及处理的消息，**导致消息的积压**，使内存耗尽。
**所以这种模式仅适用在消费者可以高效并以 某种速率能够处理这些消息的情况下使用。**



**手动应答**

 手动消息应答的方法

- `Channel.basicAck`：肯定确认
- `Channel.basicNack`：否定确认
- `Channel.basicReject`：否定确认，不处理该消息直接拒绝，**可以丢弃**



手动应答中可以通过批量应答解决网络拥堵

![ack](https://s2.loli.net/2023/12/08/rAkQEf6bHFPqz4W.png)

- `true` 代表批量应答 channel 上未应答的所有消息
- `false` 只会应答当前 tag 的消息

![pl](https://s2.loli.net/2023/12/08/NgjkrtuscJZFXol.png)



**消息自动重新入队**

RabbitMQ 会将未应答的消息重新竟然队列，如果此时其他消费者可以处理，它将会被分发给另一个消费者。
这样，即使某个消费者偶尔死亡，也可以确保不会丢失任何消息。



**代码实现**

- **消费者**

  ```Java
  public class Consuemr {
      public static void main(String[] args) throws Exception {
  
          Channel channel = RabbitMQUtil.getChannel();
          System.out.println("C1等待处理时间较长");
  
  		// 消费者消息处理
          DeliverCallback deliverCallback = (tag, msg) -> {
  
              try {
                  Thread.sleep(10000);
              } catch (InterruptedException e) {
                  e.printStackTrace();
              }
  
              System.out.println("接收到消息" + new String(msg.getBody(), StandardCharsets.UTF_8));
  
              channel.basicAck(msg.getEnvelope().getDeliveryTag(), false);
          };
        
  		// 接收消息
          channel.basicConsume(TASK_QUEUE_NAME, false, deliverCallback, System.out::println);
  
      }
  }
  ```

- 启动两个消费者，一个10s 一个3s

- 消费者发送两条消息，默认轮巡

- 如在10s内关闭消费者一，则消费者二会接收到第二条消息



### 4. 队列持久化

> 默认情况下 RabbitMQ 某种原因关闭时，它会忽视队列和消息，造成消息丢失。
> 我们需要将队列和消息都标记为持久化



**队列持久化**

之前创建的队列都是非持久化的，当 rabbitmq 重启，队列就会**被删除掉**，
要队列实现持久化，需要在声明队列的时候把 `durable` 参数设置为 `true`

![dru](https://s2.loli.net/2023/12/08/nIcC74KsOPleNtS.png)

```Java
// 设置队列持久化
channel.queueDeclare(TASK_QUEUE_NAME,true,false,false,null);
```

注意：修改队列属性后，需要将原来队列先删除

修改成功后，Web控制台会显示

![dur](https://s2.loli.net/2023/12/08/Xw8Qxd3Wg9G52nD.png)



**消息持久化**

需要在生产者发送消息时，设置消息的属性 `MessageProperties.PERSISTENT_TEXT_PLAIN`

```Java
// 设置消息持久化
channel.basicPublish("",TASK_QUEUE_NAME, MessageProperties.PERSISTENT_TEXT_PLAIN,msg.getBytes());
```





### 5. 不公平分发

> 能者多劳，高性能服务器应该处理更多消息，保证资源不被浪费



**在接收消息之前设置不公平分发**

在当前任务还没完成，或者没有应答，rabbitmq 就会把该任务分配给有空闲的消费者

```Java
/*
 设置不公平分发
 0:轮巡
 1:不公平分发，能者多劳
 */
channel.basicQos(5);
// 接收消息
channel.basicConsume(TASK_QUEUE_NAME, false, deliverCallback, System.out::println);
```



### 6. 预取值分发

> 限制信道缓冲区的大小



一般来说，增加预取将**提高**向消费者传递消息的速度。但**已传递未处理**的消息的数量也会增加，从而增加了消费者的内存消耗，所以需要合适的预取值。不同的负载该值取值也不同 100 到 300 范 围内的值通常可提供最佳的吞吐量，并且不会给消费者带来太大的风险。



```Java
/*
  设置不公平分发
  0:轮巡
  1:不公平分发，能者多劳
  >1:预取值，设置信道能堆积消息的'最大值'
*/
channel.basicQos(5);
// 接收消息
channel.basicConsume(TASK_QUEUE_NAME, false, deliverCallback, System.out::println);
```

![yqz](https://s2.loli.net/2023/12/08/cSJW2eAH8vqfUla.png)



## 四、发布确认



**原理**

生产者将信道设置成 confirm 模式，所有在该信道上面发布的消息都将会被指派一个**唯一的 ID**(从 1 开始)，一旦消息被投递到所有匹配的队列之后，broker 就会**发送一个确认**给生产者(包含消息的唯一 ID)，

这就使得生产者知道消息已经正确到达目的队列了，如果消息和队列是可持久化的，那么确认消息会在将消息**写入磁盘之后发出**，broker 回传给生产者的确认消息中 `delivery-tag` 域包含了确认消息的**序列号**，此外 broker 也可以设置 `basic.ack` 的 multiple 域，表示到这个序列号之前的所有消息都已经得到了处理。

confirm 模式最大的好处在于他是**异步**的，一旦发布一条消息，生产者应用程序就可以**在等信道返回确认的同时继续发送下一条消息**，当消息最终得到确认之后，生产者应用便可以通过回调方法来处理该确认消息，
如果RabbitMQ 因为自身内部错误导致消息丢失，就会发送一条 `nack` 消息， 生产者应用程序同样可以在回调方法中处理该 nack 消息。



**开启发布确认**

在生产者开启发布确认

```Java
// 开启发布确认
channel.confirmSelect();
```



### 1. 单个发布确认

> 它是一种**同步确认发布**的方式，只有前一条消息被确认发布，后续的消息才能继续发布，
>
> **发布速度特别的慢**，前一条没有确认发布就会**阻塞**后续消息发布，最多提供每秒不超过数百条发布消息的吞吐量



```Java
public static void Individually() throws Exception{

        Channel channel = RabbitMQUtil.getChannel();

		// 声明对列
        String qName = UUID.randomUUID().toString();
        channel.queueDeclare(qName,true,false,false,null);

		// 开启发布确认
        channel.confirmSelect();

		// 计算时间
        long begin = System.currentTimeMillis();

		// 发布消息
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            channel.basicPublish("",qName,null,(""+i).getBytes());
            if (channel.waitForConfirms()){
                System.out.println("消息发送成功");
            }
        }

        long end = System.currentTimeMillis();

        System.out.println("发布 " + MESSAGE_COUNT + " 条消息 ，用时 " + (end-begin) + " 毫秒");
    }
```



### 2. 批量发布确认

> 先发布一批消息然后一起确认可以极大地提高吞吐量
>
> 当发布出现问题时，不知道是哪个消息出问题了，必须**将整个批处理保存在内存中**，
> 以记录重要的信息而后重新发布消息。这种方案仍然是**同步**的，也一样阻塞消息的发布。



```Java
public static void batch() throws Exception{
        Channel channel = RabbitMQUtil.getChannel();

		// 声明对列
        String qName = UUID.randomUUID().toString();
        channel.queueDeclare(qName,true,false,false,null);

		// 开启发布确认
        channel.confirmSelect();

		// 计算时间
        long begin = System.currentTimeMillis();

		// 批量确认大小
        int batchCount = 100;

		// 发布消息
        for (int i = 1; i <= MESSAGE_COUNT; i++) {
            channel.basicPublish("",qName,null,(""+i).getBytes());

            if (i % batchCount == 0){
                channel.waitForConfirms();
                System.out.println("发送成功");
            }

        }

        long end = System.currentTimeMillis();

        System.out.println("发布 " + MESSAGE_COUNT + " 条消息 ，用时 " + (end-begin) + " 毫秒");

    }
```



### 3. 异步发布确认

> 利用**回调函数**来达到消息可靠性传递，通过函数回调来保证是否投递成功

```Java
public static void async() throws Exception{

        Channel channel = RabbitMQUtil.getChannel();

		// 声明对列
        String qName = UUID.randomUUID().toString();
        channel.queueDeclare(qName,true,false,false,null);

		// 开启发布确认
        channel.confirmSelect();

		// 创建一个线程安全哈希表
        ConcurrentSkipListMap<Long , String> outConfirms = new ConcurrentSkipListMap<>();

		// 计算时间
        long begin = System.currentTimeMillis();

		// 成功，回调函数
        ConfirmCallback ackCallBack = (deliveryTag, multiple) -> {
            if (multiple){
                /*
                  删除此tag之前的所有值
                  headmap会返回map中比tag小的所有值的视图，将视图清空会随之将map中的对应的值删除
                 */
                ConcurrentNavigableMap<Long, String> confirmed =
                        outConfirms.headMap(deliveryTag);
                confirmed.clear();
            }else {
                outConfirms.remove(deliveryTag);
            }
            System.out.println("确认 "+ deliveryTag);
        };
		// 失败，回调函数
        ConfirmCallback nackCallBack = (deliveryTag, multiple)->{
            System.out.println("未确认 " + deliveryTag);
        };

		// 设置消息监听器(异步)
        channel.addConfirmListener(ackCallBack,nackCallBack);

		// 发布消息
        for (int i = 0; i < MESSAGE_COUNT; i++) {
            String msg = "" + i;
            channel.basicPublish("",qName,null, msg.getBytes());
            outConfirms.put(channel.getNextPublishSeqNo(), msg);
        }

        long end = System.currentTimeMillis();
        System.out.println("发布 " + MESSAGE_COUNT + " 条消息 ，用时 " + (end-begin) + " 毫秒");
    }
```



## 五、交换机

> **生产者只能将消息发送到交换机(exchange)**
>
> RabbitMQ 消息传递模型的核心思想是: **生产者生产的消息从不会直接发送到队列**。
> 实际上，通常生产者甚至都不知道这些消息传递传递到了哪些队列中



交换机工作的内容非常简单，一方面它接收来自生产者的消息，另一方面将它们推入队列。
交换机必须知道如何处理收到的消息。消息如何发送，就是由交换机的类型来决定。

![jhj](https://s2.loli.net/2023/12/08/sQrb3qZul5KGFOt.png)

**Exchanges的类型：**

- **直接(direct)**：这是最简单的一种类型。根据消息的路由键（routingKey）将消息发送到与指定路由键**完全匹配**的队列。只有完全匹配的队列会接收到消息。

- **主题(topic)**：路由键可以使用**通配符**来指定路由键的匹配规则。例如，路由键为 `red.orange.yellow` 的消息可以匹配到键为 `*.orange.*`的队列。

- **标题(headers)**：根据消息的标题（headers）属性来匹配消息，并将其发送到与匹配的规则**完全匹配**的队列。标题属性是一组键值对，并且匹配规则可以使用各种逻辑操作符来定义，例如等于、不等于、存在等。

- **扇出(fanout)**：扇出交换将消息发送到**与之绑定的所有队列**，忽略消息的路由键。这种交换方式**广播消息**给所有绑定的队列，无论它们的数量和位置。



**BInding 交换机与队列绑定**

![binding](https://s2.loli.net/2023/12/08/1ThVQKr6WJfg9xn.png)



### 1. Fanout交换机

> 它是将接收到的所有消息**广播**到它绑定的所有队列中

![fanout](https://s2.loli.net/2023/12/08/HFpEz4M5DL1VRIT.png)

```Java
public class ReceiveLogs01 {

    protected static final String EXCHANGE_NAME = "logs";

    public static void main(String[] args) throws Exception {
        Channel channel = RabbitMQUtil.getChannel();

		// 声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME,"fanout");

		// 生成临时队列，当与发送者断开连接时会自动删除
        String queueName = channel.queueDeclare().getQueue();

		// 绑定队列到交换机
        channel.queueBind(queueName, EXCHANGE_NAME, "");

        System.out.println("ReceiveLogs01 正在等待消息。。。。。。");

        DeliverCallback ackBack = (tag,msg)
                -> System.out.println("接收到消息 "+ new String(msg.getBody(), StandardCharsets.UTF_8));

        CancelCallback cancelBack = (consumerTag)
                -> System.out.println("取消接收 " + consumerTag);

		// 接收消息
        channel.basicConsume(queueName,true,ackBack,cancelBack);
    }
}
```



### 2. Direct交换机

> 消息只去到它绑定的 routingKey 一致的队列中去

**单一绑定**

![direct](https://s2.loli.net/2023/12/08/OUXqywiYF7R8orn.png)

**多重绑定**

![direct](https://s2.loli.net/2023/12/08/76WeJKvoNjs19TE.png)



```Java
public class ReceiveLogsDirect01 {

    protected static final String EXCHANGE_NAME = "direct_logs";

    public static void main(String[] args) throws Exception{

        Channel channel = RabbitMQUtil.getChannel();

		// 声明交换机
        channel.exchangeDeclare(EXCHANGE_NAME, BuiltinExchangeType.DIRECT);

		// 声明队列
        channel.queueDeclare("console",false,false,false,null);

		// 绑定队列到交换机
        channel.queueBind("console",EXCHANGE_NAME,"info");
        channel.queueBind("console",EXCHANGE_NAME,"warning");

        System.out.println("ReceiveLogsDirect01 正在等待消息。。。。。。");

        DeliverCallback ackBack = (tag, msg)
                -> System.out.println("接收到消息 "+ new String(msg.getBody(), StandardCharsets.UTF_8));

        CancelCallback cancelBack = (consumerTag)
                -> System.out.println("取消接收 " + consumerTag);

		// 接收消息
        channel.basicConsume("console",true,ackBack,cancelBack);
    }
}
```



### 3. Topic交换机

> 通过 routingkey 通配符匹配对应的队列



 发送到 topic 交换机的消息的 routing_key 它必须是**一个单词列表**，**以点号分隔开**这些单词可以是任意单词

例如："lazy.asd.rabbit", "quasc.orange.rabbit", "quick.orange.rabbit".这种类型的。

当然这个单词列表最多不能超过 255 个字节。

特殊占位符：

- ***：可以代替一个单词**
- **#：可以替代零个或多个单词**

![topic](https://s2.loli.net/2023/12/08/Z8wmHOf2oj5zU1r.png)

```Java
public class ReceiveLogsTopic02 {


    public static void main(String[] args) throws Exception {

        Channel channel = RabbitMQUtil.getChannel();

        channel.exchangeDeclare(EXCHANGE_NAME, "topic");

        channel.queueDeclare("Q2",false, false, false, null);

        channel.queueBind("Q2", EXCHANGE_NAME, "*.*.rabbit");
        channel.queueBind("Q2", EXCHANGE_NAME, "lazy.#");

        System.out.println("Q2(*.*.rabbit / lazy.#)等待接收。。。。。。。");

        DeliverCallback ackBack = (tag, msg)
                -> System.out.println("接收到消息 "+ new String(msg.getBody(), StandardCharsets.UTF_8));

        CancelCallback cancelBack = (consumerTag)
                -> System.out.println("取消接收 " + consumerTag);

		// 接收消息
        channel.basicConsume("Q2",true,ackBack,cancelBack);
    }
}
```



## 六、死信队列

> 由于某些原因**导致 queue 中的某些消息无法被消费**，且没有后续的处理，就变成了死信，有了死信就有了死信队列



**应用场景：**

​	为了保证订单业务的消息数据不丢失，需要使用到 RabbitMQ 的死信队列机制，当消息消费发生异常时，将消息投入死信队列中。还有比如说：用户在商城下单成功并点击去支付后在指定时间未支付时自动失效



**死信的来源**

- **消息 TTL 过期**

  TTL是Time To Live的缩写, 也就是生存时间

- **队列达到最大长度**

  队列满了，无法再添加数据到 mq 中

- **消息被拒绝**

  (basic.reject 或 basic.nack) 并且 requeue=false



### 1. TTL死信

![dead](https://s2.loli.net/2023/12/08/U3DicKPbvaAzJfR.png)



**消费者C1**

```Java
public class Consumer01 {

	// 普通交换机
    protected static final String NORMAL_EXCHANGE = "normal_exchange";
	// 死信交换机
    protected static final String DEAD_EXCHANGE = "dead_exchange";
    
    protected static final String NORMAL_QUEUE = "normal_queue";
    protected static final String DEAD_QUEUE = "dead_queue";

    public static void main(String[] args) throws Exception{

        Channel channel = RabbitMQUtil.getChannel();
		// 声明交换机和队列
        channel.exchangeDeclare(NORMAL_EXCHANGE, "direct", true);
        channel.exchangeDeclare(DEAD_EXCHANGE, "direct", true);

		// 配置普通队列
        Map<String, Object> arguments = new HashMap<>();
        // 设置死信交换机
        arguments.put("x-dead-letter-exchange", DEAD_EXCHANGE);
        // 设置RoutingKey
        arguments.put("x-dead-letter-routing-key", "lisi");
        // 过期时间(一般在发送消息时，设置过期时间)
        //arguments.put("x-message-ttl", 10000);
        channel.queueDeclare(NORMAL_QUEUE,false,false,false,arguments);

        channel.queueDeclare(DEAD_QUEUE,false,false,false,null);

        // 绑定交换机与队列
        channel.queueBind(NORMAL_QUEUE,NORMAL_EXCHANGE,"zhangsan");
        channel.queueBind(DEAD_QUEUE,DEAD_EXCHANGE,"lisi");
        System.out.println("Consumer01 等待接收消息。。。。。");


		// 消息处理
        DeliverCallback ackBack = (tag, msg) -> {
            String msgs = new String(msg.getBody(),StandardCharsets.UTF_8);
                System.out.println("接收到消息 "+ msgs);
                channel.basicAck(msg.getEnvelope().getDeliveryTag(),false);
        };

        CancelCallback cancelBack = (consumerTag)
                -> System.out.println("取消接收 " + consumerTag);

        // 拒绝则要开启手动应答
        channel.basicConsume(NORMAL_QUEUE, false, ackBack, cancelBack);

    }

}
```



**消费者C2**

```Java
public class Consumer02 {

    protected static final String DEAD_QUEUE = "dead_queue";

    public static void main(String[] args) throws Exception{

        Channel channel = RabbitMQUtil.getChannel();
        System.out.println("Consumer02 等待接收消息。。。。。");


		// 消息处理
        DeliverCallback ackBack = (tag, msg)
                -> System.out.println("接收到消息 "+ new String(msg.getBody(), StandardCharsets.UTF_8));

        CancelCallback cancelBack = (consumerTag)
                -> System.out.println("取消接收 " + consumerTag);

        channel.basicConsume(DEAD_QUEUE, true, ackBack, cancelBack);

    }

}
```



**生产者**

```Java
public class Producer {

    public static void main(String[] args) throws Exception{
        Channel channel = RabbitMQUtil.getChannel();
        // 发送死信消息
        // 设置TTL (ms)
        AMQP.BasicProperties properties =
                new AMQP.BasicProperties()
                        .builder()
                        .expiration("10000")
                        .build();
        
        for (int i = 0; i < 10; i++) {
            String msg = "info "+ i;
            channel.basicPublish(NORMAL_EXCHANGE,"zhangsan",properties,msg.getBytes());
        }
    }
}
```



- 先启动生产者，和C1，C2,创建队列与交换机

  - 10后，C1接收到所有消息

- 将C1关闭，重启生产者

  - 10s后，C2接收到所有消息

  ![ttl](https://s2.loli.net/2023/12/08/4WHQgP9zZfh3oyM.png)





### 2. 最大长度

**添加最大长度属性**，注意，修改属性需先删除原先的队列

```Java
// 设置最大长度
arguments.put("x-max-length", 6);
channel.queueDeclare(NORMAL_QUEUE,false,false,false,arguments);
```



- 启动C1，C2，生产者，创建新队列

  - 此时，C1还是能接收到全部10条数据，因为处理速度快于堆积速度

- 关闭C1，重启生产者

  - 此时，C2立即收到前四条数据

    ![length](https://s2.loli.net/2023/12/08/FI7y1uixfR5PVE3.png)

  - 10s后，接收到全部10条数据



### 3. 拒收消息



**在DeliverCallBack中添加拒收操作**

```Java
DeliverCallback ackBack = (tag, msg) -> {
    String msgs = new String(msg.getBody(),StandardCharsets.UTF_8);
    if (msgs.equals("info 5")) {
        // 拒接消息
        System.out.println("拒接消息 "+msgs);
        // 不放回原队列
        channel.basicReject(msg.getEnvelope().getDeliveryTag(),false);
    }else {
        System.out.println("接收到消息 "+ msgs);
        channel.basicAck(msg.getEnvelope().getDeliveryTag(),false);
    }
};
```

- 启动C1，C2，生产者
  - 拒收的消息被转发到死信队列，被C2接收

![juj](https://s2.loli.net/2023/12/08/JEm6Pv8AyZQO9t7.png)





## 七、整合SpringBoot



**环境：**

- jdk8
- spingboot 2.3.11.RELEASE



**POM**

```xml
<!--RabbitMQ 依赖-->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>

<dependency>
   <groupId>com.alibaba</groupId>
   <artifactId>fastjson</artifactId>
   <version>1.2.47</version>
</dependency>
```



**配置文件YML**

```yaml
spring:
  rabbitmq:
    host: 服务器IP地址
    port: 5672
    username: admin
    password: '@123@'
```





## 八、延时队列

> 延时队列就是用来存放，需要在指定时间被处理的元素的队列。

**使用场景：**

- 订单在十分钟之内未支付则自动取消 

- 新创建的店铺，如果在十天内都没有上传过商品，则自动发送消息提醒。 

- 用户注册成功后，如果三天内没有登陆则进行短信提醒。 

- 用户发起退款，如果三天内没有得到处理则通知相关运营人员。 

- 预定会议后，需要在预定的时间点前十分钟通知各个与会人员参加会议

![yans](https://s2.loli.net/2023/12/08/cLQ8SrRpHiDCVb9.png)



### 1. TTL属性

> TTL 是 RabbitMQ 中一个消息或者队列的属性，表明一条消息或者该队列中的所有消息的最大存活时间，单位是毫秒。
>
> 如果同时配置了队列的TTL 和消息的 TTL，那么较小的那个值将会被使用。



**队列TTL与消息TTL**

- 设置队列的 TTL 属性，一旦消息过期，就会被队列丢弃（如果配置了死信队列被丢到死信队列中）
- 设置消息TTL属性，消息即使过期，也**不一定会被马上丢弃**，**因为消息是否过期是在即将投递到消费者之前判定的**，
  如果当前队列有严重的消息积压情况，则已过期的消息也许还能存活较长时间；

- 注意，如果不设置 TTL，表示消息永远不会过期，
  如果将 TTL 设置为 0，则表示除非此时**可以直接投递**该消息到消费者，否则该消息将会被丢弃



### 2. TTL队列

创建两个队列 QA 和 QB，两者队列 TTL 分别设置为 10S 和 40S，
然后在创建一个交换机 X 和死信交换机 Y，它们的类型都是direct，创建一个死信队列 QD

![ttl2](https://s2.loli.net/2023/12/08/Cv826lGHnFQtZU5.png)

**编写配置类**

```Java
@Configuration
public class TtlQueueConfig {

    // 普通交换机
    public static final String X_EXCHANGE = "X";
    // 死信交换机
    public static final String Y_DEAD_EXCHANGE = "Y";
    // 普通队列
    public static final String QUEUE_A = "QA";
    public static final String QUEUE_B = "QB";

    // 死信对列
    public static final String DEAD_QUEUE_D = "QD";

    // 声明交换机
    @Bean("xExchange")
    public DirectExchange xExchange() {
        return new DirectExchange(X_EXCHANGE);
    }

    @Bean("yExchange")
    public DirectExchange yExchange() {
        return new DirectExchange(Y_DEAD_EXCHANGE);
    }

    // 声明队列
    @Bean("queueA")
    public Queue queueA(){

        HashMap<String, Object> map = new HashMap<>();
        // 设置参数
        map.put("x-dead-letter-exchange", Y_DEAD_EXCHANGE);
        map.put("x-dead-letter-routing-key","YD");
        map.put("x-message-ttl", 10000);

        return QueueBuilder.durable(QUEUE_A).withArguments(map).build();
    }

    @Bean("queueB")
    public Queue queueB(){

        HashMap<String, Object> map = new HashMap<>();
        // 设置参数
        map.put("x-dead-letter-exchange", Y_DEAD_EXCHANGE);
        map.put("x-dead-letter-routing-key","YD");
        map.put("x-message-ttl", 40000);

        return QueueBuilder.durable(QUEUE_B).withArguments(map).build();
    }


    // 死信队列
    @Bean("queueD")
    public Queue queueD() {
        return QueueBuilder.durable(DEAD_QUEUE_D).build();
    }

    /**
     * ABX
     */
    @Bean
    public Binding queueABX(@Qualifier("queueA") Queue queueA,
                            @Qualifier("xExchange") DirectExchange xExchange){
        return BindingBuilder.bind(queueA).to(xExchange).with("XA");
    }

    /**
     * ABY
     */
    @Bean
    public Binding queueABY(@Qualifier("queueA") Queue queueA,
                            @Qualifier("yExchange") DirectExchange yExchange){
        return BindingBuilder.bind(queueA).to(yExchange).with("YD");
    }

    /**
     * BBX
     */
    @Bean
    public Binding queueBBX(@Qualifier("queueB") Queue queueB,
                            @Qualifier("xExchange") DirectExchange xExchange){
        return BindingBuilder.bind(queueB).to(xExchange).with("XB");
    }

    /**
     * BBY
     */
    @Bean
    public Binding queueBBY(@Qualifier("queueB") Queue queueB,
                            @Qualifier("yExchange") DirectExchange yExchange){
        return BindingBuilder.bind(queueB).to(yExchange).with("YD");
    }

    /**
     * DBY
     */
    @Bean
    public Binding queueDBY(@Qualifier("queueD") Queue queueD,
                            @Qualifier("yExchange") DirectExchange yExchange){
        return BindingBuilder.bind(queueD).to(yExchange).with("YD");
    }
}
```



**生产者**

生产者通过接口形式发送消息

```Java
@Slf4j
@RestController
@RequestMapping("/ttl")
public class SendMsgController {

    @Resource
    private RabbitTemplate rabbitTemplate;

    @GetMapping("/sendMsg/{msg}")
    public void sendMsg(@PathVariable("msg") String msg) {
      log.info("当前时间: {} , 发送一条消息给两个TTL队列: {}", new Date(), msg);

      rabbitTemplate.convertAndSend("X","XA","消息来自ttl为10s的队列: " + msg);
      rabbitTemplate.convertAndSend("X","XB","消息来自ttl为40s的队列: " + msg);

    }

}
```



**消费者**

消费者以接口形式接收消息

```Java
@Slf4j
@Component
public class DeadLetterQueueConsumer {

    // 接收消息
    @RabbitListener(queues = "QD")
    public void receiveD(Message message , Channel channel){
        String msg = new String(message.getBody());
        log.info("当前时间：{}, 接收死信队列消息：{}",new Date(),msg);
    }
}
```

- 启动后发送Get请求

  - 消费者在规定的时间收到消息

  ![ttl3](https://s2.loli.net/2023/12/08/qXPVgOJzTYIWmv5.png)









### 3. TTL消息

> 使用户发送自定义TTL属性的消息



**增加队列 QC**

![ttl4](https://s2.loli.net/2023/12/08/rStNVfyjuhmAPJF.png)



**在配置类中声明队列并绑定交换机**

```Java
@Bean("queueC")
public Queue queueC(){

    HashMap<String, Object> map = new HashMap<>();
    // 设置参数
    map.put("x-dead-letter-exchange", Y_DEAD_EXCHANGE);
    map.put("x-dead-letter-routing-key","YD");

    return QueueBuilder.durable(QUEUE_C).withArguments(map).build();
}

/**
 * CBX
 */
@Bean
public Binding queueCBX(@Qualifier("queueC") Queue queueC,
                        @Qualifier("xExchange") DirectExchange xExchange){
    return BindingBuilder.bind(queueC).to(xExchange).with("XC");
}

/**
 * CBY
 */
@Bean
public Binding queueCBY(@Qualifier("queueC") Queue queueC,
                        @Qualifier("yExchange") DirectExchange yExchange){
    return BindingBuilder.bind(queueC).to(yExchange).with("YD");
}
```



**生产者，添加接口**

```Java
@GetMapping("/sendMsg/{msg}/{ttl}")
public void sendMsg(@PathVariable("msg") String msg , @PathVariable("ttl") String ttl) {
    
  log.info("当前时间: {} , 发送一条ttl: {} ms 消息给通用TTL队列: {}", new Date(),ttl, msg);
  rabbitTemplate.convertAndSend("X","XC","消息来自通用ttl队列",m -> {
      // 设置消息属性
      m.getMessageProperties().setExpiration(ttl);
      return m;
  });

}
```

**但此方法有很大的问题**

**这就是介绍过的，在消息属性上设置 TTL 的方式，消息可能并不会按时“死亡“**

因为 RabbitMQ 只会检查第一个消息是否过期，如果过期则丢到死信队列，
如果第一个消息的延时时长很长，而第二个消息的延时时	长很短，第二个消息并不会优先得到执行。

![ttl5](https://s2.loli.net/2023/12/08/RjyvF8KIGw2qH7i.png)

### 4. 插件实现延迟队列

- [官网下载 ](https://www.rabbitmq.com/community-plugins.html)**rabbitmq_delayed_message_exchange** 插件，放置到 RabbitMQ 的插件目录

```sh
#安装
rabbitmq-plugins enable rabbitmq_delayed_message_exchange
#重启服务
systemctl restart rabbitmq-server
```



安装成功后在Web端可以看到，交换机多了一个属性

![cjttl](https://s2.loli.net/2023/12/08/ofUgOPHN1xFhQw4.png)



- 这是一种新的交换类型，该类型消息支持延迟投递机制消息传递后并**不会立即投递**到目标队列中，
  而是存储在 mnesia(一个分布式数据系统)表中，**当达到投递时间时，才投递到目标队列中**。



**创建一个示例**

![dlq](https://s2.loli.net/2023/12/08/81zoxfGEUhNPq3W.png)



**配置类**

```Java
@Configuration
public class DelayedQueueConfig {

    // 队列
    public static final String DELAYED_QUEUE_NAME = "delayed.queue";
    // 交换机
    public static final String DELAYED_EXCHANGE_NAME = "delayed.exchange";
    // routingKey
    public static final String DELAYED_ROUTING_KEY = "delayed.routingkey";

    // 声明交换机
    @Bean
    public CustomExchange delayedExchange(){

        Map<String, Object> map = new HashMap<>();
        map.put("x-delayed-type", "direct");
        return new CustomExchange(DELAYED_EXCHANGE_NAME, "x-delayed-message", true, false, map);
    }

    @Bean
    public Queue delayedQueue(){
        return new Queue(DELAYED_QUEUE_NAME);
    }

    @Bean
    public Binding delayQueueBD(@Qualifier("delayedQueue") Queue delayedQueue ,
                                   @Qualifier("delayedExchange") CustomExchange delayedExchange){
        return BindingBuilder.bind(delayedQueue).to(delayedExchange).with(DELAYED_ROUTING_KEY).noargs();
    }
}
```



**生产者新接口**

```Java
@GetMapping("/sendDelayMsg/{msg}/{delay}")
public void sendMsg(@PathVariable("msg") String msg , @PathVariable("delay") Integer delay) {
  
  log.info("当前时间: {} , 发送一条ttl: {} ms 消息给TTL队列: {}", new Date(),delay, msg);

  rabbitTemplate.convertAndSend(DELAYED_EXCHANGE_NAME,DELAYED_ROUTING_KEY,"消息来自通用ttl队列",m -> {
      // 设置消息属性
      m.getMessageProperties().setDelay(delay);
      return m;
  });

}
```



**消费者**

```Java
@Slf4j
@Component
public class DelayQueueConsumer {

    // 接收消息
    @RabbitListener(queues = DELAYED_QUEUE_NAME)
    public void receiveD(Message message , Channel channel){
        String msg = new String(message.getBody());
        log.info("当前时间：{}, 接收延迟队列消息：{}",new Date(),msg);
    }
}
```



- 启动测试

  ![dlq2](https://s2.loli.net/2023/12/08/knYe76sEdhaVRBN.png)

  - 第二条消息先消费，延时成功



## 九、发布确认高级

> 解决因某原因导致 RabbitMQ 重启，在 RabbitMQ 重启期间生产者消息投递失败， 导致消息丢失，需要手动处理和恢复的问题

**方案结构图**

![confirmSB](https://s2.loli.net/2023/12/09/ihJgXGnQOUjlco8.png)

![confirmSB2](https://s2.loli.net/2023/12/09/yDZCUQ1XfHoWiVu.png)

### 1. 整合SpringBoot



**添加配置**

```yaml
spring:
  rabbitmq:
    # 开启发布确认
    publisher-confirm-type: correlated
```

- `NONE`： 禁用发布确认模式（默认）

- `CORRELATED` ：发布消息成功到交换器后会触发回调方法

- `SIMPLE` ：有两种效果

  1. 和 `CORRELATED` 值一样会触发回调方法

  2. 在发布消息成功后使用 `rabbitTemplate` 调用 `waitForConfirms` 或 `waitForConfirmsOrDie` 方法
     等待 `broker` 节点返回发送结果，根据返回结果来判定下一步的逻辑，
     **注意**： `waitForConfirmsOrDie` 方法如果返回 `false` 会关闭 `channel`，接下来无法发送消息到 `broker`



**新增配置类**

```Java
@Configuration
public class ConfirmConfig {

    // 交换机
    public static final String CONFIRM_EXCHANGE_NAME = "confirm_exchange";
    // 队列
    public static final String CONFIRM_QUEUE_NAME = "confirm_queue";
    // routingKey
    public static final String CONFIRM_ROUTING_KEY = "key1";

    // 声明确认交换机
    @Bean("confirmExchange")
    public DirectExchange confirmExchange(){
        return new DirectExchange(CONFIRM_EXCHANGE_NAME);
    }

    // 声明确认队列
    @Bean("confirmQueue")
    public Queue confirmQueue(){
        return QueueBuilder.durable(CONFIRM_QUEUE_NAME).build();
    }

    // 绑定
    @Bean
    public Binding binding(@Qualifier("confirmQueue") Queue confirmQueue ,
                           @Qualifier("confirmExchange") DirectExchange confirmExchange){
        return BindingBuilder.bind(confirmQueue).to(confirmExchange).with(CONFIRM_ROUTING_KEY);
    }
}
```



**实现生产者回调接口**

```Java
@Slf4j
@Component
public class MyCallBack implements RabbitTemplate.ConfirmCallback{

    @Resource
    private RabbitTemplate rabbitTemplate;

    /**
     * 将此类注入到rabbitTemplate中
     */
    @PostConstruct
    public void init(){
        rabbitTemplate.setConfirmCallback(this);
    }

    /**
     * 交换机确认回调方法
     * 1.接收成功，回调
     *  1.1 correlationDate 保存了回调消息的信息
     *  1.2 交换机接收到消息 ack = true
     *  1.3 cause Null
     * 2.接收失败，回调
     *  2.1 correlationDate 保存了回调消息的信息
     *  2.2 交换机接收到消息 ack = false
     *  2.3 cause 失败的原因
     */
    @Override
    public void confirm(CorrelationData correlationData, boolean ack, String cause) {
        String id = correlationData != null ? correlationData.getId() : "";
        if (ack){
            log.info("交换机接收到Id为：{} 的消息",id);
        }else {
            log.info("交换机接收Id为：{} 的消息失败，失败原因：{}",id,cause);
        }
    }
}
```



`@PostConstruct`：注解的含义与用法

- 注解允许在 bean 的构造函数之后和 bean 的属性设置之后执行初始化逻辑。   
- 注解可以应用于任何类型的 bean，包括普通 bean、单例 bean 和原型 bean。
- 注解不能应用于接口、枚举类型或静态方法。   
- 注解的方法必须是 public 方法，并且不能有任何参数。
- 注解的方法可以抛出任何异常。 



**生产者**

```Java
@Slf4j
@RestController
@RequestMapping("/confirm")
public class ProducerController {

    @Resource
    private RabbitTemplate rabbitTemplate;

    @GetMapping("/sendMsg/{msg}")
    public void sendMsg(@PathVariable("msg") String message) {
        CorrelationData correlationData = new CorrelationData("1");
        rabbitTemplate.convertAndSend(CONFIRM_EXCHANGE_NAME,CONFIRM_ROUTING_KEY,message,correlationData);
        log.info("发送消息: {}",message);

    }
}
```



**消费者**

```Java
@Slf4j
@Component
public class ConfirmConsumer {

    @RabbitListener(queues = CONFIRM_QUEUE_NAME)
    public void receiveConfirmMsg(Message message){
        log.info("接收到队列confirm.queue的消息：{}",message);
    }
}
```



**启动**

- 正常情况下消息成功接收

![confirmMsg](https://s2.loli.net/2023/12/09/YTDgXoOn8Vhy4ZE.png)

- 修改Key的值，则消息无法匹配到队列，会被直接丢弃

![confirmMsg2](https://s2.loli.net/2023/12/09/mAyGaoPu2ZEr5Sj.png)

**注意**：此时丢弃的消息交换机不知道，需要告诉生产者消息接收失败



### 2. 回退消息

> 设置回退消息，可以在当消息传递过程中不可达目的地时将消息返回给生产者



**增加配置**

```yaml
spring:
  rabbitmq:
    # 开启回退消息
    publisher-returns: true

```



**在回调方法中实现回退接口**

```Java
@Slf4j
@Component
public class MyCallBack implements RabbitTemplate.ConfirmCallback,RabbitTemplate.ReturnCallback {

    @Resource
    private RabbitTemplate rabbitTemplate;

    /**
     * 将此类注入到rabbitTemplate中
     */
    @PostConstruct
    public void init(){
        rabbitTemplate.setConfirmCallback(this);
        rabbitTemplate.setReturnCallback(this);
    }

    /**
     * 交换机确认回调方法
     * 1.接收成功，回调
     *  1.1 correlationDate 保存了回调消息的信息
     *  1.2 交换机接收到消息 ack = true
     *  1.3 cause Null
     * 2.接收失败，回调
     *  2.1 correlationDate 保存了回调消息的信息
     *  2.2 交换机接收到消息 ack = false
     *  2.3 cause 失败的原因
     */
    @Override
    public void confirm(CorrelationData correlationData, boolean ack, String cause) {
        String id = correlationData != null ? correlationData.getId() : "";
        if (ack){
            log.info("交换机接收到Id为：{} 的消息",id);
        }else {
            log.info("交换机接收Id为：{} 的消息失败，失败原因：{}",id,cause);
        }
    }

    /**
     * 返回消息回调
     * 只有在消息不可达目的地时 才可进行回退
     *
     * @param message    the 返回的消息。
     * @param replyCode  the 回复代码。
     * @param replyText  the 回复文本。
     * @param exchange   the 交换机
     * @param routingKey the routing key.
     */
    @Override
    public void returnedMessage(Message message, int replyCode, 
                                String replyText, String exchange, String routingKey) {
        log.info("消息：{} 被交换机：{} 退回, 原因：{}，路由键：{}",
                 message.getBody(),replyText,exchange,routingKey);
    }
}
```



**启动**

![confirmMsg3](https://s2.loli.net/2023/12/09/AhODwc2vXM8BFng.png)

可以看到消息被退回



### 3. 备份交换机

> 当交换机接收到一条不可路由消息时，将会把这条消息转发到备份交换机中，由备份交换机来进行转发和处理



通常备份交换机的类型为 `Fanout` ，这样就能把所有消息都投递到与其绑定的队列中，然后我们在备份交换机下绑定一个队列，
所有无法被路由的消息，都进入这个队列，还可以建立一个报警队列，用独立的消费者来进行监测和报警。



**简单结构**

![backup](https://s2.loli.net/2023/12/09/njlwGQtFiXOIWuH.png)



**修改配置类**

> 注意：修改已存在交换机配置需要将已存在的交换机删除

```Java
@Configuration
public class ConfirmConfig {

    // 交换机
    public static final String CONFIRM_EXCHANGE_NAME = "confirm_exchange";
    // 队列
    public static final String CONFIRM_QUEUE_NAME = "confirm_queue";
    // routingKey
    public static final String CONFIRM_ROUTING_KEY = "key1";

    // 备份交换机
    public static final String BACKUP_EXCHANGE_NAME = "backup_exchange";
    // 备份队列
    public static final String BACKUP_QUEUE_NAME = "backup_queue";
    // 报警队列
    public static final String WARNING_QUEUE_NAME = "warning_queue";

    // 声明确认交换机
    @Bean("confirmExchange")
    public DirectExchange confirmExchange(){
        return ExchangeBuilder.directExchange(CONFIRM_EXCHANGE_NAME)
                .durable(true)
            	// 设置备份交换机
                .withArgument("alternate-exchange",BACKUP_EXCHANGE_NAME).build();
    }

    // 声明确认队列
    @Bean("confirmQueue")
    public Queue confirmQueue(){
        return QueueBuilder.durable(CONFIRM_QUEUE_NAME).build();
    }

    // 绑定
    @Bean
    public Binding binding(@Qualifier("confirmQueue") Queue confirmQueue ,
                           @Qualifier("confirmExchange") DirectExchange confirmExchange){
        return BindingBuilder.bind(confirmQueue).to(confirmExchange).with(CONFIRM_ROUTING_KEY);
    }

    // 声明备份交换机
    @Bean("backupExchange")
    public FanoutExchange backupExchange(){
        return new FanoutExchange(BACKUP_EXCHANGE_NAME);
    }

    // 声明备份队列
    @Bean("backupQueue")
    public Queue backupQueue(){
        return QueueBuilder.durable(BACKUP_QUEUE_NAME).build();
    }

    // 声明警告队列
    @Bean("warningQueue")
    public Queue warningQueue(){
        return QueueBuilder.durable(WARNING_QUEUE_NAME).build();
    }

    // 绑定
    @Bean
    public Binding BBB(@Qualifier("backupQueue") Queue backupQueue ,
                       @Qualifier("backupExchange") FanoutExchange backupExchange){
        return BindingBuilder.bind(backupQueue).to(backupExchange);
    }

    @Bean
    public Binding WBB(@Qualifier("warningQueue") Queue warningQueue ,
                       @Qualifier("backupExchange") FanoutExchange backupExchange){
        return BindingBuilder.bind(warningQueue).to(backupExchange);

    }

}
```



**报警消费者**

```Java
@Slf4j
@Component
public class WarningConsumer {

    // 接收报警信息
    @RabbitListener(queues = WARNING_QUEUE_NAME)
    public void receive(String message) {
        log.info("[WARNING] Unreceived '{}'", message.getBytes(StandardCharsets.UTF_8));
    }
}
```



**启动**

![warm](https://s2.loli.net/2023/12/09/msbpa5Z2CgGQhYS.png)

消息成功被报警消费者接收

**注意：此处消息没有触发回退**

- 因为当回退，和备份同时设置时，备份的优先级更高

## 十、其他性质



### 1. 幂等性

> 对于同一操作发起的一次请求或者多次请求的结果是一致的

 **例如支付操作：**

- 用户购买商品后支付，支付扣款成功，但是返回结果的时候网络异常
- 用户再次点击按钮，此时会进行第二次扣款。



**消息重复消费**

消费者在消费 MQ 中的消息时，MQ 已把消息发送给消费者，消费者在给 MQ 返回 ack 时网络中断， 故 MQ 未收到确认信息，该条消息会重新发给其他的消费者，或者在网络重连后再次发送给该消费者，但实际上该消费者已成功消费了该条消息，造成消费者消费了重复的消息。

**解决思路**

MQ 消费者的幂等性的解决一般使用**全局 ID** ，**每次消费消息时用该 id 先判断该消息是否已消费过。**

主流的幂等性有两种操作:

- 唯一 ID+指纹码机制,利用数据库主键去重

  指纹码：**唯一信息码**,一般都是由我们的业务规则拼接而来，然后利用查询语句进行判断这个 id 是否存在数据库中
  优势： 实现简单就一个拼接，然后查询判断是否重复；
  劣势： 在高并发时，增大数据库的压力

- 利用 redis 的原子性去实现

  利用 redis 执行 setnx 命令，天然具有幂等性



### 2. 优先级队列

> 优先处理某些订单



- **Web控制台添加属性**

![youxain](https://s2.loli.net/2023/12/09/2tMuDId8KiyTwnx.png)

- **声明队列时添加优先级**

```java
Map<String, Object> params = new HashMap();
params.put("x-max-priority", 10);
channel.queueDeclare("hello", true, false, false, params);
```



- **发送消息添加优先级**

```java
AMQP.BasicProperties properties = new AMQP.BasicProperties().builder().priority(10).build();
```



**前提条件：**

- 队列需要设置为优先级队列
- 消息需要设置消息的优先级
- 消费者需要等待消息已经发送到队列中才去消费，因为这样才有机会对消息进行排序



### 3. 惰性队列

> 惰性队列会尽可能的将消息存入磁盘中，而在消费者消费到相应的消息时才会被加载到内存中去

- **背景原因**

它的一个重要的设计目标是能够支持更长的队列，即**支持更多的消息存储**。
当消费者由于各种各样的原因而致使长时间内不能消费消息**造成堆积时**，惰性队列就很有必要了

默认情况下，当生产者发送消息时，队列中的消息存储在内存之中，可以更快的将消息发送给消费者。
即使是持久化的消息，被写入磁盘的时也会在内存中留一份备份。
当RabbitMQ **需要释放内存时**，会将内存中的消息换页至磁盘中，操作时间较长**会阻塞队列的操作**，导致无法接收新的消息



**队列的两种模式**：`default 和 lazy。`

- 默认的为`default` 模式

- `lazy` 模式即为惰性队列的模式，可以通过调用 `channel.queueDeclare` 方法的时候在参数中设置，或通过 `Policy` 的方式设置，
  如果队列同时使用这两种方式设置，`Policy` 方式优先级更高

  ```Java
  Map<String, Object> args = new HashMap<String, Object>();
  args.put("x-queue-mode", "lazy");
  channel.queueDeclare("myqueue", false, false, false, args);
  ```



- **占用内存比较**

![lazy](https://s2.loli.net/2023/12/09/O1MVzaZX9Np2HRt.png)



**在发送 1 百万条消息时，每条消息大概占 1KB 的情况下，普通队列占用内存是 1.2GB，而惰性队列仅仅 占用 1.5MB**

