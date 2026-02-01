# Elasticsearch 重要的配置项

在Elasticsearch安装目录下的conf文件夹中包含了一个重要的配置文件：elasticsearch.yml。

elasticsearch的配置信息有很多种，大部分配置都可以通过elasticsearch.yml和接口的方式进行。

1. cluster.name：elasticsearch

配置elasticsearch的集群名称，默认值是elasticsearch，建议改成与所存数据相关的名称，elasticsearch会自动发现在同一网段下的集群名称相同的节点。

2. node.name: "node1"

集群中的节点名，在同一个集群中不能重复。节点的名称一旦设置，就不能再修改了。当然，也可以设置成服务器的主机名称，例如 node.name: ${HOSTNAME} 。

3. node.master: true

指定该节点是否有资格被选举成为master节点，默认为true，如果被设置为true，则只是有资格成为master节点，具体能否成为master节点，需要通过选举产生。

4. node.data: true

指定该节点是否存储索引数据，默认为true。数据的增、删、改、查都是在Data节点完成的。

5. index.number_of_shards: 5

设置默认的索引分片个数，默认为5片。也可以在创建索引时设置该值，具体设置为多大的值要根据数据量的大小来定。如果数据量不大，则设置成1时效率最高。

6. index.number_of_replicas: 1

设置默认的索引副本个数，默认为1个。副本数越多，集群的可用性越好，但是写索引时需要同步的数据越多。

7. path.conf: /path/to/conf

设置配置文件的存储路径，默认时elasticsearch目录下conf文件夹。建议使用默认值。

8. path.data: /path/to/data1,/path/to/data2

设置索引数据的存储路径，默认是elasticsearch根目录下的data文件夹。切记不要使用默认值，因为若elasticsearch进行了升级，则有可能导致数据全部丢失。可以用半角逗号隔开设置的多个存储路径，在多硬盘的服务器上设置多个存储路径是很有必要的。

9. path.logs: /path/to/logs

设置日志文件的存储路径，默认是elasticsearch根目录下的logs文件夹，建议修改到其他地方。

10. path.plugins:/path/plugins

设置第三方插件的存放路径，默认是elasticsearch根目录下的plugins文件夹。

11. bootstrap.mlockall: true

设置为true时可锁住内存。因为当JVM开始swap时，elasticsearch的效率会降低，所以要保证它不swap。

12. network.bind_host: 192.168.0.1

设置本节点绑定的IP地址，IP地址类型是IPv4或IPv6，默认为0.0.0.0

13. network.pulish_host: 192.168.0.1

设置其他节点和该节点交互的IP地址，如果不设置，则会进行自动判断。

14. network.host: 192.168.0.1

用于同时设置bind_host和publish_host这两个参数。

15. http.port: 9200

设置对外服务的HTTP端口，默认为9200。elasticsearch 的节点需要配置两个端口号，一个是对外提供服务的端口号，一个是集群内部通信使用的端口号。http.port设置的是对外提供服务的端口号。注意，如果在一个服务器上配置多个节点，则切记对端口号进行区分。

16. transport.tcp.port: 9300

设置集群内部的节点间交互的TCP端口，默认是9300。注意，如果在一个服务器上配置多个节点，则切记对端口号进行区分。

17. transport.tcp.compress: true

设置在节点间传数据时是否压缩，默认为false，不压缩。

18. discovery.zen.minimum_master_nodes: 1

设置在选举master节点时需要参与的最少的候选节点数，默认为1。如果使用默认值，则当网络不稳定时可能会出现脑裂。合理的数值为（master_eligible_nodes / 2 ）+ 1，其中master_eligible_nodes表示集群中的候选主节点数。

19. discovery.zen.ping.timeout: 3s

设置在集群中自动发现其他节点时ping连接的超时时间，默认为3秒。在较差的网络环境下设置得大一些，防止因误判该节点的存活状态而导致分片的转移。