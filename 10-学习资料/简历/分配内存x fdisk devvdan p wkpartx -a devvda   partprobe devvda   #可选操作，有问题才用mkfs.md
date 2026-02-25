1. 分配内存

   ```
   fdisk /dev/vda
   n p w
   kpartx -a /dev/vda   partprobe /dev/vda   #可选操作，有问题才用
   mkfs.ext4 /dev/vda3
      mkdir /data
      mount /dev/vda3 /data
      vim /etc/fstab
         /dev/vda3   /data   ext4   defaults   0   0
   
   ```

   2. 扩展 逻辑卷

      ```
      创建新分区： 使用 parted 或 fdisk 创建一个新分区 /dev/vda3，确保它的大小足够大，以容纳你希望添加的空间。请注意，这一步可能会修改分区表，因此请务必在继续之前进行数据备份。
      
      将新分区标记为物理卷： 运行以下命令将新分区标记为 LVM 物理卷：
      
      sudo pvcreate /dev/vda3
      将新的 PV 合并到卷组： 现在，将新创建的物理卷添加到卷组 cl 中。运行以下命令：
      
      sudo vgextend cl /dev/vda3
      扩展逻辑卷： 使用 lvextend 命令将逻辑卷 cl-root 扩展以占用新的物理卷空间。假设 cl-root 是逻辑卷的名称，运行以下命令：
      
      sudo lvextend -l +100%FREE /dev/cl/root
      调整 XFS 文件系统大小： 使用 xfs_growfs 命令来调整 XFS 文件系统的大小。在这之前，请确保逻辑卷已经被成功扩展。
      
      sudo xfs_growfs /dev/cl/root
      ```

      

      ```
      
      ```

      