## Raid 扩容

1. 首先确认磁盘阵列卡的类型 （**Adaptec 控制器** 还是 **LSI/Broadcom MegaRAID**）

   ```
   lspci | grep RAID  确认存储卡类型 确认是使用 arcconf还是storcli 或 MegaCLI
   ```

   ```
   lspci | grep RAID
   5e:00.0 RAID bus controller: Broadcom / LSI MegaRAID SAS-3 3108 [Invader] (rev 02)
   ```

   可以看到目前的存储卡类型是LSI MegaRAID的，所以使用storcli 命令

2. 通过 storcli show 查看存储卡的信息

   ```
   ./storcli64 show 
   CLI Version = 007.2705.0000.0000 August 24, 2023
   Operating system = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
   Status Code = 0
   Status = Success
   Description = None
   
   Number of Controllers = 1
   Host Name = 249
   Operating System  = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
   
   System Overview :
   ===============
   
   ------------------------------------------------------------------------------------
   Ctl Model                   Ports PDs DGs DNOpt VDs VNOpt BBU sPR DS  EHS ASOs Hlth 
   ------------------------------------------------------------------------------------
     0 AVAGOMegaRAIDSAS9361-8i     8  11   2     0   2     0 N/A On  1&2 Y      3 Opt  
   ------------------------------------------------------------------------------------
   
   Ctl=Controller Index|DGs=Drive groups|VDs=Virtual drives|Fld=Failed
   PDs=Physical drives|DNOpt=Array NotOptimal|VNOpt=VD NotOptimal|Opt=Optimal
   Msng=Missing|Dgd=Degraded|NdAtn=Need Attention|Unkwn=Unknown
   sPR=Scheduled Patrol Read|DS=DimmerSwitch|EHS=Emergency Spare Drive
   Y=Yes|N=No|ASOs=Advanced Software Options|BBU=Battery backup unit/CV
   Hlth=Health|Safe=Safe-mode boot|CertProv-Certificate Provision mode
   Chrg=Charging | MsngCbl=Cable Failure
   ```

    通过 storcli 的输出可以看到，目前的存储卡的型号状态等相关信息

   ### **控制器基本信息**

   - **控制器型号**：`AVAGO MegaRAID SAS9361-8i`（Broadcom/LSI 的高性能 RAID 控制器）。
   - **控制器状态**：
     - **Status Code = 0**：操作成功，控制器响应正常。
     - **Health = Opt**：控制器及 RAID 阵列处于 **最优状态**，无错误或降级。
   - **物理磁盘（PDs）**：检测到 **11 块物理磁盘**。
   - **逻辑配置**：
     - **驱动器组（DGs）**：2 个驱动器组（可能对应两个独立的 RAID 阵列）。
     - **虚拟磁盘（VDs）**：2 个虚拟磁盘（即两个逻辑卷）。

   

3. 首先先确认目前的阵列的详细信息

   ```
   ./storcli64 /c0/dall show
   这个命令会显示控制器 0 上所有磁盘组（d = drive group）的详细信息，包括：Drive Group 编号（如 DG/VD 栏） 包含的虚拟盘 RAID 等级 容量 状态等
   假设要看磁盘组 0 的成员：
   ./storcli64 /c0/d0 show all
   磁盘组1
   ./storcli64 /c0/d1 show all
   要看到具体每块硬盘（物理磁盘）在哪个磁盘组里
   ./storcli64 /c0 /eall /sall show all
   ```

   ```
   ./storcli64 /c0/dall show
   CLI Version = 007.2705.0000.0000 August 24, 2023
   Operating system = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
   Controller = 0
   Status = Success
   Description = Show Drive Group Succeeded
   
   
   TOPOLOGY :
   ========
   
   -----------------------------------------------------------------------------
   DG Arr Row EID:Slot DID Type  State BT       Size PDC  PI SED DS3  FSpace TR 
   -----------------------------------------------------------------------------
    0 -   -   -        -   RAID1 Optl  N  446.625 GB dflt N  N   dflt N      N  
    0 0   -   -        -   RAID1 Optl  N  446.625 GB dflt N  N   dflt N      N  
    0 0   0   27:0     28  DRIVE Onln  N  446.625 GB dflt N  N   dflt -      N  
    0 0   1   27:1     29  DRIVE Onln  N  446.625 GB dflt N  N   dflt -      N  
    1 -   -   -        -   RAID6 Optl  N   60.027 TB dflt N  N   dflt N      N  
    1 0   -   -        -   RAID6 Optl  N   60.027 TB dflt N  N   dflt N      N  
    1 0   0   27:2     32  DRIVE Onln  Y   20.008 TB dflt N  N   dflt -      N  
    1 0   1   27:3     34  DRIVE Onln  Y   20.008 TB dflt N  N   dflt -      N  
    1 0   2   27:4     30  DRIVE Onln  Y   20.008 TB dflt N  N   dflt -      N  
    1 0   3   27:5     31  DRIVE Onln  Y   20.008 TB dflt N  N   dflt -      N  
    1 0   4   27:6     33  DRIVE Onln  Y   20.008 TB dflt N  N   dflt -      N  
   -----------------------------------------------------------------------------
   
   DG=Disk Group Index|Arr=Array Index|Row=Row Index|EID=Enclosure Device ID
   DID=Device ID|Type=Drive or RAID Type|Onln=Online|Rbld=Rebuild|Optl=Optimal
   Dgrd=Degraded|Pdgd=Partially degraded|Offln=Offline|BT=Background Task Active
   PDC=PD Cache|PI=Protection Info|SED=Self Encrypting Drive|Frgn=Foreign
   DS3=Dimmer Switch 3|dflt=Default|Msng=Missing|FSpace=Free Space Present
   TR=Transport Ready
   ```

   由此可见，目前机器上存在两个磁盘阵列组，其中磁盘组0 是由一组 2 块盘构成的 RAID1，磁盘组1 是由5 块 20T 硬盘组成的 RAID6（2 块用于校验，3 块用于数据）

   4. 目前的需求是在已有的raid6中，新增3块新的硬盘进磁盘组1 ，需要扩展磁盘组 + 重建虚拟盘容量

**Raid扩容是风险性操作，一旦更新过程中发生中断和断电，有极大可能丢数据**

- 首先要确保新增硬盘的状态是**online状态** 且无外来阵列的

- 查看新增硬盘，确认哪些硬盘是新的，空闲的 **磁盘状态的ugood的** 

  ```
  ./storcli64 /c0 /eall /sall show
  CLI Version = 007.2705.0000.0000 August 24, 2023
  Operating system = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
  Controller = 0
  Status = Success
  Description = Show Drive Information Succeeded.
  
  
  Drive Information :
  =================
  
  ----------------------------------------------------------------------------------------
  EID:Slt DID State DG       Size Intf Med SED PI SeSz Model                      Sp Type 
  ----------------------------------------------------------------------------------------
  27:0     28 Onln   0 446.625 GB SATA SSD N   N  512B SAMSUNG MZ7LH480HAHQ-00005 U  -    
  27:1     29 Onln   0 446.625 GB SATA SSD N   N  512B SAMSUNG MZ7LH480HAHQ-00005 U  -    
  27:2     32 Onln   1  20.008 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:3     34 Onln   1  20.008 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:4     30 Onln   1  20.008 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:5     31 Onln   1  20.008 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:6     33 Onln   1  20.008 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:7     35 JBOD   -   6.985 TB SATA SSD N   N  512B SAMSUNG MZ7L37T6HBLA-00A07 U  -    
  27:8     36 JBOD   -  20.009 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:9     37 JBOD   -  20.009 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  27:10    38 JBOD   -  20.009 TB SATA HDD N   N  512B WDC  WUH722222ALE6L4       U  -    
  ----------------------------------------------------------------------------------------
  
  EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
  DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
  UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
  Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
  SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
  UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
  CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
  UBUnsp=UBad Unsupported|Rbld=Rebuild
  ```

  由上所示，可以看到27:7- 27:10 的状态是JBOD ( just a bunch of disks) ，通过状态展现，目前确认 27:8-27:10 这三块机械硬盘是加入到磁盘组1 中的 硬盘

图解过程：

```
[3 新硬盘] ➜ 加入 RAID6 磁盘组（DG1） ➜ 重建中...
                                 ↓
                         虚拟盘空间变大（VD）
                                 ↓
                  Linux 系统识别出更大容量 ➜ 扩分区、扩文件系统
```



- 那么已经确认了，就需要先把JBOD状态的磁盘 转换成 ugood 状态

```
./storcli64 /c0 /e27 /s8 set good force
./storcli64 /c0 /e27 /s9 set good force
./storcli64 /c0 /e27 /s10 set good force
```

- 然后将其加入到磁盘组1 中

  ```
  #./storcli64 /c0/d1 add drives=27:8,27:9,27:10
  由于磁盘过大，保险起见，将一块一块加进组内
  ./storcli64 /c0/v1 start migrate type=raid6 option=add drives=27:8
  ```

  ```
  start migrate 是代表着迁移，在线 RAID6 磁盘扩容操作（Online Capacity Expansion，OCE）
  这个命令实际上对已有的虚拟盘 /c0/v1（RAID6 类型）执行在线扩容（添加物理盘 27:8）
  过程：
  控制器会将现有的数据重新布局为“更多磁盘”组成的新 RAID6（从原来的N块 → N+1块）。
  所有数据都需要重新校验、分块、重写。
  所以整个 RAID 虚拟盘都要重写一次数据，相当于在迁移 60TB 的数据量。
  整个RAID 6要：
  1. 重新组织冗余校验结构，
  2. 将原来的数据和校验信息分布到新的磁盘布局中。
  所以：
  实际迁移/重写的“数据总量”几乎是原 RAID 的整个 60TB，而不是新硬盘的容量。
  ```

  执行后控制器会开始 **重构 RAID6**，这个过程可能会持续**几个小时**甚至更久，期间可以使用以下命令查看状态：

  ```
  这个是重建查看的命令
  ./storcli64 /c0/d1 show rebuild
  迁移的查看命令：
  ./storcli64 /c0/v1 show migrate
  ```

- 考虑到业务的使用，不确定是否会影响到当前服务器的使用，需要控制重建的 **优先级** ，所以可以通过 `storcli` 工具调整重建的 **优先级**，从而减少重建对系统正常使用的影响。这个设置称为 **重建的后台任务优先级（Rebuild Rate）** 或 **Rebuild Rate Limit**。

  - 查看当前重建的优先级

    ```
    ./storcli64 /c0 show rebuildrate
    Controller = 0
    Rebuild Rate = 30%
    ```

  - 查看迁移的优先级
    
- 设置重建优先级（降低对性能的影响）
  
  ```
    ./storcli64 /c0 set rebuildrate=10
    ```
  
  - 参数说明：
  
    ```
      10：重建优先级设置为 10%，RAID 控制器将以较低优先级进行重建，减少对磁盘 I/O 的影响，但重建时间会更长。
      100：重建优先级设置为 100%，最快重建，但对当前系统读写性能影响大。
      ```
  
- 
  
- 调整建议
  
  | 场景              | 推荐设置 |
    | ----------------- | -------- |
    | 正常业务高峰期    | 10~20    |
    | 夜间/低峰时段     | 50~80    |
    | 空闲时间/无人使用 | 100      |
  

  

  
- 等**rebuild** 结束之后，我们就可以查看虚拟盘的容量了

  ```
  查看虚拟盘编号：
  ./storcli64 /c0/vall show
  ```

  ```
  ./storcli64 /c0/vall show
  CLI Version = 007.2705.0000.0000 August 24, 2023
  Operating system = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
  Controller = 0
  Status = Success
  Description = None
  
  
  Virtual Drives :
  ==============
  
  ----------------------------------------------------------------------
  DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name        
  ----------------------------------------------------------------------
  0/0   RAID1 Optl  RW     Yes     NRWTD -   ON  446.625 GB GenericR1_0 
  1/1   RAID6 Optl  RW     Yes     RWTD  -   ON   60.027 TB test        
  ----------------------------------------------------------------------
  ```

  可以看到目前服务器上有两个虚拟盘，我们是将三块硬盘到 RAID6 所属的 **DG1** 中，现在需要 **扩展虚拟盘 VD1 的容量** 

- 扩展虚拟盘容量（使用最大空间）

  ```
  ./storcli64 /c0/v1 expand size=max
  ```

  说明：

  - `/c0`：第 0 号控制器
  - `/v1`：虚拟盘编号是 VD1（就是扩展的那个 RAID6）
  - `size=max`：自动使用所有新增空间

- 检查是否生效，生效的话，应该是比当前的60T大的

  ```
  ./storcli64 /c0/v1 show
  
  #针对 /dev/sdb 重新扫描容量
  echo 1 > /sys/class/block/sdb/device/rescan
  
  # 验证操作系统是否识别新容量
  lsblk | grep sdb
  ```



4. 当raid 已经正式完成扩容之后，需要在系统中扩容分区和文件系统

- 查看当前服务器磁盘的文件系统

  ```
  lsblk -f 
  NAME               FSTYPE      LABEL UUID                                   MOUNTPOINT
  sda                                                                         
  ├─sda1             vfat              04B5-4D08                              /boot/efi
  ├─sda2             xfs               1d5b6062-9759-424e-b1f2-927ad9901b98   /boot
  └─sda3             LVM2_member       rr24LP-jnM9-IoDG-enys-l1wm-836X-vvROr6 
    ├─zstack-root    xfs               45c43ead-3a84-41e2-bf57-7316eac00d14   /
    └─zstack-swap    swap              a514e507-4173-4342-9767-6ca9894063f8   [SWAP]
  sdb                LVM2_member       3ied9h-dymb-4moi-EtkO-6Pke-3KDY-F2aQ11 
  ├─data_vg-data_lv  ext4              8d2bece0-d859-4afc-b73d-842fb14e638e   /data
  └─data_vg-sucai_vg ext4              88539412-2581-4d88-8ef5-3b49f7c0a983   /www
  sdc                LVM2_member       ibo1l4-0Ykm-7jrC-YxxT-l0Ys-kTrX-n24e6n 
  └─ssd_vg-ssd_lv    xfs               bed3a9e7-4047-4d1c-a65a-3715374745e2   /www-ssd
  sdd                                                                         
  sde                                                                         
  sdf                                                                         
  (base) [root@249 storcli]# df -HT
  Filesystem                   Type      Size  Used Avail Use% Mounted on
  devtmpfs                     devtmpfs  135G     0  135G   0% /dev
  tmpfs                        tmpfs     135G  115k  135G   1% /dev/shm
  tmpfs                        tmpfs     135G  3.4M  135G   1% /run
  tmpfs                        tmpfs     135G     0  135G   0% /sys/fs/cgroup
  /dev/mapper/zstack-root      xfs       474G   94G  381G  20% /
  /dev/sda2                    xfs       1.1G  206M  858M  20% /boot
  /dev/sda1                    vfat      628M  6.1M  622M   1% /boot/efi
  /dev/mapper/data_vg-data_lv  ext4       22T  652G   21T   4% /data
  /dev/mapper/data_vg-sucai_vg ext4       44T   32T  9.7T  77% /www
  tmpfs                        tmpfs      27G     0   27G   0% /run/user/0
  tmpfs                        tmpfs      27G     0   27G   0% /run/user/1000
  /dev/mapper/ssd_vg-ssd_lv    xfs       7.7T  155G  7.6T   3% /www-ssd
  ```

  可以看到目前服务器上sdb的文件系统是etx4 ，我们需要新增/www的容量

- 扩展PV(物理卷)

  ```
  pvresize /dev/sdb
  ```

- 查看卷组大小变化

  ```
  vgs
  ```

  在这条命令里，就应该看到sdb 的物理卷的可用空间增加

- 扩展/www 逻辑卷

  ```
  lvextend -l +100%FREE /dev/data_vg/sucai_vg
  ```

- 扩展 ext4 文件系统

  ```
  resize2fs /dev/data_vg/sucai_vg
  ```

- 确认是否完成

  ```
  df -HT
  ```

  

