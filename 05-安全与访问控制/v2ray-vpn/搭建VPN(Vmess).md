### 搭建VPN(Vmess)

### 1.安装v2ray脚本

```shell
#!/bin/bash

author=bwgvps
# github=https://github.com/bwgvps/v2ray

# bash fonts colors
red='\e[31m'
yellow='\e[33m'
gray='\e[90m'
green='\e[92m'
blue='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$@${none}; }
_blue() { echo -e ${blue}$@${none}; }
_cyan() { echo -e ${cyan}$@${none}; }
_green() { echo -e ${green}$@${none}; }
_yellow() { echo -e ${yellow}$@${none}; }
_magenta() { echo -e ${magenta}$@${none}; }
_red_bg() { echo -e "\e[41m$@${none}"; }

is_err=$(_red_bg 错误!)
is_warn=$(_red_bg 警告!)

err() {
    echo -e "\n$is_err $@\n" && exit 1
}

warn() {
    echo -e "\n$is_warn $@\n"
}

# root
[[ $EUID != 0 ]] && err "当前非 ${yellow}ROOT用户.${none}"

# yum or apt-get, ubuntu/debian/centos
cmd=$(type -P apt-get || type -P yum)
[[ ! $cmd ]] && err "此脚本仅支持 ${yellow}(Ubuntu or Debian or CentOS)${none}."

# systemd
[[ ! $(type -P systemctl) ]] && {
    err "此系统缺少 ${yellow}(systemctl)${none}, 请尝试执行:${yellow} ${cmd} update -y;${cmd} install systemd -y ${none}来修复此错误."
}

# wget installed or none
is_wget=$(type -P wget)

# x64
case $(uname -m) in
amd64 | x86_64)
    is_jq_arch=amd64
    is_core_arch="64"
    ;;
*aarch64* | *armv8*)
    is_jq_arch=arm64
    is_core_arch="arm64-v8a"
    ;;
*)
    err "此脚本仅支持 64 位系统..."
    ;;
esac

is_core=v2ray
is_core_name=V2Ray
is_core_dir=/etc/$is_core
is_core_bin=$is_core_dir/bin/$is_core
is_core_repo=v2fly/$is_core-core
is_conf_dir=$is_core_dir/conf
is_log_dir=/var/log/$is_core
is_sh_bin=/usr/local/bin/$is_core
is_sh_dir=$is_core_dir/sh
is_sh_repo=$author/$is_core
is_pkg="wget unzip"
is_config_json=$is_core_dir/config.json
tmp_var_lists=(
    tmpcore
    tmpsh
    tmpjq
    is_core_ok
    is_sh_ok
    is_jq_ok
    is_pkg_ok
)

# tmp dir
tmpdir=$(mktemp -u)
[[ ! $tmpdir ]] && {
    tmpdir=/tmp/tmp-$RANDOM
}

# set up var
for i in ${tmp_var_lists[*]}; do
    export $i=$tmpdir/$i
done

# load bash script.
load() {
    . $is_sh_dir/src/$1
}

# wget add --no-check-certificate
_wget() {
    [[ $proxy ]] && export https_proxy=$proxy
    wget --no-check-certificate $*
}

# print a mesage
msg() {
    case $1 in
    warn)
        local color=$yellow
        ;;
    err)
        local color=$red
        ;;
    ok)
        local color=$green
        ;;
    esac

    echo -e "${color}$(date +'%T')${none}) ${2}"
}

# show help msg
show_help() {
    echo -e "Usage: $0 [-f xxx | -l | -p xxx | -v xxx | -h]"
    echo -e "  -f, --core-file <path>          自定义 $is_core_name 文件路径, e.g., -f /root/${is_core}-linux-64.zip"
    echo -e "  -l, --local-install             本地获取安装脚本, 使用当前目录"
    echo -e "  -p, --proxy <addr>              使用代理下载, e.g., -p http://127.0.0.1:2333 or -p socks5://127.0.0.1:2333"
    echo -e "  -v, --core-version <ver>        自定义 $is_core_name 版本, e.g., -v v5.4.1"
    echo -e "  -h, --help                      显示此帮助界面\n"

    exit 0
}

# install dependent pkg
install_pkg() {
    cmd_not_found=
    for i in $*; do
        [[ ! $(type -P $i) ]] && cmd_not_found="$cmd_not_found,$i"
    done
    if [[ $cmd_not_found ]]; then
        pkg=$(echo $cmd_not_found | sed 's/,/ /g')
        msg warn "安装依赖包 >${pkg}"
        $cmd install -y $pkg &>/dev/null
        if [[ $? != 0 ]]; then
            [[ $cmd =~ yum ]] && yum install epel-release -y &>/dev/null
            $cmd update -y &>/dev/null
            $cmd install -y $pkg &>/dev/null
            [[ $? == 0 ]] && >$is_pkg_ok
        else
            >$is_pkg_ok
        fi
    else
        >$is_pkg_ok
    fi
}

# download file
download() {
    case $1 in
    core)
        link=https://github.com/${is_core_repo}/releases/latest/download/${is_core}-linux-${is_core_arch}.zip
        [[ $is_core_ver ]] && link="https://github.com/${is_core_repo}/releases/download/${is_core_ver}/${is_core}-linux-${is_core_arch}.zip"
        name=$is_core_name
        tmpfile=$tmpcore
        is_ok=$is_core_ok
        ;;
    sh)
        link=https://github.com/${is_sh_repo}/releases/latest/download/code.zip
        name="$is_core_name 脚本"
        tmpfile=$tmpsh
        is_ok=$is_sh_ok
        ;;
    jq)
        link=https://github.com/jqlang/jq/releases/download/jq-1.7rc1/jq-linux-$is_jq_arch
        name="jq"
        tmpfile=$tmpjq
        is_ok=$is_jq_ok
        ;;
    esac

    msg warn "下载 ${name} > ${link}"
    if _wget -t 3 -q -c $link -O $tmpfile; then
        mv -f $tmpfile $is_ok
    fi
}

# get server ip
get_ip() {
    export "$(_wget -4 -qO- https://one.one.one.one/cdn-cgi/trace | grep ip=)" &>/dev/null
    [[ -z $ip ]] && export "$(_wget -6 -qO- https://one.one.one.one/cdn-cgi/trace | grep ip=)" &>/dev/null
}

# check background tasks status
check_status() {
    # dependent pkg install fail
    [[ ! -f $is_pkg_ok ]] && {
        msg err "安装依赖包失败"
        is_fail=1
    }

    # download file status
    if [[ $is_wget ]]; then
        [[ ! -f $is_core_ok ]] && {
            msg err "下载 ${is_core_name} 失败"
            is_fail=1
        }
        [[ ! -f $is_sh_ok ]] && {
            msg err "下载 ${is_core_name} 脚本失败"
            is_fail=1
        }
        [[ ! -f $is_jq_ok ]] && {
            msg err "下载 jq 失败"
            is_fail=1
        }
    else
        [[ ! $is_fail ]] && {
            is_wget=1
            [[ ! $is_core_file ]] && download core &
            [[ ! $local_install ]] && download sh &
            [[ $jq_not_found ]] && download jq &
            get_ip
            wait
            check_status
        }
    fi

    # found fail status, remove tmp dir and exit.
    [[ $is_fail ]] && {
        exit_and_del_tmpdir
    }
}

# parameters check
pass_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
        online)
            err "如果想要安装旧版本, 请转到: https://github.com/233boy/v2ray/tree/old"
            ;;
        -f | --core-file)
            [[ -z $2 ]] && {
                err "($1) 缺少必需参数, 正确使用示例: [$1 /root/$is_core-linux-64.zip]"
            } || [[ ! -f $2 ]] && {
                err "($2) 不是一个常规的文件."
            }
            is_core_file=$2
            shift 2
            ;;
        -l | --local-install)
            [[ ! -f ${PWD}/src/core.sh || ! -f ${PWD}/$is_core.sh ]] && {
                err "当前目录 (${PWD}) 非完整的脚本目录."
            }
            local_install=1
            shift 1
            ;;
        -p | --proxy)
            [[ -z $2 ]] && {
                err "($1) 缺少必需参数, 正确使用示例: [$1 http://127.0.0.1:2333 or -p socks5://127.0.0.1:2333]"
            }
            proxy=$2
            shift 2
            ;;
        -v | --core-version)
            [[ -z $2 ]] && {
                err "($1) 缺少必需参数, 正确使用示例: [$1 v1.8.1]"
            }
            is_core_ver=v${2#v}
            shift 2
            ;;
        -h | --help)
            show_help
            ;;
        *)
            echo -e "\n${is_err} ($@) 为未知参数...\n"
            show_help
            ;;
        esac
    done
    [[ $is_core_ver && $is_core_file ]] && {
        err "无法同时自定义 ${is_core_name} 版本和 ${is_core_name} 文件."
    }
}

# exit and remove tmpdir
exit_and_del_tmpdir() {
    rm -rf $tmpdir
    [[ ! $1 ]] && {
        msg err "哦豁.."
        msg err "安装过程出现错误..."
        echo -e "反馈问题) https://github.com/${is_sh_repo}/issues"
        echo
        exit 1
    }
    exit
}

# main
main() {

    # check old version
    [[ -f $is_sh_bin && -d $is_core_dir/bin && -d $is_sh_dir && -d $is_conf_dir ]] && {
        err "检测到脚本已安装, 如需重装请使用${green} ${is_core} reinstall ${none}命令."
    }

    # check parameters
    [[ $# -gt 0 ]] && pass_args $@

    # show welcome msg
    clear
    echo
    echo "........... $is_core_name script by $author .........."
    echo

    # start installing...
    msg warn "开始安装..."
    [[ $is_core_ver ]] && msg warn "${is_core_name} 版本: ${yellow}$is_core_ver${none}"
    [[ $proxy ]] && msg warn "使用代理: ${yellow}$proxy${none}"
    # create tmpdir
    mkdir -p $tmpdir
    # if is_core_file, copy file
    [[ $is_core_file ]] && {
        cp -f $is_core_file $is_core_ok
        msg warn "${yellow}${is_core_name} 文件使用 > $is_core_file${none}"
    }
    # local dir install sh script
    [[ $local_install ]] && {
        >$is_sh_ok
        msg warn "${yellow}本地获取安装脚本 > $PWD ${none}"
    }

    timedatectl set-ntp true &>/dev/null
    [[ $? != 0 ]] && {
        msg warn "${yellow}\e[4m提醒!!! 无法设置自动同步时间, 可能会影响使用 VMess 协议.${none}"
    }

    # install dependent pkg
    install_pkg $is_pkg &

    # jq
    if [[ $(type -P jq) ]]; then
        >$is_jq_ok
    else
        jq_not_found=1
    fi
    # if wget installed. download core, sh, jq, get ip
    [[ $is_wget ]] && {
        [[ ! $is_core_file ]] && download core &
        [[ ! $local_install ]] && download sh &
        [[ $jq_not_found ]] && download jq &
        get_ip
    }

    # waiting for background tasks is done
    wait

    # check background tasks status
    check_status

    # test $is_core_file
    if [[ $is_core_file ]]; then
        unzip -qo $is_core_ok -d $tmpdir/testzip &>/dev/null
        [[ $? != 0 ]] && {
            msg err "${is_core_name} 文件无法通过测试."
            exit_and_del_tmpdir
        }
        for i in ${is_core} geoip.dat geosite.dat; do
            [[ ! -f $tmpdir/testzip/$i ]] && is_file_err=1 && break
        done
        [[ $is_file_err ]] && {
            msg err "${is_core_name} 文件无法通过测试."
            exit_and_del_tmpdir
        }
    fi

    # get server ip.
    [[ ! $ip ]] && {
        msg err "获取服务器 IP 失败."
        exit_and_del_tmpdir
    }

    # create sh dir...
    mkdir -p $is_sh_dir

    # copy sh file or unzip sh zip file.
    if [[ $local_install ]]; then
        cp -rf $PWD/* $is_sh_dir
    else
        unzip -qo $is_sh_ok -d $is_sh_dir
    fi

    # create core bin dir
    mkdir -p $is_core_dir/bin
    # copy core file or unzip core zip file
    if [[ $is_core_file ]]; then
        cp -rf $tmpdir/testzip/* $is_core_dir/bin
    else
        unzip -qo $is_core_ok -d $is_core_dir/bin
    fi

    # add alias
    echo "alias $is_core=$is_sh_bin" >>/root/.bashrc

    # core command
    ln -sf $is_sh_dir/$is_core.sh $is_sh_bin

    # jq
    [[ $jq_not_found ]] && mv -f $is_jq_ok /usr/bin/jq

    # chmod
    chmod +x $is_core_bin $is_sh_bin /usr/bin/jq

    # create log dir
    mkdir -p $is_log_dir

    # show a tips msg
    msg ok "生成配置文件..."

    # create systemd service
    load systemd.sh
    is_new_install=1
    install_service $is_core &>/dev/null

    # create condf dir
    mkdir -p $is_conf_dir

    load core.sh
    # create a tcp config
    add tcp
    # remove tmp dir and exit.
    exit_and_del_tmpdir ok
}

# start.
main $@
```

### 2. 安装V2Ray

bash <(curl -s -L https://git.io/bwg_v2ray)

![image-20250115144505365](C:\Users\C\AppData\Roaming\Typora\typora-user-images\image-20250115144505365.png)

## 管理V2Ray代理

成功安装V2Ray后，我们直接输入`v2ray`即可打开管理页面，如下图，之后就是按提示操作即可，如果你不想执行任何功能，直接按 Enter 回车退出即可）：

![image-20250115144615426](C:\Users\C\AppData\Roaming\Typora\typora-user-images\image-20250115144615426.png)

新的V2Ray脚本简化了很多流程，例如我们常用的是 (添加、更改、查看、删除) 配置，以下内容让你可以快速掌握使用

**1、添加配置**

- `v2ray add` -> 添加配置
- `v2ray add ss` -> 添加一个 Shadowsocks 配置
- `v2ray add tcp` -> 添加一个 VMess-TCP 配置
- `v2ray add kcpd` -> 添加一个 VMess-mKCP-dynamic-port 动态端口配置

备注，使用 `v2ray add` 添加配置的时候，仅 *TLS 相关协议配置必须提供域名，其他均可自动化处理。

如需查看更多 add 参数用法，请查看下面的 add 说明

**2、更改配置**

- `v2ray change` -> 更改配置
- `v2ray change tcp` -> 更改 TCP 相关配置
- `v2ray change tcp port auto` -> 更改 TCP 相关配置的端口，端口使用自动创建，也可以使用 `v2ray port tcp auto`
- `v2ray change kcp id auto` -> 更改 mKCP 相关配置的 UUID，UUID 使用自动创建，也可以使用 `v2ray id tcp auto`

如需查看更多 change 参数用法，请查看下面的 change 说明

**3、查看配置：**

- `v2ray info` -> 查看配置
- `v2ray info tcp` -> 查看 TCP 相关配置
- `v2ray info kcp` -> 查看 kcp 相关配置

**4、删除配置**

- `v2ray del` -> 删除配置
- `v2ray del kcp` -> 删除 KCP 相关配置
- `v2ray del tcp` -> 删除 TCP 相关配置

**提醒，谨慎使用 del 参数**

## 配置V2Ray客户端

完成V2Ray服务端搭建后，我们就需要在本地客户端配置V2Ray了，支持iOS、Android手机、Mac、Windows等，其实就是在客户端上填入上一步的连接信息即可。

链接：https://github.com/bwgvps/v2ray-tutorial/wiki/iOS%E8%8B%B9%E6%9E%9C%E6%89%8B%E6%9C%BA%E5%AE%A2%E6%88%B7%E7%AB%AFShadowrocket%E4%B8%8B%E8%BD%BD%E6%96%B9%E6%B3%95%E4%B8%8E%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B



## 转换vmess 转clash订阅

格式转换地址： https://subconverter.speedupvpn.com/

gitlab地址：https://github.com/CareyWang/sub-web.git



## 搭建V2Ray常见问题

无法使用一般都是两种情况，一是无法连接上端口，二是客户端内核支持有问题。

如果你的 VPS 有外部防火墙，请确保你已经开放了端口

测试端口是否能连接上：

打开：https://tcp.ping.pe/

写上你的 VPS IP 跟端口；内容为 ip:端口，示例：`1.1.1.1:443`，然后点击 `Go`；或者直接回车

如果显示 successful；证明端口能连接；如果显示 failed；那是无法连接上端口。

提醒，你可以使用 `v2ray ip` 查看 VPS IP。

关闭防火墙，执行如下命令：

```
systemctl stop firewalld; systemctl disable firewalld; ufw disable
```

关闭防火墙之后再测试一下端口是否通，如果不通，你可能还有外部防火墙没关， **必须要能连接上端口才能正常使用** 。

如果能连接上端口，那就继续

使用 `v2ray add ss` 添加一个 SS 看看能不能正常使用，如果正常使用，证明运行没有问题。

提醒，默认安装的 V2Ray 内核为最新版本

如果无法使用，可能是你客户端的内核太旧

请尝试使用不同的客户端进行测试；比如 v2rayN；v2rayNG 等

请尝试设置 VMessAEAD，某些客户端会有相关选项

某些客户端得把 额外id(alterid) 填写为 0；比如垃圾苹果那边的东西

解决方案一，请尝试将服务器端的内核版本降级

使用 `v2ray update core 4.45.2` 降级即可

解决方案二，升级客户端内核

> 备注，请尽量将客户端内核和服务器端内核保持一致！**内核版本低于 5 可能会出现莫名其妙的问题**

在使用过程中一般不会出现问题，直接选择下一步就可以了，如果你的系统不支持使用这个脚本，可以尝试更换一个系统，支持Ubuntu 16+ / Debian 8+ / CentOS 7+，推荐使用 Debian 9 系统，脚本会自动启用 BBR 优化。