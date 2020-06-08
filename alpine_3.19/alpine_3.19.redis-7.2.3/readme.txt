## redis cluster
docker run --name redis-master -p 6379:6379 --network br0 -d redis redis-server --appendonly yes

docker run --name redis-replica1 -p 6380:6379 --network br0 -d redis redis-server --appendonly yes --slaveof redis-master 6379
docker run --name redis-replica2 -p 6381:6379 --network br0 -d redis redis-server --appendonly yes --slaveof redis-master 6379

## redis sentinel
echo "sentinel monitor mymaster 172.16.197.21 6379 2" > sentinel_1.conf
echo "sentinel monitor mymaster 172.16.197.21 6379 2" > sentinel_2.conf
echo "sentinel monitor mymaster 172.16.197.21 6379 2" > sentinel_3.conf

docker run --name redis-sentinel1 -p 26379:26379 --network br0 -d -v ./sentinel_1.conf:/etc/sentinel.conf redis redis-sentinel /etc/sentinel.conf
docker run --name redis-sentinel1 -p 26380:26379 --network br0 -d -v ./sentinel_1.conf:/etc/sentinel.conf redis redis-sentinel /etc/sentinel.conf
docker run --name redis-sentinel1 -p 26381:26379 --network br0 -d -v ./sentinel_1.conf:/etc/sentinel.conf redis redis-sentinel /etc/sentinel.conf



## Understanding Redis Sentinel Logs
https://redis.io/docs/management/sentinel

9:X 17 Dec 2023 18:37:07.731 * oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
9:X 17 Dec 2023 18:37:07.732 * Redis version=7.2.3, bits=64, commit=00000000, modified=0, pid=9, just started
9:X 17 Dec 2023 18:37:07.732 * Configuration loaded
9:X 17 Dec 2023 18:37:07.733 * monotonic clock: POSIX clock_gettime
9:X 17 Dec 2023 18:37:07.734 * Running mode=sentinel, port=26379.
9:X 17 Dec 2023 18:37:07.885 * Sentinel new configuration saved on disk
9:X 17 Dec 2023 18:37:07.886 * Sentinel ID is 328043feed0397ef915c328b7a66759f51ae4330
9:X 17 Dec 2023 18:37:07.886 # +monitor master mymaster 172.16.197.21 6379 quorum 2
9:X 17 Dec 2023 18:37:09.979 * +sentinel sentinel 931a91b1633d7a29d7a1d17684786dcaf7edeee8 172.16.197.24 26379 @ mymaster 172.16.197.21 6379
9:X 17 Dec 2023 18:37:09.985 * Sentinel new configuration saved on disk
9:X 17 Dec 2023 18:37:10.245 * +sentinel sentinel d839dfcc2b4f85d4001d8f99e5b356a1d1892bf9 172.16.197.26 26379 @ mymaster 172.16.197.21 6379
9:X 17 Dec 2023 18:37:10.253 * Sentinel new configuration saved on disk
9:X 17 Dec 2023 18:37:17.959 * +slave slave 172.16.197.16:6379 172.16.197.16 6379 @ mymaster 172.16.197.21 6379
9:X 17 Dec 2023 18:37:17.966 * Sentinel new configuration saved on disk
9:X 17 Dec 2023 18:37:17.966 * +slave slave 172.16.197.17:6379 172.16.197.17 6379 @ mymaster 172.16.197.21 6379
9:X 17 Dec 2023 18:37:17.973 * Sentinel new configuration saved on disk


## RedisInsight
https://docs.redis.com/latest/ri

$ docker run -v redisinsight:/db -p 8001:8001 redislabs/redisinsight:latest







