### 查看集群状态
echo srvr | nc zk1 2181

### 下表中是所有的 zookeeper 的命令，都是由 4 个字符组成。
echo srvr | nc zk1 2181
---------------------------------------------------------------------------------------------------.
Category			Command			Description
---------------------------------------------------------------------------------------------------.
Server status		|ruok			|Prints imok if the server is running and not in an error state.
					|conf			|Prints the server configuration (from zoo.cfg).
					|envi			|Prints the server environment, 
					|				|including ZooKeeper version, Java version, 
					|				|and other system properties.
					|srvr			|Prints server statistics, including latency statistics, 
					|				|the number of znodes, 
					|				|and the server mode (standalone, leader, or follower).
					|stat			|Prints server statistics and connected clients.
					|srst			|Resets server statistics.
					|isro			|Shows whether the server is in read-only (ro) mode 
					|				|(due to a network partition) or read/write mode (rw).
---------------------------------------------------------------------------------------------------.
Client connections	|dump			|Lists all the sessions and ephemeral znodes for the ensemble. 
					|				|You must connect to the leader (see srvr) for this command.
					|cons			|Lists connection statistics for all the server’s clients.
					|crst			|Resets connection statistics.
---------------------------------------------------------------------------------------------------.
Watches				|wchs			|Lists summary information for the server’s watches.
					|wchc			|Lists all the server’s watches by connection. 
					|				|Caution: may impact server performance for a large number 
					|				|of watches.
					|wchp			|Lists all the server’s watches by znode path. 
					|				|Caution: may impact server performance 
					|				|for a large number of watches.
---------------------------------------------------------------------------------------------------.
Monitoring			|mntr			|Lists server statistics in Java properties format, 
					|				|suitable as a source for monitoring systems 
					|				|such as Ganglia and Nagios.


### zookeeper 下载地址
http://mirror.bit.edu.cn/apache/zookeeper/stable/

一、zookeeper有三个端口（可以修改）
	1、2181
	2、3888
	3、2888

二、3个端口的作用
	1、2181：对 client 端提供服务
	2、3888：选举 leader 使用
	3、2888：集群内机器通讯使用（Leader监听此端口）

三、部署时注意
	1、单机单实例，只要端口不被占用即可
	2、单机伪集群（单机，部署多个实例），三个端口必须修改为组组不一样, 如：
		myid1 : 2181,3888,2888
		myid2 : 2182,3788,2788
		myid3 : 2183,3688,2688
	3、集群（一台机器部署一个实例）

四、集群为大于等于3个基数
	如 3、5、7....,不宜太多，集群机器多了选举和数据同步耗时时长长，不稳定。
	目前觉得，三台选举+N台observe很不错。


$ZOOKEEPER_HOME/bin/zkServer.sh start //启动
$ZOOKEEPER_HOME/bin/zkServer.sh start-foreground // 前台启动
$ZOOKEEPER_HOME/bin/zkServer.sh status //检查状态
$ZOOKEEPER_HOME/bin/zkServer.sh stop //停止

### 安装 netcat-traditional 用以支持 nc 命令
$ apt-get -y install netcat-traditional 

### zookeeper 命令
通过nc或者telnet命令访问2181端口，通过执行ruok（Are you OK?）命令来检查zookeeper是否启动成功：
$ echo srvr | nc zk1 2181
>>> Zookeeper version: 3.5.5-390fe37ea45dee01bf87dc1c042b5e3dcce88653, built on 05/03/2019 12:07 GMT
>>> Latency min/avg/max: 1/11/21
>>> Received: 6
>>> Sent: 5
>>> Connections: 1
>>> Outstanding: 0
>>> Zxid: 0x100000002
>>> Mode: follower
>>> Node count: 5

### zookeeper cluster
/usr/local/zookeeper/conf/zoo.cfg

tickTime = 2000 						# tickTime则是上述两个超时配置的基本单位，
						  				  例如对于initLimit，其配置值为5，
						  				  说明其超时时间为 2000ms * 5 = 10秒。
dataDir =  /opt/zookeeper-3.4.9/data 	# 其配置的含义跟单机模式下的含义类似，
							 			  不同的是集群模式下还有一个myid文件。
										  myid文件的内容只有一行，且内容只能为1 - 255之间的数字，
										  这个数字亦即上面介绍server.id中的id，表示zk进程的id。
dataLogDir = /opt/zookeeper-3.4.9/logs	# 如果没提供的话使用的则是dataDir。
										  zookeeper的持久化都存储在这两个目录里。
										  dataLogDir里是放到的顺序日志(WAL)。
										  而dataDir里放的是内存数据结构的snapshot，便于快速恢复。
										  为了达到性能最大化，一般建议把dataDir和dataLogDir分到不同的磁盘上，
										  这样就可以充分利用磁盘顺序写的特性。
clientPort = 2181
initLimit = 5 							# ZooKeeper集群模式下包含多个zk进程，
										  其中一个进程为leader，余下的进程为follower。
										  当follower最初与leader建立连接时，它们之间会传输相当多的数据，尤其是follower的数据落后leader很多。initLimit配置follower与leader之间建立连接后进行同步的最长时间。
syncLimit = 2							# 配置follower和leader之间发送消息，请求和应答的最大时间长度。

server.1=node1:2888:3888 				
server.2=node2:2888:3888
server.3=node3:2888:3888

server.id=host:port1:port2 				# server.id 其中id为一个数字，表示zk进程的id，
													这个id也是data目录下myid文件的内容
										  host 是该zk进程所在的IP地址
										  port1 表示 follower 和 leader 交换消息所使用的端口
										  port2 表示选举 leader 所使用的端口

### 启动集群
node1
/usr/local/zookeeper/bin/zkServer.sh start-foreground
node2
/usr/local/zookeeper/bin/zkServer.sh start-foreground
node3
/usr/local/zookeeper/bin/zkServer.sh start-foreground

### 连接集群
$ZOOKEEPER_HOME/bin/zkCli.sh -server zk1:2181,zk2:2181,zk3:2181
>>> 从日志可以看出客户端成功连接的是哪个节点 连接上哪台机器的zk进程是随机的

### 常用操作
> ls /					-- 查看所有节点 
> deleteall /nodepath 	-- 强制删除节点

### 集群状态
node1
/usr/local/zookeeper/bin/zkServer.sh status
node2
/usr/local/zookeeper/bin/zkServer.sh status
node3
/usr/local/zookeeper/bin/zkServer.sh status

>>> ZooKeeper JMX enabled by default											
>>> Using config: /opt/zookeeper-3.4.9/bin/../conf/zoo.cfg											
>>> Mode: follower											
>>> ZooKeeper JMX enabled by default											
>>> Using config: /opt/zookeeper-3.4.9/bin/../conf/zoo.cfg											
>>> Mode: leader											
>>> ZooKeeper JMX enabled by default											
>>> Using config: /opt/zookeeper-3.4.9/bin/../conf/zoo.cfg											
>>> Mode: follower											




