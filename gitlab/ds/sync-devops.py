# -*- coding: utf-8 -*-
import pymysql
import json
import os
import sys
import logging
import logging.handlers
import time
import traceback
from typing import List, Dict, Any
from datetime import datetime

from alibabacloud_devops20210625.client import Client as devops20210625Client
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_devops20210625 import models as devops_20210625_models
from alibabacloud_tea_util import models as util_models
from alibabacloud_tea_util.client import Client as UtilClient

# 配置日志
def setup_logging(debug=False):
    # 创建logs目录
    if not os.path.exists('logs'):
        os.makedirs('logs')
    
    # 配置日志格式
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    # 配置文件处理器（使用RotatingFileHandler进行日志轮转）
    file_handler = logging.handlers.RotatingFileHandler(
        'logs/sync_devops.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(logging.Formatter(log_format))
    
    # 配置控制台处理器
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(log_format))
    
    # 配置根日志记录器
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG if debug else logging.INFO)
    root_logger.addHandler(file_handler)
    root_logger.addHandler(console_handler)
    
    # 设置第三方库的日志级别
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('requests').setLevel(logging.WARNING)

class ConfigManager:
    @staticmethod
    def load_config() -> Dict[str, Any]:
        """加载配置文件"""
        config_path = os.path.join(os.path.dirname(__file__), 'config.json')
        logger = logging.getLogger(__name__)
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
                
            # 验证必要的配置项
            required_fields = {
                'devops': ['organization_id', 'access_key_id', 'access_key_secret', 'endpoint'],
                'database': ['host', 'port', 'user', 'password', 'db', 'charset']
            }
            
            for section, fields in required_fields.items():
                if section not in config:
                    raise ValueError(f"配置文件缺少必要的部分: {section}")
                for field in fields:
                    if field not in config[section]:
                        raise ValueError(f"配置文件缺少必要的字段: {section}.{field}")
            
            logger.info("成功加载配置")
            return config
        except FileNotFoundError:
            logger.error(f"错误：配置文件 {config_path} 不存在")
            sys.exit(1)
        except json.JSONDecodeError:
            logger.error("错误：配置文件格式不正确")
            sys.exit(1)
        except ValueError as e:
            logger.error(f"错误：{str(e)}")
            sys.exit(1)
        except Exception as e:
            logger.error(f"加载配置文件时发生错误: {str(e)}")
            logger.error(f"错误详情: {traceback.format_exc()}")
            sys.exit(1)

class DatabaseManager:
    def __init__(self, config: Dict[str, Any]):
        self.db_config = config['database']
        self.logger = logging.getLogger(__name__)
    
    def create_connection(self):
        """创建数据库连接"""
        try:
            return pymysql.connect(
                host=self.db_config['host'],
                port=self.db_config['port'],
                user=self.db_config['user'],
                password=self.db_config['password'],
                database=self.db_config['db'],
                charset=self.db_config['charset'],
                cursorclass=pymysql.cursors.DictCursor
            )
        except Exception as e:
            self.logger.error(f"创建数据库连接失败: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            raise

    def init_database(self):
        """初始化数据库表结构"""
        self.logger.info("正在初始化数据库表结构...")
        try:
            with self.create_connection() as conn:
                with conn.cursor() as cursor:
                    # 创建代码库表
                    cursor.execute("""
                    CREATE TABLE IF NOT EXISTS repositories (
                        id BIGINT PRIMARY KEY,
                        name VARCHAR(255) NOT NULL,
                        path VARCHAR(255),
                        description TEXT,
                        visibility_level INT,
                        web_url VARCHAR(255),
                        created_at DATETIME,
                        updated_at DATETIME,
                        last_sync_at DATETIME,
                        sync_status VARCHAR(50),
                        organization_id VARCHAR(100),
                        created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
                    """)
                    conn.commit()
                    self.logger.info("数据库表结构初始化成功")
        except Exception as e:
            self.logger.error(f"初始化数据库表结构失败: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            raise

    def save_repositories(self, repos: list, org_id: str):
        """存储代码库信息到数据库"""
        self.logger.info(f"正在保存 {len(repos)} 个代码库信息到数据库...")
        try:
            with self.create_connection() as conn:
                with conn.cursor() as cursor:
                    # 获取当前时间
                    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    
                    # 准备SQL语句
                    insert_sql = """
                    INSERT INTO repositories (
                        id, name, path, description, visibility_level, web_url, 
                        created_at, updated_at, last_sync_at, sync_status, organization_id
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    ) ON DUPLICATE KEY UPDATE
                        name = VALUES(name),
                        path = VALUES(path),
                        description = VALUES(description),
                        visibility_level = VALUES(visibility_level),
                        web_url = VALUES(web_url),
                        updated_at = VALUES(updated_at),
                        last_sync_at = NULL,
                        sync_status = 'pending',
                        updated_time = CURRENT_TIMESTAMP
                    """
                    
                    # 遍历代码库列表并保存
                    for repo in repos:
                        # 提取代码库信息 - 处理可能的字典或对象
                        if isinstance(repo, dict):
                            repo_id = repo.get('id')
                            repo_name = repo.get('name')
                            repo_path = repo.get('path')
                            repo_description = repo.get('description')
                            repo_visibility_level = repo.get('visibility_level')
                            repo_web_url = repo.get('web_url')
                            repo_created_at = repo.get('created_at')
                            repo_updated_at = repo.get('updated_at')
                        else:
                            # 假设是对象
                            repo_id = getattr(repo, 'id', None)
                            repo_name = getattr(repo, 'name', None)
                            repo_path = getattr(repo, 'path', None)
                            repo_description = getattr(repo, 'description', None)
                            repo_visibility_level = getattr(repo, 'visibility_level', None)
                            repo_web_url = getattr(repo, 'web_url', None)
                            repo_created_at = getattr(repo, 'created_at', None)
                            repo_updated_at = getattr(repo, 'updated_at', None)
                        
                        # 执行SQL语句
                        cursor.execute(insert_sql, (
                            repo_id, repo_name, repo_path, repo_description, repo_visibility_level, repo_web_url,
                            repo_created_at, repo_updated_at, current_time, 'pending', org_id
                        ))
                    
                    # 提交事务
                    conn.commit()
                    self.logger.info(f"成功保存 {len(repos)} 个代码库信息到数据库")
        except Exception as e:
            self.logger.error(f"保存代码库信息到数据库失败: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            raise

class DevOpsClient:
    def __init__(self, config: Dict[str, Any]):
        self.org_id = config['devops']['organization_id']
        self.access_key_id = config['devops']['access_key_id']
        self.access_key_secret = config['devops']['access_key_secret']
        self.endpoint = config['devops']['endpoint']
        self.logger = logging.getLogger(__name__)
    
    def create_client(self) -> devops20210625Client:
        """创建DevOps客户端"""
        try:
            # 使用access_key创建客户端
            config = open_api_models.Config()
            config.endpoint = self.endpoint
            config.access_key_id = self.access_key_id
            config.access_key_secret = self.access_key_secret
            return devops20210625Client(config)
        except Exception as e:
            self.logger.error(f"创建DevOps客户端失败: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            raise

    def get_repositories(self):
        """获取代码库列表"""
        self.logger.info("开始获取代码库列表...")
        try:
            client = self.create_client()
            all_repositories = []
            page = 1
            per_page = 100  # 每页获取100条记录
            
            while True:
                # 使用分页参数
                request = devops_20210625_models.ListRepositoriesRequest(
                    organization_id=self.org_id,
                    page=page,
                    per_page=per_page
                )
                
                runtime = util_models.RuntimeOptions()
                headers = {
                    'Content-Type': 'application/json;charset=utf-8'
                }
                
                self.logger.debug(f"发送请求，组织ID: {self.org_id}, 页码: {page}")
                response = client.list_repositories_with_options(request, headers, runtime)
                
                if response and response.body and response.body.success:
                    # 检查响应体的属性
                    if hasattr(response.body, 'result'):
                        repositories = response.body.result
                    elif hasattr(response.body, 'data'):
                        repositories = response.body.data
                    else:
                        repositories = response.body
                    
                    if repositories:
                        all_repositories.extend(repositories)
                        # 如果返回的记录数小于per_page，说明已经是最后一页
                        if len(repositories) < per_page:
                            break
                        page += 1
                    else:
                        break
                else:
                    error_msg = response.body.message if response.body else '未知错误'
                    self.logger.error(f"获取代码库列表失败: {error_msg}")
                    break
                
            if all_repositories:
                self.logger.info(f"成功获取到 {len(all_repositories)} 个代码库")
                return all_repositories
            else:
                self.logger.warning("获取到的代码库列表为空")
                return []
                
        except Exception as e:
            self.logger.error(f"获取代码库列表时发生错误: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            return []

def main():
    # 设置日志
    setup_logging(debug=True)
    logger = logging.getLogger(__name__)
    
    try:
        # 加载配置
        logger.info("=== 开始同步代码库 ===")
        logger.info("步骤1: 加载配置...")
        config = ConfigManager.load_config()
        
        # 初始化数据库
        logger.info("\n步骤2: 初始化数据库...")
        db_manager = DatabaseManager(config)
        db_manager.init_database()
        
        # 获取代码库数据
        logger.info("\n步骤3: 获取代码库列表...")
        devops_client = DevOpsClient(config)
        repositories = devops_client.get_repositories()
        
        if repositories:
            # 存储到数据库
            logger.info("\n步骤4: 保存代码库信息到数据库...")
            try:
                db_manager.save_repositories(repositories, config['devops']['organization_id'])
                logger.info(f"成功存储 {len(repositories)} 个代码库信息")
            except Exception as e:
                logger.error(f"数据库操作失败: {str(e)}")
                logger.error(f"错误详情: {traceback.format_exc()}")
                return 1
        else:
            logger.warning("没有获取到代码库信息")
        
        logger.info("\n=== 代码库同步完成 ===")
        return 0
        
    except Exception as e:
        logger.error(f"程序执行出错: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return 1

if __name__ == '__main__':
    sys.exit(main())