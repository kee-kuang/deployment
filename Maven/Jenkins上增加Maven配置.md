## 在原Jenkins上增加Maven配置

### 下载Maven压缩包

```
# cd /opt
# wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.8.1/apache-maven-3.8.1-bin.zip
# unzip apache-maven-3.8.1-bin.zip

```

### 配置环境变量

```
# vim /etc/profile
export MAVEN_HOME=/opt/apache-maven-3.8.1
export PATH=$PATH:$MAVEN_HOME/bin

#验证是否生效
mvn -v 
```

### Jenkins 配置过程

1. 在构建选项上选择**Invoke top-level Maven targets**

2. 选择 Maven 版本

3. 在目标内添加**clean install -Dmaven.test.skip=true**

   ```
   clean install -Dmaven.test.skip=true  
   这是一个Maven 命令，用于构建项目并跳过执行测试
   每个选项的含义：
   
   clean：在构建之前先清理项目。
   install：将构建的项目安装到本地 Maven 仓库，以供其他项目使用。
   -Dmaven.test.skip=true：跳过执行测试。通常在构建过程中执行测试用例，但此选项将禁用测试的执行。
   通过使用 -Dmaven.test.skip=true，构建过程将忽略测试阶段，直接进行编译、打包和安装操作。这在某些情况下可能有用，例如在构建过程中测试用例无法通过或者构建速度较慢时
   ```

   

4. 高级选项内，指定配置文件路径