### 当前 Makefile 文件物理路径
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

name 	:=redis.c1

server_info:
	docker exec -it $(name) /bin/sh -c 'redis-cli -c -h $(name) -p 6379 info server'
	
replication_info:
	docker exec -it $(name) /bin/sh -c 'redis-cli -c -h $(name) -p 6379 info replication'

create_cluster:
	redis-cli --cluster create \
	172.16.197.21:6379 172.16.197.16:6379 \
    172.16.197.17:6379 172.16.197.18:6379 \
    172.16.197.19:6379 172.16.197.20:6379 \
    --cluster-replicas 1

cluster_nodes:
	docker exec -it $(name) /bin/sh -c 'redis-cli -c -h $(name) -p 6379 cluster nodes'

### make cmd cmd='get a' name=redis.c4
cmd:
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 6379 $(cmd)'

replicaof:
	docker exec -it $(name) /bin/sh -c 'redis-cli -c -h $(name) -p 6379 replicaof redis.c2 6379'

### sentinel
sentinel:
	# redis-sentinel /etc/sentinel.conf
	cp /etc/sentinel.0.conf /etc/sentinel.conf && redis-server /etc/sentinel.conf --sentinel

sentinel_info:
	#redis-cli -p 26379 info
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 26379 info'

sentinel_master_name:
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster'

sentinel_master_info:
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 26379 sentinel master mymaster'

sentinel_sentinels:
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 26379 sentinel sentinels mymaster'

sentinel_replicas:
	docker exec -it $(name) /bin/sh -c 'redis-cli -p 26379 sentinel replicas mymaster'

stop_master:
	docker container stop redis.c1


