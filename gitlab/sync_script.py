#!/usr/bin/env python3
"""
功能：使用阿里云SDK同步云效仓库
"""

import os
import json
import logging
import logging.handlers
import time
import sys
import requests
import traceback

# 配置日志
def setup_logging(debug=False):
    # 创建logs目录
    if not os.path.exists('logs'):
        os.makedirs('logs')
    
    # 配置日志格式
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    # 配置文件处理器（使用RotatingFileHandler进行日志轮转）
    file_handler = logging.handlers.RotatingFileHandler(
        'logs/sync.log',
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
        required_fields = ['accessToken', 'organizationId']
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

class CodeupSyncer:
    def __init__(self, config):
        self.config = config
        self.access_token = config['accessToken']
        self.base_url = "https://devops.aliyun.com/api"
        self.headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json"
        }
        self.logger = logging.getLogger(__name__)

    def list_repositories(self):
        """获取仓库列表"""
        try:
            self.logger.info("开始获取仓库列表...")
            
            response = requests.get(
                f"{self.base_url}/repositories",
                headers=self.headers
            )
            
            if response.status_code == 200:
                repositories = response.json()
                self.logger.info(f"成功获取到 {len(repositories)} 个仓库")
                return repositories
            else:
                self.logger.error(f"获取仓库列表失败: HTTP {response.status_code}")
                self.logger.error(f"响应内容: {response.text}")
                return []
                
        except Exception as e:
            self.logger.error(f"获取仓库列表时发生错误: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            return []

    def trigger_sync(self, repository_id):
        """触发仓库同步"""
        try:
            self.logger.info(f"开始同步仓库 {repository_id}")
            
            # 根据文档更新API端点和参数
            response = requests.post(
                f"{self.base_url}/repository/{repository_id}/mirror",
                headers=self.headers,
                json={
                    "accessToken": self.access_token,
                    "organizationId": self.config['organizationId']
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    self.logger.info(f"仓库 {repository_id} 同步成功")
                    return True
                else:
                    self.logger.error(f"仓库 {repository_id} 同步失败: {result.get('errorMessage')}")
                    return False
            else:
                self.logger.error(f"仓库 {repository_id} 同步失败: HTTP {response.status_code}")
                self.logger.error(f"响应内容: {response.text}")
                return False
                
        except Exception as e:
            self.logger.error(f"同步仓库 {repository_id} 时发生错误: {str(e)}")
            self.logger.error(f"错误详情: {traceback.format_exc()}")
            return False

def main():
    try:
        # 设置日志
        setup_logging(debug=True)
        logger = logging.getLogger(__name__)
        
        # 加载配置
        logger.info("正在加载配置...")
        config = load_config()
        if not config:
            logger.error("配置加载失败，程序退出")
            return 1
        
        # 创建同步器
        syncer = CodeupSyncer(config)
        
        # 获取仓库列表
        logger.info("正在获取仓库列表...")
        repositories = syncer.list_repositories()
        
        if not repositories:
            logger.error("未找到任何仓库")
            return 1
        
        # 同步每个仓库
        success_count = 0
        fail_count = 0
        
        for repo in repositories:
            repo_id = repo['id']
            logger.info(f"正在同步仓库: {repo_id}")
            
            # 尝试同步，最多重试3次
            max_retries = 3
            for attempt in range(max_retries):
                if syncer.trigger_sync(repo_id):
                    success_count += 1
                    break
                elif attempt < max_retries - 1:
                    wait_time = (attempt + 1) * 5  # 递增等待时间
                    logger.warning(f"同步失败，{wait_time}秒后重试...")
                    time.sleep(wait_time)
                else:
                    logger.error(f"仓库 {repo_id} 同步失败，已达到最大重试次数")
                    fail_count += 1
        
        logger.info(f"同步完成: 成功 {success_count} 个, 失败 {fail_count} 个")
        
        if fail_count > 0:
            logger.warning(f"有 {fail_count} 个仓库同步失败")
            return 1
        
        return 0
        
    except Exception as e:
        logger.error(f"程序执行出错: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 