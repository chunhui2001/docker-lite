### Redis Cluster
Redis3.0 版本之前，可以通过 Redis Sentinel（哨兵）来实现高可用 ( HA )，从3.0版本之后，官方推出了 Redis Cluster，它的主要用途是实现数据分片 (Data Sharding)，不过同样可以实现HA，是官方当前推荐的方案。

### Redis Sentinel
在 Redis Sentinel 模式中，每个节点需要保存全量数据，冗余比较多，而在 Redis Cluster 模式中，每个分片只需要保存一部分的数据，对于内存数据库来说，还是要尽量的减少冗余。在数据量太大的情况下，故障恢复需要较长时间，另外，内存实在是太贵了。。。

### Redis Cluster Hash
Redis Cluster 的具体实现细节是采用了 Hash 槽的概念，集群会预先分配 16384 个槽，并将这些槽分配给具体的服务节点，通过对 Key 进行 CRC16(key)%16384 re运算得到对应的槽是哪一个，从而将读写操作转发到该槽所对应的服务节点。当有新的节点加入或者移除的时候，再来迁移这些槽以及其对应的数据。在这种设计之下，我们就可以很方便的进行动态扩容或缩容，个人也比较倾向于这种集群模式。

### 滚动日志
redis 的日志文件不会自动滚动，redis-server 每次在写日志时，均会以追加方式调用 fopen 写日志，而不处理滚动。也可借助 linux 自带的 logrotate 来滚动 redis 日志，命令 logrotate 一般位于目录 /usr/sbin 下。

### 启动redis
$ /usr/local/redis/src/redis-server /usr/local/redis/redis.conf

### 目标集群
172.16.12.1:6379    master
172.16.12.2:6379    master
172.16.12.3:6379    master
172.16.12.4:6379    slave
172.16.12.5:6379    slave
172.16.12.6:6379    slave

### 确认版本
$ ./redis-cli -p 6379 info server

### 搭建集群 (5.0.5)
Redis Cluster 集群至少需要三个 master 节点, 本文将以单机多实例的方式部署 3 个主节点及 3 个从节点, 6 个节点实例分别使用不同的端口及工作目录

### 修改配置文件
redis 安装目录 /usr/local/redis-5.0.5 下的 redis.conf 文件，并修改以下配置：
daemonize yes 						# 开启后台运行
port 8001 							# 工作端口
bind 172.16.0.15 					# 绑定机器的内网 IP,一定要设置呀老铁，不要用 127.0.0.1
dir /usr/local/redis-cluster/8001/ 	# 指定工作目录，rdb,aof 持久化文件将会放在该目录下，不同实例一定要配置不同的工作目录
cluster-enabled yes 				# 启用集群模式
cluster-config-file nodes-8001.conf # 生成的集群配置文件名称，集群搭建成功后会自动生成，在工作目录下
cluster-node-timeout 5000 			# 节点宕机发现时间，可以理解为主节点宕机后从节点升级为主节点时间
appendonly yes 						# 开启AOF模式
pidfile /var/run/redis_6379.pid 	# pid file所在目录

### redis-trib
由于创建集群需要用到 redis-trib 这个命令，它依赖 Ruby 和 RubyGems，因此我们要先安装一下
-- redis 5.0版本 集群搭建不需要我们安装 ruby 就可以搭建成功
[root@VM_0_15_centos redis-cluster]# yum install ruby
[root@VM_0_15_centos redis-cluster]# yum install rubygems
[root@VM_0_15_centos redis-cluster]# gem install redis --version 3.3.3

### 开始创建集群, --cluster-replicas 1     # 表示为集群中的每一个主节点指定一个从节点，即一比一的复制。
$ redis-cli --cluster create --replicas 1   172.16.0.15:8001 \
                                            172.16.0.15:8002 172.16.0.15:8003 172.16.0.15:8004 172.16.0.15:8005 172.16.0.15:8006
OR
$ redis-cli --cluster create 172.16.197.21:6379 172.16.197.16:6379 \
                                            172.16.197.17:6379 172.16.197.18:6379 172.16.197.19:6379 172.16.197.20:6379 --cluster-replicas 1
### redis-cli 链接时使用 -c 选项
$ redis-cli -c
$ redis-cli -c -h 0.tcp.ngrok.io -p 17331

### 查看集群状态
172.16.0.15:8001> cluster nodes
节点id    ip/端口
79cd93ae 172.16.0.15:8004@18004 slave 			119dec17 	0 1531008204920 4 connected
cc4dfee4 172.16.0.15:8005@18005 slave 			f7170d84 	0 1531008203000 5 connected
t1b85ec0 172.16.0.15:8006@18006 slave 			f5f60ebf 	0 1531008204419 6 connected
119dec17 172.16.0.15:8001@18001 myself,master 	- 			0 1531008204000 1 connected 0-5460
f7170d84 172.16.0.15:8002@18002 master 			- 			0 1531008203000 2 connected 5461-10922
f5f60ebf 172.16.0.15:8003@18003 master 			- 			0 1531008203419 3 connected 10923-16383
-- 控制台信息显示: 当前集群中存在3个主节点和3个从节点，说明我们的集群已经搭建成功
-- 至此，Redis Cluster 集群就搭建完成了！

### 查看集群信息
172.16.0.15:8001> cluster nodes
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:1630
cluster_stats_messages_pong_sent:1606
cluster_stats_messages_sent:3236
cluster_stats_messages_ping_received:1601
cluster_stats_messages_pong_received:1630
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:3236

### 删除节点
# redis-cli --cluster del-node 127.0.0.1:7000 `<node-id>`
-- 如果待删除的是 master 节点，则在删除之前需要将该 master 负责的 slots 先全部迁到其它 master。
-- 如果删除后，其它节点还看得到这个被删除的节点，则可通过FORGET命令解决，需要在所有还看得到的其它节点上执行：
   > CLUSTER FORGET `<node-id>`

### master 机器硬件故障
-- 这种情况下, master 机器可能无法启动，导致其上的 master 无法连接, master 将一直处于 “master,fail” 状态, 如果是 slave 则处于 “slave,fail” 状态。
-- 如果是 master，则会它的 slave 变成了 master，因此只需要添加一个新的从节点作为原 slave（已变成master）的 slave 节点。完成后，通过CLUSTER FORGET将故障的 master 或 slave 从集群中剔除即可。
-- 需要在所有 node 上执行一次 “CLUSTER FORGET”，否则可能遇到被剔除 node 的总是处于 handshake 状态。

### 检查节点状态
$ redis-cli --cluster check 192.168.0.251:6381
-- 如发现如下这样的错误：
   [WARNING] Node 192.168.0.251:6381 has slots in migrating state (5461).
   [WARNING] The following slots are open: 5461
-- 可以使用redis命令取消slots迁移（5461为slot的ID）：
   cluster setslot 5461 stable
-- 需要注意，须登录到192.168.0.251:6381上执行redis的setslot子命令。

### 变更主从关系
在目标 slave 上执行，命令格式：> cluster replicate <master-node-id>
假设将 “192.168.0.251:6381” 的master 改为 “3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e”:
$ redis-cli -h 192.168.0.251 -p 6381 cluster replicate 3c3a0c74aae0b56170ccb03a76b60cfe7dc1912e

### 从 slaves 读数据
默认不能从 slaves 读取数据，但建立连接后，执行一次命令 READONLY, 即可从 slaves 读取数据. 如果想再次恢复不能从 slaves 读取数据, 可以执行下命令 READWRITE。

### 添加一个新主(master)节点
$ redis-cli --cluster add-node 192.168.0.251:6390 192.168.0.251:6381

### 添加一个新从(slave)节点
$ redis-cli --cluster add-node 192.168.0.251:6390 192.168.0.251:6381 --cluster-slave

### slots 相关命令
CLUSTER ADDSLOTS slot1 [slot2] ... [slotN]
CLUSTER DELSLOTS slot1 [slot2] ... [slotN]
CLUSTER SETSLOT slot NODE node
CLUSTER SETSLOT slot MIGRATING node
CLUSTER SETSLOT slot IMPORTING node

### 禁止指定命令
KEYS 命令很耗时，FLUSHDB 和 FLUSHALL 命令可能导致误删除数据，所以线上环境最好禁止使用，可以在 Redis 配置文件增加如下配置：
rename-command KEYS ""
rename-command FLUSHDB ""
rename-command FLUSHALL ""

### 数据迁移
可使用命令 “redis-cli --cluster import” 将数据从一个 redis 集群迁到另一个 redis 集群。

### 大压力下Redis参数调整要点
--------------------------------------------------------
参数                      建议最小值   说明
--------------------------------------------------------
repl-ping-slave-period   0          每10秒ping一次
repl-timeout             60         60秒超时，也就是ping十次
cluster-node-timeout     15000      --
repl-backlog-size        1GB        Master对slave的队列大小
appendfsync              no         让系统自动刷
save                     --         大压力下，调大参数值，以减少写RDB带来的压力： 
                                    "900 20 300 200 60 200000"
appendonly               --         对于队列，建议单独建立集群，并且设置该值为 no
--------------------------------------------------------

### 为何大压力下要这样调整？
--------------------------------------------------------
-- 最重要的原因之一Redis的主从复制，两者复制共享同一线程，虽然是异步复制的，但因为是单线程，所以也十分有限。如果主从间的网络延迟不是在0.05左右，比如达到0.6，甚至1.2等，那么情况是非常糟糕的，因此同一Redis集群一定要部署在同一机房内。
-- 这些参数的具体值，要视具体的压力而定，而且和消息的大小相关，比如一条200~500KB的流水数据可能比较大，主从复制的压力也会相应增大，而10字节左右的消息，则压力要小一些。大压力环境中开启appendfsync是十分不可取的，容易导致整个集群不可用，在不可用之前的典型表现是QPS毛刺明显。
-- 这么做的目的是让Redis集群尽可能的避免master正常时触发主从切换，特别是容纳的数据量很大时，和大压力结合在一起，集群会雪崩。


###  问题排查
https://www.cnblogs.com/aquester/p/10916284.html
1. aof 文件损坏
如果最后一条日志为“16367:M 08 Jun 14:48:15.560 # Server started, Redis version 3.2.0”节点状态始终终于fail状态，则可能是aof文件损坏了，这时可以使用工具edis-check-aof --fix进行修ç，如：
$ redis-check-aof --fix appendonly-6380.aof 
2. in `call': ERR Slot 16011 is already busy (Redis::CommandError)
如果使用主机名而不是IP，也可能遇到这个错误，如：“redis-cli create --replicas 1 redis1:6379 redis2:6379 redis3:6379 redis4:6379 redis5:6379 redis6:6379”，可能也会得到错误“ERR Slot 16011 is already busy (Redis::CommandError)”。
3. for lack of backlog (Slave request was: 51875158284)
默认值：
# redis-cli config get repl-timeout
A) "repl-timeout"
B) "10"
# redis-cli config get client-output-buffer-limit
A) "client-output-buffer-limit"
B) "normal 0 0 0 slave 268435456 67108864 60 pubsub 33554432 8388608 60"
增大：
redis-cli config set "client-output-buffer-limit" "normal 0 0 0 slave 2684354560 671088640 60 pubsub 33554432 8388608 60"
4. 复制中断场景
A) master的slave缓冲区达到限制的硬或软限制大小，与参数client-output-buffer-limit相关；
B) 复制时间超过repl-timeout指定的值，与参数repl-timeout相关。
slave 反复循环从 master 复制, 如果调整以上参数仍然解决不了, 可以尝试删除slave上的aof和rdb文件, 然后再重启进程复制, 这个时候可能能正常完成复制。
5. 日志文件出现：Asynchronous AOF fsync is taking too long (disk is busy?). Writing the AOF buffer without waiting for fsync to complete, this may slow down Redis.
考虑优化以下配置项：
no-appendfsync-on-rewrite 值设为 yes
repl-backlog-size 和 client-output-buffer-limit 调大一点
6. 日志文件出现：
MISCONF Redis is configured to save RDB snapshots, but is currently not able to persist on disk. Commands that may modify the data set are disabled. Please check Redis logs for details about the error.
考虑设置 stop-writes-on-bgsave-error 值为 “no”。
7. Failover auth granted to
当日志大量反反复复出现下列内容时，很可能表示 master 和 slave 间同步和通讯不顺畅，导致无效的failover和状态变更，这个时候需要调大相关参数值，容忍更长的延迟，因此也特别注意集群内所有节点间的网络延迟要尽可能的小，最好达到 0.02ms 左右的水平，调大参数的代价是主备切换变迟钝。
 

### Tips
1. 如果想重新创建集群，需要登录到每个节点，执行 flushdb，然后执行 cluster reset，重启节点；
2. 如果要批量杀掉 Redis 进程，可以使用 pkill redis-server 命令；
3. 如果 redis 开启了密码认证，则需要在 redis.conf 中增加属性 : masterauth yourpassword ，并且需要修改 /usr/local/share/gems/gems/redis-3.3.3/lib/redis目录下的client.rb文件，将 password 属性设置为 redis.conf 中的 requirepass 的值，不同的操作系统 client.rb 的位置可能不一样，可以使用 find / -name "client.rb"全盘查找一下；
4. Redis 开启密码认证后，在集群操作时问题会比较多，因此建议不要开启密码认证，搭配使用防火墙保证 Redis 的安全。
DEFAULTS = {
	:url => lambda { ENV["REDIS_URL"] },
	:scheme => "redis",
	:host => "127.0.0.1",
	:port => 6379,
	:path => nil,
	:timeout => 5.0,
	:password => "yourpassword",
	:db => 0,
	:driver => nil,
	:id => nil,
	:tcp_keepalive => 0,
	:reconnect_attempts => 1,
	:inherit_socket => false
}

### 向集群中添加几个key
$ curl http://127.0.0.1:8080/test/add/test_key_01 
> {"value":"Sun Jul 08 09:15:43 CST 2018","key":"test_key_01"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_02"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_03"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_04"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_05"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_06"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_07"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_08"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_09"}

$ curl http://127.0.0.1:8080/test/add/test_key_10
> {"value":"Sun Jul 08 09:17:02 CST 2018","key":"test_key_10"}

### 验证主从同步及数据分片
先连接3个主节点，查看当前节点key的情况: > keys *
接下来连接3个从节点，查看key的情况: > keys *
-- 可以看到，主从同步及数据分片都已经OK了。

### 删除一个可以试试，随便选一个test_key_02吧, 验证删除key后在其他主动节点是否同时删除
$ curl http://127.0.0.1:8080/test/del/test_key_02
> {"test_key_02是否存在?":false}

### 验证主从切换
我们先停掉8001这个主节点，从理论上讲，8004节点将会升级为主节点，等到8001节点再次启动之后，8001将会作为8004的slave节点，并从8004同步最新的数据，我们来一起验证一下：
此时，进入8004节点，查看其主从状态：
> info replication
>>>>>>> # Replication
>>>>>>> role:master
>>>>>>> connected_slaves:0
>>>>>>> master_replid:276339bcb6889ad591ee983974d10a023afdc6d4
>>>>>>> master_replid2:0000000000000000000000000000000000000000
>>>>>>> master_repl_offset:6153
>>>>>>> second_repl_offset:-1
>>>>>>> repl_backlog_active:0
>>>>>>> repl_backlog_size:1048576
>>>>>>> repl_backlog_first_byte_offset:1
>>>>>>> repl_backlog_histlen:6153
-- 可以发现，8004已经升级为master节点，并拥有0个slave节点。我们现在继续add一些key进来：

### 接下来再次启动8001并查看key值：
-- 当再次启动后，8001同步了8004的key，并由之前的master节点转为slave节点。
-- 以上可以看出，故障转移生效。


### 关注一个异常情况：
我们知道，test_key_20这个名称的key，会路由到8001->8004这个分片，8004为master，8001为slave，现在我们del掉这个key，并且kill掉8004，然后再次添加这个key，看看会发生什么情况。
预想结果可能会因为8004宕机，8001升级为主节点，test_key_20将会保存到8001节点。   

$ curl http://127.0.0.1:8080/test/del/test_key_20
{"test_key_20是否存在?":false}

$ kill -9 31619

$ curl http://127.0.0.1:8080/test/add/test_key_20
{"timestamp":1531017417511,"status":500,"error":"Internal Server Error","exception":"redis.clients.jedis.exceptions.JedisConnectionException","message":"Could not get a resource from the pool","path":"/test/add/test_key_20"}

$ curl http://127.0.0.1:8080/test/add/test_key_20
{"value":"Sun Jul 08 10:37:00 CST 2018","key":"test_key_20"}

-- 我们发现，当 kill 掉 8004 这个主节点之后，第一次 add 的时候，应用程序报错了，这个时候，对于 test_key_20 的 add 操作丢失了！！！
-- 当第二次add的时候才能成功。 这个问题是因为 JedisPool 中部分连接失效导致的，第一次应用程序拿到了一个失效的连接，导致操作失败，
-- 当第一次操作失败之后，jedisPool 会剔除无效连接，因此第二次才可以拿到有效连接去操作redis。
-- 当然，这种情况可以通过调节 jedisPool 的配置属性来尽量减少，但是有点耗性能，不推荐。


### 哨兵机制
1. 修改 sentinel.conf 配置文件 sentinel monitor mymaster  192.168.64.128 6379 1  #主节点 名称 IP 端口号 选举次数 
设置了密码的话则需配置(我的没配) sentinel auth-pass mymaster 123456 
2. 修改心跳检测 5000毫秒 sentinel down-after-milliseconds mymaster 5000 
3. sentinel parallel-syncs mymaster 2 --- 做多多少合格节点 
4. 如果10秒后,mysater仍没活过来，则启动 failover  sentinel failover-timeout mymaster   10000

另外做哨兵模式的时候从库的配置 redis.conf 也要修改, 允许别的机器连接 就是上面讲过的修改 bind 还有关闭保护模式. 

### step by step
# Redis Server
1. Disable protected mode in redis.conf
2. Disable bind address in redis.conf 

# Sentinel 
1. Run redis Sentinel
2. Create redis configuration file
   a. sentinel monitor mymaster <master_ip> 6379 2


3. redis-server sentinel.conf --sentinel &


