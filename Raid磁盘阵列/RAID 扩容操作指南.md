# RAID 扩容操作指南

## 1. 确认存储卡类型（**Adaptec 控制器** 还是 **LSI/Broadcom MegaRAID**）

首先，需要确认磁盘阵列卡的类型，以确定使用的命令行工具。可以通过以下命令查看存储卡类型：

```
lspci | grep RAID
```

例如，输出如下：

```
5e:00.0 RAID bus controller: Broadcom / LSI MegaRAID SAS-3 3108 [Invader] (rev 02)
```

如果输出类似于上述示例，表示使用的是 **LSI MegaRAID** 控制器，此时需要使用 `storcli` 工具进行操作。

## 2. 查看存储卡信息

使用 `storcli` 查看存储卡的详细信息：

```
./storcli64 show
```

示例输出：

```
CLI Version = 007.2705.0000.0000 August 24, 2023
Operating system = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64
Status Code = 0
Status = Success
Description = None

Number of Controllers = 1
Host Name = 249
Operating System  = Linux 4.18.0-425.19.2.4.g0fd3a169.el8.x86_64

System Overview :
================

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

通过上述命令的输出，可以看到存储卡型号、状态、以及 RAID 配置的概况。

### **控制器基本信息**

- **控制器型号**：`AVAGO MegaRAID SAS9361-8i`（Broadcom/LSI 的高性能 RAID 控制器）。
- **控制器状态**：
  - **Status Code = 0**：操作成功，控制器响应正常。
  - **Health = Opt**：控制器及 RAID 阵列处于 **最优状态**，无错误或降级。
- **物理磁盘（PDs）**：检测到 **11 块物理磁盘**。
- **逻辑配置**：
  - **驱动器组（DGs）**：2 个驱动器组（可能对应两个独立的 RAID 阵列）。
  - **虚拟磁盘（VDs）**：2 个虚拟磁盘（即两个逻辑卷）。

## 3. 查看磁盘阵列组信息

通过以下命令查看所有磁盘组（Drive Groups）的详细信息：

这个命令会显示控制器 0 上所有磁盘组（d = drive group）的详细信息，包括：Drive Group 编号（如 DG/VD 栏） 包含的虚拟盘 RAID 等级 容量 状态等

```
./storcli64 /c0/dall show
```

如果要查看某个磁盘组的详细信息，可以使用：

```
./storcli64 /c0/d0 show all  # 查看磁盘组 0 的详细信息
./storcli64 /c0/d1 show all  # 查看磁盘组 1 的详细信息
./storcli64 /c0 /eall /sall show all #要查看每块硬盘（物理磁盘）所在的磁盘组
```

示例输出：

```
TOPOLOGY :
========
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
```

从上面的输出中，我们可以看到有两个磁盘阵列组（DG0 和 DG1），其中 DG0 是一个 RAID1 阵列，包含 2 块 446.625 GB 的 SSD；DG1 是一个 RAID6 阵列，包含 5 块 20.008 TB 的硬盘。

## 4. 确认新增硬盘的状态

在进行 RAID 扩容前，需要确认新增硬盘的状态为 **Onln**，并且没有被配置为外来阵列。可以使用以下命令查看硬盘信息：

```
./storcli64 /c0 /eall /sall show
```

输出中新增硬盘的状态应为 **JBOD**（Just a Bunch of Disks），需要将这些硬盘转换为 **UGood**（Unconfigured Good）状态。

示例输出：

```
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

### 转换硬盘为 UGood 状态

```
./storcli64 /c0 /e27 /s8 set good force
./storcli64 /c0 /e27 /s9 set good force
./storcli64 /c0 /e27 /s10 set good force
```

### 将硬盘加入到 RAID6 磁盘组

```
./storcli64 /c0/d1 add drives=27:8,27:9,27:10
```

或者逐块添加：

```
./storcli64 /c0/v1 start migrate type=raid6 option=add drives=27:10
```

`start migrate` 命令表示在线扩容（Online Capacity Expansion, OCE），即将新硬盘加入到现有的 RAID6 阵列中。这个过程涉及数据重新布局，整个 RAID 阵列需要重新校验、分块、重写。

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

### 查看迁移状态

```
./storcli64 /c0/v1 show migrate
```

## 5. 调整重建优先级

由于 RAID 重建会消耗较多 I/O 资源，如果需要在重建过程中保证业务的正常运行，可以调整重建的优先级。查看当前重建优先级：

```
./storcli64 /c0 show rebuildrate
```

如果需要调整重建优先级，可以使用以下命令：

```
./storcli64 /c0 set rebuildrate=10
```

参数 `10` 表示将重建优先级设置为 10%，减少对系统性能的影响。

### 重建优先级建议设置

| 场景              | 推荐设置 |
| ----------------- | -------- |
| 正常业务高峰期    | 10~20    |
| 夜间/低峰时段     | 50~80    |
| 空闲时间/无人使用 | 100      |

## 6. 调整重建优先级

RAID 重建通常是一个资源密集型的过程，它会占用大量的 I/O 带宽和计算资源。特别是在数据迁移或磁盘故障恢复期间，可能会影响系统的整体性能。因此，为了在重建过程中尽量减少对系统和业务的影响，我们可以根据实际需求来调整重建的优先级或速率。

###  查看当前重建速率

首先，可以使用以下命令来查看当前的重建速率配置：

```
./storcli64 /c0 show rebuildrate
```

此命令将显示当前 RAID 设备的重建速率，这个速率是控制 RAID 重建过程对系统性能影响的一个关键参数。重建速率通常以百分比的形式表示，较低的速率意味着重建过程将占用较少的系统资源。

### 调整重建速率

如果在重建过程中需要调整重建优先级或迁移速率，可以使用以下命令进行修改：

```
/opt/MegaRAID/storcli/storcli64 /c0 set migraterate=70
```

在这个命令中，`migraterate=70` 表示将 RAID 迁移速率设置为 70%。该命令会通过调整磁盘重建的速率，减少其对系统性能的影响，尤其是在业务高峰期或系统负载较大的情况下。

###  迁移速率的影响

迁移速率控制的是磁盘重建过程中所使用的带宽和 I/O 资源的比例。调整迁移速率的意义如下：

- **较低的迁移速率（如 10%）**：适用于需要最大化系统性能时的场景。虽然重建过程会非常缓慢，但对其他业务的影响最小。适用于系统负载较高，或者需要保障业务连续性的时候。
- **较高的迁移速率（如 70%）**：适用于需要尽快完成 RAID 重建的情况。迁移速率越高，重建过程会加快，但也可能导致系统性能下降，影响其他服务的运行。

### 自动化调整脚本

```
#!/bin/bash

# 设置高峰时段（7点~1点）
PEAK_START=7
PEAK_END=24

# 钉钉 Webhook URL
DINGTALK_WEBHOOK="https://oapi.dingtalk.com/robot/send?access_token=a048d5d6506999cf4ac615699976a4a16e0fcfe8b1e837d5ff7d8ffba0464105"

# Prometheus Pushgateway URL
PUSHGATEWAY_URL="http://192.168.100.249:9091/metrics/job/raid_migration"

# 无限循环执行
while true; do
    CURRENT_HOUR=$(date +'%H')
    CURRENT_HOUR=$((10#$CURRENT_HOUR))  

    MIGRATE_STATUS=$(/opt/MegaRAID/storcli/storcli64 /c0/v1 show migrate)

    if ! echo "$MIGRATE_STATUS" | grep -iq "In Progress"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') 未检测到RAID迁移任务，跳过速率调整与推送。"
        sleep 300
        continue
    fi

    MIGRATE_PROGRESS=$(echo "$MIGRATE_STATUS" | awk '/^[[:space:]]*[0-9]+[[:space:]]+Migrate/ {print $3}')
    MIGRATE_ESTIMATED_TIME=$(echo "$MIGRATE_STATUS" | awk '/^[[:space:]]*[0-9]+[[:space:]]+Migrate/ {for(i=5;i<=NF;i++) printf $i " "; print ""}')

    RATE=30
    if [[ $CURRENT_HOUR -ge $PEAK_START && $CURRENT_HOUR -lt $PEAK_END ]]; then
        /opt/MegaRAID/storcli/storcli64 /c0 set migraterate=70
        RATE=70
    else
        /opt/MegaRAID/storcli/storcli64 /c0 set migraterate=100
        RATE=100
    fi

    LOG_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    MESSAGE="[$LOG_TIME] 当前RAID迁移进度：${MIGRATE_PROGRESS}%，预计剩余时间：${MIGRATE_ESTIMATED_TIME}，当前迁移速率：${RATE}%"

    # 推送钉钉
    curl -s -X POST "$DINGTALK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{
            \"msgtype\": \"text\",
            \"text\": {
                \"content\": \"$MESSAGE\"
            }
        }" > /dev/null

    # 推送到 Pushgateway
    cat <<EOF | curl --data-binary @- "$PUSHGATEWAY_URL"
# raid_migration_progress 类型指标
raid_migration_progress $MIGRATE_PROGRESS
# raid_migration_rate类型指标
raid_migration_rate $RATE
EOF

    # 输出日志
    echo "$MESSAGE"
    echo "------------------------------------------"

    sleep 3600
done
```



## 7. 扩展虚拟盘容量

当 RAID 重建完成后，需要验证是否已经成功扩容

### 验证扩展效果

在扩展虚拟盘容量后，可以通过以下命令来验证虚拟盘容量是否已经扩展：

```
./storcli64 /c0/v1 show
```

此外，可以通过重新扫描磁盘来查看系统是否识别到了新增的容量：

```
echo 1 > /sys/class/block/sdb/device/rescan
```

### 查看操作系统是否识别新容量

使用以下命令可以查看操作系统是否识别到新增的容量：

```
lsblk | grep sdb
```

## 8. 扩展分区和文件系统

扩展磁盘容量后，操作系统可能仍然未识别新空间。此时需要扩展分区和文件系统。

### 1. 扩展物理卷（让 PV 识别出多出来的 20T）

```
pvresize /dev/sdb
```

这条命令执行后，物理卷 `/dev/sdb` 会扩展，卷组 `data_vg` 的 Free Size 会多出20T。

（⚡非常快，几秒钟完成）

------

### 2. 检查卷组空间（确认 Free Size 变多了）

```
vgdisplay data_vg
```

你会看到 Free PE / Size 那里，不再是 0了，应该多了 20T左右。

------

### 3. 扩容逻辑卷 `/www`（就是 `data_vg-sucai_vg`）

```
lvextend -l +100%FREE /dev/data_vg/sucai_vg
```

（把 data_vg 卷组的全部空闲空间，加到 sucai_vg 上）

------

### 4. 扩展文件系统（让 `/www` 实际容量变大）

- 如果 `/www` 是 **xfs** 文件系统：

  ```
  xfs_growfs /www
  ```

- 如果是 **ext4**：

  ```
  resize2fs /dev/data_vg/sucai_vg
  ```

为了避免对话框断开，确实需要确保扩容过程不中断。为了安全起见，你可以把扩容的命令放在后台执行，这样即使当前终端会话断开了，扩容操作也会继续进行。

#### **使用 `screen` 或 `tmux`**

如果你想要更强大的后台管理工具，可以使用 `screen` 或 `tmux`。它们可以让你即使断开连接后，依然保持会话并且随时重新连接。

1. 启动一个新的 `screen` 会话：

   ```
   screen -S resize_session
   ```

2. 然后执行 `resize2fs`：

   ```
   resize2fs /dev/data_vg/sucai_vg
   ```

3. 按 `Ctrl+A` 然后按 `D`，这会让你**暂时离开**这个 `screen` 会话，但不会中断执行。

4. 随时可以用这个命令重新连接：

   ```
   screen -r resize_session
   ```

### 使用 `nohup` 保证命令持续执行

`nohup` 会将命令放到后台运行，即使会话关闭，命令也不会中断。你可以按以下步骤操作：

1. **暂停当前命令**（按 `Ctrl+Z`），这会将当前进程挂起。

2. **将进程放到后台**，输入：

   ```
   bg
   ```

   这会将当前命令移到后台执行。

3. **让进程不受终端关闭的影响**，输入：

   ```
   disown
   ```

   这会使得该进程脱离终端，确保即使终端断开，命令继续执行。

4. **查看输出**（如果有日志文件输出）： 如果你是第一次执行 `resize2fs`，而没有用 `nohup`，你可以暂时查看输出文件：

   ```
   tail -f nohup.out
   ```

   （如果之前没有使用 `nohup`，需要稍后再查看日志）