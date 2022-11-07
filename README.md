- [Debezium、Kafka、Doris 和 Flink 快速入门](#debezium-kafka-doris---flink-----)
  * [Kafka 的搭建](#kafka----)
  * [Kafka Connect 使用](#kafka-connect---)
    + [新增连接器](#-----)
    + [删除连接器](#-----)
    + [查询连接器状态](#-------)
    + [获取连接器配置信息](#---------)
    + [重启连接器](#-----)
    + [暂停连接器](#-----)
    + [查看所有插件集合](#--------)
    + [校验连接器配置](#-------)
  * [Kafka Connector 的定义](#kafka-connector----)
    + [name](#name)
    + [connector.class](#connectorclass)
    + [tasks.max](#tasksmax)
    + [key.converter](#keyconverter)
    + [value.converter](#valueconverter)
    + [header.converter](#headerconverter)
    + [config.action.reload](#configactionreload)
    + [transforms](#transforms)
    + [predicates](#predicates)
    + [errors.retry.timeout](#errorsretrytimeout)
    + [errors.retry.delay.max.ms](#errorsretrydelaymaxms)
    + [errors.tolerance](#errorstolerance)
    + [errors.log.enable](#errorslogenable)
    + [errors.log.include.messages](#errorslogincludemessages)
    + [topic.creation.groups](#topiccreationgroups)
    + [exactly.once.support](#exactlyoncesupport)
    + [transaction.boundary](#transactionboundary)
    + [transaction.boundary.interval.ms](#transactionboundaryintervalms)
    + [offsets.storage.topic](#offsetsstoragetopic)
  * [Debezium 的使用](#debezium----)
  * [Flink 的搭建](#flink----)
  * [Flink 基于 Kafka 的流式计算](#flink----kafka------)
  * [附篇：基于 Rabbit MQ 的流式计算](#------rabbit-mq------)
  * [Flink SQL](#flink-sql)
    + [建表](#--)
    + [简单查询](#----)
    + [表操作 & 高级应用](#----------)
  * [Flink Table Api](#flink-table-api)
    + [通过 Table API 流式计算 Debezium 投递过来的数据](#---table-api------debezium--------)
    + [通过 Table API 流式计算自定义格式数据](#---table-api------------)
    + [附篇：基于 Java 函数的 SQL 计算](#------java-----sql---)
  * [Flink Source & Sink 全流程示例](#flink-source---sink------)
    + [环境的定义](#-----)
    + [数据源的定义](#------)
    + [创建表 & 执行 SQL](#---------sql)
    + [定义输出流 & Sink](#--------sink)
    + [执行程序](#----)
  * [Flink Job 的部署](#flink-job----)
    + [Flink 应用程序的依赖管理](#flink----------)
    + [Flink 入口函数的指定](#flink--------)
    + [Flink 发布 Job](#flink----job)
  * [Flink SQL Gateway](#flink-sql-gateway)
  * [关于 Flink 的遗漏问题](#---flink------)
  * [Doris 的安装](#doris----)
    + [从 MySQL 导入数据](#--mysql-----)
    + [Doris SQL 注意事项](#doris-sql-----)
    + [Doris 查询效率案例对比](#doris---------)
  * [参考资料](#----)


# Debezium、Kafka、Doris 和 Flink 快速入门

本文的每一个章节都是可以独立查看的，对部分章节不感兴趣可以直接跳过，本文将重点关注数据流的采集、计算以及输出相关的内容，不会涉及 Flink 等组件的高级使用方法，更详细的使用方式与方法请尽可能的参考相关开源项目的官方文档(详见本文末)。

## Kafka 的搭建

本文采用 Kafka 版本为 3.3.1，是截止到本文发布为止最新版本。

首先下载 Kafka 到本地服务器将其解压后，打开 `server.properties` 配置文件并对其进行配置：

```properties
############################# Server Basics #############################
# 当前 Kafka 的 Broker Id，每一台 Kafka 节点都需要有一个唯一的整数型ID。
broker.id=0 【标记一】
############################# Socket Server Settings #############################
# Socket 服务器监听的地址，host name 则默认使用 java.net.InetAddress.getCanonicalHostName()，端口默认为 9092.
# 该配置的格式如下：
#    listeners = listener_name://host_name:port
# 例子：
#    listeners = PLAINTEXT://your.host.name:9092
listeners=PLAINTEXT://10.0.170.197:9092 【标记二】
# Broker 将会把 listener 的 name、hostname 和 port 发送给客户端。
# 如果不设定，将会使用 "listeners" 的配置（如上）。
#advertised.listeners=PLAINTEXT://your.host.name:9092

# 将 listener 的名字映射到安全协议，默认情况下它们是一样的，你需要查看官方文档获取更详细的说明
#listener.security.protocol.map=PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

# 服务器用来接收网络请求并向对方发出响应的线程数
num.network.threads=3
# 服务器用来处理请求的线程数量，包括磁盘I/O
num.io.threads=8
# Socket Server 发送的套接字缓存设定 buffer (SO_SNDBUF)
socket.send.buffer.bytes=102400
# Socket Server 接收的套接字缓存设定 buffer (SO_RCVBUF)
socket.receive.buffer.bytes=102400
# Socket Server 接收请求的最大限制（用于防止 OOM）
socket.request.max.bytes=104857600
############################# Log Basics #############################
# 用于存放日志的目录，用逗号分割多个目录
log.dirs=/tmp/kafka-logs
# 每个主体默认的日志分区（partition）数，更多的分区将会提高并行消费的能力，但同时会增加跨 broker 的文件增多
num.partitions=1
# 当启动和恢复的时候用在每个数据目录的线程数，在关闭的时候会进行刷新
# 如果存储介质时 RAID 阵列，建议调大这个配置
num.recovery.threads.per.data.dir=1
############################# Internal Topic Settings  #############################
# group metadata "__consumer_offsets" 和 "__transaction_state"的复制因子，开发过程中通常使用1（即不复制），生产环境建议使用大于1的值来确保高可用性，通常设置为3。
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
############################# Log Flush Policy #############################
# 消息会立即写入文件系统，但默认情况下我们只使用 fsync() 来延迟同步 OS 缓存。以下配置将设置数据如何刷新到磁盘中。
# 在此处，需要对你的需求进行权衡：
#    1. 持久性：如果不使用复制，未刷新的数据可能会丢失。
#    2. 延迟：过大的刷新间隔可能会导致较高的延迟，因为每一次都可能会将大量的数据刷新到磁盘。
#    3. 吞吐量：刷新操作是比较消耗性能的，但是过小的刷新间隔可能会降低 Kafka 的吞吐量。
# 下面的设置允许配置刷新策略以在一段时间或每 N 条消息（或两者）后刷新数据。 这可以在全局范围内完成并在每个主题的基础上覆盖。
# 在接收到多少条消息的时候强制将数据刷新到磁盘
#log.flush.interval.messages=10000

# 在强制将数据刷新到磁盘之前，一条消息最多可以在日志中停留的时间（毫秒）
#log.flush.interval.ms=1000

############################# Log Retention Policy #############################
# 以下配置用来控制日志段的处置。 
# 可以将策略设置为在一段时间后删除日志段，或者在累积给定大小后删除日志段。
# 只要满足这些条件中的任何一个，就会删除一个段，并且删除总是从日志的末尾开始。

# 基于时间的日志处置策略，日志端最长保留时间（小时）
log.retention.hours=168
# 基于大小的日志处置策略，注意，该设置与 log.retention.hours 是互不干扰的
#log.retention.bytes=1073741824

# 日志段文件的最大大小。 当达到这个大小时，将创建一个新的日志段。
#log.segment.bytes=1073741824

# 检查日志段以查看是否可以根据保留策略删除的时间间隔
log.retention.check.interval.ms=300000
############################# Zookeeper #############################
# Zookeeper 链接字符串，通过逗号来进行分割多个 Zookeeper，例如： "127.0.0.1:3000,127.0.0.1:3001,127.0.0.1:3002"。
# 可以在此处指定应用程序所使用的根目录，例如下面的配置：
zookeeper.connect=localhost:2181/kafka-esteel 【标记三】
# 链接 Zookeeper 的超时时间
zookeeper.connection.timeout.ms=18000
############################# Group Coordinator Settings #############################
# 以下配置指定 GroupCoordinator 将延迟初始消费者 rebalance 的时间（以毫秒为单位）。
# 当新的 Kafka 节点加入到组的时候， rebalance 将进一步延迟 group.initial.rebalance.delay.ms 的值，最大为 max.poll.interval.ms，其默认值为 3 秒。
# 但是我们在此处将其设置为 0 目的是为了方便开发和调试。
# 但是在生产环境中，默认值3秒更合适，因为这会避免在应用程序启动的时候进行不必要的 rebalance 从而造成性能损耗.
group.initial.rebalance.delay.ms=0
```
我们需要修改以上配置文件中相关标记的值，它们分别是：

- ①：配置 Kafka 的 Broker ID
- ②：配置 Socket 服务器监听的地址
- ③：配置 Zookeeper 的地址

配置完毕后，先启动 Zookeeper （本文不涉及）后，再通过以下命令启动 Kafka：

```shell
./bin/kafka-server-start.sh -daemon config/server.properties
```

通过 JPS 查看进程，如果 Kafka 进程存在，则代表 Kafka 已经启动成功，否则可以将上述命令中的 `-daemon` 参数移除，重新启动查看日志输出，或者可以通过查看 `logs/server.log` 查看报错信息，根据错误信息进行问题排查。

## Kafka Connect 使用

Kafka 默认不会启动 Connect 线程，需要手动启动。

在启动 Kafka Connect 之前，需要新建一个 `worker.properties` 配置文件，配置文件内容在 `connect-distributed.properties` 中已经有了模板，我们可以直接使用该模板配置启动 Connect 线程，模板配置如下：

```properties
# Kafka 集群配置，此处只配置了一台
bootstrap.servers=10.0.170.197:9092

# 集群的名称，必须是唯一的，用于形成 Connect 集群组。 
# 请注意，这不能与 consumer group ID 冲突。
group.id=connect-cluster

# 转换器指定 Kafka 中数据的格式以及如何将其转换为 Connect 数据。 
# 每个 Connector 可以根据他们实际情况来进行配置。
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
# 是否转换 schema 信息
key.converter.schemas.enable=true
value.converter.schemas.enable=true

# 用于存储偏移量的 topic 名称，这个 topic 需要有多个 partition 并且设置成可复制的.
# Kafka 的 Connector 会自动创建该 topic，当然你也可以手动创建该 topic。
# 大多数情况下我们会将 replication 设置的比较多，例如示例中的 25，但是开发测试的时候一般用1。
offset.storage.topic=connect-offsets
offset.storage.replication.factor=1
#offset.storage.partitions=25

# 用于存储 connector 和 task 配置的 topic，需要注意的是这个 topic 必须是一个【单分区】、【压缩的】以及【可复制】 的主题，所以我们这里没有对 partition 进行配置的选项。
# 与 storage topic 类似，该 topic 会自动创建，也可以自己手动创建，手动创建该 topic 需要遵循上面的三点要求。
# replication 在开发和测试阶段通常使用1，在生产环境我们通常设置为3。
config.storage.topic=connect-configs
config.storage.replication.factor=1

# 用于存储状态的 topic，该 topic 可以拥有多个 partition，并且能够被复制和压缩。
# 该 topic 也会被自动创建，当然也可以自己手动创建，手动创建的时候需要遵循上述要求。
# replication 在开发和测试阶段通常使用1，在生产环境我们通常设置更多。
status.storage.topic=connect-status
status.storage.replication.factor=1
#status.storage.partitions=5

# 刷新速度，在开发环境可以设置快一些
offset.flush.interval.ms=10000

# Rest 接口的配置
#listeners=HTTP://:8083

# Rest 接口分发到客户端的设置，默认与 listeners 保持一致
#rest.advertised.host.name=
#rest.advertised.port=
#rest.advertised.listener=

# 设置插件目录，多个目录可以用逗号隔开，某些插件（例如debezium 的 PGSQL 的插件配置可能有细微的差别）详细说明请查看官方文档。
plugin.path=/app/kafka_2.13-3.3.1/plugins
```

将插件部署到 `/app/kafka_2.13-3.3.1/plugins` 目录下之后，就可以通过以下命令启动整个 Connect 线程了：

```shell
./bin/connect-distributed.sh config/connect-distributed.properties
```

如果需要后台运行，加入 `-daemon` 参数即可，通过后台运行的方式启动，可以在 `logs/connect.log` 中查看连接器的运行日志。

启动成功之后，可以通过 rest 接口对连接器进行操作，以下是常见的链接器操作：

### 新增连接器

需要注意，新增连接器，需要在 `plugin.path` 目录中已经存在其所依赖的 jar 包，也就是说连接器（connector）本身是基于连接器插件（connect plugin）创建的。

例如，我们创建一个 debezium 连接器（connector）的时候，需要先将 debezium 的 Kafka 连接器插件（connect）放入到 `plugin.path` 目录中，然后才能够基于 debezium 创建连接器（connector），其他连接器插件同理。

```http request
POST /connectors HTTP/1.1
Host: connect.example.com
Content-Type: application/json
Accept: application/json

{
  "name": "mysql-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "db01.test.esteel.tech",
    "database.port": "3306",
    "database.user": "foo",
    "database.password": "bar",
    "database.server.id": "184054",
    "topic.prefix": "mysql",
    "database.include.list": "esteel_test",
    "schema.history.internal.kafka.bootstrap.servers": "10.0.170.197:9092",
    "schema.history.internal.kafka.topic": "dbhistory.fullfillment",
    "include.schema.changes": "true"
  }
}
```
```http request
HTTP/1.1 201 Created
Content-Type: application/json

{
  "name": "mysql-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "db01.test.esteel.tech",
    "database.port": "3306",
    "database.user": "foo",
    "database.password": "bar",
    "database.server.id": "184054",
    "topic.prefix": "mysql",
    "database.include.list": "esteel_test",
    "schema.history.internal.kafka.bootstrap.servers": "10.0.170.197:9092",
    "schema.history.internal.kafka.topic": "dbhistory.fullfillment",
    "include.schema.changes": "true"
  },
  "tasks": [],
  "type": "source"
}
```

### 删除连接器

```http request
DELETE /connectors/{name} HTTP/1.1
Host: connect.example.com
Accept: application/json
```

```http request
HTTP/1.1 204 No Content
```

### 查询连接器状态

```http request
GET /connectors/{connector-name}/status HTTP/1.1
Host: connect.example.com
Accept: application/json
```

```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "name": "mysql-connector",
    "connector": {
        "state": "RUNNING",
        "worker_id": "10.0.170.197:8083"
    },
    "tasks": [
        {
            "id": 0,
            "state": "RUNNING",
            "worker_id": "10.0.170.197:8083"
        }
    ],
    "type": "source"
}
```

### 获取连接器配置信息

```http request
GET /connectors/{name}/config HTTP/1.1
Host: connect.example.com
Accept: application/json
```

```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.user": "foo",
    "database.server.id": "184054",
    "database.history.kafka.bootstrap.servers": "10.0.170.197:9092",
    "database.history.kafka.topic": "dbhistory.fullfillment",
    "database.server.name": "fullfillment",
    "schema.history.internal.kafka.bootstrap.servers": "10.0.170.197:9092",
    "database.port": "3306",
    "include.schema.changes": "true",
    "topic.prefix": "mysql",
    "schema.history.internal.kafka.topic": "dbhistory.fullfillment",
    "database.hostname": "db01.test.esteel.tech",
    "database.password": "bar",
    "name": "mysql-connector",
    "database.include.list": "esteel_test"
}
```

### 重启连接器

```http request
POST /connectors/{name}/restart HTTP/1.1
Host: connect.example.com
Accept: application/json
```

```http request
HTTP/1.1 202 ACCEPTED
Content-Type: application/json

{
      "name": "my-connector",
      "connector": {
          "state": "RUNNING",
          "worker_id": "fakehost1:8083"
      },
      "tasks":
      [
          {
              "id": 0,
              "state": "RUNNING",
              "worker_id": "fakehost2:8083"
          },
          {
              "id": 1,
              "state": "RESTARTING",
              "worker_id": "fakehost3:8083"
          },
          {
              "id": 2,
              "state": "RESTARTING",
              "worker_id": "fakehost1:8083"
          }
      ]
}
```

### 暂停连接器

```http request
PUT /connectors/{name}/pause HTTP/1.1
Host: connect.example.com
Accept: application/json
```
```http request
HTTP/1.1 202 Accepted
```

### 查看所有插件集合

```http request
GET /connector-plugins HTTP/1.1
Host: connect.example.com
Accept: application/json
```

```http request
HTTP/1.1 200 OK
Content-Type: application/json

[
    {
        "class": "io.debezium.connector.mysql.MySqlConnector",
        "type": "source",
        "version": "2.0.0.Final"
    },
    {
        "class": "org.apache.kafka.connect.mirror.MirrorCheckpointConnector",
        "type": "source",
        "version": "3.3.1"
    },
    {
        "class": "org.apache.kafka.connect.mirror.MirrorHeartbeatConnector",
        "type": "source",
        "version": "3.3.1"
    },
    {
        "class": "org.apache.kafka.connect.mirror.MirrorSourceConnector",
        "type": "source",
        "version": "3.3.1"
    }
]
```

### 校验连接器配置

```http request
PUT /connector-plugins/FileStreamSinkConnector/config/validate HTTP/1.1
Host: connect.example.com
Accept: application/json
Content-Type: application/json

{
    "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
    "tasks.max": "1",
    "topics": "test-topic"
}
```
```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "name": "FileStreamSinkConnector",
    "error_count": 1,
    "groups": [
        "Common"
    ],
    "configs": [
        {
            "definition": {
                "name": "topics",
                "type": "LIST",
                "required": false,
                "default_value": "",
                "importance": "HIGH",
                "documentation": "",
                "group": "Common",
                "width": "LONG",
                "display_name": "Topics",
                "dependents": [],
                "order": 4
        },
            "value": {
                "name": "topics",
                "value": "test-topic",
                "recommended_values": [],
                "errors": [],
                "visible": true
            }
        },
        {
            "definition": {
                "name": "file",
                "type": "STRING",
                "required": true,
                "default_value": "",
                "importance": "HIGH",
                "documentation": "Destination filename.",
                "group": null,
                "width": "NONE",
                "display_name": "file",
                "dependents": [],
                "order": -1
            },
            "value": {
                "name": "file",
                "value": null,
                "recommended_values": [],
                "errors": [
                    "Missing required configuration \"file\" which has no default value."
                ],
                "visible": true
            }
        },
        {
            "definition": {
                "name": "name",
                "type": "STRING",
                "required": true,
                "default_value": "",
                "importance": "HIGH",
                "documentation": "Globally unique name to use for this connector.",
                "group": "Common",
                "width": "MEDIUM",
                "display_name": "Connector name",
                "dependents": [],
                "order": 1
            },
            "value": {
                "name": "name",
                "value": "test",
                "recommended_values": [],
                "errors": [],
                "visible": true
            }
        },
        {
            "definition": {
                "name": "tasks.max",
                "type": "INT",
                "required": false,
                "default_value": "1",
                "importance": "HIGH",
                "documentation": "Maximum number of tasks to use for this connector.",
                "group": "Common",
                "width": "SHORT",
                "display_name": "Tasks max",
                "dependents": [],
                "order": 3
        },
            "value": {
                "name": "tasks.max",
                "value": "1",
                "recommended_values": [],
                "errors": [],
                "visible": true
            }
        },
        {
            "definition": {
                "name": "connector.class",
                "type": "STRING",
                "required": true,
                "default_value": "",
                "importance": "HIGH",
                "documentation": "Name or alias of the class for this connector. Must be a subclass of org.apache.kafka.connect.connector.Connector. If the connector is org.apache.kafka.connect.file.FileStreamSinkConnector, you can either specify this full name,  or use \"FileStreamSink\" or \"FileStreamSinkConnector\" to make the configuration a bit shorter",
                "group": "Common",
                "width": "LONG",
                "display_name": "Connector class",
                "dependents": [],
                "order": 2
            },
            "value": {
                "name": "connector.class",
                "value": "org.apache.kafka.connect.file.FileStreamSinkConnector",
                "recommended_values": [],
                "errors": [],
                "visible": true
            }
        }
    ]
}
```

## Kafka Connector 的定义

Kafka Connect 分 Source（源）和 Sink（落地）两种，我们可以自己实现一个 Connect 插件，也可以使用第三方提供的 Connect 插件，无论是自己实现还是使用第三方的 Connector，都需要使用到 Kafka 的 Connector 配置。

所有的配置，我们都可以在[官方文档](https://kafka.apache.org/documentation/#sourceconnectconfigs "Source Connector Configs")中查看到。

以 Kafka Source Connect 的配置为例，主要包括以下配置。

### name

全局唯一的名称

### connector.class

入口程序，此连接器的类的名称或别名。 必须是 `org.apache.kafka.connect.connector.Connector` 的子类。 如果连接器是 `org.apache.kafka.connect.file.FileStreamSinkConnector`，你可以指定这个全名，或者使用“FileStreamSink”或“FileStreamSinkConnector”使配置更短一些。

### tasks.max

这个连接器最大任务数量

### key.converter

key的反序列化类，这个配置我们在 `connect-distributed.properties` 配置文件中见过，这个配置是独立于连接器存在的，

### value.converter

这个配置是 value 的反序列化类，其他同上。

### header.converter

消息头（header）的反序列化类，默认情况下，`SimpleHeaderConverter` 用于将标头值序列化为字符串，并通过推断模式来反序列化它们。

### config.action.reload

当外部配置提供程序的更改导致连接器的配置属性发生更改时，Connect 应该对连接器执行的操作。 

`none` 值表示 Connect 将不执行任何操作。 

`restart` 值表示 Connect 应使用更新的配置属性重新启动/重新加载连接器。

该配置项的默认值是 `restart`。

### transforms

针对消息记录进行转换的转换器别名，官方文档并未详细说明该配置项的作用，但是在 Confluent 的文档中关于SMT的部分进行了描述。

> 单一消息转换器（Single Message Transformation —— SMT）应用在消息进入 Kafka 之前（Source Connect），通过 SMT 对消息进行转换。
> 或在消息转出之前（Sink Connect），通过 SMT 对消息进行转换。

当前 SMT 提供了类似：Drop、Cast、ExtractField、ExtractTopic、Filter等 SMT。

### predicates

官方文档并未详细说明，其作用类似于路由统配，通过 predicates 对消息进行过滤，只有当满足特定条件的消息才会被 transforms 进行转换。

目前在 Kafka Connect 中有以下三种 predicates：

1. TopicNameMatches
2. HasHeaderKey
3. RecordIsTombstone

### errors.retry.timeout

重新尝试失败操作的最大持续时间（以毫秒为单位）。 默认值为 0，这意味着不会尝试重试。 使用 -1 进行无限重试。

### errors.retry.delay.max.ms

连续重试尝试之间的最大持续时间（以毫秒为单位）。 一旦达到此限制，抖动将被添加到延迟中，以防止雷鸣般的羊群问题。

### errors.tolerance

在连接器操作期间容忍错误的行为。 默认是 `none`，表示任何错误都会导致连接器任务立即失败； 而 `all` 则是跳过有问题的记录。

### errors.log.enable

如果为 `true`，则将每个错误以及失败操作的详细信息和有问题的记录写入 Connect 应用程序日志。 默认是 `false`，因此只报告不允许的错误。

### errors.log.include.messages

是否在日志中包含导致失败的 Connect 记录。对于 sink 记录，将记录主题、分区、偏移量和时间戳。 对于源记录，将记录键和值（及其模式）、所有标头以及时间戳、Kafka Topic、Kafka Partitions、源分区和源偏移量（offset）。 默认值是 `false`，意味着不会记录键、值和标头等信息写入日志文件。

### topic.creation.groups

所属配置组

### exactly.once.support

如果设置为 `required` ，则强制对连接器进行预检检查，以确保它可以提供给定配置的 exactly-once delivery。 一些连接器能够提供exactly-once delivery，但不能告知 Connect。

在这种情况下，应在创建连接器之前仔细查阅连接器的文档，并且该属性的值应设置为 `requested`。

此外，如果该值设置为 `required` ，但执行预检验证的 worker 没有为source connector启用exactly-once支持，则创建或验证连接器的请求将会失败。

### transaction.boundary

允许的值为：`poll`、`interval`、`connector`。 

如果设置为 `poll`，则将为来自此连接器的每个任务提供给 Connect 的每批记录启动并提交一个新的生产者事务。 

如果设置为`connector`，则依赖于连接器定义的事务边界； 需要注意的是，并非所有连接器都能够定义自己的事务边界，在这种情况下，尝试使用此值实例化连接器将失败。 

最后，如果设置为`interval`，则仅在用户定义的时间间隔过去后提交事务。

### transaction.boundary.interval.ms

参考上面的文档，如果 `transaction.boundary` 设置为 `interaval`，那么这里就需要告知它间隔多久后提交事务。

### offsets.storage.topic

用于此连接器的单独偏移主题的名称。 如果为 null 或未指定，将使用 worker 的全局偏移量主题名称。 如果指定了名称，并且此连接器所针对的 Kafka 集群上尚不存在偏移量主题，则将创建该主题（前提是连接器生产者的 `bootstrap.servers` 属性已被 worker 的覆盖）。 

这个配置仅适用于分布式模式； 在独立模式下，设置此属性将无效。

## Debezium 的使用

Debezium 是一个集成了多种数据源抽取的开源工具，目前支持的数据源包括：

- MySQL
- MongoDB
- Oracle
- SQL Server
- Db2
- Cassandra
- Vitess
- PostgreSQL

该工具支持独立部署以及通过 Kafka Connect 的方式部署插件，目前我们使用的是 Kafka Connect 插件的方式来使用该工具。

我们以 mysql 为例，首先我们需要将[插件](https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.0.0.Final/debezium-connector-mysql-2.0.0.Final-plugin.tar.gz)下载到本地服务器。

将其解压到 Kafka Connect 的插件目录，即 `plugin.path` 所指向的目录。

然后重启 Kafka Connect 线程即可完成插件的安装，完成安装之后，我们可以通过 Kafka Connect 的 REST API 添加连接器，具体参数如下：

```json
{
    "name": "inventory-connector", 
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector", 
        "database.hostname": "192.168.99.100", 
        "database.port": "3306", 
        "database.user": "debezium-user", 
        "database.password": "debezium-user-pw", 
        "database.server.id": "184054", 
        "topic.prefix": "fullfillment", 
        "database.include.list": "inventory", 
        "schema.history.internal.kafka.bootstrap.servers": "kafka:9092", 
        "schema.history.internal.kafka.topic": "schemahistory.fullfillment", 
        "include.schema.changes": "true" 
    }
}
```

参数分别为：

1. `name` 连接器名称，全局唯一
2. `connector.class` 连接器入口类
3. `database.hostname` 数据库链接地址
4. `database.port` 数据库端口
5. `database.user` 用户名
6. `database.password` 密码
7. `database.server.id` 在这个 Connector 下一个唯一的ID
8. `topic.prefix` 当前连接器在 Kafka 中的 topic 前缀
9. `database.include.list` 指定要监听哪些数据库
10. `schema.history.internal.kafka.bootstrap.servers` Kafka Borkers 的配置
11. `schema.history.internal.kafka.topic `数据库模式历史主题的名称，该主题仅供 Debezium 内部使用。
12. `include.schema.changes` 是否包括表结构变化语句

Debezium 的消息体包含了详细的信息，如下所示：

新增的消息体：

```json
{
	"schema": {...},
	"payload": {
		"before": null,
		"after": {
			"id": 1,
			"value": "123123"
		},
		"source": {
			"version": "2.0.0.Final",
			"connector": "mysql",
			"name": "mysql",
			"ts_ms": 1666859621000,
			"snapshot": "false",
			"db": "esteel_test",
			"sequence": null,
			"table": "test",
			"server_id": 17023,
			"gtid": "c6e015bc-fff1-11eb-893f-005056bfba6e:207829436",
			"file": "mysql-bin.000323",
			"pos": 172717546,
			"row": 0,
			"thread": 16846597,
			"query": null
		},
		"op": "c",
		"ts_ms": 1666859621404,
		"transaction": null
	}
}
```

修改的消息体：
```json
{
	"schema": {...},
	"payload": {
		"before": {
			"id": 10,
			"value": "哈哈哈"
		},
		"after": {
			"id": 10,
			"value": "吼吼吼"
		},
		"source": {
			"version": "2.0.0.Final",
			"connector": "mysql",
			"name": "mysql",
			"ts_ms": 1667182575000,
			"snapshot": "false",
			"db": "esteel_test",
			"sequence": null,
			"table": "test",
			"server_id": 17023,
			"gtid": "c6e015bc-fff1-11eb-893f-005056bfba6e:209669074",
			"file": "mysql-bin.000324",
			"pos": 420044895,
			"row": 0,
			"thread": 17136155,
			"query": null
		},
		"op": "u",
		"ts_ms": 1667182575811,
		"transaction": null
	}
}
```

删除的消息体：
```json
{
	"schema": {...},
	"payload": {
		"before": {
			"id": 6,
			"value": "sasdf"
		},
		"after": null,
		"source": {
			"version": "2.0.0.Final",
			"connector": "mysql",
			"name": "mysql",
			"ts_ms": 1667179951000,
			"snapshot": "false",
			"db": "esteel_test",
			"sequence": null,
			"table": "test",
			"server_id": 17023,
			"gtid": "c6e015bc-fff1-11eb-893f-005056bfba6e:209649121",
			"file": "mysql-bin.000324",
			"pos": 405238928,
			"row": 0,
			"thread": 17136155,
			"query": null
		},
		"op": "d",
		"ts_ms": 1667179951725,
		"transaction": null
	}
}
```

可以通过 `op` 属性来判断当前消息体所对应的数据库操作类型，该属性包括以下几个类型：

- 'c' 表示当前事件是创建
- 'd' 表示当前事件是删除
- 'u' 表示当前事件是更新
- 'r' READ，当 Debezium 首次监听的时候，会将库表中所有的数据通过 READ 事件发送出来，可以通过修改配置文件将 READ 事件转换成 CREAT 事件。

除此之外，需要注意 payload 中 before、after 分别代表这个操作所针对的记录变化信息，before代表记录操作前的快照，after代表记录操作后的结果。

在 schema 属性中会包含所有的库表结构信息，由于这部分内容十分冗长，大多数时候我们需要将其禁用掉，禁用的方法比较简单，就是打开 kafka 的 `connect-distributed.properties` （或者你自己的 `worker.properties`）配置文件，修改其中的 `value.converter.schemas.enable` 为 `false` 即可，如下：

```properties
value.converter.schemas.enable=false
```

此时，监听到的库表结构信息就变成了：

```json
{
	"before": {
		"id": 16,
		"value": "阿斯顿发生"
	},
	"after": {
		"id": 16,
		"value": "123123"
	},
	"source": {
		"version": "2.0.0.Final",
		"connector": "mysql",
		"name": "mysql",
		"ts_ms": 1667187462000,
		"snapshot": "false",
		"db": "esteel_test",
		"sequence": null,
		"table": "test",
		"server_id": 17023,
		"gtid": "c6e015bc-fff1-11eb-893f-005056bfba6e:209707800",
		"file": "mysql-bin.000324",
		"pos": 485814959,
		"row": 0,
		"thread": 17136155,
		"query": null
	},
	"op": "u",
	"ts_ms": 1667196009284,
	"transaction": null
}
```

当然，我们还可以对数据格式进行自定义（非必要不建议），从而进一步的精简消息内容，参考以下实现：

```properties
transforms=unwrap,...
transforms.unwrap.type=io.debezium.transforms.ExtractNewRecordState
transforms.unwrap.drop.tombstones=false
transforms.unwrap.delete.handling.mode=rewrite
transforms.unwrap.add.fields=table,lsn
```

结果：

```json
{
    "id": 8,
    "value": "3333",
    "__table": "test",
    "__deleted": "true"
}
```

注意： Debezium 在删除记录的时候，会在发出删除操作之后，向Kafka中写入一个null，它表示日志压缩可以删除所有具有该键的记录，原文如下：

> A tombstone record that has the same key as the deleted row and a value of null. This record is a marker for Apache Kafka. It indicates that log compaction can remove all records that have this key.

但是在 Sink 端，接收到 Null 值可能会引发 NPE 异常，所以在 Flink 接收 Kafka 数据的时候，需要针对 Null 值进行判断，例如示例中，我们使用 MyStringSchema 重写了反序列化接口，从而避免 NPE 问题的产生：

```java
public class MyStringSchema extends SimpleStringSchema {

    @Override
    public String deserialize(byte[] message) {
        if (Objects.isNull(message)) {
            return null;
        }
        return super.deserialize(message);
    }
}
```

## Flink 的搭建

Flink 的集群搭建比较简单，此处仅对其配置文件进行简单的说明：

```properties
#==============================================================================
# Common
#==============================================================================

# 此设置仅在独立模式下使用，并且可以通过指定 bin/jobmanager.sh --host <hostname> 参数在 JobManager 端被覆盖。
# 在 HA 模式下，该属性将会被配置文件中的 master 文件中的内容所覆盖。

jobmanager.rpc.address: 10.0.170.194

# JobManager 可访问的 RPC 端口。

jobmanager.rpc.port: 6123

# JobManager 将绑定到的主机接口。 默认情况下是 localhost，并且会阻止 JobManager 在运行它的机器/容器之外进行通信。 在 Hadoop YARN 上，如果设置为“localhost”，则此设置将被忽略，默认为 0.0.0.0。 
# 而在 Kubernetes 上，此设置将被忽略，默认为 0.0.0.0。要启用此功能，请将绑定主机地址设置为可以访问外部网络接口的地址，例如 0.0.0.0。

jobmanager.bind-host: 0.0.0.0

# JobManager 的总进程内存大小。请注意，这考虑了 JobManager 进程中的所有内存使用情况，包括 JVM 元空间和其他开销。
# 如果该值设置过小，在运行 Job 的时候可能会出现资源不足的运行时异常，具体情况在实际运行中可以遇到
# 这里的值我是变动过的，默认是1400m（即1400兆）。

jobmanager.memory.process.size: 6g

# 与 jobmanager.bind-host 类似，在 Kubernetes 上，此设置将被忽略，默认为 0.0.0.0。要启用此功能，请将绑定主机地址设置为可以访问外部网络接口的地址，例如 0.0.0.0。

taskmanager.bind-host: 0.0.0.0

# 请注意这个配置！！！！
# TaskManager 运行的主机地址，JobManager 和其他 TaskManager 可以访问。 如果没有指定，TaskManager 会尝试不同的策略来识别地址。
# 请注意，此地址需要 JobManager 可以访问，并将流量转发到 TaskManager 绑定到的接口之一（请参阅“taskmanager.bind-host”）。
# 另请注意，除非所有 TaskManager 都在同一台机器上运行，否则需要为每个 TaskManager 单独配置此地址。

taskmanager.host: 10.0.170.194

# TaskManager 的总进程内存大小。 请注意，这考虑了 TaskManager 进程中的所有内存使用情况，包括 JVM 元空间和其他开销。
# 此处配置我也变动过，原始配置好像是1400m，如果此配置过小，同样会在执行 Job 的时候报出资源不足异常。

taskmanager.memory.process.size: 6g

# 用 Flink 总内存来设置内存大小，用来替换'taskmanager.memory.process.size' 配置
# 该配置不建议与 'taskmanager.memory.process.size' 同时配置.
#
# taskmanager.memory.flink.size: 1280m

# 每个 TaskManager 提供的任务槽数。 每个插槽运行一个并行管道，通常配置成 CPU 的数量。

taskmanager.numberOfTaskSlots: 4

# 默认 Job 并行度，如果程序没有显示的设置其并行度，则会使用该配置

parallelism.default: 1

# 文件系统的配置，默认情况下使用的是本地路径，我们也可以使用 hdfs://mynamenode:12345 将文件存储到 HDFS 上
#
# fs.default-scheme

#==============================================================================
# 高可用配置
#==============================================================================

# 配置高可用，只有 'NONE' 和 'zookeeper' 两种方式
#
# high-availability: zookeeper

# 保存主恢复元数据的路径。 ZooKeeper 为检查点和领导者选举存储了小的基本事实，而这个位置存储了较大的对象，比如持久化的数据流图。
# 这个文件系统必须是所有节点都能够访问到的文件系统，例如使用 HDFS、S3、Ceph、nfs 等。 
# high-availability.storageDir: hdfs:///flink/ha/

# Zookeeper 节点配置，如下所示：
# "host1:clientPort,host2:clientPort,..." (default clientPort: 2181)
#
# high-availability.zookeeper.quorum: localhost:2181


# ACL 选项基于 https://zookeeper.apache.org/doc/r3.1.2/zookeeperProgrammers.html#sc_BuiltinACLSchemes
# 它的值可以是 "creator" (ZOO_CREATE_ALL_ACL) 或 "open" (ZOO_OPEN_ACL_UNSAFE)
# 默认值是 "open"， 如果 ZK 的 security 是启用状态，则可以改成 "creator"
#
# high-availability.zookeeper.client.acl: open

#==============================================================================
# 容错和检查点配置
#==============================================================================

# 关于检查点的一些配置
#
# execution.checkpointing.interval: 3min
# execution.checkpointing.externalized-checkpoint-retention: [DELETE_ON_CANCELLATION, RETAIN_ON_CANCELLATION]
# execution.checkpointing.max-concurrent-checkpoints: 1
# execution.checkpointing.min-pause: 0
# execution.checkpointing.mode: [EXACTLY_ONCE, AT_LEAST_ONCE]
# execution.checkpointing.timeout: 10min
# execution.checkpointing.tolerable-failed-checkpoints: 0
# execution.checkpointing.unaligned: false
#
# Supported backends are 'hashmap', 'rocksdb', or the
# <class-name-of-factory>.
#
# state.backend: hashmap

# 检查点文件系统的目录，此处采用 HDFS 文件系统
#
# state.checkpoints.dir: hdfs://namenode-host:port/flink-checkpoints

# 默认的保存点文件系统目录
#
# state.savepoints.dir: hdfs://namenode-host:port/flink-savepoints

# 为支持增量检查点的后端（如 RocksDB 状态后端）启用/禁用增量检查点的标志。
#
# state.backend.incremental: false

# 故障转移策略，即作业计算如何从任务失败中恢复。
# 如果它们的生产数据不再可用于消费，仅重新启动可能受任务失败影响的任务，这通常包括下游任务和潜在的上游任务。

jobmanager.execution.failover-strategy: region

#==============================================================================
# Rest 和 Web 端配置
#==============================================================================

# Rest 客户端链接的端口
#rest.port: 8081

# The address to which the REST client will connect to
#
rest.address: 0.0.0.0

# 可以设置成给定一个范围的随机端口
#
#rest.bind-port: 8080-8090

# 默认是 localhost， 这意味着不可以通过外部访问该接口
# 如果要启用外部访问，需要将其改成 0.0.0.0
#
rest.bind-address: 0.0.0.0

# 是否允许通过 web 端提交作业

web.submit.enable: true

# 是否允许通过 web 端取消作业

web.cancel.enable: true

#==============================================================================
# 高级设置
#==============================================================================

# Override the directories for temporary files. If not specified, the
# system-specific Java temporary directory (java.io.tmpdir property) is taken.
#
# For framework setups on Yarn, Flink will automatically pick up the
# containers' temp directories without any need for configuration.
#
# Add a delimited list for multiple directories, using the system directory
# delimiter (colon ':' on unix) or a comma, e.g.:
#     /data1/tmp:/data2/tmp:/data3/tmp
#
# Note: Each directory entry is read from and written to by a different I/O
# thread. You can include the same directory multiple times in order to create
# multiple I/O threads against that directory. This is for example relevant for
# high-throughput RAIDs.
#
# io.tmp.dirs: /tmp

# The classloading resolve order. Possible values are 'child-first' (Flink's default)
# and 'parent-first' (Java's default).
#
# Child first classloading allows users to use different dependency/library
# versions in their application than those in the classpath. Switching back
# to 'parent-first' may help with debugging dependency issues.
#
# classloader.resolve-order: child-first

# The amount of memory going to the network stack. These numbers usually need 
# no tuning. Adjusting them may be necessary in case of an "Insufficient number
# of network buffers" error. The default min is 64MB, the default max is 1GB.
# 
# taskmanager.memory.network.fraction: 0.1
# taskmanager.memory.network.min: 64mb
# taskmanager.memory.network.max: 1gb

#==============================================================================
# Flink Cluster Security Configuration
#==============================================================================

# Kerberos authentication for various components - Hadoop, ZooKeeper, and connectors -
# may be enabled in four steps:
# 1. configure the local krb5.conf file
# 2. provide Kerberos credentials (either a keytab or a ticket cache w/ kinit)
# 3. make the credentials available to various JAAS login contexts
# 4. configure the connector to use JAAS/SASL

# The below configure how Kerberos credentials are provided. A keytab will be used instead of
# a ticket cache if the keytab path and principal are set.

# security.kerberos.login.use-ticket-cache: true
# security.kerberos.login.keytab: /path/to/kerberos/keytab
# security.kerberos.login.principal: flink-user

# The configuration below defines which JAAS login contexts

# security.kerberos.login.contexts: Client,KafkaClient

#==============================================================================
# ZK Security Configuration
#==============================================================================

# Below configurations are applicable if ZK ensemble is configured for security

# Override below configuration to provide custom ZK service name if configured
# zookeeper.sasl.service-name: zookeeper

# The configuration below must match one of the values set in "security.kerberos.login.contexts"
# zookeeper.sasl.login-context-name: Client

#==============================================================================
# HistoryServer
#==============================================================================

# The HistoryServer is started and stopped via bin/historyserver.sh (start|stop)

# Directory to upload completed jobs to. Add this directory to the list of
# monitored directories of the HistoryServer as well (see below).
#jobmanager.archive.fs.dir: hdfs:///completed-jobs/

# The address under which the web-based HistoryServer listens.
#historyserver.web.address: 0.0.0.0

# The port under which the web-based HistoryServer listens.
#historyserver.web.port: 8082

# Comma separated list of directories to monitor for completed jobs.
#historyserver.archive.fs.dir: hdfs:///completed-jobs/

# Interval in milliseconds for refreshing the monitored directories.
#historyserver.archive.fs.refresh-interval: 10000
```

除此之外，我们还需要修改 conf/workers、conf/masters 配置文件的内容，其实就是以前的 master、slave 配置，例如 masters 配置文件下的内容是：

```text
10.0.170.194:8081
```

workers 配置文件下的内容是：

```text
10.0.170.195
10.0.170.196
```

做好上述配置之后，将整个文件夹分发到所有节点上，然后依次修改每个节点上 conf/flin-conf.yaml 配置文件的内容：

```properties
# 请注意这个配置！！！！
# TaskManager 运行的主机地址，JobManager 和其他 TaskManager 可以访问。 如果没有指定，TaskManager 会尝试不同的策略来识别地址。
# 请注意，此地址需要 JobManager 可以访问，并将流量转发到 TaskManager 绑定到的接口之一（请参阅“taskmanager.bind-host”）。
# 另请注意，除非所有 TaskManager 都在同一台机器上运行，否则需要为每个 TaskManager 单独配置此地址。

taskmanager.host: 10.0.170.194
```

所有工作准备完毕之后，通过以下命令启动集群（集群节点之间需要能够无密码访问）：

```shell
.bin/start-cluster.sh
```

## Flink 基于 Kafka 的流式计算 

直接参考代码仓库中的 `com.esteel.streaming.kafka.e2.KafkaStreamingJob`

```java
/**
 * @author Kehaw
 * @since JDK11
 */
public class KafkaStreamingJob {

    public static void main(String[] args) throws Exception {
        // 定义流式计算的环境
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 配置失败重启策略
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
                Integer.MAX_VALUE, // 尝试重启的次数
                org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS) // 间隔
        ));

        KafkaSource<MysqlDataMapping> source = buildSource();
        DataStream<MysqlDataMapping> stream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka source");
        stream.rebalance().filter(Objects::nonNull).map((MapFunction<MysqlDataMapping, Object>) value -> "Received message: " + value).print();
        // execute program
        env.execute("Flink Streaming Java API Skeleton");
    }

    private static KafkaSource<MysqlDataMapping> buildSource() {
        KafkaSource<MysqlDataMapping> source = KafkaSource.<MysqlDataMapping>builder()
                .setBootstrapServers("10.0.170.197:9092")
                .setTopics("mysql2.esteel_test.test")
                .setGroupId("my-test-group")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new TableDataDeserializationSchema())
                .build();
        return source;
    }
}
```

核心代码主要描述了如何定义环境、在这个环境里定义数据源，然后基于数据源将消息打印出来。

此处我们使用了一个自定义的反序列化类 `TableDataDeserializationSchema`，该类主要作用就是将 Kafka 中的数据反序列化成我们的 Java 类 `MysqlDataMapping`。


## 附篇：基于 Rabbit MQ 的流式计算 

直接参考代码仓库中的 `com.esteel.streaming.rabbitmq.e1.RabbitStreamingJob`

为了和 Kafka 的流式计算有所区别，我们在 Rabbit MQ 的流式计算中，加入了水位线以及窗口算子的概念。

```java
/**
 * @author Kehaw
 * @since JDK 11
 */
public class RabbitStreamingJob {

    public static void main(String[] args) throws Exception {
        // 创建 Flink 执行环境
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 配置失败重启策略
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
                Integer.MAX_VALUE, // 尝试重启的次数
                org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS) // 间隔
        ));

        RMQSource<SensorReading> source = buildSource();

        // 设置时间戳和水位线
        WatermarkStrategy<SensorReading> watermarkStrategy = WatermarkStrategy
                .<SensorReading>forBoundedOutOfOrderness(Duration.ofSeconds(5))
                .withTimestampAssigner(new SensorTimeAssigner());

        // 将数据源添加到环境中
        DataStream<SensorReading> sensorData = env.addSource(source)
                .assignTimestampsAndWatermarks(watermarkStrategy)
                .setParallelism(2);

        DataStream<SensorAvgResult> avgTemp = sensorData
                // 根据指标ID对数据进行分组
                .keyBy(SensorReading::getMetricId)
                // 再将数据按5秒的滚动窗口进行拆分
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                // 使用用户自定义的函数进行计算，例如此处是计算5秒内的平均值
                .apply(new TemperatureAverager());

        // 将结果打印（这里是调用toString方法）
        // 如果需要进行下一步写入，需要在这里进行定义并写入数据汇
        avgTemp.print();
        // 提交执行
        env.execute("Compute average sensor temperature");

    }

    private static RMQSource<SensorReading> buildSource() {
        // 初始化 Rabbit MQ 链接配置
        final RMQConnectionConfig connectionConfig = new RMQConnectionConfig
                .Builder()
                .setHost("mss-mq.dev.mysteelsoft.tech")
                .setPort(5672)
                .setVirtualHost("iothub")
                .setUserName("iothub")
                .setPassword("------")
                .build();

        // 定义数据源
        return new RMQSource<>(
                connectionConfig,
                "iothub-flink-receive-q",
                true,
                new SensorDeserializationSchema());
    }

    public static class TemperatureAverager implements WindowFunction<SensorReading, SensorAvgResult, Long, TimeWindow> {

        /**
         * @param sensorId 分组ID，这里是指标ID
         * @param window   窗口对象
         * @param input    输入的数据
         * @param out      输出的数据
         */
        @Override
        public void apply(Long sensorId, TimeWindow window, Iterable<SensorReading> input, Collector<SensorAvgResult> out) {
            int count = 0;
            BigDecimal sum = new BigDecimal("0");
            for (SensorReading sensorReading : input) {
                count++;
                sum = sum.add(sensorReading.getMetricValue());
            }
            if (count == 0) {
                return;
            }
            BigDecimal result = sum.divide(BigDecimal.valueOf(count), 4, RoundingMode.HALF_UP);
            SensorAvgResult avg = new SensorAvgResult();
            avg.setMid(sensorId);
            avg.setAvgValue(result);
            out.collect(avg);
        }
    }
}
```

## Flink SQL

我们这里通过一个最简单的例子来实现 Flink 的 SQL 查询。

首先确保 Debezium 的数据已经正确的进入到 Kafka，通过 Kafka 命令查询 Topic 列表如下所示：

```text
__consumer_offsets
connect-configs
connect-offsets
connect-status
dbhistory.fullfillment
mysql.esteel_test.test
```

其中，`mysql.esteel_test.test` 是我们需要监听的数据，并且确保采用的格式是默认不包含 schema 信息的 JSON 数据。 通过 Rest API 建立 Debezium Connector 的请求参数如下：

```json
{
    "name": "mysql-connector", 
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector", 
        "database.hostname": "db01.test.esteel.tech", 
        "database.port": "3306", 
        "database.user": "foo", 
        "database.password": "bar", 
        "database.server.id": "184054", 
        "topic.prefix": "mysql", 
        "database.include.list": "esteel_test", 
        "schema.history.internal.kafka.bootstrap.servers": "10.0.170.197:9092", 
        "schema.history.internal.kafka.topic": "dbhistory.fullfillment", 
        "include.schema.changes": "false"
    }
}
```

确保上述信息准确无误之后，可以通过 Flink 自带的 SQL 查询客户端进行数据查询。

在进行查询之前，我们需要在 Flink 的 Lib 目录下添加两个 JAR 包，并分发到所有的 Flink 节点上，它们分别是：

```text
wget https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.3.1/kafka-clients-3.3.1.jar
wget https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/1.16.0/flink-connector-kafka-1.16.0.jar
```

准备好一切之后，可以通过 Flink 自带的 SQL 客户端进行操作。

### 建表

原始的数据库表结构如下：

```sql
create table esteel_test.test
(
    id    bigint auto_increment primary key,
    value varchar(100) null
);
```

在 Flink 中，通过 `./bin/sql-client.sh` 打开 SQL 客户端，并输入新建的语句如下：

```sql
CREATE TABLE esteel_test (
    id    bigint primary key,
    `value` STRING
) WITH (
 'connector' = 'kafka',
 'topic' = 'mysql.esteel_test.test',
 'properties.bootstrap.servers' = '10.0.170.197:9092',
 'properties.group.id' = 'my-test-group',
 'scan.startup.mode' = 'earliest-offset',
 'properties.auto.offset.reset' = 'earliest',
 'format' = 'debezium-json'
)
```

这段建表语句的前半部分与 MySQL 中的 DDL 很像，只是将 `varchar` 改成了 `STRING`，将自增列的描述移除了，需要注意的是，`value` 是关键字，需要进行转义。

后半部分是对数据来源（source）的描述，其中：

1. connector 连接器类型，我们这里选择 kafka
2. topic 需要监听的 topic
3. properties.bootstrap.servers Kafka的集群地址
4. properties.group.id Kafka 客户端 consumer 分组ID
5. scan.startup.mode 消费模式，我们这里选择从最早的一条记录开始消费
6. properties.auto.offset.reset 偏移量设置，我们这里与上面保持一致
7. format 消息格式解析，我们采用 debezium-json 即可（因为我们的数据就是从 Debezium 中发出的）

### 简单查询

创建完毕之后，可以通过以下语句对这个 Flink Table 进行查询：

```sql
select * from esteel_test;
```

得到结果如下：

| id  | Value |
|-----|-------|
| 18  | Hello |
| 19  | World |

并且，随着数据库中的字段更新，该表会实时的发生变化。

我们也可以对数据集合进行计算等操作：

```sql
select sum(id) from esteel_test;
```



### 表操作 & 高级应用

Flink 对 SQL 的支持基于实现了 SQL 标准的 Apache Calcite，所以可以使用大部分我们所常见的查询方法，Flink 支持包括数据定义语言（Data Definition Language，DDL）、数据操纵语言（Data Manipulation Language，DML）以及查询语言等常规操作。

所以，与 MySQL 一样，你可以使用 Drop、Alter 等常规 SQL 操作，目前 Flink SQL 支持以下操作：

- SELECT (Queries)
- CREATE TABLE, CATALOG, DATABASE, VIEW, FUNCTION
- DROP TABLE, DATABASE, VIEW, FUNCTION
- ALTER TABLE, DATABASE, FUNCTION
- ANALYZE TABLE
- INSERT
- SQL HINTS
- DESCRIBE
- EXPLAIN
- USE
- SHOW
- LOAD
- UNLOAD

具体可以参考官方文档关于 SQL 方面的详细描述。

对于数据类型的支持，目前 Flink SQL 支持以下几种数据类型：

- CHAR
- VARCHAR
- STRING
- BOOLEAN
- BINARY
- VARBINARY
- BYTES
- DECIMAL
- TINYINT
- SMALLINT
- INTEGER
- BIGINT
- FLOAT
- DOUBLE
- DATE
- TIME
- TIMESTAMP
- TIMESTAMP_LTZ
- INTERVAL
- ARRAY
- MULTISET
- MAP
- ROW
- RAW
- Structured types

虽然 Flink 并未完全实现 Apache  Calcite 的功能，但是一些字符串的组合却已经被预留为关键字以备未来使用。如果你希望使用[保留字符串](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/dev/table/sql/overview/#%e4%bf%9d%e7%95%99%e5%85%b3%e9%94%ae%e5%ad%97)作为你的字段名，请在使用时使用反引号将该字段名包起来（如 `value`, `count` ）。

## Flink Table Api

| Name                        | Version       | Source                                | Sink                        |
|-----------------------------|---------------|---------------------------------------|-----------------------------|
| Filesystem                  |               | Bounded and Unbounded Scan, Lookup    | Streaming Sink, Batch Sink  |
| Elasticsearch               | 6.x & 7.x     | Not supported                         | Streaming Sink, Batch Sink  |
| Apache Kafka                | 0.10+         | Unbounded Scan                        | 	Streaming Sink, Batch Sink |
| Amazon Kinesis Data Streams |               | Unbounded Scan                        | Streaming Sink              |
| JDBC                        |               | Bounded Scan, Lookup                  | Streaming Sink, Batch Sink  |
| Apache HBase                | 1.4.x & 2.2.x | Bounded Scan, Lookup                  | Streaming Sink, Batch Sink  |
| Apache Hive                 |               | Unbounded Scan, Bounded Scan, Lookup  | Streaming Sink, Batch Sink  |

### 通过 Table API 流式计算 Debezium 投递过来的数据 

上一节说到建表以及对表进行查询，这些操作都是基于 Flink 的 SQL Client 进行的，这一节将通过 Table API 对表进行查询。

完整的代码如下：

```java
package com.esteel.streaming.kafka.e3;

import org.apache.flink.streaming.connectors.kafka.table.KafkaConnectorOptions;
import org.apache.flink.table.api.*;

/**
 * @author Kehaw
 * @since 2022/10/28
 */
public class TableKafkaJob {
    public static void main(String[] args) {
        final EnvironmentSettings settings = EnvironmentSettings.inStreamingMode();
        
        // 为处理创建环境
        TableEnvironment env = TableEnvironment.create(settings);

        // 定义表结构
        Schema.Builder schemaBuilder = Schema.newBuilder();
        schemaBuilder.column("id", DataTypes.BIGINT())
                .column("value", DataTypes.STRING());

        // 定义表
        TableDescriptor tableDescriptor = TableDescriptor.forConnector("kafka")
                .option(KafkaConnectorOptions.TOPIC.key(), "mysql.esteel_test.test")
                .option(KafkaConnectorOptions.PROPS_BOOTSTRAP_SERVERS, "10.0.170.197:9092")
                .option(KafkaConnectorOptions.PROPS_GROUP_ID, "my-test-group")
                .option(KafkaConnectorOptions.SCAN_STARTUP_MODE.key(), "earliest-offset")
                .option("properties.auto.offset.reset", "earliest")
                .format("debezium-json")
                .schema(schemaBuilder.build())
                .build();
        
        // 创建临时表
        env.createTemporaryTable("esteel_test", tableDescriptor);
        
        // 执行SQL查询
        Table table = env.sqlQuery("select sum(id)  from esteel_test");
        // 执行任务并打印
        TableResult result = table.execute(); 
        result.print();
    }
}
```

定义表结构和表的代码，完成的工作其实和上一节通过 SQL 创建表的工作是一样的，用 SQL 表达的意思就是：

```sql
CREATE TABLE esteel_test (
    id    bigint primary key,
    `value` STRING
) WITH (
 'connector' = 'kafka',
 'topic' = 'mysql.esteel_test.test',
 'properties.bootstrap.servers' = '10.0.170.197:9092',
 'properties.group.id' = 'my-test-group',
 'scan.startup.mode' = 'earliest-offset',
 'properties.auto.offset.reset' = 'earliest',
 'format' = 'debezium-json'
)
```

### 通过 Table API 流式计算自定义格式数据

上一节介绍了如何处理 Debezium 格式的数据，这一节介绍如何使用自定义格式的数据。

```java
/**
 * @author Kehaw
 * @since 2022/11/1
 */
public class RabbitStreamingTableJob {

    public static void main(String[] args) {
        // 环境
        final StreamExecutionEnvironment streamEnv = StreamExecutionEnvironment.getExecutionEnvironment();
        // Stream Table，基于流的 Table 环境
        StreamTableEnvironment tableEnv = StreamTableEnvironment.create(streamEnv);

        DataStream<SensorReading> sensorData = streamEnv.addSource(buildSource())
                .assignTimestampsAndWatermarks(WatermarkStrategy.noWatermarks())
                .setParallelism(1);

        // 建表
        Table inputTable = tableEnv.fromDataStream(sensorData);
        tableEnv.createTemporaryView("InputTable", inputTable);
        // 查询
        Table resultTable = tableEnv.sqlQuery("SELECT metricId, avg(metricValue) FROM InputTable group by metricId");
        TableResult result = resultTable.execute();
        result.print();
    }

    /**
     * 构建数据源
     *
     * @return 数据源
     */
    private static RMQSource<SensorReading> buildSource() {
        final RMQConnectionConfig connectionConfig = new RMQConnectionConfig
                .Builder()
                .setHost("mss-mq.dev.mysteelsoft.tech")
                .setPort(5672)
                .setVirtualHost("iothub")
                .setUserName("iothub")
                .setPassword("xxxxx")
                .build();

        // 定义数据源
        return new RMQSource<>(
                connectionConfig,
                "iothub-flink-receive-q",
                true,
                new SensorDeserializationSchema());
    }
}
```

简单来说，就是通过 `SensorDeserializationSchema` 将数据反序列化后再对数据进行计算，反序列化的结果是 `SensorReading` 类，结构如下所示：

```java
/**
 * @author Kehaw
 * @since 2022/10/14
 */
@Data
public class SensorReading {

    @JsonProperty("$id")
    private String id;

    @JsonProperty("$createdAt")
    private long createdAt;

    private long metricId;

    private BigDecimal metricValue;

    private long metricTime;

    @JsonProperty("$type")
    private String type;
}
```

与上一节不同的地方在于，我们不需要显式的调用 `createTable` 函数去创建一个表，只需要通过 `tableEnv.fromDataStream(sensorData);` 就可以自动的创建一个数据结构为 `SensorReading` 的表。

然后我们在这个基础之上，我们通过以下 SQL 来计算传感器传递过来的指标数据，对其求平均：

```java
tableEnv.sqlQuery("SELECT metricId, avg(metricValue) FROM InputTable group by metricId");
```

得到的结果如下所示：

| O   | Matrices ID | AVG Value                |
|-----|-------------|--------------------------|
| +U  | 1000000696  | 6182.100384000000000000  |
| -U  | 1000000563  | 56044.313440000000000000 |
| +U  | 1000000563  | 56166.148904000000000000 |
| -U  | 1000000744  | -33.500098280000000000   |
| +U  | 1000000744  | -33.579670960000000000   |
| -U  | 1000000563  | 56166.148904000000000000 |
| +U  | 1000000563  | 56287.984368000000000000 |
| -U  | 1000000744  | -33.579670960000000000   |
| +U  | 1000000744  | -33.659243640000000000   |

第一列表示UPDATE_BEFORE(-U)和UPDATE_AFTER(+U)，其他的还有 I 表示插入， D 表示删除，该计算会持续不间断的继续下去。

当然，我们也可以同时加入多个 Source，新建多张表进行 Join 查询，这个可以在后面的扩展中自行试验。

### 附篇：基于 Java 函数的 SQL 计算

上一节我们使用 SQL 语句对流式数据进行计算，这一节我们将使用 Java 的函数实现同样的功能。

我们查看源代码：

```java
public static void main(String[] args) throws Exception {
    // 环境
    final StreamExecutionEnvironment streamEnv = StreamExecutionEnvironment.getExecutionEnvironment();
    // Stream Table，基于流的 Table 环境
    StreamTableEnvironment tableEnv = StreamTableEnvironment.create(streamEnv);

    DataStream<SensorReading> sensorData = streamEnv.addSource(buildSource())
            .assignTimestampsAndWatermarks(WatermarkStrategy.noWatermarks())
            .setParallelism(1);

    // 建表
    Table inputTable = tableEnv.fromDataStream(sensorData);
    Table resultTable = inputTable.groupBy($("metricId"))
            .select($("metricId").as("mid"), $("metricValue").avg().as("avgValue"));

    DataStream<Row> resultStream = tableEnv.toChangelogStream(resultTable);
    resultStream.print();
    streamEnv.execute();

}
```

在原来使用 SQL 语句的地方，我们换成了 Java 函数，所表达的意思是一样的，但是需要注意的是，SQL 的 Group By 是放在最后，而通过 Java 函数执行的时候，需要先 Group By，再进行 select 查询。

## Flink Source & Sink 全流程示例

在数据计算完毕之后，我们需要通过 Sink 的方式将数据沉淀到另外一个地方，我们既可以将计算结果 Sink 到另一个 Flink Job，也可以将计算结果 Sink 到 Kafka、Rabbit MQ 以及 RDBMS 中。

在本节，我们将会把整个 Flink 流式计算的代码中的细节进行拆分说明。

### 环境的定义

首先，我们需要创建一个 Flink 执行的环境，由于我们是实时计算，因此我们需要创建一个实时流环境，如下：

```java
final StreamExecutionEnvironment streamEnv = StreamExecutionEnvironment.getExecutionEnvironment();
```

接下来，我们希望将实时流的数据转换成 Table，那么我们就需要创建一个基于实时流的 Table 环境，如下：

```java
final StreamTableEnvironment tableEnv = StreamTableEnvironment.create(streamEnv);
```

### 数据源的定义

接下来，我们先给实时流环境 `StreamExecutionEnvironment` 添加一个实时流的来源，我们这里选择 Rabbit MQ：

```java
DataStream<SensorReading> sensorData = streamEnv.addSource(buildSource())
                .assignTimestampsAndWatermarks(WatermarkStrategy.noWatermarks())
                .setParallelism(1);
```

在 `buildSource` 函数中，我们定义了 Rabbit MQ Source 如下：

```java
private static RMQSource<SensorReading> buildSource() {
    final RMQConnectionConfig connectionConfig = new RMQConnectionConfig
            .Builder()
            .setHost("mss-mq.dev.mysteelsoft.tech")
            .setPort(5672)
            .setVirtualHost("iothub")
            .setUserName("iothub")
            .setPassword("bar")
            .build();

    // 定义数据源
    return new RMQSource<>(
            connectionConfig,
            "iothub-flink-receive-q",
            true,
            new SensorDeserializationSchema());
}
```

这里需要关注的一点是 `new SensorDeserializationSchema()` 这个自定义的数据反序列化类，该类的作用是将 Rabbit MQ 中的数据反序列化成 Java 对象，其内容如下：

```java
/**
 * @author Kehaw
 * @since 2022/10/14
 */
public class SensorDeserializationSchema extends AbstractDeserializationSchema<SensorReading> {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public SensorReading deserialize(byte[] message) throws IOException {
        if (Objects.nonNull(message)) {
            return MAPPER.readValue(message, SensorReading.class);
        } else {
            return null;
        }
    }
}
```

我们通过 `addSource` 函数将 Rabbit MQ Source 添加到实时流里，并标记这个实时流没有水位线设置，并行度为1，那么它返回了一个 `DataStream` 数据流对象。

### 创建表 & 执行 SQL

然后，我们根据这个数据流，创建了一个表：

```java
Table inputTable = tableEnv.fromDataStream(sensorData);
```

接下来，我们在这个表的基础上，执行了一段 SQL 对数据进行计算并输出到另外一个结果表中：


```java
Table resultTable = tableEnv.sqlQuery("SELECT metricId as mid, avg(metricValue) as avgValue, metricTime as ts FROM InputTable group by metricId, metricTime");
```

我们也可以通过 Java 函数的方式来执行这一段 SQL，但是需要注意的是，Java 函数的方式需要将 Group By 放到最前面，如下所示：

```java
Table resultTable = inputTable.groupBy($("metricId"), $("metricTime"))
            .select($("metricId").as(TABLE_COL_MID),
                    $("metricValue").avg().as(TABLE_COL_AVG_VAL),
                    $("metricTime").as(TABLE_COL_TIME));
```

### 定义输出流 & Sink

然后，我们基于这个结果表，定义一个输出流：

```java
Schema schema = Schema.newBuilder()
                .column(TABLE_COL_MID, DataTypes.BIGINT())
                .column(TABLE_COL_AVG_VAL, DataTypes.DECIMAL(10, 2))
                .column(TABLE_COL_TIME, DataTypes.BIGINT())
                .build();
DataStream<Row> resultStream = tableEnv.toChangelogStream(resultTable, schema);
```

接下来，我们为这个输出流添加一个 Sink ，希望将计算结果数据输出到这个 Sink 中，并为它起了一个名字以及设置了它的并行度为1：

```java
resultStream.addSink(buildSink()).name("Sink data result to MySQL").setParallelism(1);
```

构建 Sink 的代码如下：

```java
/**
 * 构建 Sink
 * @return Sink
 */
private static SinkFunction<Row> buildSink() {
    JdbcStatementBuilder<Row> jdbcStatementBuilder = (preparedStatement, row) -> {
        Object o1 = row.getField(TABLE_COL_MID);
        long mid = 0L;
        if (Objects.nonNull(o1)) {
            mid = Long.parseLong(o1.toString());
        }

        Object o2 = row.getField(TABLE_COL_AVG_VAL);
        BigDecimal value = new BigDecimal(0);
        if (Objects.nonNull(o2)) {
            value = new BigDecimal(o2.toString());
        }

        Object o3 = row.getField(TABLE_COL_TIME);
        long ts = 0L;
        if (Objects.nonNull(o3)) {
            ts = Long.parseLong(o3.toString());
        }
        preparedStatement.setLong(1, mid);
        preparedStatement.setBigDecimal(2, value);
        preparedStatement.setLong(3, ts);
    };

    JdbcConnectionOptions connectionOptions = new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
            .withDriverName("com.mysql.cj.jdbc.Driver")
            .withUrl("jdbc:mysql://10.0.170.23:3306/esteel_test?autoReconnect=true&serverTimezone=GMT%2B8")
            .withUsername("foo")
            .withPassword("bar")
            .build();

    JdbcExecutionOptions jdbcExecutionOptions = JdbcExecutionOptions.builder()
            .withBatchIntervalMs(200)             // optional: 默认为0，基于时间定时向 MySQL 中写入数据
            .withBatchSize(1000)                  // optional: 默认为5000，基于数据条数向 MySQL 中写入数据
            .withMaxRetries(5)                    // optional: 默认为3，出错后尝试次数
            .build();
    return JdbcSink.sink("insert into test_result(mid, value, ts) values(?,?,?)",
            jdbcStatementBuilder,
            jdbcExecutionOptions,
            connectionOptions
    );
}
```

这里需要注意的是，构建 `JdbcExecutionOptions` 的时候， BatchSize 默认是 5000，即积累到 5000 条数据的时候才会发起插入请求，所以运行示例的时候如果你的数据量不够多，需要手动在这里将这个值设置的小一些。

### 执行程序

最后，我们调用 `execute()` 函数执行程序：

```java
streamEnv.execute();
```

这样，我们的结果表中就会写入数据。

## Flink Job 的部署

### Flink 应用程序的依赖管理

在本地环境调试完毕之后，接下来的工作就是将编写的程序部署到 Flink 集群上执行作业。

首先查看 Flink 的 lib 文件夹，里面有一些 Flink 自带的 Jar 包，例如 1.16.0 版本自带的 Jar 包如下：

- flink-cep-1.16.0.jar
- flink-connector-files-1.16.0.jar
- flink-csv-1.16.0.jar
- flink-dist-1.16.0.jar
- flink-json-1.16.0.jar
- flink-scala_2.12-1.16.0.jar
- flink-shaded-zookeeper-3.5.9.jar
- flink-table-api-java-uber-1.16.0.jar
- flink-table-planner-loader-1.16.0.jar
- flink-table-runtime-1.16.0.jar
- log4j-1.2-api-2.17.1.jar
- log4j-api-2.17.1.jar
- log4j-core-2.17.1.jar
- log4j-slf4j-impl-2.17.1.jar

如果你的程序中使用到了 Flink 自带的 Jar 包，那么可以将依赖设置为 provided，这样可以减少编译后的体积，通常情况下，我们会根据自己的项目情况，将一些 Jar 包预置到 Kafka 的 lib 目录下，这样就可以大大减少应用程序 Jar 包的体积。

如果你使用的是 IDEA，那么需要在 POM 文件中额外的加入一个配置，将所有标记为 provided 的依赖重新配置成 compile，用来解决找不到类的问题（这可能是 IDEA 的 BUG）

```xml
<profiles>
    <profile>
        <id>add-dependencies-for-IDEA</id>
        <activation>
            <property>
                <name>idea.version</name>
            </property>
        </activation>

        <dependencies>
            <dependency>
                <groupId>org.apache.flink</groupId>
                <artifactId>flink-java</artifactId>
                <version>${flink.version}</version>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>org.apache.flink</groupId>
                <artifactId>flink-clients</artifactId>
                <version>${flink.version}</version>
                <scope>compile</scope>
            </dependency>
            <dependency>
                <groupId>org.apache.flink</groupId>
                <artifactId>flink-json</artifactId>
                <version>${flink.version}</version>
                <scope>compile</scope>
            </dependency>
            ...
        </dependencies>
    </profile>
</profiles>
```

### Flink 入口函数的指定

在 POM 文件中，找到以下配置，将其修改为你想要执行的 main 方法所在的 class 类即可：

```xml
<transformers>
    <transformer
            implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
        <mainClass>com.esteel.streaming.kafka.e1.KafkaStreamingJob</mainClass>
    </transformer>
</transformers>
```

### Flink 发布 Job

打开 Flink 的 Web UI，在左侧菜单中的下方找到 Submit New Job，进入后点击右上角的 Add New 按钮，将你的 Jar 包上传到 Flink 集群，然后点击你刚刚上传的 Jar，选择启动即可。

## Flink SQL Gateway

我们可以通过 REST 客户端请求 Flink 来执行 SQL。

在通过 REST 请求 SQL 之前，我们需要先将 Flink 的 SQL Gateway 组件线程启动起来，命令如下：

```shell
./bin/sql-gateway.sh start -Dsql-gateway.endpoint.rest.address=0.0.0.0
```

启动成功之后，我们就可以通过 REST 接口进行 SQL 查询了。

Flink 的 SQL 执行在 REST 客户端上需要执行三步：

1. 获取 Session ID
2. 获取 SQL 的执行 ID
3. 获取 SQL 的执行结果

首先通过 POST 请求拿到一个 Session ID，即：

```http request
POST /v1/sessions HTTP/1.1
Host: connect.example.com
Accept: application/json
```
```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "sessionHandle": "3185cef4-b100-4109-a8d8-ce02eb35be96"
}
```

得到这个 Session ID 之后，使用该 Session ID 来执行 SQL 语句，并获取到一个 operation ID，如下：

```http request
POST /v1/sessions/{sessionId}/statements HTTP/1.1
Host: connect.example.com
Content-Type: application/json
Accept: application/json

{
    "statement": "SELECT 1"
}
```
```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "operationHandle": "bbd4a15c-ea77-45a6-9aa0-62061e53da19"
}
```

最后，通过 Session ID 和 Operation ID 获取这段 SQL 的执行结果，如下：

```http request
GET /v1/sessions/{sessionHandle}/operations/{operationHandle}/result/0 HTTP/1.1
Host: connect.example.com
Accept: application/json
```
```http request
HTTP/1.1 200 OK
Content-Type: application/json

{
    "results": {
        "columns": [
            {
                "name": "EXPR$0",
                "logicalType": {
                    "type": "INTEGER",
                    "nullable": false
                },
                "comment": null
            }
        ],
        "data": [
            {
                "kind": "INSERT",
                "fields": [
                    1
                ]
            }
        ]
    },
    "resultType": "PAYLOAD",
    "nextResultUri": "/v1/sessions/3185cef4-b100-4109-a8d8-ce02eb35be96/operations/bbd4a15c-ea77-45a6-9aa0-62061e53da19/result/1"
}
```

## 关于 Flink 的遗漏问题

后续，就需要基于上面所描述的基础，开展基于 Flink 的实际生产工作，可能会包括但不限于以下基本概念：

1. 流处理和批处理相关API的运用
2. 状态处理器
3. 算子和窗口
4. 检查点和保存点
5. 时态和水位线
6. Table API & SQL 的高级使用，例如 Join 等
7. Catalogs
8. Hive
9. 复杂事件处理 —— CEP
10. Flink 的管理类 REST API 的应用

## Doris 的安装

首先， Doris 当前版本经过实际测试下来的情况来看，JDK 版本不能超过1.9，最好使用 1.8 版本的 JDK。

Doris 的安装分两步，第一步安装 FE（Frontend），第二步安装 BE（Backend），总的来说这两步的安装都非常简单，没有特别需要注意的地方。

首先下载 FE 程序 `apache-doris-fe-1.1.3-bin` 打开 `conf/fe.conf` 配置文件，修改其中的配置：

```properties
# 注意，如果你的 IP 地址是 10.0.170.XXX，那么你此处的配置就是 10.0.170.0/24
priority_networks = 10.0.170.0/24
```

而 BE 的安装与 FE 差不多，同样需要修改 `conf/be.conf` 配置文件中的配置：

```properties
# 注意，这里与 FE 保持一致
priority_networks = 10.0.170.0/24
```

配置完毕之后，通过以下命令分别启动 FE 和 BE：

```shell
## FE 启动
./bin/start_fe.sh --daemon

## BE 启动
./bin/start_be.sh --daemon
```
启动成功后，既可以通过常用的 MySQL 客户端通过 root 账号（无密码）访问 Doris。

### 从 MySQL 导入数据

MySQL 的 DDL 语句并不能完整的运行在 Doris 之上，需要将大部分针对字段的描述定义移除掉，例如：`default ...`、`auto increment` 等等。

可以使用 Doris 的外部表来进行数据的导入，我们以 MySQL 为例。

在进行正式的操作前，我们需要先在 BE 端安装 ODBC 驱动，需要注意的是， Doris 对 MySQL 的 ODBC 是有要求的，当前 Doris 版本（1.1）只能使用 MySQL 8.0.28 以下（含8.0.28）版本的 ODBC，因为 8.0.28+ 版本的 ODBC 会因 SSL 证书问题报错。

```shell
wget https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.28-linux-glibc2.12-x86-64bit.tar.gz
```

然后，通过其自带的 installer 来进行 ODBC 的安装：

```shell
./myodbc-installer -a -d -n "MySQL ODBC 8.0.28 Unicode Driver" -t "Driver=/user/lib64/libmyodbc8w.so"
```

安装完毕之后记得检查以下 BE 的 ODBC 配置是否与我们的安装路径一致，打开 `conf/odbcinst.ini` 查看 Driver 配置是否正确：

```text
[PostgreSQL]
Description     = ODBC for PostgreSQL
Driver          = /usr/lib/psqlodbc.so
Setup           = /usr/lib/libodbcpsqlS.so
FileUsage       = 1


# Driver from the mysql-connector-odbc package
# Setup from the unixODBC package
[MySQL ODBC 8.0 Unicode Driver]
Description     = ODBC for MySQL
Driver          = /user/lib64/libmyodbc8w.so
FileUsage       = 1

# Driver from the oracle-connector-odbc package
# Setup from the unixODBC package
[Oracle 19 ODBC driver]
Description=Oracle ODBC driver for Oracle 19
Driver=/usr/lib/libsqora.so.19.1
```

建立外部表需要先在 Doris 内部建立一个 external source，在客户端中输入以下命令来创建一个 external source：

```sql
CREATE EXTERNAL RESOURCE `mysql_odbc_erp`
PROPERTIES (
    "type" = "odbc_catalog",
    "host" = "10.0.170.23",
    "port" = "3306",
    "user" = "foo",
    "password" = "bar",
    "database" = "zoo",
    "odbc_type" = "mysql",
    "driver" = "MySQL ODBC 8.0 Unicode Driver"
);
```

ODBC RESOURCE 建立完毕之后，可以基于该 RESOURCE 创建一个外部表，方法如下：

```sql
CREATE EXTERNAL TABLE `demo_ext` (
  `k1` decimal(9, 3) NOT NULL COMMENT "",
  `k2` char(10) NOT NULL COMMENT "",
  `k3` datetime NOT NULL COMMENT "",
  `k5` varchar(20) NOT NULL COMMENT "",
  `k6` double NOT NULL COMMENT ""
) ENGINE=ODBC
COMMENT "ODBC"
PROPERTIES (
    "odbc_catalog_resource" = "mysql_odbc_erp",
    "database" = "zoo",
    "table" = "xxxx"
);
```

这样，这个外部表就建立好了，我们可以通过 Doris 来查询该表的数据，我们也可以建立一张一模一样结构的表，通过以下语句将数据导入进来：

```sql
# 将外部表 demo_ext 的数据导入到内部表 demo
insert into demo select * from demo_ext; 
```

### Doris SQL 注意事项

通常来讲，我们在 Doris 上建表只定义最基本的数据结构，例如：

```sql
CREATE TABLE IF NOT EXISTS `payment_application_item`
(
    `row_id`      bigint(20),
    `app_no`      varchar(100),
    `fee_type`    varchar(20),
    `fee_code`    varchar(40),
    `app_amount`  decimal(16, 2),
    `paid_amount` decimal(16, 2),
    `origin`      varchar(20)
) DISTRIBUTED BY HASH(row_id) BUCKETS 2 PROPERTIES ("replication_num" = "1");
```

一般不加字段定义类的 DDL，例如 `primary key`、`auto increment`、`default ...` 等等，而`json`这种类型的字段，需要用 `text` 来替换。

并且，目前来看，有一部分子查询的使用方式 Doris 并不支持（[参考](https://github.com/apache/doris/discussions/10974)），例如：

```sql
select a.* ,(select sum(b.num) from b where a.id = b.rid) nums from a;
```

原始能够在 MySQL 上执行的 SQL 并不一定能够无缝的迁移到 Doris 上，需要针对 Doris 做一定的改造。 

### Doris 查询效率案例对比 

原始 SQL：

```sql
SELECT *
FROM (SELECT temp.org_id                                                                                                                                 AS orgId
           , temp.sale_contract_code                                                                                                                     AS contractCode
           , temp.org_name                                                                                                                               AS ownCompanyName
           , temp.customer_name                                                                                                                          AS customerName
           , temp.department_id                                                                                                                          AS department_id
           , temp.department_name                                                                                                                        AS departmentName
           , temp.staff_id                                                                                                                               AS staff_id
           , temp.staff_name                                                                                                                             AS staffName
           , scd.category_name                                                                                                                           AS categoryName
           , scd.product_spec                                                                                                                            AS productSpec
           , scd.product_material                                                                                                                        AS productMaterial
           , scd.factory_name                                                                                                                            AS factoryName
           , scd.quantity                                                                                                                                AS contractQuantity
           , bill.bill_quantity                                                                                                                          AS billQuantity
           , bill.out_quantity                                                                                                                           AS outStockQuantity
           , bill.settlement_quantity                                                                                                                    AS settlementQuantity
           , sia.settlement_quantity                                                                                                                     AS invoiceQuantity
           , IF(IF(distribute.completeRate >= 100, 2, scd.out_store_state) = 2, 0,
                distribute.underPaymentQuantity)                                                                                                         AS underPaymentQuantity
           , distribute.completeRate                                                                                                                     AS completeRate
           , scd.sale_price                                                                                                                              AS saleUnitPrice
           , scd.sale_amount                                                                                                                             AS saleAmount
           , bill.bill_amount                                                                                                                            AS billAmount
           , bill.out_amount                                                                                                                             AS outStockAmount
           , bill.settlement_amount                                                                                                                      AS settlementAmount
           , sia.settlement_amount                                                                                                                       AS invoiceAmount
           , IF(distribute.completeRate >= 100, 2, scd.out_store_state)                                                                                  AS outStoreState
           , temp.signed_at                                                                                                                              AS signAt
           , temp.sale_contract_type                                                                                                                     AS saleContractType
           , temp.delivery_ended_at                                                                                                                      AS deliveryEndedAt
           , DATE_FORMAT(temp.created_at, '%Y-%m-%d')                                                                                                    AS createdAt
           , temp.operator_id                                                                                                                            AS operator_id
           , temp.operator_name                                                                                                                          AS creatorName
           , temp.settlement_status                                                                                                                      AS settlementStatus
           , scd.distributed_quantity                                                                                                                    AS distributeQuantity
           , IF(IF(distribute.completeRate >= 100, 2, scd.out_store_state) = 2, 0, IF(distribute.completeRate >= 99, 0,
                                                                                      DATEDIFF(DATE_FORMAT(NOW(), '%Y-%m-%d'), temp.delivery_ended_at))) AS overdueDays
           , ROUND(scd.distributed_amount / scd.distributed_quantity, 2)                                                                                 AS distributeAvgPrice
           , scd.distributed_amount                                                                                                                      AS distributeAmount
           , distribute.saleUnderPaymentQuantity                                                                                                         AS saleUnderPaymentQuantity
      FROM esteel_erp_contract.sale_contract_detail scd
               INNER JOIN esteel_erp_contract.sale_contract_info temp
                          ON scd.sale_contract_code = temp.sale_contract_code
               LEFT JOIN (SELECT b.sale_detail_id
                               , IF(b.distribution_status = 3, sum(a.distribution_quantity) - sum(a.pick_up_quantity),
                                    IF(b.quantity > IFNULL(sum(a.distribution_quantity), 0), b.quantity,
                                       IFNULL(sum(a.distribution_quantity), 0)) -
                                    IFNULL(sum(a.pick_up_quantity), 0))                                                                   AS underPaymentQuantity
                               , ROUND(
                      CONVERT(IF(b.distribution_status = 3, sum(a.pick_up_quantity) / sum(a.distribution_quantity),
                                 IFNULL(sum(a.pick_up_quantity), 0) /
                                 IF(b.quantity > IFNULL(sum(a.distribution_quantity), 0), b.quantity,
                                    IFNULL(sum(a.distribution_quantity), 0))), DECIMAL(15, 4)) * 100,
                      2)                                                                                                                  AS completeRate
                               , IF(b.distribution_status = 3, 0,
                                    IF(IFNULL(sum(a.distribution_quantity), 0) > b.quantity, 0, b.quantity -
                                                                                                IFNULL(sum(a.distribution_quantity), 0))) AS saleUnderPaymentQuantity
                          FROM esteel_erp_contract.sale_contract_detail b
                                   LEFT JOIN esteel_erp_contract.`distribution` a
                                             ON a.sale_detail_id = b.sale_detail_id
                                                 AND a.STATUS = 1
                                                 AND a.org_id = 10008
                          GROUP BY b.sale_detail_id,b.distribution_status,b.quantity) distribute
                         ON scd.sale_detail_id = distribute.sale_detail_id
               LEFT JOIN (SELECT bd.sale_detail_id        AS sale_detail_id
                               , sum(bd.bill_quantity)    AS bill_quantity
                               , sum(bd.bill_amount)      AS bill_amount
                               , sum(bd.out_quantity)     AS out_quantity
                               , sum(bd.out_amount)       AS out_amount
                               , sum(bd.settled_quantity) AS settlement_quantity
                               , sum(bd.settled_amount)   AS settlement_amount
                          FROM esteel_erp_contract.bill_detail bd
                                   INNER JOIN esteel_erp_contract.bill b ON bd.bill_code = b.bill_code
                          WHERE b.org_id = 10008
                            AND b.bill_status IN (1, 2, 3, 4, 6)
                          GROUP BY bd.sale_detail_id) bill
                         ON scd.sale_detail_id = bill.sale_detail_id
               LEFT JOIN (SELECT bd.sale_detail_id            AS sale_detail_id,
                                 sum(ssd.settlement_quantity) AS settlement_quantity,
                                 sum(ssd.settlement_amount)   AS settlement_amount
                          FROM esteel_erp_contract.bill_detail bd
                                   LEFT JOIN esteel_erp_contract.sale_settlement_detail ssd
                                             ON ssd.bill_detail_code = bd.bill_detail_code
                                   INNER JOIN esteel_erp_contract.sale_invoice_apply_detail siad
                                              ON siad.settlement_detail_code = ssd.settlement_detail_code
                                   INNER JOIN esteel_erp_contract.sale_invoice_apply sia
                                              ON sia.invoice_apply_code = siad.invoice_apply_code
                          WHERE sia.invoice_apply_status = 3
                            AND sia.org_id = 10008
                          GROUP BY bd.sale_detail_id) sia
                         ON scd.sale_detail_id = sia.sale_detail_id
      WHERE temp.org_id = 10008
        AND temp.contract_status = 3) temp
WHERE temp.createdAt >= '2022-01-01'
  AND temp.createdAt <= '2022-11-07'
  AND temp.outStoreState = '1'
  AND (temp.department_id IN
       (10011, 10013, 10014, 10016, 10017, 10009, 10010, 10011, 10013, 10014, 10016, 10017, 10009, 10010)
    OR temp.operator_id = 10149)
ORDER BY temp.createdAt DESC
```

| 数据库   | 执行效率    |
|-------|---------|
| MySQL | 14.49 秒 |
| Doris | 450 毫秒  |

## 参考资料

[Kafka 官方文档](https://kafka.apache.org/documentation)

[Flink 官方文档](https://nightlies.apache.org/flink/flink-docs-master/zh/docs/dev/configuration/overview/)

[Debezium 官方文档](https://debezium.io/documentation/reference/2.0/)

[Doris 官方文档](https://doris.apache.org/zh-CN/docs/sql-manual/sql-functions/string-functions/concat)

（全文完）

