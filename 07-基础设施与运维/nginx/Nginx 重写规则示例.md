## Nginx 重写规则示例

### 根据二级域名增加二级目录

```
if ($host ~* ^(edi|xinxing|ogshop|pubilc|ict|jiangxi|boli|poly|sjc|anhui|gylgz|mro|shop|shanghai|shuangxun)\.ccsdzsc\.com$) {
            rewrite ^/(.*)$ http://web.ccsdzsc.com/$1 permanent;
        }
```

### 动态根据二级域名获取二级目录(可以成功)

```
server_name_in_redirect off;
    set $subdomain "";
    if ($host ~* ^(\w+)\.ccsdzsc.com$) {
        set $subdomain $1;
    }

    # 添加一个新的 location 块用于重定向
    location ~ ^/(\d+)$ {
        rewrite ^/(\d+)$ /$subdomain/$1 permanent;
    }
  ${subdomain}web 拼接内容
语句解释：
server_name_in_redirect off;: 此指令关闭自动重定向到服务器名称。在重定向时，通常使用server_name指令的值作为重定向URL。通过将其设置为"off"，意味着将使用原始请求的Host标头在重定向URL中。
set $subdomain "";: 此行用空字符串初始化一个名为$subdomain的变量。
if ($host ~* ^(\w+)\.ccsdzsc.com$) {: 这是一个if块，检查传入请求的Host标头的值是否与模式^(\w+)\.ccsdzsc.com$匹配。~*表示不区分大小写的匹配，(\w+)捕获一个或多个单词字符（字母、数字或下划线）作为子域。
set $subdomain $1;: 如果前面的if块中的条件为真，它将$subdomain变量的值设置为捕获的子域（即$1的值）。
location ~ ^/(\d+)$ {: 这个块定义了一个location指令，匹配具有数值路径的请求。^/(\d+)$正则表达式捕获路径末尾的一个或多个数字。
rewrite ^/(\d+)$ /$subdomain/$1 permanent;: 如果请求匹配location，它会重写URL。它从路径中获取捕获的数字，并使用之前捕获的子域构造一个新的URL。permanent标志表示这是一个永久（301）重定向。
```

### 全部域名指定固定二级目录跳转

```
location ~ ^/(\d+)$ {
        rewrite ^/(\d+)$ /qgshop/$1 permanent;
    } 
语句解释：
location ~ ^/(\d+)$ {: 这是一个 location 块，它使用正则表达式 ^/(\d+)$ 匹配以数字结尾的路径。解释如下：
~: 表示进行正则表达式匹配。
^/(\d+)$: 是一个正则表达式，它匹配以斜杠开头，后面跟着一个或多个数字，然后是字符串的结尾。
在正则表达式中，\d+ 是一个模式，表示匹配一个或多个数字字符。具体解释如下：
\d: 表示匹配任何一个数字字符，相当于字符类 [0-9]。
+: 表示匹配前面的元素（在这里是\d）一次或多次
rewrite ^/(\d+)$ /qgshop/$1 permanent;: 如果请求的路径匹配上述的正则表达式，就会执行重写。具体来说，它将路径中的数字捕获并用 $1 表示，然后构建一个新的路径 /qgshop/$1。最后的 permanent 表示这是一个永久重定向
```

### 使用 `map` 指令将不同的主机名映射到相应的路径

```
map $host $custom_path {
            default "";
            "edi.ccsdzsc.com" "/ediweb/42";
            "xinxing.ccsdzsc.com" "/xinxingweb/42";
            "ogshop.ccsdzsc.com" "/ogshopweb/42";
            "public.ccsdzsc.com" "/publicweb/42";
            "ict.ccsdzsc.com" "/ictweb/42";
            "jiangxi.ccsdzsc.com" "/jiangxiweb/42";
            "boli.ccsdzsc.com" "/boliweb/42";
            "poly.ccsdzsc.com" "/polyweb/42";
            "sjc.ccsdzsc.com" "/sjcweb/42";
            "anhui.ccsdzsc.com" "/anhuiweb/42";
            "gylgz.ccsdzsc.com" "/gylgzweb/42";
            "mro.ccsdzsc.com" "/mroweb/42";
            "shop.ccsdzsc.com" "/shopweb/42";
            "shanghai.ccsdzsc.com" "/shanghaiweb/42";
            "shuangxun.ccsdzsc.com" "/shuangxunweb/42";
        }
        server{
        ...
        }
        if ($custom_path) {
            return 301 http://$host$custom_path;
        }
语句解释：
map $host $custom_path { ... }: 这是一个 Nginx 的 map 指令，用于创建一个变量 $custom_path，它根据 $host 变量（即请求的主机名）的值进行映射。不同的主机名映射到了不同的路径。如果主机名没有在定义的列表中，那么 $custom_path 的值就是空字符串。
if ($custom_path) { return 301 http://$host$custom_path; }: 这是一个条件语句，如果 $custom_path 不为空，则执行一个永久性的（301）重定向。重定向的目标 URL 是由请求的主机名和映射得到的路径组成的。
具体来说，对于每个主机名，配置将请求重定向到相应的路径。例如，对于主机名 edi.ccsdzsc.com，请求将被重定向到 /ediweb/42。这种方式使得对不同主机名的请求可以根据预定义的映射表被重定向到不同的路径，从而实现定制化的 URL 路径映射。
```

### 条件语句检查请求的主机名是否匹配特定的主机名。如果匹配，则执行相应的永久性重定向，将请求重定向到预定义的路径

```
if ($host = edi.ccsdzsc.com) {
            return 301 http://edi.ccsdzsc.com/ediweb/42;
        }

        if ($host = xinxing.ccsdzsc.com) {
            return 301 http://xinxing.ccsdzsc.com/xinxingweb/42;
        }
```

### 固定跳转

```
rewrite ^/$ /6 permanent;
```

