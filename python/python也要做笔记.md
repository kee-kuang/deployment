***
# 内置函数

#### 排序  #sort() / sorted()

```python
# 迭代对象类型 决定 返回对象类型

# 修改原始列表
列表.sort()
# 不改变原始列表
# key 排序依据(自动迭代元素), reverse=False 升序(默认)
输出列表 = 原始列表.sorted(可迭代对象, key=None, reverse=False)

# 列表排序
NewList = sorted(OldList, reverse=False)

# 元组列表排序, 返回元组列表
TupleList = sorted(List, key=lambda Tuple: Tuple[1], reverse=False)

# 字典内元素排序, 返回元组列表, Item下标对应键值, 0为键, 1为值
TupleList = sorted(Dict.items(), key=lambda Item: Item[0], reverse=False)
Dict = dict(TupleList)

# 字典列表排序, 返回字典列表
TupleList = sorted(字典列表, key=lambda Item: Item[键], reverse=False)
```

#### 隐藏函数  #lambda

```python
# 格式
lambda 输入形参: 输出形参

# 例
# 隐藏函数格式
Lambda = lambda x,y: x+y
Sum = Lambda(0,0)

# 实际格式
def Lambda(x,y):
    return x+y
Sum = Lambda(0,0)

# 进阶/简易用法, 联合map()使用
SumList = map(lambda a,b:a+b,[1,2,3],[4,5,6])
```

#### 列表映射 #map()

```python
# 格式，返回迭代器
map(函数(形参1, 形参2, 形参3), 形参列表1, 形参列表2, 形参列表3...)

# 例1
列表 = map(lambda x:x+1,[0,1,2,3,4])
# 输出
列表 = [1,2,3,4,5]

# 例2, 数组转字符串
List = [1,2,3]
Num = ''.join(map(str,List))
# 输出
Num = '123'

# 例3，输入数组
Input = '1 2 3'
nums = list(map(int,input().strip().split()))
# 输出
nums = [1,2,3]
```

#### 并行迭代 #zip()

```python
# 基础用法
List = ['123','abc']
result_1 = zip(List)
result_2 = zip(*List) # zip('123','abc')

list(result_1) == [('123'), ('abc')]
list(result_2) == [('1', 'a'), ('2', 'b'), ('3', 'c')]
```

```python
# 进阶用法，列表推导式
```

> ```python
> # 示例
> array1 = ['1', '2', '3']
> array2 = ['4', '5', '6']
> array3 = ['7', '8', '9']
> 
> result = [x + y + z for x, y, z in zip(array1, array2, array3)]
> result = ['147', '258', '369']
> 
> result = [[x, y, z] for x, y, z in zip(array1, array2, array3)]
> result = [['1', '4', '7'], ['2', '5', '8'], ['3', '6', '9']]
> ```

#### 迭代转字符串 #join()

```python
str = 'char'.join(list)
```

#### 生成索引 #enumerate()

```python
Dict = enumerate(List)
Dict['元素'] = 索引
```

#### 生成器 #yield

#### 获取对象属性

```python
# 属性列表
list = dir(object)

# 属性值
value = getattr(object, 'key')
```

***

# 数学相关

#### 取绝对值

```python
# 格式
绝对值 = abs(int参数)
```

#### 取余数/商  #divmod()

```python
# 格式, 返回元 组
商,余数 = divmod(被除数, 除数)

# 进阶用法, 计算时间
# 年=Y,月=m,日=d,时=H,分=M,秒=S
M,S = divmod(S,60)
H,M = divmod(M,60)
d,H = divmod(H,24)
时间 = f"{d}天{H}小时{M}分{S}秒"
```

#### 无穷

```python
# 正无穷
float('inf')
float('Inf')

# 负无穷
-float('inf')
float('-inf')
```

#### 字符串相关

```python
# 查询字符串
返回下标 = 字符串.find(子字符串)
```

#### 数据类型转换

```python
# 字符转整型
num = ord(char)

# 整型转字符
char = chr(num)

# 十进制转十六进制
H = hex(D)

# 十进制转八进制
O = oct(D)

# 转十进制
num = int(other, 2/8/16)

# 字节类型（bytes）转 十六进制字符串
hex_data = byte_data.hex()
# 十六进制字符串 转 字节类型（bytes）, 两个十六进制字符代表一个字节
byte_data = bytes.fromhex(hex_data)
```

#### 字节流相关

```python
# 每1位都为0/1, 8位即256种组合
1英文字符 = 1字节 = 8比特 = 8位
1byte = 8bit
```

#### 生成字节流

```python
byte_arr = bytearray(4) # type = bytes
byte_arr = bytearray([0xFF] * 4)
```

***

# 进阶技巧

#### if/else 进阶技巧

```python
# 三目运算符格式
值1 if 条件 else 值2
```
> ```python
> # 示例, 比大小
> Min = X if X<Y else Y
> # 实际格式
> if X<Y:
>        Min = X
> else:
>        Min = Y
> ```

#### for/in 进阶技巧

```python
#1 列表生成式
列表 = [i for i in 范围 if 条件1 if 条件2]
列表 = [(x,y) for x in 范围 for y in 范围]
```
> ```python
> # 示例：0-100 内6的倍数
> List = [i for i in range(100) if i%2==0 if i%3==0]
> List = [i for i in range(100) if i%2==0 and i%3==0]
> ```

```python
#2 字典生成式
字典 = {value: index for index, value in enumerate(List)}
字典 = {index-1: value for index, value in enumerate(List)} # 列表的字典形式
```

> ```python
> # 示例：列表元素对应序数输出
> List = ['a','b','c']
> Dict = {index: value for index, value in enumerate(List)}
> Dict = {'1':'a','2':'b','3':'c'}
> ```

#### try-except-else 使用（异常处理）

```python
try:
    ### 正常执行
except:
    ### 处理异常
else:
    ### try成功执行后执行
```

#### with/as 使用（自动释放资源）

```python
# 格式
with open('文件.txt', 'r', encoding='utf-8') as f:
    print(f.read())
```

***

# 方法相关

#### 方法调用 进阶技巧

```python
# 直接执行方法
变量 = 方法()

# 先调用方法
变量 = 方法
# 执行
变量()
```

#### 方法参数

```python
# 格式
def fun(*args, **kwargs)

# 参数
*args # 不定长元组
**kwargs # 不定长字典
```

#### 装饰器

```python
# 格式
```
>  ```python
>  def 装饰器(fun):
>      def printf(*args, **kwargs): # 参数可有可无
>          print(fun())
>          return "Hello, World!"
>      return printf
>  @装饰器
>  def func():
>      return "WhoAmI?"
>  
>  print(func())
>  ```

```python
# 实际
```

> ```python
> def 装饰器(fun):
>  	print(fun())
>  	return "Hello, World!"
> 
> def func():
>  	return "WhoAmI?"
> 
> print(装饰器(func))
> ```

***

#### 静态方法

```python
class MyClass():
    def __init__(self):
        pass
	
    @staticmethod
    def MyFun(item):
        pass
```

***

# 类相关

### 类的内置方法

#### 定义实例化对象输出

```python
class student:
    id = 1
    def __init__(self):
        self.name = 'ming'
    def __repr__(self):
        return f'student id: {self.id}, student name: {self.name}'
```

***

### 类的继承

```python
class MyString(str):
    # self = str 对象

    def reverse(self):
        return MyString(self[::-1])  # 返回 MyString 类型而不是普通 str

    def upper_case(self):
        return MyString(self.upper())  # 返回 MyString 类型而不是普通 str

    def lower_case(self):
        return MyString(self.lower())  # 返回 MyString 类型而不是普通 str

    # ASCII 码加 1
    def hello(self):
        tem = ''
        for i in self:
            tem += chr(ord(i)-1)
        return MyString(tem)  # 返回 MyString 类型而不是普通 str


# 测试
s = MyString("cba")
result = s.hello().upper_case().reverse()  # 链式调用
print(result)  # 输出: "BCD"

```



***

# 内置库

## base64 库

#### 备注

```python
编码/解码的对象为二进制数据
编码/解码输出的对象为二进制数据
```

#### Base64 编码

```python
str_base64 = base64.b64encode(str.encode()).decode()
```

#### Base64 解码

```python
str = base64.b64decode(str_base64.encode()).decode()
```

***

## collections 库

#### 计数器（根据 value 排序）

```python
from collections import Counter

Dict = "abbccc"
Num = Counter(Dict)
Num = {'a':1, 'b':2, 'c':3}
```

***

## datetime 库（日期）

#### 导入

```python
# 日期格式化
form datetime import datetime
# 修改日期
form datetime import timedelta
```

#### 日期代码

```python
### 本地信息通过 locale库 配置
%y 两位数的年份表示（00-99）
%Y 四位数的年份表示（000-9999）
%m 月份（01-12）
%d 月内中的一天（0-31）
%H 24小时制小时数（0-23）
%I 12小时制小时数（01-12）
%M 分钟数（00-59）
%S 秒（00-59）
%a 本地简化星期名称
%A 本地完整星期名称
%b 本地简化的月份名称
%B 本地完整的月份名称
%c 本地相应的日期表示和时间表示
%j 年内的一天（001-366）
%p 本地A.M.或P.M.的等价符
%U 一年中的星期数（00-53）星期天为星期的开始
%w 星期（0-6），星期天为星期的开始
%W 一年中的星期数（00-53）星期一为星期的开始
%x 本地相应的日期表示
%X 本地相应的时间表示
%Z 当前时区的名称
%% %号本身
```

#### 数据类型

```python
# datetime.date = %Y-%m-%d
# datetime.datetime = %Y-%m-%d %H:%M:%S

# data = datetime.date.today()
<class 'datetime.date'> # %Y-%m-%d

# data = (datetime.date).strftime("%Y-%m-%d")
<class 'str'> # %Y-%m-%d

# data = datetime.date.today().timetuple()
<class 'time.struct_time'> # 时间数组

# data = time.strptime(datetime.date, "%Y-%m-%d")
# data = time.strptime(str, "%Y-%m-%d")
<class 'time.struct_time'> # 时间数组

# data = time.strftime("%Y-%m-%d %H:%M:%S", time.struct_time)
<class 'str'> # %Y-%m-%d %H:%M:%S

# data = time.mktime(time.struct_time)
<class 'float'> # 时间戳

# data = datetime.fromtimestamp(float)
<class 'datetime.datetime'> # %Y-%m-%d %H:%M:%S

# data = datetime.datetime.now()
<class 'datetime.datetime'>

# data = datetime.datetime.now().timestamp()
<class 'float'> # 时间戳
```

#### 当前日期

```python
from datetime import date
Today = date.today()
```

#### 格式化日期

```python
格式化日期 = datetime.strptime(初始日期, '初始日期代码')	# Today 初始日期代码:%Y-%m-%d %H:%M:%S
想要的日期格式 = 格式化日期.strftime("想要的日期代码")
```

> ```python
> 例子
> new_ime = datetime.strptime(old_time, '%B %d, %Y').strftime("%Y-%m-%d")
> ```

#### 时间戳

```python
# 日期 转 时间戳
TimeArray = Today.timetuple()
NOW = time.mktime(time.strptime(Today, "%Y-%m-%d"))
# OR
TimeStamp = time.strftime("%Y-%m-%d %H:%M:%S", TimeArray)
```

#### 修改时间

```python
# 格式
想要的日期 = datetime.strptime(初始日期, '初始日期代码')+timedelta(增减时间单位=数量)

# 增减时间单位
days #天
hours #小时
minute #分钟
second #秒
millisecond #毫秒
```

***

## dotenv 库（读取 env 文件）

#### 安装

```
pip install python-dotenv
```

#### 使用

```python
# 读取 env 文件
from dotenv import load_dotenv
load_dotenv()

# env 文件格式
变量名=变量值
```

***

## enum (枚举类)

```python
from enum import IntEnum


class Gender(IntEnum):
    male = 1
    female = 2

    def zh(self):
        gender_map = {
            'male': '男',
            'female': '女'
        }
        return gender_map[self.name]


class Robot:
    def __init__(self, gender: Gender):
        self.gender = gender

    def __repr__(self):
        return f'<name: {self.gender.name}, value: {self.gender.value}>'


robot = Robot(Gender.male)
print(robot)
print(robot.gender)
print(robot.gender.zh())
```

***

## json 库

#### 导入

```python
import json
```

#### requests 对象 转 json 对象

```python
### 不需要json库
json_data = res.json()
```

#### Python 对象 转 json 数据/字符串

```python
# separators 指定符号, a(,) 隔开键值对, b(:)隔开键值
# 默认中文转为Ascll, 不转换需添加参数 ensure_ascii=False
json_data = json.dumps(data, separators=("a","b"), ensure_ascii=False)

json_data = json.dumps({"a":1,"b":2,"c":3}, separators=("|","——"))
json_data = '{"a"——1|"b"——2|"c"——3}'
```

#### Python 对象 转 json 文件

```python
# indent 缩进数
with open("json文件", 'w', encoding="utf-8") as json_file:
    json.dump(data, json_file, ensure_ascii=False, indent=4)
```

#### json 数据/字符串 转 Python 对象

```python
data = json.loads(json_data)
```

#### json 文件 转 Python 对象

```python
with open("json文件", "r",  encoding="utf-8") as json_file:
    data = json.load(json_file)
```

***

## locale 库（地区）

#### 导入

```python
import locale
```

#### 所有可用的地区代码

```python
locale.locale_alias
```

#### 更改当前地区

```python
locale.setlocale(locale.LC_TIME, '地区代码')
```

#### 常见地区代码

```python
### 格式： 国家代码_语言代码
中国中文: 'zh_CN'
美国英语: 'en_US'
英国英语: 'en_GB'
法国法语: 'fr_FR'
德国德语: 'de_DE'
日本日语: 'ja_JP'
西班牙西语: 'es_ES'
```

***

## logging 库（日志）

#### 导入

```python
# 日志记录器
import logging
# 日志分片器
from logging.handlers import TimedRotatingFileHandler
```

#### 初始化日志记录器

```python
class logger:
    def __init__(self):
        self.logger = self.setup_logger()
        self.error_logger = self.setup_logger('error')
        if os.getenv('LOG_PATH'):
            self.app_log = os.getenv('LOG_PATH')
        else:
            self.app_log = 'storage/logs/app.log'
        if os.getenv('ERROR_LOG_PATH'):
            self.error_log = os.getenv('ERROR_LOG_PATH')
        else:
            self.app_log = 'storage/logs/error.log'

    def setup_logger(self, level='INFO'):
        # 创建日志记录器
        logger = logging.getLogger('my_logger')
        if logger.hasHandlers():
            # 如果已经有处理器，直接返回现有的 logger
            return logger
        
        logger.setLevel(logging.DEBUG)

        # 创建文件处理器和控制台处理器
        # 创建文件处理器, 二选一
        if level.upper() == 'ERROR':
            file_handler = logging.FileHandler(self.error_log)
        else:
            file_handler = logging.FileHandler(self.app_log)
        # 创建 TimedRotatingFileHandler 处理器, 自动分片
        # if level.upper() == 'ERROR':
        #     file_handler = logging.handlers.TimedRotatingFileHandler(filename='self.error_log', when='midnight', interval=1, backupCount=1)
        # else:
        #     file_handler = logging.handlers.TimedRotatingFileHandler(filename='self.app_log', when='midnight', interval=1, backupCount=1)

        console_handler = logging.StreamHandler()

        # 设置日志级别
        file_handler.setLevel(logging.INFO)
        console_handler.setLevel(logging.DEBUG)

        # 创建日志格式器
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

        # 将格式器添加到处理器
        file_handler.setFormatter(formatter)
        console_handler.setFormatter(formatter)

        # 将处理器添加到记录器
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)

        return logger

    def write_to_log(self, message, level='INFO'):
        # 记录日志
        if level.upper() == 'DEBUG':
            self.logger.debug(message)
        elif level.upper() == 'INFO':
            self.logger.info(message)
        elif level.upper() == 'WARNING':
            self.logger.warning(message)
        elif level.upper() == 'ERROR':
            self.logger.error(message)
        elif level.upper() == 'CRITICAL':
            self.logger.critical(message)
        else:
            self.logger.debug('日志记录器传入参数错误')

    def write_to_error_log(self, message):
        self.logger.error(message)

    def close(self):
        # 移除所有的处理器
        for handler in self.logger.handlers[:]:
            self.logger.removeHandler(handler)

        for handler in self.error_logger.handlers[:]:
            self.error_logger.removeHandler(handler)
```

#### 使用

```python
# 示例
logger = logger()
logger.write_to_log("这是要写入日志文件的DEBUG消息", 'DEBUG')
logger.write_to_log("这是要写入日志文件的消息", 'INFO')
logger.write_to_log("这是要写入日志文件的WARNING消息", 'WARNING')
logger.write_to_error_log("这是要写入日志文件的ERROR消息")
```

#### 日志级别

```python
DEBUG：最详细的日志级别，主要用于调试目的，记录详细的程序执行信息。
INFO：一般信息级别，用于记录程序正常运行时的重要信息。
WARNING：警告级别，表示出现了可能会引起问题但不严重到需要中止程序运行的情况。
ERROR：错误级别，表示出现了需要处理的错误，但程序仍然可以继续运行。
CRITICAL：严重错误级别，表示出现了严重错误，程序可能无法继续运行。
```

***

## os 库

#### 用途

```python
系统操作
```

#### 使用方法

```python
os.函数(变量)
```

#### 调用 Shell

```python
返回内容 = os.popen(命令)
```

#### 获取文件列表

```python
# 获取当前文件名
## __file__为当前文件绝对路径
os.path.basename(__file__)

# 获取路径下文件&文件夹
文件&文件夹列表 = os.listdir(path)
```

#### 获取路径

```python
# 获取当前工作路径
path = os.getcwd()

# 拼接目录和文件名
file_path = os.path.join(directory, file_name)

# 获取最大公共路径数
num = os.path.commonprefix(List)

# 获取文件所在文件夹
directory = os.path.dirname(file_path)
```

#### 更改 python 工作路径

```python
os.chdir(path)
```

#### 创建文件夹

```python
# 检测文件夹不存在时创建
def create_directory_if_not_exists(directory):
    if not os.path.exists(directory):
        # 文件夹存在时报错
        os.makedirs(directory)
create_directory_if_not_exists(directory)

# 不检测文件夹是否存在
os.makedirs(directory, exist_ok=True)
```

#### 重命名文件/文件夹

```python
### 方法1
os.renames(old, new)
### 方法2
os.replace(old, new)
```

#### 删除文件/文件夹

```python
### 删除文件
os.remove(path)
### 删除空文件夹（文件夹非空报错）
os.rmdir(path)
```

#### 获取系统文件夹

```python
path_ProgrmData = os.getenv("LOCALAPPDATA")

# 系统文件夹列表
'ALLUSERSPROFILE': 'C:\\ProgramData(所有用户共享数据的位置)'
'APPDATA': 'C:\\Users\\admin\\AppData\\Roaming(存储应用程序数据的根目录)'
'COMMONPROGRAMFILES': 'C:\\Program Files\\Common Files(存储多个应用程序共享的文件)'
'COMMONPROGRAMFILES(X86)': 'C:\\Program Files (x86)\\Common Files(存储多个应用程序共享的文件)'
'COMMONPROGRAMW6432': 'C:\\Program Files\\Common Files'
'COMPUTERNAME': '计算机名称'
'COMSPEC': 'C:\\Windows\\system32\\cmd.exe'
'DRIVERDATA': 'C:\\Windows\\System32\\Drivers\\DriverData'
'HOMEDRIVE': 'C:'
'HOMEPATH': '\\Users\\admin'
'IDEA_INITIAL_DIRECTORY': 'C:\\Users\\admin\\Desktop'
'LOCALAPPDATA': 'C:\\Users\\admin\\AppData\\Local'
'LOGONSERVER': '\\\\DESKTOP-0824AOF'
'MOZ_PLUGIN_PATH': 'C:\\Program Files (x86)\\Foxit Software\\Foxit Reader\\plugins\\'
'NUMBER_OF_PROCESSORS': '4'
'ONEDRIVE': 'C:\\Users\\admin\\OneDrive'
'ONEDRIVECONSUMER': 'C:\\Users\\admin\\OneDrive'
'OS': 'Windows_NT'
'PROCESSOR_ARCHITECTURE': 'AMD64'
'PROCESSOR_IDENTIFIER': 'Intel64 Family 6 Model 61 Stepping 4, GenuineIntel'
'PROCESSOR_LEVEL': '处理器主版本号'
'PROCESSOR_REVISION': '处理器信息'
'PROGRAMDATA': 'C:\\ProgramData'
'PROGRAMFILES': 'C:\\Program Files'
'PROGRAMFILES(X86)': 'C:\\Program Files (x86)'
'PROGRAMW6432': 'C:\\Program Files'
'PSMODULEPATH': 'C:\\Program Files\\WindowsPowerShell\\Modules;C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules'
'PUBLIC': 'C:\\Users\\Public'
'SYSTEMDRIVE': 'C:'
'SYSTEMROOT': 'C:\\Windows'
'TEMP': 'C:\\Users\\admin\\AppData\\Local\\Temp'
'TMP': 'C:\\Users\\admin\\AppData\\Local\\Temp'
'USERDOMAIN': 'DESKTOP-0824AOF'
'USERDOMAIN_ROAMINGPROFILE': 'DESKTOP-0824AOF'
'USERNAME': 'admin'
'USERPROFILE': 'C:\\Users\\admin'
'VS140COMNTOOLS': 'D:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\Common7\\Tools\\'
'WINDIR': 'C:\\Windows'
```

#### 获取环境变量

```python
# 获取系统变量
api_key=os.getenv("变量名")
```

***

## random 库（随机数）

#### 随机弹出列表元素

```python
from random import choice

list = [1, 2, 3, 4, 5]
random_element = choice(list)
```

***

## re 库（正则匹配）

#### 正则

```python
compile(正则条件)
用法:正则条件 = re.compile('正则表达式')
url正则：re_url = re.compile(r'href="[a-zA-z]+://[^\s]*"')
```

#### 匹配

```python
match = 正则条件.search(text).group()	#一次性匹配,group()为内容
```

#### 替换

```python
str_2 = 正则条件.sub('字符串',str_1)
```

#### 正则条件

```python
### 空白行
^\s+
```

***

### 端口号

#### 代理端口

```python
clash：7890
安易加速器：10807
```

#### 服务器默认端口

```python
Apache：80
Mysql：3306
Mongodb：27017
```

#### 常用服务端口

```python
SSH：22
HTTP：80
HTTPS：443
远程桌面：3389
```

***

## requests 库

```python
## get不需要额外参数
res = requests.get(url)
## post需要提交post表单，内容为 字典/字符串
res = requests.post(url, data=data)
```

#### 关闭连接

```python
res.close()
```

#### 移除 SSL 认证

```python
res = res.get(url,verify=False)
```

> ```python
> ### 不显示警告
> import urllib3
> urllib3.disable_warnings()
> ```

#### 保存文件

```python
文件内容 = res.content
```

#### 请求参数

```python
# headers
res = res.get(headers=headers)
headers = {'Connection':'close'}	#短连接
headers = {'Connection':'keep-alive'}	#长连接
headers = {'referer':'url'}	#来源地址

# data
res = res.post(data=data)

# body
res = res.post(json=body)
```

#### 设置代理 (clash 的代理默认为 "http://127.0.0.1:7890")

```python
proxies = {"http" : "http://127.0.0.1:7890", "https" : "http://127.0.0.1:7890"}
```

#### 获取基本属性

```python
### 状态码
code = res.status_code

# 请求头
req_headers = res.request.headers
# 响应头
res_headers = res.headers
```

#### 获取本地 ip

```python
socket 库构造UDP包
```

> ``` python
> import socket
> s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
> s.connect(('8.8.8.8', 80))
> ip = s.getsockname()[0]
> ```

#### 获取出口 ip

```python
搜狗接口：https://www.sogou.com/websearch/features/getTime.jsp
```

> ```python
> url = 'https://www.sogou.com/websearch/features/getTime.jsp'
> ip = requests.get(url).json()['ip']
> ```

#### 中文乱码解决方法

```python
res.encoding = "utf-8"
res = res.text
```

#### ISO-8859-1 乱码解决方法

```python
res = res.text.encode("ISO-8859-1").decode("utf-8")

# 其他方法, 未验证
res.encoding = res.apparent_encoding
```

#### URL 编码/解码

```python
import urllib
### 解码
字符串 = urllib.parse.unquote("URL字符串")
### 编码
URL字符串 = urllib.parse.quote("字符串")
```

***

## threading 库（多线程）

```python
import threading

# 自定义 线程队列
def Threads(Fun: function, # 多线程目标函数
			TagList: list, # 多线程目标
			Args=None: tuple # 可选参数元组):
		# 结果队列
	results_queue = queue.Queue()

	# 创建并启动线程
	threads = []
    
	# for Tem in range(Count):
	for Tag in TagList:
		if Args:
			thread = threading.Thread(target=Fun, args=(Tag, Args, results_queue))
		else:
			thread = threading.Thread(target=Fun, args=(Tag, results_queue))
		threads.append(thread)
		thread.start()

	# 等待所有线程完成
	for thread in threads:
		thread.join()

    # 结果列表
    results_list = []

    # 获取所有线程的结果
    while not results_queue.empty():
        result = results_queue.get()
        if result is not None:
            results_list.append(result)

    return results_list

def task(Tag, # 多线程目标
         Args=None: tuple # 可选参数元组
		results_queue: list):

    try:
        results_queue.put(Tag)  # 将结果放入队列
    except Exception as e:
        results_queue.put(None)  # 如果出错也放入 None

def main():
    # 调用
    # Count = 10 # 多线程目标
    List = [1,2,3...] # 多线程目标
    Args = (data1,data2,data3...) # 其他参数元组
    # results = Treads(task, Count, Args)
    results = Threads(task, List, Args)
```

***



***

## time 库（时间）

#### 数据类型

```python
# datetime.date = %Y-%m-%d
# datetime.datetime = %Y-%m-%d %H:%M:%S

# data = datetime.date.today()
<class 'datetime.date'> # %Y-%m-%d

# data = (datetime.date).strftime("%Y-%m-%d")
<class 'str'> # %Y-%m-%d

# data = datetime.date.today().timetuple()
<class 'time.struct_time'> # 时间数组

# data = time.strptime(datetime.date, "%Y-%m-%d")
# data = time.strptime(str, "%Y-%m-%d")
<class 'time.struct_time'> # 时间数组

# data = time.strftime("%Y-%m-%d %H:%M:%S", time.struct_time)
<class 'str'> # %Y-%m-%d %H:%M:%S

# data = time.mktime(time.struct_time)
<class 'float'> # 时间戳

# data = datetime.fromtimestamp(float)
<class 'datetime.datetime'> # %Y-%m-%d %H:%M:%S
```

#### 时间戳 转 时间

```python
# 时间戳 TimeStamp
# 时间数组 TimeArray
#转换为时间数组
时间数组 = time.localtime(时间戳)
#转换为时间
时间 = time.strftime("%Y-%m-%d %H:%M:%S", 时间数组)
```

#### 时间 转 时间戳

```python
#转换为时间数组
时间数组 = time.strptime(时间, "%Y-%m-%d %H:%M:%S")
#转换为时间戳
时间戳 = time.mktime(时间数组)
```

#### 使用

```python
# 暂停
time.sleep(秒数)

# 获取当前时间戳
TimeStamp = time.time()
```

***

## traceback 库（异常信息）

#### 使用

```python
try:
    ### 正常执行
except:
    ### 输出异常
    print(traceback.print_exc())
else:
    ### try成功执行后执行
```

#### 异常类别

```python
except Exception:
    ### 继承自 Exception 的异常
except SystemExit:
    ### 系统退出异常,调用 sys.exit() 时引发
except KeyboardInterrupt:
    ### 键盘中断异常（通常是 Ctrl+C）
except BaseException:
    ### 所有异常
```

#### 输出详细报错

```python
try:
    ### 正常执行
except:
    ### 输出异常
    print(traceback.format_exc())
```

***

## urllib 库（编码转换）

#### 编码

```python
import urllib.parse

url = "https://你好.mp4"

encoded_url = urllib.parse.quote(url, safe=':/?&=')
print("转码后的 URL:")
print(encoded_url)
```

#### 解码

```python
import urllib.parse

url = "https://%E4%BD%A0%E5%A5%BD.mp4"

decoded_url = urllib.parse.unquote(url)
print("\n解码后的 URL:")
print(decoded_url)
```

***

## 字典操作

#### 字典属性

```python
for key,value in dict.items()	#键值对
for key in dict.key()	#键
for value in dict.value()	#值
```

***

## 字符串操作

#### 判断字符串属性

```python
# 检测字符串是否由字母和数字组成
str.isalnum()
```

#### 位置

```python
左l，右r
```

#### 替换字字段

```python
str.replace('原字段','替换后字段')
### 替换不间断空白符 '\xa0' 等
text = text.replace(u'\xa0', u'').encode().decode()
```

#### 切片返回列表

```python
str.split('分割定位字符')
```

#### 去除首尾指定字符（默认去除空字符）

```python
str.lstrip('字符')
str.rstrip('字符')
str.strip('字符')
```

#### 字符串大小写

```python
# 转小写
str = str.lower()

# 转大写
str = str.upper()

# 大小写互转
str = str.swapcase()
```

***

# 第三方库

## argparse 库（cmd 调用添加参数）

#### 创建解析器(对象)

```python
parser = argparse.ArgumentParser()
```

#### 添加参数

```python
parser.add_argument(
        '--file_id', dest='file_id', required=True,
        help='请键入file_id'
    )
```

#### 解析参数

```python
args = parser.parse_args()
```

#### 参数列表

```python
name or flags ### 选项字符串的名字或者列表, 例如 foo 或者 -f, --foo
action ### 命令行遇到参数时的动作. 默认值是 store; store_const, 表示赋值为const; append，将遇到的值存储成列表; append_const, 将参数规范中定义的一个值保存到一个列表; count, 存储遇到的次数, 也可继承 argparse.Action 自定义参数解析
nargs ### 应该读取的命令行参数个数，可为数字或 ? 号，不指定值时对于 Positional argument 使用 default，对 Optional argument 使用 const; * 号表示 0 或多个参数； + 号表示 1 或多个参数
const ## action 和 nargs 所需要的常量值
default ### 不指定参数时的默认值
type ### 命令行参数应该被转换成的类型
choices ### 参数可允许的值的一个容器
required ### 可选参数是否可以省略 (仅针对可选参数)
help ### 参数的帮助信息, 当指定为 argparse.SUPPRESS 时表示不显示该参数的帮助信息
metavar ### 在 usage 说明中的参数名称, 对于必选参数默认就是参数名称, 对于可选参数默认是全大写的参数名称
dest ### 解析后的参数名称, 默认情况下, 对于可选参数选取最长的名称, 中划线转换为下划线
```

***

## bs4 库 BeautifulSoup 模块

#### 用途
```python
html页面解析
```

#### 导入
```python
from bs4 import BeautifulSoup
```

#### 使用方法
```python
对象.函数（）
```

#### 构建对象

```python
html = res.text.encode()
> 或
html = res.content
```
> ```python
> bs = BeautifulSoup(html)
> > 或
> bs = BeautifulSoup(html,'lxml')
> ```

#### 树结构

```python
对象.prettify()
```

#### 获取标签

```python
### 获取标签名
tag = 对象.name
### 获取其他标签字典
tags = 对象.attrs
```

#### 获取内容

```python
content = 对象.text
### 子节点
content = 对象.content
content = 对象.contents[序号]
### 父节点
content = 对象.parent
content = 对象.parents
### 兄弟节点
content = 对象.next_sibling
```

#### find 方法

```python
### 根据标签查找
find('标签',class_='',其他标签)
findAll('标签',class_='',其他标签)
### 根据内容查找
find(text="内容").parent
### 根据内容正则查找
find(text=re.compile('正则表达式')).parent
```
```python
### 设置 recursive 属性
```
> ```python
> ## True 找子孙节点，False 只找子节点
> findAll('标签',recursive=True/False)
> ```
```python
### 设置 limit 属性
```
> ```python
> ## limit 限制获取数量
> findAll('标签',limit=数量)
> ```

#### 去除 DeprecationWarning 告警

```python
import warnings
warnings.filterwarnings("ignore",category=DeprecationWarning)
```

***

## DrissionPage

#### 导入

```python
from DrissionPage import ChromiumPage
```

***

## fake_useragent 库（随机 UA 头）

#### 使用

```python
from fake_useragent import UserAgent

ua = UserAgent()
headers = {'User-Agent':ua.random}
```

***

## ipaddress 库

#### IP

```python
# 检测ip版本
ip版本 = ipaddress.ip_address('ip').version

#检测是否为私有地址
结果 = ipaddress.ip_address('ip').is_private
```

#### IP 段

```python
# ip段格式
ip地址/网络前缀长度

# 计算ip数量
count = ipaddress.ip_network('ip段').num_addresses

# 返回ip列表
iplist = ipaddress.ip_network('ip段').hosts()

# 计算掩码和反掩码
子网掩码 = ipaddress.ip_network('ip段',strict=False).netmask
子网反掩码 = ipaddress.ip_network('ip段',strict=False).hostmask

# 获取网络号
网络号 = ipaddress.ip_network('ip段',strict=False).network_address
网络号 = ipaddress.ip_interface('ip段').network

# 获取广播地址
广播地址 = ipaddress.ip_network('ip段',strict=False).broadcast_address

#检测是否为私有地址
结果 = ipaddress.ip_network('ip段').is_private
```

***

## lxml 库

#### 使用方法

```python
from lxml import etree
```

#### 创建对象

```python
tree = etree.HTML(res.text)
```

#### 根据 xpath 查找

```python
content = tree.xpath("完整xpath信息")
```

***

## paramiko 库（SSH）

#### SSH 连接

```python
# 建立sshclient对象
ssh = paramiko.SSHClient()

# 允许将信任的主机自动加入到host_allow列表，此处须放在connect前
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

# 调用connect，建立连接
ssh.connect(hostname='IP', port=22, username='super', password='super')

# 执行命令
stdin, stdout, stderr = ssh.exec_command('ls')

# stdout为结果，stderr为错误
print(stdout.read().decode())

# 关闭连接
ssh.close()
```

***

## Playwright

#### 导入

```python

```

***

## Pyinstaller 库（封装 exe）

#### 参数说明

```python
# 封装为单独文件
-F

# 不显示CMD窗口（只对Windows有效）
-w

# 添加图标
-i 图标文件
```

***

## selenium 库

#### 环境，两者版本需一致

> ```python
> Chrome下载地址
> https://www.google.com/chrome/
> ```
>
> ```python
> Chromedriver下载地址,需解压到python安装目录下
> https://googlechromelabs.github.io/chrome-for-testing/	#stable
> ```
>
> ```python
> 浏览器驱动常用命名：driver或browser
> ```

#### 导入

```python
from selenium import webdriver	#浏览器驱动，必需
from selenium.webdriver.common.by import By	#元素定位
from selenium.webdriver.support.wait import WebDriverWait	#显性等待
```

#### 使用流程

```python
from selenium import webdriver	#导入库
options = webdriver.ChromeOptions()	#创建配置对象
driver = webdriver.Chrome(options=options)	#实例化浏览器
driver.get('url')	#打开网页
```

#### 基本操作

```python
driver = webdriver.Chrome()	#浏览器驱动
driver.get('url')	#打开网页
driver.page_source	#获取当前网页源代码
driver.current_url	#获取当前标签页的url
driver.screen_shot(img_name)	#页面截图
driver.forward()	#页面前进
driver.back()	#页面后退
driver.close()	#关闭当前标签页，如果只有一个标签页则关闭浏览器
driver.quit()	#关闭浏览器
```

#### 去掉开头警告

```python
import warnings
warnings.simplefilter('ignore', ResourceWarning)
```

#### 配置操作

```python
options = webdriver.ChromeOptions()	#创建配置对象
options.配置选项(参数信息)
```

> ```python
> ### 配置选项列表
> add_argument	#常用
> add_experimental_option
> ```

```python
driver = webdriver.Chrome(options=options)	#实例化浏览器
```

#### 设置浏览器路径

```python
# 设置ChromeDriver路径
from selenium.webdriver.chrome.service import Service

Path = 'chrome path'
service = Service(executable_path=Path)
driver = webdriver.Chrome(service=service,options=options)
```

#### 设置窗口

```python
driver.set_window_size(长,宽)	#设置窗口大小
driver.maximize_window()	#全屏窗口
```

> ```python
> ### 无窗口模式
> from selenium import webdriver
> options = webdriver.ChromeOptions()
> options.add_argument("--headless=old")	#设置无界面模式
> ```

#### 参数

```python
## options.add_argument(参数信息)
--incognito #无痕模式
--start-maximized #启动时最大化
--headless #无界面模式
--no-referrers #不发送 Http-Referer 头
--user-agent #使用给定的 User-Agent 字符串
–disable-images #禁用图像
--disable-javascript #禁用JavaScript
--omnibox-popup-count="num" #将网址列弹出的提示选单数量改为num个
--process-per-tab #每个分页使用单独进程
--process-per-site #每个站点使用单独进程
--in-process-plugins #插件不启用单独进程
--disable-gpu #禁用GPU
--disable-infobars # 禁用浏览器正在被自动化程序控制的提示
```

```python
## options.add_experimental_option(参数信息)
```

#### 无窗口模式

```python
# 设置无界面模式
from selenium import webdriver
options = webdriver.ChromeOptions()
options.add_argument('--headless')  # 有白框
options.add_argument("--headless=old")  # 正常

# 初始化 ChromeDriver
driver = webdriver.Chrome(options=options)
```

#### 捕获日志

```python
# 配置caps
caps = {
    'browserName': 'chrome',
    'goog:loggingPrefs': {'performance': 'ALL'},  # 记录性能日志
}

# 将 caps 添加到 options 中
for key, value in caps.items():
    options.set_capability(key, value)

# 初始化 ChromeDriver
driver = webdriver.Chrome(options=options)

# 获取性能日志
logs = driver.get_log("performance")
for item in logs:
    # print(f'log：{item}')
    log = json.loads(item["message"])["message"]
    print(log)
    if "Network.response" in log["method"] or "Network.request" in log["method"] or "Network.webSocket" in log["method"]:
        print(log)
```

```python
# 日志种类
'browser'：捕获浏览器控制台日志输出的内容，包括 console.log、console.error 等 JavaScript 控制台输出。
适用于捕获页面上的 JavaScript 错误或自定义日志信息。

'driver'：捕获与 WebDriver 驱动相关的日志信息。包含 WebDriver 自身的调试信息和执行状态。
适用于调试 WebDriver 的运行时行为。

'client'：捕获 WebDriver 客户端的日志信息。通常用于调试 WebDriver 客户端与服务器之间的通信。
包含与 WebDriver 服务器的 HTTP 请求和响应。

'server'：捕获 WebDriver 服务器的日志信息。主要用于查看 WebDriver 服务端的日志，例如使用 RemoteWebDriver 时。
包含服务器端处理 WebDriver 请求的详细信息。

'performance'：
捕获浏览器的性能日志。包括页面加载过程中的网络请求、时间线数据等。
适用于性能分析、监控网络请求和响应等。

'profiler'：捕获性能分析日志。主要用于收集性能分析工具生成的日志数据。
适用于深度性能分析和调优。
```

#### 设置参数隐藏特征

```python
options.add_experimental_option('useAutomationExtension', False)	#去掉开发者警告
options.add_experimental_option('excludeSwitches', ['enable-automation'])	#隐藏特征
options.add_argument("--disable-blink-features")	#隐藏特征
options.add_argument("--disable-blink-features=AutomationControlled")	#隐藏特征
options.add_argument('--disable-infobars') # 禁用浏览器正在被自动化程序控制的提示
                     
driver = webdriver.Chrome(options=options)	#浏览器驱动
```

#### 设置请求头

```python
options.add_argument('--proxy-server=http://ip:端口')	#配置代理
options.add_argument('--user-agent={}'.format(UA头))	#配置User-Agent
```

#### Cookie 信息

```python
driver.get_cookies()	#获取 Cookie json 数据
```

> ```python
> ### 保存为本地Cookie
> import pickle
> pickle.dump(Cookie数据, open('Cookies.pkl', 'wb'))
> 
> ### 加载Cookie
> Cookies = pickle.load(open('Cookies.pkl', 'rb'))
> for Cookie in Cookies:
>     Cookie_dict = {
>         'domain': '.域名',	#'.'为开头，必须要有该字段，否则就是假登录
>         'name': Cookie.get('name'),
>         'value': Cookie.get('value')
>     }
> driver.add_cookie(Cookie_dict)
> ```

#### 执行 cdp 隐藏特征（只在当前页面生效）

```cmd
需已安装NodeJS和科学上网
npx extract-stealth-evasions	#cmd执行命令
生成文件"stealth.min.js"
```

> ```python
> driver = webdriver.Chrome()	#浏览器驱动
> f = open('stealth.min.js','r')
> js = f.read()
> ### 关键代码
> driver.execute_cdp_cmd(
>  cmd_args={'source': js},
>  cmd="Page.addScriptToEvaluateOnNewDocument",
> )
> driver.get(url)
> ```

#### WebElement 对象

```python
# 实例化 WebElement对象
Element = driver.find_element(By.XPATH,'xpath信息')

# 方法
Element.text # 获取文本
element.tag_name # 获取 Tag Name
Element.get_attribute("元素名") # 获取元素, 例如 class/src
Element.page_source # 获取页面源码
```

#### 定位单一元素（定位多元素列表为 find_element<font color='red'>s</font>）

> ```python
> # 定位文本, 两种方法
> driver.find_element(By.XPATH, "//*[contains(text(),'文本信息')]")
> driver.find_element(By.XPATH,"//标签[text()='元素']")
> ```
>
> ```python
> driver.find_element(By.CSS_SELECTOR,'css_selector信息')
> ```
>
> ```python
> # Xpath 定位
> driver.find_element(By.XPATH,'xpath信息') # xpath为数组时用'.'分隔
> driver.find_element(By.XPATH,"//标签[@元素名='元素']")
> ```
>
> ```python
> driver.find_element(By.ID，'ID信息')
> ```
>
> ```python
> # Tag 定位
> driver.find_element(By.TAG_NAME, 'Tag Name')
> ```
>
> ```python
> # class name 定位
> driver.find_element(By.class_name,'class名')
> ```
>
> ```python
> driver.find_element(By.PARTIAL_LINK_TEXT)
> ```
>
> ```python
> driver.find_element(By.LINK_TEXT)
> ```
>
> ```python
> driver.find_element(By.name)
> ```
>
> ```python
> # 定位所有
> elements = driver.find_elements(By.XPATH, "//*")
> ```
>
> ```python
> # 定位子元素
> Element = driver.find_element(By.XPATH,"//*")
> element = Element.find_element(By.XPATH,".//xpath信息")
> ```

#### Xpath 构造

```python
//class[@元素类型1='元素值1' and @元素类型2='元素值2']
//父元素Xpath[n]/子元素Xpath[n]
//父元素Xpath//子元素Xpath # //表示多层级
```

#### 窗口操作

```python
# 获取打开的多个窗口句柄
windows = driver.window_handles
# 切换到第一个窗口
driver.switch_to.window(windows[-1])

# 切换至指定 iframe
iframe_element = driver.find_element(By.XPATH, "xpath路径/iframe")
driver.switch_to.frame(iframe_element)

# 切换至默认 iframe
driver.switch_to.default_content()
```

#### 时间设置

```python
# 页面加载等待(默认300s)
driver.set_page_load_timeout(时长)

# 元素定位等待(默认0s)
driver.implicitly_wait(时长)

# 页面加载等待
timeout = 30
driver.set_page_load_timeout(timeout)
driver.implicitly_wait(timeout)
```

#### 模拟操作

```python
# 导入定位模块
from selenium.webdriver.common.by import By

# 模拟点击
driver.find_element(By.CLASS_NAME, "提交按钮class“).click()

# 模拟输入
driver.find_element(By.XPATH, "xpath路径").send_keys(输入code)

# 模拟清空
driver.find_element(By.XPATH, "xpath路径").clear()

# 模拟删除
driver.find_element(By.XPATH, "xpath路径").send_keys(Keys.BACKSPACE)

# 模拟鼠标悬停
from selenium.webdriver import ActionChains
above = driver.find_element(By.XPATH, "xpath路径")
# 对定位的元素执行鼠标悬停操作, perform 为提交所有 ActionChains 类中存储的行为
ActionChains(driver).move_to_element(above).perform()
# 鼠标横向滑动
ActionChains(driver).move_by_offset(xoffset=(x像素), yoffset=0).perform()
# 释放鼠标
ActionChains(driver).release().perform()

# 截图
captcha_element = driver.find_element(By.CLASS_NAME, "图片class") # 定位
captcha_element.screenshot("captcha.png") # 截图并保存s

# 切换至指定 iframe
iframe_element = driver.find_element(By.XPATH, "xpath路径/iframe")
driver.switch_to.frame(iframe_element)

# 切换至默认 iframe
driver.switch_to.default_content()
```

#### 手动调试（监控浏览器）

```python
# CMD 打开已有浏览器
chrome.exe --remote-debugging-port=9222 --user-data-dir="E:\selenium\ChromeProfile"

# selenium 调试
chrome_options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")
```

#### 扩展（有时间尝试使用）

```python
# 抓包
selenium-wire

# 导入 seleniumwire
from seleniumwire import webdriver
```

***

## tkinter 库（GUI 编程）

#### GUI 编程

```
常用 Python GUI 库：5tkinter、wxPython
```

#### 导入

```python
import tkinter as tk
# from tkinter import *
```

#### 使用

```python
# 创建窗口对象
```

***

## torch 库

#### 安装gpu版本

```bash
# cuda version = 11.8
pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118

# 备注
cp=>python版本 cu=>cuda版本

# 库列表
https://download.pytorch.org/whl/cu124

# 命令行安装
https://pytorch.org

# cuda 列表
https://developer.nvidia.com/cuda-toolkit-archive
```

***

## WebDriverManager 库（ChromeDriver 自动管理）

#### 导入

```python
# 导入
from webdriver_manager.chrome import ChromeDriverManager

# 初始化ChromeDriver
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
```

***

## wheel 库（py 文件封装成 whl 库文件）

#### 需要的库

```cmd
pip install wheel
pip install setuptools
```

#### 配置

```python
配置setup.py
```
> ```python
> ### 注意：包名！=库名，安装/卸载使用包名，引用使用库名 #
> ### 包名可与库名一致 #
> from setuptools import setup
> setup(
>     name='whl包名',	#包名不能为中文
>     version='1.0',	#版本号
>     description='这是一段描述',	#描述
>     author='',	#作者
>     author_email='',	#作者邮箱
>     packages=['文件夹'],	#需要封装的包,最终的库名
> 	)
> ```

```cmd
setup.py所在目录下打开cmd
```
> ```cmd
> python setup.py bdist_wheel
> ```

```cmd
所生成whl文件位于dist文件夹
pip安装whl文件
```
> ```cmd
> pip install whl文件	#第一次安装包
> pip install --upgrade whl文件	#后续更新包
> ```

```python
使用
```
> ```python
> from 原文件夹名 import *
> import 原文件夹名
> ```
```python
删除包
```
> ```python
> pip uninstall 包名
> ```

***

## 表格制作
### xlwt 库（表格制作）

#### 使用

```python
import xlwt
```

#### 初始化

```python
book = xlwt.Workbook(encoding='utf-8')
sheet = book.add_sheet(u'表1', cell_overwrite_ok=True)
```

#### 插入数据

```python
sheet.write(行, 列, 数据)
```

#### 保存文件

```python
book.save('表格.xlsx')
```

***

### openpyxl 库（表格制作）

#### 使用

```python
import openpyxl
from openpyxl import Workbook
```

#### 初始化

```python
try:
	# 加载已有表格
	wb = openpyxl.load_workbook('表格.xlsx')
	sheet = wb['Sheet1']
except:
    # 生成新表格
	wb = Workbook()
	sheet = wb.active
	sheet.title = 'Sheet1'
```

#### 插入数据

```python
# 单行插入
sheet.append(['列1','列2','列3'])

# 多列写入
for i in range(len(data)):
    # 获取每行数据
	row_data = [data['列名'][i] for '列名' in '列名s']
	sheet.append(row_data)
```

#### 清除数据

```python
# 使用
sheet.delete_rows(开始行号, 清除行数)
```

#### 格式

```python
# 调整列宽
ws.column_dimensions['列字母'].width = 20.0
 
# 调整行高
ws.row_dimensions[行号].height = 40

# 列名加粗
bold_font = Font(bold=True)
for col in range(1, len(cols) + 1):
	ws.cell(row=1, column=col).font = bold_font
```

#### 保存文件

```python
wb.save('表格.xlsx')
```

***

### csv 库（csv 表格）

***

### pandas 库（数据处理，简单）

#### 导入

```python
import pandas as pd
```

#### 一般属性

```python
# 数据
data

# DataFrame对象
df

# 生成writer, 追加模式(文件需存在), 覆盖已有工作表
writer = pd.ExcelWriter(xlsx, engine='openpyxl', mode='a', if_sheet_exists='replace')

# 判断空值
pd.isna(data)
```

#### 设置

```python
# 设置自适应列宽
```
> ```python
> xlsx = 'file.xlsx'
> with pd.ExcelWriter(xlsx, engine='openpyxl') as writer:
>     dataframe.to_excel(excel_writer=writer, sheet_name=sheetName, index=False)
>     worksheet = writer.sheets[sheetName]
>     # 单元格数据转字符串
>     df_str = dataframe.astype(str)
>     # 计算每列最大字符串长度
>     max_lengths = df_str.map(len).max()
>     max_lengths_with_columns = max_lengths.combine(dataframe.columns.to_series().map(len), max)
>     # 设置列宽为最大字符串长度加5
>     column_widths = (max_lengths_with_columns+5).tolist()
>     # 设置列宽
>     for i, width in enumerate(column_widths):
>     column_letter = chr(65 + i)  # 65 是 'A' 的 ASCII 码
>     worksheet.column_dimensions[column_letter].width = width
> ```

#### pd 对象合并

```python
new_data = {'a':'1', 'b':'2', 'c':'3'}
# 旧版本pandas
df = df.append(new_data, ignore_index=True)
# 新版本pandas
df = pd.concat([df, pd.DataFrame([new_data])], ignore_index=True)
```

#### 读取

```python
# 读取第一个sheet
df = pd.read_excel('表格.xlsx', engine="openpyxl")
df = pd.read_csv('file.csv', encoding='utf-8')

# 单个sheet
df = pd.read_excel('sheet_name.xlsx', sheet_name=0)
df = pd.read_excel('sheet_name.xlsx', sheet_name='表2')
# 多个sheet, 返回字典
df_dict = pd.read_excel('sheet_name.xlsx', sheet_name=[0, '表2'])
# 全部sheet, 返回字典
df_dict = pd.read_excel('sheet_name.xlsx', sheet_name=None)

##### 

# 读取一行
data = df.loc[行号,:]

# 读取一列
data = df.loc[:,"列标签"]
data = df["列标签"]

# 读取列标题
列标题 = df.columns
```

#### 写入单个 sheet

```python
data = {'列1':['数据1','数据2','数据3']}

# 数据转为DataFrame对象
df = pd.DataFrame(data)

# 写入CSV文件，index=False表示不保留行索引
df.to_csv('data.csv', index=False)
```

#### 写入多个 sheet

```python
data = {"列1":[1, 2, 3], "列2":[4, 5, 6], "列3":[7, 8, 9]}
df = pd.DataFrame(data)

# 生成writer
with pd.ExcelWriter('data.xlsx', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name="sheet1")
    df.to_excel(writer, sheet_name="sheet2")
    df.to_excel(writer, sheet_name="sheet3")
```

#### 转换

```python
# 使用 rename() 方法改变列名
df_renamed = df.rename(columns={'old_key1': 'new_key1', 'old_key2': 'new_key2', 'old_key3': 'new_key3'})

# 将 DataFrame 转换为字典，以列名为键
dict_from_df = df.to_dict(orient='columns')
data_dict = df.to_dict(orient='records') # csv格式

# 将 DataFrame 转换为字典，以列名为键
dict_from_df = df.to_dict(orient='index')

# 将 字典列表 转换为 DataFrame
df_dict_list = [{'name':'a', 'age':'1'}, {'name':'b', 'age':'2'}]
df = pd.DataFrame(df_dict_list)
```

***

## 持久化模块

### pickle 库

#### pkl 文件处理

```python
# 导入
import pickle

# 读取pkl文件
f = open('test.pkl','rb')
data = pickle.load(f)
```

### numpy 库

#### pkl 文件处理

```python
# 导入
import numpy as np

# 读取pkl文件
path = 'test.pkl'
data = np.load(path,allow_pickle=True)
```

***

## 绘图

### matplotlib 库

#### plt 模块

```python
# 导入
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm

# 设置
# 设置中文字体方法1，SimSun为宋体
plt.rcParams['font.sans-serif'] = ['SimSun']
# 设置中文字体方法2
font_prop = fm.FontProperties(fname='C:/Windows/Fonts/simhei.ttf')
# 防止保存图像时'-'显示为方块
plt.rcParams['axes.unicode_minus'] = False


# 设置标题、x坐标标题、y坐标标题
plt.title("标题")
plt.title("标题", fontproperties=font_prop)
plt.xlabel('x轴', fontproperties=font_prop)
plt.ylabel('y轴', fontproperties=font_prop)

# 展示图片
plt.show()
```

#### 折线图

```python
import matplotlib.pyplot as plt

# 清除图层缓存
plt.clf()
X = [1, 2, 3, 4, 5]
Y = ['A', 'B', 'C', 'D', 'E']

# 指定系统中的字体路径
font_path = 'C:/Windows/Fonts/simhei.ttf'
font_prop = fm.FontProperties(fname=font_path)

# 设置图表大小
plt.figure(figsize=(12, 4))  # 调整宽度为12，高度为4

# 创建折线图，使用 'o' 表示数据点的标记
plt.plot(X, Y, linestyle='-', marker='o', linewidth=2, markersize=4)

# 设置标题和标签时使用指定的字体
plt.title('title', fontproperties=font_prop)
plt.xlabel('X_title', fontproperties=font_prop)
plt.ylabel('Y_title', fontproperties=font_prop)

# 在每隔几个点上方显示数据
for i, (x, y) in enumerate(zip(X, Y)):
    if i % 5 == 0:  # 每隔几个点才显示一次数据标签
        plt.text(x, y, f"{y}", ha='center', va='bottom',fontproperties=font_prop, color="black")
        
# 在每个点上方显示数据
for i, (x, y) in enumerate(zip(X, Y)):
    plt.text(x, y, f"{y}", ha='center', va='bottom', fontproperties=font_prop, color="black")

# 强制设置 X 轴的范围（适用于较少的日期数据）
plt.xticks(X[::7], rotation=45)  # 每隔 7 个显示一个
plt.xticks(X, rotation=45)  # 显示所有的日期刻度

# plt.show()
plt.savefig(f"plt.png")

plt.close()
```

#### 柱状图

```python
import matplotlib.pyplot as plt

# 清除图层缓存
plt.clf()
# 示例数据
categories = ['A', 'B', 'C', 'D', 'E']
values = [1, 2, 3, 4, 5]

# 创建柱状图
plt.figure(figsize=(8, 6))  # 设置图形大小
plt.bar(categories, values, color='skyblue')

# 添加标题和标签
plt.title('title')
plt.xlabel('X标签')
plt.ylabel('Y标签')

# 显示数据值在柱状图顶部
for i, value in enumerate(values):
    plt.text(i, value + 1, str(value), ha='center', va='bottom')  # 在每个柱子顶部显示数值

# 显示图形
plt.show()

plt.close()
```

#### 同比柱状图

```python
plt.clf()
# 数据
categories = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期天']  # x轴的分类
values1 = [1, 2, 3, 4, 5, 6, 7]  # 第一组数据
values2 = [10, 20, 30, 40, 50, 60, 70]  # 第二组数据
dates1 = ['1-1', '1-2', '1-3', '1-4', '1-5', '1-6', '1-7']  # 第一组数据的日期标签
dates2 = ['1-8', '1-9', '1-10', '1-11', '1-12', '1-13', '1-14']  # 第二组数据的日期标签

# 指定系统中的字体路径
font_path = 'C:/Windows/Fonts/simhei.ttf'
font_prop = fm.FontProperties(fname=font_path)

# 生成x轴位置
x = arange(len(categories))  # x轴的刻度位置
width = 0.3  # 每个柱子的宽度

# 创建柱状图
plt.figure(figsize=(16, 6))
bar1 = plt.bar(x - width / 2, values1, width, label='Group 1', color='#92D050')  # 第一组数据，左移 width/2
bar2 = plt.bar(x + width / 2, values2, width, label='Group 2', color='#00B0F0')  # 第二组数据，右移 width/2

# 添加标题和标签
plt.title(f'title', fontproperties=font_prop)
plt.xlabel('日期', fontproperties=font_prop)
plt.ylabel(f'ylabel_name', fontproperties=font_prop)
plt.xticks(x, categories, fontproperties=font_prop)  # 设置x轴的标签
plt.legend()  # 显示图例

# 为每个柱子添加日期和数量标签
for i, (b1, b2) in enumerate(zip(bar1, bar2)):
    # 获取每个柱子的 x 和 y 坐标位置
    x1, y1 = b1.get_x() + b1.get_width() / 2, b1.get_height()
    x2, y2 = b2.get_x() + b2.get_width() / 2, b2.get_height()

    # 在柱子上方添加数量标签和日期标签
    # 文字 左右偏移 & 上下偏移
    plt.text(x1 - 0.1, y1 + 0.5, f"{dates1[i]}", ha='center', va='bottom', fontsize=12, color='black')
    plt.text(x1 - 0.1, y1 + 0.5, f"{values1[i]}", ha='center', va='top', fontsize=12, color='black')

    plt.text(x2 + 0.1, y2 + 0.5, f"{dates2[i]}", ha='center', va='bottom', fontsize=12, color='black')
    plt.text(x2 + 0.1, y2 + 0.5, f"{values2[i]}", ha='center', va='top', fontsize=12, color='black')

# 显示图形
# plt.show()
# 保存图像
plt.savefig(f"bar_chart.png")
plt.close()
```

***

## 数据库

### pymongo 库（MongoDB 数据库）

#### 使用

```python
import pymogo
myclient = pymongo.MongoClient("mongodb://localhost:27017/")	#连接数据库
mydb = myclient["库"]	#创建库实例
mycol = mydb["集合"]	#创建集合实例
```

***

### pymysql （Mysql/MariaDB 数据库）

#### mysql 数据库

##### 使用

```python
import pymysql

# 连接到 MariaDB 服务器
connection = pymysql.connect(
    host='localhost',
    port=3306,
    user='root',
    password='root',
    database='mydb',
    charset='utf8mb3',
    cursorclass=pymysql.cursors.DictCursor
)

cursor = connection.cursor()

# 使用连接执行查询等操作
try:
    # 执行 SQL 查询
    sql = "SELECT * FROM users"
    cursor.execute(sql)
    result = cursor.fetchall() # 执行 sql
    connect.commit() # 事务提交
    print(result)
finally:
    # 关闭连接
    connection.close()
```

#### 获取自增 id

```python
cursor.execute(sql, data)

# 提交事务
connection.commit()

# 获取刚插入数据的自增 ID
auto_increment_id = cursor.lastrowid
print(f"自增ID: {auto_increment_id}")
```

#### sql 语句

```python
# 增
(f"NSERT INTO `TableName` (`id`, `name`, `url`) VALUES (1, 'HELLO', 'https://hello.com') "
 f"ON DUPLICATE KEY UPDATE  `name` = VALUES(`name`), `url` = VALUES(`url`);")
# 改
UPDATE TableName SET name = 'HELLO' WHERE id = 1;
# 查
SELECT * FROM TableName
```

#### 数据格式化

```python
tableData = []
# 执行 SQL 操作
sql = (f'select * from {TableName};')
cursor.execute(sql)
result = cursor.fetchall()
    
if result:
    # 提取列名
    column_names = [col[0] for col in cursor.description]

    # 将每一行的数据转换为字典，并将所有字典组成一个列表
    for row in result:
        tem_dict = {col: value for col, value in zip(column_names, row)}
        tableData.append(tem_dict)

	# print(tableData)
```

### sqlalchemy 库（数据库 ORM 框架）

#### 需要的库

```python
pip install pymysql
pip install sqlalchemy
```

#### 导入

```python
from sqlalchemy import create_engine, Column, Integer, String, SmallInteger, DateTime, func
from sqlalchemy.orm import declarative_base, sessionmaker
```

#### 基础用法

```python
from sqlalchemy import create_engine, Column, Integer, String, DateTime, SmallInteger, func, and_, or_, in_
from sqlalchemy.ext import declarative_base, sessionmaker

# 1. 连接 MySQL 数据库（需要安装 pymysql）
DATABASE_URL = 'mysql+pymysql://用户名:密码@主机/数据库'

# 2. 创建 SQLAlchemy 引擎
engine = create_engine(DATABASE_URL, echo=True)  # echo=True 打印 SQL 查询日志

# 3. 定义模型基类
def Base():
    """创建 SQLAlchemy 的基础模型类"""
    return declarative_base()

# 4. 定义映射到数据库表的模型类
class Student(Base):
    __tablename__ = 'student'  # 数据库表名

    # 表字段定义
    id = Column(Integer, primary_key=True, autoincrement=True) # 主键, 自增ID
    name = Column(String(255), default='', nullable=True, comment='名字') # varchar
    status = Column(SmallInteger, default=0, nullable=False, comment='状态标识') # tinyint
    created_at = Column(DateTime, default=func.now(), nullable=False, comment='创建时间')
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False, comment='修改时间')

# 5. 创建数据库表（如果不存在的话）
Base.metadata.create_all(engine)

# 6. 创建 Session 类
Session = sessionmaker(bind=engine)
session = Session()

# 7. 插入数据
new_student = Student(name='name_1', status=0)
session.add(new_student)
session.commit()
print(f"Inserted Table Student with ID: {new_student.id}")

# 8. 查询数据
student = session.query(Student).filter(Student.id == 1).first()

# 9. 数据排序
student = session.query(Student).filter(Student.status == 1).order_by(desc('id'))

# 10. 限制数据量
student = session.query(Student).filter(Student.status == 1).limit(1)

# 11. 更新数据
student = session.query(Student).filter(Student.id == 1).first()
if student:
    student.name = 'new_name_1'
    session.commit()
    print(f"Updated Table Student with ID: {student.id}")
else:
    print("No student found with that id.")

# 12. 删除数据
student = session.query(Student).filter(Student.id == file_id).first()
if student:
    session.delete(student)
    session.commit()
    print(f"Deleted student with ID: {student.id}")
else:
    print("No student found with that id.")

# 13. 批量插入数据
students = [Student(name=item['name'], status=item['status']) for item in Item]
session.add_all(students)
session.commit()
print(f"Inserted {len(students)} to Student.")

# 14. 批量更新数据
updated_count = session.query(student).filter(Student.status == status).update(
    {"name": new_name}, synchronize_session="fetch"
)
session.commit()
print(f"Updated {updated_count} rows.")

# 15. 批量删除数据
deleted_count = session.query(Student).filter(Student.id.in_(student_ids)).delete(synchronize_session="fetch")
session.commit()
print(f"Deleted {deleted_count} rows.")

# 16. 关闭 Session
session.close()

# and、or、in 使用
student = session.query(Student).filter(and_(Student.id == 1)).first()
student = session.query(Student).filter(or_(Student.id == 1)).first()
student = session.query(Student).filter(Student.id.in_(student_ids)).all()
```

#### 方法封装

```python
# 导入
import os
from dotenv import load_dotenv
from urllib.parse import quote
from collections import OrderedDict
from sqlalchemy import create_engine, Column, Integer, String, SmallInteger, DateTime, func, Index
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()


class Config:
    # 加载环境变量
    DB_USERNAME = os.getenv("py_sucai_db_username")
    DB_PASSWORD = quote(os.getenv("py_sucai_db_password"))
    DB_HOST = os.getenv("py_sucai_host")
    DB_PORT = int(os.getenv("py_sucai_port"))
    DB_NAME = os.getenv("py_sucai_database")

    @staticmethod
    def get_database_url():
        # 创建数据库连接，使用 pymysql 作为 MySQL 连接器
        return f"mysql+pymysql://{Config.DB_USERNAME}:{Config.DB_PASSWORD}@{Config.DB_HOST}:{Config.DB_PORT}/{Config.DB_NAME}"

def Base():
    """创建 SQLAlchemy 的基础模型类"""
    return declarative_base()


# 定义 Student 模型类，映射到 `student` 表
class StudentBase(Base()):
    __tablename__ = 'student'

    # 表的列定义
    id = Column(Integer, primary_key=True, autoincrement=True) # 主键, 自增ID
    name = Column(String(255), default='', nullable=True, comment='名字') # varchar
    status = Column(SmallInteger, default=0, nullable=False, comment='状态标识') # tinyint
    created_at = Column(DateTime, nullable=False, default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, nullable=False, default=func.now(), onupdate=func.now(), comment="更新时间")
    deleted_at = Column(DateTime, nullable=True, comment="删除时间")
    # 索引
    __table_args__ = (
        Index('name_status_idx', 'name', 'status', unique=False),  # 创建复合索引, name_status_idx 为自定义索引名
        {'mysql_engine': 'InnoDB', 'mysql_charset': 'utf8mb4', 'mysql_collate': 'utf8mb4_0900_ai_ci'}  # 表参数
    )
    # 自定义 Student 模型对象输出
    def __repr__(self):
        return f"<Student(id={self.id}, name='{self.name}', status={self.status})>"


# 管理数据库的工具类
class StudentModel:
    def __init__(self):
        self.DATABASE_URL = Config.get_database_url()
        # 创建 SQLAlchemy 引擎
        self.engine = create_engine(self.DATABASE_URL, echo=True)  # echo=True 打印 SQL 查询日志
        # 创建 Session 类
        self.Session = sessionmaker(bind=self.engine)
        self.session = None
        self.query = None

    def add_one(self, **kwargs):  # 使用关键字参数
        """
        批量插入数据。
        :param kwargs: 代表一条记录的字典。
        """
        # 连接数据库
        self.session = self.Session()
        # 创建新的 Student 实例
        new_student = StudentBase(**kwargs)  # 直接用关键字参数传递
        self.session.add(new_student)
        self.session.commit()  # 提交事务
        self.session.refresh(new_student)  # 刷新插入的对象
        self.session.close()
        return new_student

    def add_many(self, args):
        """
        批量插入数据。
        :param args: 包含多个字典的列表，每个字典代表一条记录。
        """
        self.session = self.Session()
        # 创建 Student 实例列表
        new_students = [StudentBase(**arg) for arg in args]  # 遍历列表，将每个字典转换为一个 FileDialogue 实例
        # 批量添加到 session
        self.session.add_all(new_students)
        # 提交事务
        self.session.commit()
        # 输出插入的记录
        for new_student in new_students:
            print(f"Inserted Table student with ID: {new_student.id}")

        low_count = len(new_students)
        self.session.close()

        return low_count  # 返回插入的数据长度

    def search(self, **kwargs):
        """
        批量插入数据。
        :param kwargs: 代表查询条件的字典。
        """
        self.session = self.Session()
        # 动态构建过滤条件
        query = self.session.query(StudentBase)
        # 使用 kwargs 中的条件动态生成查询过滤
        for key, value in kwargs.items():
            # 如果字段存在于模型中，则将 'Student.key' 加入过滤条件
            if hasattr(StudentBase, key):
                query = query.filter(getattr(StudentBase, key) == value)
        # 执行查询并获取第一个匹配的结果
        self.session.close()
        return query
    
    def search_latest(self, **kwargs):
        """
        根据 file_id 和 slice_type 查询记录，按 id 降序排序并限制返回 1 条记录。
        :param kwargs: 代表查询条件的字典。
        :return: 查询到的 FileDialogueBase 对象，或 None（如果没有匹配的记录）
        """
        self.session = self.Session()
        # 动态构建查询条件
        # 创建基础查询
        query = self.session.query(StudentBase)
        # 动态构建查询条件
        for key, value in kwargs.items():
            if hasattr(StudentBase, key):
                query = query.filter(getattr(StudentBase, key) == value)
        # 按 id 降序排序
        if query.all():
            try:
                query = query.order_by(desc(StudentBase.id))
            except Exception as e:
                pass
        # 限制返回 1 条记录
        result = query.limit(1).first()  # 使用 first() 来获取第一条记录
        self.session.close()
        return result
    
    def searchAicCoverUri(self, **kwargs):
        """
        查询所有的 student.name，并支持可选的查询条件。

        :param kwargs: 可选的查询条件
        :return: name 列表
        """
        self.session = self.Session()
        query = self.session.query(StudentBase.name)  # 仅查询 name 字段

        # 添加动态过滤条件
        for key, value in kwargs.items():
            if hasattr(StudentBase, key):
                query = query.filter(getattr(StudentBase, key) == value)

        # 执行查询并获取所有结果
        result = query.all()

        # 提取 background_id 并返回列表
        return [row.name for row in result]

    def Filter(self, **kwargs):
        """
        根据传入的参数动态生成查询条件，并返回查询对象
        支持链式调用。
        :param kwargs: 代表查询条件的字典。
        """
        self.session = self.Session()
        # 动态构建过滤条件
        self.query = self.session.query(StudentBase)
        # 使用 kwargs 中的条件动态生成查询过滤
        for key, value in kwargs.items():
            # 如果字段存在于模型中，则将 'Student.key' 加入过滤条件
            if hasattr(StudentBase, key):
                self.query = self.query.filter(getattr(StudentBase, key) == value)
        return self

    def update(self, **kwargs):
        """
        更新数据, 需先调用 Filter 获取查询对象
        支持链式调用。
        :param kwargs: 代表更新数据的字典。
        """
        # 执行更新操作并获取更新的行数
        if self.query:
            rows_updated = self.query.update(kwargs, synchronize_session='fetch') # rows_updated 为记录数量
            self.query = None
            # 提交事务
            self.session.commit()
            self.session.close()
        return self  # 返回实例以支持链式调用


def StudentFormat(query_results):
    """
    格式化查询结果，转换为有序字典列表，确保时间格式化，并处理单个对象的情况。

    :param query_results: 查询结果，可以是单个 ORM 对象、列表或 None
    :return: 格式化后的数据列表，每个元素都是 OrderedDict
    """
    data = []

    # 确保 query_results 始终是一个可迭代对象（列表或类似的）
    if query_results is None:
        return data  # 如果没有结果，返回空列表

    # 如果是单一对象（如 first() 返回的对象），将其转化为包含一个元素的列表
    if not isinstance(query_results, list):
        query_results = [query_results]

    # 遍历 query_results，格式化数据
    for result in query_results:
        if result is None:
            continue  # 跳过 None 对象

        result_dict = result.__dict__

        # 格式化时间字段
        result_dict['created_at'] = result.created_at.strftime('%Y-%m-%d %H:%M:%S') if result.created_at else None
        result_dict['updated_at'] = result.updated_at.strftime('%Y-%m-%d %H:%M:%S') if result.updated_at else None

        # 自定义字段顺序
        ordered_result = OrderedDict([
            ('id', result_dict['id']),
            ('name', result_dict['name']),
            ('status', result_dict['status']),
            ('created_at', result_dict['created_at']),
            ('updated_at', result_dict['updated_at']),
        ])
        data.append(ordered_result)

    # 返回格式化后的数据
    return data


# 调用
if __name__ == '__main__':
# 使用 StudentModel 类执行操作
    studentModel = StudentModel()
    
    # 插入单条数据
    student = studentModel.add_one(name="student_name_1", status=0)
    
    # 插入多条数据
    students = studentModel.add_many([{'name': "student_name_1"}, {'name': "student_name_2"}, {'name': "student_name_3"}])
    
    # 查询数据
    query = studentModel.search(name="file_name_1", status=0)
    # 获取单条数据
    result = query.first()
    # 获取多条数据
    results = query.all()

    # 更新数据
    studentModel.Filter(name="file_name_1").update(status=1)
    # 或
    studentModel.Filter(name="file_name_1")
    studentModel.update(status=1)
    

```

***

# 方法/类的进阶使用

#### 自定义数据结构

```python
class Student:
    def __init__(self, name: str):
        self.name = name

    def __repr__(self):
        return f'<name: {self.name}>'
```

#### 多线程队列

```python
import queue
from concurrent.futures import ThreadPoolExecutor

# 自定义 线程队列
def Threads(Fun: function, # 多线程目标函数
            TagList: list, # 多线程目标
            Args=None: tuple, # 可选参数元组
            max_threads=10):
    # 结果队列
    results_queue = queue.Queue()

    # 创建线程池，最多最多 10 个线程
    with ThreadPoolExecutor(max_workers=max_threads) as executor:
        futures = []

        # 将任务提交给线程池
        for Target in TargetList:
            if Args:
                futures.append(executor.submit(Fun, Target, Args, results_queue))
            else:
                futures.append(executor.submit(Fun, Target, results_queue))

        # 等待所有线程完成
        for future in futures:
            future.result()  # 获取结果并等待任务完成

    # 结果列表
    results_list = []
    while not results_queue.empty():
        result = results_queue.get()
        if result is not None:
            results.extend(result)

    return results_list

def task(Tag, # 多线程目标
         Args=None: tuple # 可选参数元组
		results_queue: list):

    try:
        results_queue.put(Tag)  # 将结果放入队列
    except Exception as e:
        results_queue.put(None)  # 如果出错也放入 None

def main():
    # 调用
    # Count = 10 # 多线程目标
    List = [1,2,3...] # 多线程目标
    Args = (data1,data2,data3...) # 其他参数元组
    # results = Treads(task, Count, Args)
    results = Threads(task, List, Args)
```

#### 异步队列

```python
from multiprocessing import Queue
import threading

class MyThread:
    def __init__(self, fun, *args, **kwargs):
        # 设置队列数
        self.task_create_queue = Queue(maxsize=3)
        self.stop_event = threading.Event()
        self.fun = fun
        self.result = None
        threading.Thread(target=self.worker, daemon=True).start()

    def worker(self, *args, **kwargs):
        """子进程任务，从队列获取任务并执行"""
        while not self.stop_event.is_set():
            try:
                arg = self.task_create_queue.get(timeout=1)  # 设置超时，避免一直阻塞
                result = self.fun(arg)
                self.result = result
            except Exception as e:
                if str(e) == 'Queue is empty':
                    continue  # 处理队列为空的情况
                continue

    def stop(self, *args, **kwargs):
        self.stop_event.set()  # 设置停止事件

    def create_task(self, arg, *args, **kwargs):
        # 使用非阻塞方式添加任务
        # self.task_create_queue.put(arg, block=False)  # 将任务添加到队列
        self.task_create_queue.put(arg, block=True)  # 将任务添加到队列
        return self.result

def fun_test(arg):
    print(arg)
    return arg

def main():
    # 创建异步队列
    task = MyThread(fun_test)
    for arg in range(5):
        # 添加异步任务
        result = task.create_task(arg)
```

#### DbManager 封装

```python
# db_manager 封装
# coding=utf-8
import pymysql

class DBManager:
    def __init__(self, database='database_name'):
        # 本地数据库
        self.host = 'localhost'
        self.port = 3306
        self.username = 'root'
        self.password = 'root'
        self.database = database
        self.connection = None
        self.cursor = None

    def connect(self):
        # 连接数据库
        self.connection = pymysql.connect(
            host=self.host,
            port=self.port,
            user=self.username,
            password=self.password,
            database=self.database
        )
        self.cursor = self.connection.cursor()

    def close(self):
        if self.connection:
            self.connection.close()

    def commit(self):
        if self.connection:
            self.connection.commit()
            
# db_manager 使用
# 初始化
db_manager = DBManager()
# 连接数据库
db_manager.connect()
# 获取游标
cursor = db_manager.cursor
# 执行 sql
cursor.execute(sql)
# 获取结果
result = cursor.fetchall()
# 事务提交
db_manager.commit()
# 关闭连接
db_manager.close()
```



***

# 引用文件

### 不同目录下

```python
import sys
sys.path.append('文件绝对路径')
import 文件
```

### 同目录下 / 子目录

```python
import 文件
import 文件夹/文件
```

***

### 引用库

#### 配置库 / 包的 "__init__.py" 文件

```python
#__init__.py
from .文件 import 函数
__all__=['允许其他项目引用的文件列表']
```

#### 配置项目

```python
#项目.py
form 库/包 import *
fun = 函数()...
```

***

### 查看库信息

```python
import 库名
```

#### 查看库安装路径

```python
安装路径 = 库名.__file__
```

#### 查看方法列表

```python
方法列表 = 库名.__all__
```

#### 查看注释文档

```python
注释 = 库名.__doc__
```

#### 查看帮助

```python
帮助 = help(库名)
```

***

### 生成 requirements.txt

```python
pip freeze > requirements.txt
```

# 位运算

## '^'

```python
# 判断两数是否异号
num ^ -num < 0
```

***

## '&'

```python
# 取余
余数 = 除数 & 被除数

# 进阶，判断奇偶
奇数 & 1 == 1
```

***

## '<<'

```python
# 左移，乘2
4 == 2<<1
```

***

## '>>'

```python
# 右移，除2
2 == 4>>1
```

## 进阶用法

#### 列表的交并补

```python
# 交集
list(set(a) & set(b))

# 并集
list(set(a) | set(b))

# 补集/差集
list(set(a) - set(b))
list(set(b) - set(a))

# 对称差集
list(set(a) | set(b)) - list(set(a) & set(b))
list(set(a) ^ set(b))
```

***

# 工具接口

## Q 绑查询

```python
# 手机号码查Q号

# Q号查手机号码

```

***

# 异常问题合集

## pip ssl异常

```python
# 解决方案：降级 urllib3
pip install urllib3==1.25.11
```

***

