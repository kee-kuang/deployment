#!/usr/bin/env python3
"""
功能：测试阿里云云效API连接和权限
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
        'logs/test.log',
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

def test_api_connection(config):
    """测试API连接"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("开始测试API连接...")
        
        # 测试1: 验证accessToken格式
        logger.info("测试1: 验证accessToken格式...")
        if not config['accessToken'] or len(config['accessToken']) < 10:
            logger.error("accessToken格式不正确，长度应该大于10个字符")
            return False
            
        # 测试2: 验证organizationId格式
        logger.info("测试2: 验证organizationId格式...")
        if not config['organizationId'] or len(config['organizationId']) < 10:
            logger.error("organizationId格式不正确，长度应该大于10个字符")
            return False
            
        # 测试3: 测试API连接
        logger.info("测试3: 测试API连接...")
        headers = {
            "Authorization": f"Bearer {config['accessToken']}",
            "Content-Type": "application/json"
        }
        
        # 测试获取代码组列表
        params = {
            "organizationId": config['organizationId'],
            "accessToken": config['accessToken'],
            "parentId": config['organizationId'],  # 使用企业ID作为父路径
            "page": 1,
            "pageSize": 100
        }
        
        response = requests.get(
            "https://devops.aliyun.com/api/repository/groups/get/all",
            headers=headers,
            params=params
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                logger.info("API连接测试成功")
                return True
            else:
                error_msg = result.get('errorMessage', '未知错误')
                logger.error(f"API连接测试失败: {error_msg}")
                return False
        elif response.status_code == 401:
            logger.error("API认证失败: accessToken可能无效或已过期")
            return False
        elif response.status_code == 403:
            logger.error("API权限不足: 请检查accessToken的权限")
            return False
        else:
            logger.error(f"API连接测试失败: HTTP {response.status_code}")
            logger.error(f"响应内容: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        logger.error("网络连接失败: 请检查网络连接或API地址是否正确")
        return False
    except requests.exceptions.Timeout:
        logger.error("请求超时: 请检查网络连接")
        return False
    except Exception as e:
        logger.error(f"API连接测试出错: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return False

def test_list_repository_groups(config):
    """测试获取代码组列表"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("开始测试获取代码组列表...")
        
        headers = {
            "Authorization": f"Bearer {config['accessToken']}",
            "Content-Type": "application/json"
        }
        
        # 测试1: 获取代码组列表
        logger.info("测试1: 获取代码组列表...")
        params = {
            "organizationId": config['organizationId'],
            "accessToken": config['accessToken'],
            "parentId": config['organizationId'],  # 使用企业ID作为父路径
            "page": 1,
            "pageSize": 100
        }
        
        response = requests.get(
            "https://devops.aliyun.com/api/repository/groups/get/all",
            headers=headers,
            params=params
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                groups = result.get('result', [])
                if not groups:
                    logger.warning("未找到任何代码组，请检查是否有代码组访问权限")
                    return []
                    
                logger.info(f"成功获取到 {len(groups)} 个代码组")
                for group in groups:
                    logger.info(f"代码组ID: {group['id']}, 名称: {group.get('name', 'N/A')}, 路径: {group.get('path', 'N/A')}")
                return groups
            else:
                error_msg = result.get('errorMessage', '未知错误')
                logger.error(f"获取代码组列表失败: {error_msg}")
                return []
        elif response.status_code == 401:
            logger.error("获取代码组列表失败: accessToken可能无效或已过期")
            return []
        elif response.status_code == 403:
            logger.error("获取代码组列表失败: 权限不足，请检查accessToken的权限")
            return []
        else:
            logger.error(f"获取代码组列表失败: HTTP {response.status_code}")
            logger.error(f"响应内容: {response.text}")
            return []
            
    except requests.exceptions.ConnectionError:
        logger.error("网络连接失败: 请检查网络连接")
        return []
    except requests.exceptions.Timeout:
        logger.error("请求超时: 请检查网络连接")
        return []
    except Exception as e:
        logger.error(f"获取代码组列表时发生错误: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return []

def test_list_repositories(config):
    """测试获取仓库列表"""
    try:
        logger = logging.getLogger(__name__)
        logger.info("开始测试获取仓库列表...")
        
        headers = {
            "Authorization": f"Bearer {config['accessToken']}",
            "Content-Type": "application/json"
        }
        
        # 测试1: 获取仓库列表
        logger.info("测试1: 获取仓库列表...")
        params = {
            "organizationId": config['organizationId'],
            "accessToken": config['accessToken']
        }
        
        response = requests.get(
            "https://devops.aliyun.com/api/repository/list",
            headers=headers,
            params=params
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                repositories = result.get('result', [])
                if not repositories:
                    logger.warning("未找到任何仓库，请检查是否有仓库访问权限")
                    return []
                    
                logger.info(f"成功获取到 {len(repositories)} 个仓库")
                for repo in repositories:
                    logger.info(f"仓库ID: {repo['id']}, 名称: {repo.get('name', 'N/A')}")
                return repositories
            else:
                error_msg = result.get('errorMessage', '未知错误')
                logger.error(f"获取仓库列表失败: {error_msg}")
                return []
        elif response.status_code == 401:
            logger.error("获取仓库列表失败: accessToken可能无效或已过期")
            return []
        elif response.status_code == 403:
            logger.error("获取仓库列表失败: 权限不足，请检查accessToken的权限")
            return []
        else:
            logger.error(f"获取仓库列表失败: HTTP {response.status_code}")
            logger.error(f"响应内容: {response.text}")
            return []
            
    except requests.exceptions.ConnectionError:
        logger.error("网络连接失败: 请检查网络连接")
        return []
    except requests.exceptions.Timeout:
        logger.error("请求超时: 请检查网络连接")
        return []
    except Exception as e:
        logger.error(f"获取仓库列表时发生错误: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return []

def test_trigger_sync(config, repository_id):
    """测试触发仓库同步"""
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"开始测试同步仓库 {repository_id}...")
        
        headers = {
            "Authorization": f"Bearer {config['accessToken']}",
            "Content-Type": "application/json"
        }
        
        # 测试1: 验证请求参数
        logger.info("测试1: 验证请求参数...")
        request_data = {}  # 根据示例，请求体为空对象
        
        # 测试2: 发送同步请求
        logger.info("测试2: 发送同步请求...")
        response = requests.post(
            f"https://devops.aliyun.com/api/repository/{repository_id}/mirror",
            headers=headers,
            params={
                "organizationId": config['organizationId'],
                "accessToken": config['accessToken']
            },
            json=request_data
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                logger.info(f"仓库 {repository_id} 同步测试成功")
                return True
            else:
                error_msg = result.get('errorMessage', '未知错误')
                logger.error(f"仓库 {repository_id} 同步测试失败: {error_msg}")
                return False
        elif response.status_code == 401:
            logger.error("同步失败: accessToken可能无效或已过期")
            return False
        elif response.status_code == 403:
            logger.error("同步失败: 权限不足，请检查accessToken的权限")
            return False
        else:
            logger.error(f"仓库 {repository_id} 同步测试失败: HTTP {response.status_code}")
            logger.error(f"响应内容: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        logger.error("网络连接失败: 请检查网络连接")
        return False
    except requests.exceptions.Timeout:
        logger.error("请求超时: 请检查网络连接")
        return False
    except Exception as e:
        logger.error(f"同步测试时发生错误: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return False

def main():
    try:
        # 设置日志
        setup_logging(debug=True)
        logger = logging.getLogger(__name__)
        
        # 加载配置
        logger.info("=== 开始测试 ===")
        logger.info("步骤1: 加载配置...")
        config = load_config()
        if not config:
            logger.error("配置加载失败，程序退出")
            return 1
        
        # 测试获取仓库列表
        logger.info("\n步骤2: 测试获取仓库列表...")
        repositories = test_list_repositories(config)
        if not repositories:
            logger.error("获取仓库列表失败，程序退出")
            return 1
        
        # 测试同步第一个仓库
        logger.info("\n步骤3: 测试仓库同步...")
        if repositories:
            first_repo = repositories[0]
            if not test_trigger_sync(config, first_repo['id']):
                logger.error("仓库同步测试失败")
                return 1
        
        logger.info("\n=== 所有测试完成 ===")
        return 0
        
    except Exception as e:
        logger.error(f"程序执行出错: {str(e)}")
        logger.error(f"错误详情: {traceback.format_exc()}")
        return 1

if __name__ == "__main__":
    sys.exit(main()) 