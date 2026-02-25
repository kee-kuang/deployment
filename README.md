# 部署文档库索引

> 按技能分类整理的运维部署知识库
> 整理日期: 2025-02-25

---

## 📁 目录结构

### 01-容器与编排
容器化技术和容器编排相关部署文档
- **docker/** - Docker 容器部署
- **docker-compose/** - Docker Compose 编排
- **k8s/** - Kubernetes 集群部署
- Centos 7 k8s1.22 版本部署文档
- K8s 部署 Nacos 文档

### 02-中间件与数据库
各类中间件和数据库的部署配置
- **Redis/** - 缓存数据库
- **Rabbitmq/** - 消息队列
- **Mongodb/** - 文档数据库
- **Postgresql/** - 关系型数据库
- **clickhouse/** - 列式数据库
- **greenplum/** - MPP 数据库
- **Nacos/** - 配置中心与服务发现
- **Seata/** - 分布式事务
- **Sentinel/** - 流量控制与熔断
- **Elk/** - Elasticsearch + Logstash + Kibana
- **Fastdfs/** - 分布式文件存储
- **oss/** - 对象存储
- **xxl/** - 分布式任务调度
- **casdoor/** - 身份认证平台
- **Liboffice/** - 文档转换服务
- **中间件部署/** - 综合中间件部署

### 03-监控与可观测性
系统监控、日志收集、链路追踪
- **Prometheus/** - 监控告警系统
- **filebeat/** - 日志收集
- **arthas/** - Java 诊断工具
- **Skywalking/** - APM 链路追踪
- INFLASH 开发环境日志查看 + SkyWalking 使用手册

### 04-CICD 与 DevOps
持续集成、持续部署、DevOps 工具链
- **Jenkins/** - CI/CD 流水线
- **gitlab/** - 代码仓库与 CI
- **Sonarqube/** - 代码质量分析
- **ansible/** - 自动化运维
- DevOps.pdf
- pipeline.txt

### 05-安全与访问控制
网络安全、VPN、堡垒机、安全培训
- **WireGuard/** - VPN 解决方案
- **openvpn/** - SSL VPN
- **v2ray-vpn/** - 代理工具
- **clash/** - 代理客户端
- **洞象/** - 安全工具
- **安全培训课件/** - 安全意识培训
- **运营商安全文件/** - 行业安全规范
- Teleport 混合云部署方案.md
- 网络安全漏洞防护典型案例 v2.docx
- 钓鱼邮件防范详细指南.pdf

### 06-应用部署
业务应用系统部署文档
- **瓴犀微服务平台系统设计-20240904/**
- 标品-初始部署文档.md
- 瓴犀平台内网环境部署文档.docx
- 瓴犀平台部署(集群版).docx
- 部署.docx
- 系统崩溃及恢复步骤文档.md

### 07-基础设施与运维
服务器、网络、存储等基础设施
- **nginx/** - Web 服务器
- **AC安装/** - 无线控制器
- **GPU-linux/** - GPU 服务器配置
- **Raid磁盘阵列/** - 存储阵列
- 14楼网络拓扑图.pdf
- 物理机桥接文档.pdf
- 服务器迁移第一次预演方案模板.xlsx

### 08-脚本与工具
自动化脚本和运维工具
- **sh/** - Shell 脚本
- **python/** - Python 脚本
- **pythonscrite/** - Python 项目
- **脚本/** - 综合脚本库
- **Maven/** - Java 构建工具
- **ffmpeg/** - 音视频处理
- **yapi/** - API 文档管理
- **it-tool/** - IT 工具集
- **php/** - PHP 相关
- 3-新Yapi使用说明.docx
- 腾讯云cos挂载到本地.md

### 09-运维管理
运维管理模板和检查清单
- **巡检单模板/** - 日常巡检
- **性能测试/** - 压测相关
- **monitoring/** - 监控配置
- **监控安装包/** - 监控软件包
- **tkdownload/** - 下载工具
- **steam/** - Steam 相关
- 网管日志接入手册.doc
- 操作(1).md

### 10-学习资料
技术学习和个人成长
- **Python-100-Days-master/** - Python 学习教程
- **简历/** - 个人简历
- Linux 安装 Python3.docx
- DB2 客户端安装及远程数据库连接配置文档.docx
- Pivotal Greenplum 学习笔记.docx
- go 笔记.md

### 99-归档资料
压缩包和归档文件
- Python-100-Days-master.zip
- apache-jmeter-5.4.1.zip
- Snipaste-2.5.6-Beta-x64.zip

---

## 🔍 快速查找

| 想找什么 | 去哪个目录 |
|---------|-----------|
| Docker/K8s | `01-容器与编排/` |
| Redis/MySQL/ES | `02-中间件与数据库/` |
| 监控告警 | `03-监控与可观测性/` |
| Jenkins/GitLab | `04-CICD与DevOps/` |
| VPN/堡垒机 | `05-安全与访问控制/` |
| 业务部署 | `06-应用部署/` |
| 网络/存储 | `07-基础设施与运维/` |
| 脚本工具 | `08-脚本与工具/` |
| 巡检模板 | `09-运维管理/` |
| 学习教程 | `10-学习资料/` |

---

## 📝 使用说明

1. **文件命名**: 尽量使用英文或拼音，避免特殊字符
2. **定期归档**: 过期文档及时移至 `99-归档资料/`
3. **版本管理**: 重要变更请提交 Git 记录
4. **补充索引**: 新增文档后更新此 README

---

*维护者: 阿淇*  
*GitHub: https://github.com/kee-kuang/deployment*
