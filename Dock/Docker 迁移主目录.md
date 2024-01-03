### Docker 迁移主目录

```
在docker的使用中随着下载镜像越来越多，构建镜像、运行容器越来越多, 数据目录必然会逐渐增大；当所有docker镜像、容器对磁盘的使用达到上限时，就需要对数据目录进行迁移。如何避免：
1.在安装前对/var/lib/docker（docker默认数据存储目录）目录进行扩容；
2.在docker安装完成后，修改docker默认存储位置为磁盘容量较大的位置；规避迁移数据过程中造成的风险。
```

1. 查询数据目录

   在迁移时需停止docker服务，务必在平台不使用时进行迁移，使用以下命令查询当前docker数据目录安装路径：

   ```
   docker info | grep "Docker Root Dir"
   ```

   ### 迁移方案

   1. 软链接

      1.1停掉Docker服务：

      ```
      systemctl stop docker
      ```

      1.2 根据上面查到的路径，移动整个/var/lib/docker目录到数据盘的目的路径(没有rsync命令时需安装rsync)：

      ```
      rsync -avzP /var/lib/docker  /data
      参数解释：
      -a，归档模式，表示递归传输并保持文件属性。
      -v，显示rsync过程中详细信息。可以使用"-vvvv"获取更详细信息。
      -P，显示文件传输的进度信息。(实际上"-P"="--partial --progress"，其中的"--progress"才是显示进度信息的)。
      -z, 传输时进行压缩提高效率。
      ```

      1.3 备份数据目录

      ```
      mv /var/lib/docker  /var/lib/docker.bak
      ```

      1.4 添加软连接

      ```
      ln -s /data/docker /var/lib/
      ```

      1.5 重启docker 

      ```
      systemctl start docker
      ```

      **启动 Docker 之后，Docker 写入的路径依然是 /var/lib/docker ，但是因为软链接的设置，实际已经是往新的目录写入了。至此，完成了 Docker 安装(存储)目录的迁移。通过上述方法完成迁移之后，在确认 Docker 能正常工作之后，删除原目录备份数据：**
      **rm -rf /var/lib/docker.bak**

   2. 修改默认存储路径

      直接移出数据，并修改docker默认存放路径位置

      

      2.1停掉Docker服务：

      ```
      systemctl stop docker
      ```

      2.2 根据上面查到的路径，移动整个/var/lib/docker目录到数据盘的目的路径(没有rsync命令时需安装rsync)：

      ```
      rsync -avzP /var/lib/docker  /data
      参数解释：
      -a，归档模式，表示递归传输并保持文件属性。
      -v，显示rsync过程中详细信息。可以使用"-vvvv"获取更详细信息。
      -P，显示文件传输的进度信息。(实际上"-P"="--partial --progress"，其中的"--progress"才是显示进度信息的)。
      -z, 传输时进行压缩提高效率。
      ```

      2.3 修改配置默认路径,在EXECStart后面添加--graph=/home/rain/docker/

      ```
      vim /usr/lib/systemd/system/docker.service    ExecStart=/usr/bin/dockerd  --graph=/home/rain/docker
      ```

      2.4 重启docker

      2.5 查看docker数据存储目录

      ```
      docker info | grep "Docker Root Dir"
      ```

      3. 通过mount挂载的bind命令

         3.1 备份 fstab文件

         ```
         cp /etc/fstab /etc/fstab.$(date +%Y-%m-%d)
         ```

         3.2停掉Docker服务：

         ```
         systemctl stop docker
         ```

         3.3 根据上面查到的路径，移动整个/var/lib/docker目录到数据盘的目的路径(没有rsync命令时需安装rsync)：

         ```
         rsync -avzP /var/lib/docker  /data
         参数解释：
         -a，归档模式，表示递归传输并保持文件属性。
         -v，显示rsync过程中详细信息。可以使用"-vvvv"获取更详细信息。
         -P，显示文件传输的进度信息。(实际上"-P"="--partial --progress"，其中的"--progress"才是显示进度信息的)。
         -z, 传输时进行压缩提高效率。
         ```

         3.4 将备份保存

         ```
         mv /var/lib/docker/ /var/lib/docker.bak
         ```

         3.5 通过mount挂载的bind命令将新位置挂载到老位置

         ```
         # 创建挂载点 mkdir /var/lib/docker
         mount --bind /home/rain/docker /var/lib/docker mount -a
         创建开机自动挂载
         vim /etc/fstab # 最后一行添加 /home/rain/docker /var/lib/docker                     none    bind            0 0 # 挂载 mount -a
         如有必要重启服务器确认是否成功迁移
         reboot
         通过上述方法完成迁移之后，在确认 Docker 能正常工作之后，删除原目录备份数据：
         rm -rf /var/lib/docker.bak
         ```

         