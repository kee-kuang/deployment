#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
功能：获取阿里云云效代码库列表并存储到MySQL数据库
"""

import os
import sys
import json
import logging
import logging.handlers
import time
import traceback
import pymysql
from typing import List, Dict, Any

from alibabacloud_devops20210625.client import Client as devops20210625Client
from alibabacloud_credentials.client import Client as CredentialClient
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
        'logs/sync_repositories.log',
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

def load_config(config_path='config.json'):
    """加载配置文件"""
    try:
        if not os.path.exists(config_path):
            logging.error(f"配置文件不存在: {config_path}")
            return None
            
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
            
        # 验证必要的配置项
        required_fields = ['accessToken', 'organizationId', 'db_host', 'db_port', 'db_user', 'db_password', 'db_name']
        for field in required_fields:
            if field not in config:
                raise ValueError(f"配置文件缺少必要的字段: {field}")
            
        # 检查配置值
        if not config['accessToken'] or config['accessToken'] == 'your-access-token':
            logging.error("accessToken 未设置或使用了默认值，请修改 config.json")
            return None
            
        if not config['organizationId'] or config['organizationId'] == 'your-organization-id':
            logging.error("organizationId 未设置或使用了默认值，请修改 config.json")
            return None
            
        logging.info("成功加载配置")
        return config
    except Exception as e:
        logging.error(f"加载配置文件失败: {str(e)}")
        return None

def create_client(config):
    """
    使用凭据初始化账号Client
    @return: Client
    @throws Exception
    """
    try:
        # 工程代码建议使用更安全的无AK方式，凭据配置方式请参见：https://help.aliyun.com/document_detail/378659.html。
        credential = CredentialClient()
        open_api_config = open_api_models.Config(
            credential=credential
        )
        # Endpoint 请参考 https://api.aliyun.com/product/devops
        open_api_config.endpoint = f'devops.cn-hangzhou.aliyuncs.com'
        return devops20210625Client(open_api_config)
    except Exception as e:
        logging.error(f"创建客户端失败: {str(e)}")
        logging.error(f"错误详情: {traceback.format_exc()}")
        return None

def get_repositories(client, config):
    """获取代码库列表"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("开始获取代码库列表...")
        
        list_repositories_request = devops_20210625_models.ListRepositoriesRequest(
            organization_id=config['organizationId'],
            access_token=config['accessToken']
        )
        runtime = util_models.RuntimeOptions()
        headers = {}
        
        # 调用API获取代码库列表
        response = client.list_repositories_with_options(list_repositories_request, headers, runtime)
        
        if response and response.body and response.body.success:
            repositories = response.body.data
            logger.info(f"成功获取到 {len(repositories)} 个代码库")
            return repositories
        else:
            error_msg = response.body.message if response.body else '未知错误'
            logger.error(f"获取代码库列表失败: {error_msg}")
            return []
            
    except Exception as e:
        logger.error(f"获取代码库列表时发生错误: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return []

def init_database(config):
    """初始化数据库连接和表结构"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("正在连接数据库...")
        
        # 连接数据库
        conn = pymysql.connect(
            host=config['db_host'],
            port=int(config['db_port']),
            user=config['db_user'],
            password=config['db_password'],
            database=config['db_name'],
            charset='utf8mb4'
        )
        
        # 创建游标
        cursor = conn.cursor()
        
        # 创建代码库表
        logger.info("正在创建代码库表...")
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
        
        # 提交事务
        conn.commit()
        logger.info("数据库初始化成功")
        
        return conn, cursor
        
    except Exception as e:
        logger.error(f"初始化数据库失败: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return None, None

def save_repositories(conn, cursor, repositories, config):
    """保存代码库信息到数据库"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("正在保存代码库信息到数据库...")
        
        # 获取当前时间
        current_time = time.strftime('%Y-%m-%d %H:%M:%S')
        
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
            updated_time = CURRENT_TIMESTAMP
        """
        
        # 遍历代码库列表并保存
        for repo in repositories:
            # 提取代码库信息
            repo_id = repo.id
            repo_name = repo.name
            repo_path = repo.path
            repo_description = repo.description
            repo_visibility_level = repo.visibility_level
            repo_web_url = repo.web_url
            repo_created_at = repo.created_at
            repo_updated_at = repo.updated_at
            
            # 执行SQL语句
            cursor.execute(insert_sql, (
                repo_id, repo_name, repo_path, repo_description, repo_visibility_level, repo_web_url,
                repo_created_at, repo_updated_at, current_time, 'pending', config['organizationId']
            ))
        
        # 提交事务
        conn.commit()
        logger.info(f"成功保存 {len(repositories)} 个代码库信息到数据库")
        return True
        
    except Exception as e:
        logger.error(f"保存代码库信息到数据库失败: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        # 回滚事务
        conn.rollback()
        return False

def main():
    try:
        # 设置日志
        setup_logging(debug=True)
        logger = logging.getLogger(__name__)
        
        # 加载配置
        logger.info("=== 开始同步代码库 ===")
        logger.info("步骤1: 加载配置...")
        config = load_config()
        if not config:
            logger.error("配置加载失败，程序退出")
            return 1
        
        # 创建客户端
        logger.info("\n步骤2: 创建API客户端...")
        client = create_client(config)
        if not client:
            logger.error("创建API客户端失败，程序退出")
            return 1
        
        # 获取代码库列表
        logger.info("\n步骤3: 获取代码库列表...")
        repositories = get_repositories(client, config)
        if not repositories:
            logger.error("获取代码库列表失败，程序退出")
            return 1
        
        # 初始化数据库
        logger.info("\n步骤4: 初始化数据库...")
        conn, cursor = init_database(config)
        if not conn or not cursor:
            logger.error("初始化数据库失败，程序退出")
            return 1
        
        # 保存代码库信息到数据库
        logger.info("\n步骤5: 保存代码库信息到数据库...")
        if not save_repositories(conn, cursor, repositories, config):
            logger.error("保存代码库信息到数据库失败，程序退出")
            return 1
        
        # 关闭数据库连接
        cursor.close()
        conn.close()
        
        logger.info("\n=== 代码库同步完成 ===")
        return 0
        
    except Exception as e:
        logger.error(f"程序执行出错: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 