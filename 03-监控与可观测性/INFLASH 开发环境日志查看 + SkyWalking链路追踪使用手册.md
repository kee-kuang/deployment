# INFLASH 开发环境日志查看 + SkyWalking链路追踪使用手册

### 地址

#### ELK地址

[http://ec2-52-195-208-165.ap-northeast-1.compute.amazonaws.com:5601/](http://ec2-52-195-208-165.ap-northeast-1.compute.amazonaws.com:5601/)

賬號：elastic

密碼：lingxi

#### SkyWalking地址

[ec2-52-195-208-165.ap-northeast-1.compute.amazonaws.com:11800](http://ec2-52-195-208-165.ap-northeast-1.compute.amazonaws.com:8383/)

### ELK日志查询

现状 : 开发查日志log需登录服务器查看日志详情，这种查询效率比较低，较为原始。

解决 : 使用elk来查询线上日志，可以做到按时间维度，按查询条件查询，也可以做相关统计

具体操作: 

1.入口

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/a8b383d5-bb83-4346-a481-d610c2757157.png)

2.进入日志列表内容

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/fcdf630a-9592-4a6f-aeab-ae6b9ce486bc.png)

3.开发者选择对应负责服务

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/88245b21-73af-4a5a-96b0-16ff1f846c0d.png)

4.列表常用有时间，content，**traceid（后面有介绍用途）**

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/2d901c4d-b68d-4429-8fb5-df5448240200.png)

如果想了解怎么定义自己elk查日志模版。详情可以看下这个文档：[《kibana看日志的使用方式》](https://alidocs.dingtalk.com/i/nodes/7NkDwLng8ZMn7PeXhmqazAdlJKMEvZBY?cid=219219161%3A230301323&corpId=ding3f6114629b19d183&doc_type=wiki_doc&iframeQuery=utm_medium%3Dim_card%26utm_source%3Dim&utm_medium=im_card&utm_scene=team_space&utm_source=im#)

#### Skywalking使用

用途: 线上排查问题利器，链路追踪，服务拓扑调用关系

场景: 

1.  **根据traceid查询整个链路相关微服务日志**
    
2.  **查询链路中各个微服务中调用耗时详情，可以查看慢请求，慢sql，循环逻辑调用情况**
    

使用步骤:

1.列表关联微服内容

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/f3f0b374-2946-413b-a298-d51c1ecc9ce1.png)

2.微服务拓扑图

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/781b6c32-77bd-49ed-a7a7-f89b43456ad2.png)

3.查看trace详情，可以看到对应trace链路各个服务之间的调用

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/583c229a-e6b7-454a-8fcb-57ffb11bc58b.png)

4.具体线上生产实操，elk 与  skywalking apm管理后台结合使用

步骤：

1.  线上有慢http接口，或者error异常 在elk看到 log级别error ，从elk查看到对应log traceid
    

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/7f9f693b-1db0-47c6-b0ab-27cb8a0db108.png)

2.复制粘贴traceid 到skywalking apm管理后台上查看链路耗时详情:

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/ZWGl0w3o7NQ0O34Y/img/483e26ba-2282-4063-8c80-f55c380d1395.png)

根据以上步骤可以解决：**接口性能问题，慢请求，慢sql，循环逻辑调用情况**

如果有同学有兴趣考虑怎么接入可以看下这个文档: 

[《skywalking+ek+nginx全链路日志方案》](https://alidocs.dingtalk.com/i/nodes/o14dA3GK8g5Zlvw3hZqg9BobV9ekBD76?cid=219219161%3A230301323&corpId=ding3f6114629b19d183&doc_type=wiki_doc&iframeQuery=utm_medium%3Dim_card%26utm_source%3Dim&utm_medium=im_card&utm_scene=team_space&utm_source=im#)