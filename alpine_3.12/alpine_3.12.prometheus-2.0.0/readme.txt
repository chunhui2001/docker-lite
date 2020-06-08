### exporter
# prometheus 使用 exporter 工具来暴露主机和应用程序上的指标

### node_exporter
# 提供了一个可用于收集各种主机指标数据 (CPU,内存和磁盘)。它还有一个textfile收集器，允许你导出静态指标。


# 删除 wanip=10.244.2.158:9090 数据
$ curl -X POST -g 'http://xxx.com/prometheus/api/v1/admin/tsdb/delete_series?match[]={wanip="10.244.2.158:9090"}'

# 删除所有数据
$ curl -X POST -g 'http://xxx.com/prometheus/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'

需要注意的是上面的 API 调用并不会立即删除数据，实际数据任然还存在磁盘上，会在后面进行数据清理。
要确定何时删除旧数据，可以使用--storage.tsdb.retention参数进行配置（默认情况下，Prometheus 会将数据保留15天）。


http//:localhost:9090/targets
