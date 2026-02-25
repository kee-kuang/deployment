# it-tool 搭建过程和使用方式

## 简介

基本上涵盖了日常要用到的大部分工具，例如json格式化、编码转换、UUID生成

## 安装

```
docker run -d --name it-tools --restart unless-stopped -p 8080:80 corentinth/it-tools:latest
```

使用docker 部署，之后能在端口8080 下访问和使用这些工具了

github地址：

**https://github.com/CorentinTh/it-tools**

## 功能介绍

```
1. Token generator:
生成带有所需字符、大写或小写字母、数字和/或符号的随机字符串。
2. Hask text 
使用您需要的函数对文本字符串进行哈希处理：MD5、SHA1、SHA256、SHA224、SHA512、SHA384、SHA3 或 RIPEMD160
3.Date-time converter
将日期和时间转换为各种不同的格式
4.Integer base converter
在不同基数之间转换数字（十进制、十六进制、二进制、八进制、基数64等）
5.Json to toml 
解析 JSON 并将其转换为 TOML

```

