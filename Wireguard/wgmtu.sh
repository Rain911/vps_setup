#!/bin/bash

# 定义文字颜色
Green="\033[32m"  && Red="\033[31m" && GreenBG="\033[42;37m" && RedBG="\033[41;37m" && Font="\033[0m"

# 修改mtu数值
setmtu(){
    echo -e "${GreenBG}WireGuard 修改服务器端MTU值，最大效率加大网速，默认值 MTU = 1420 "
    echo -e "WireGuard 客户端可以MTU参数自动，请修改电脑客户端TunSafe配置把MTU行注释掉。${Font}"
    read -p "请输入数字(1200--1500): " num

    if [[ ${num} -ge 1200 ]] && [[ ${num} -le 1500 ]]; then
       mtu=$num
    else
       mtu=1420
    fi

    wg-quick down wg0
    sed -i "s/MTU = .*$/MTU = ${mtu}/g"  /etc/wireguard/wg0.conf

    wg-quick up wg0

    echo -e "${RedBG}    服务器端MTU值已经修改!    ${Font}"

}


# 修改端口号
setport(){
    echo -e "${GreenBG}修改 WireGuard 服务器端端口号，客户端要自行修改${Font}"
    read -p "请输入数字(100--60000): " num

    if [[ ${num} -ge 100 ]] && [[ ${num} -le 60000 ]]; then
       port=$num
       wg-quick down wg0
       sed -i "s/ListenPort = .*$/ListenPort = ${port}/g"  /etc/wireguard/wg0.conf
       wg-quick up wg0
       echo -e "${RedBG}    端口号已经修改!    ${Font}"
    else
       echo -e "${RedBG}    没有修改端口号!    ${Font}"
    fi

}

# 显示手机客户端二维码
wgconf()
{
    echo -e "${RedBG}:: 显示手机客户端二维码  (如改端口,请先菜单5重置客户端配置)  ${Font}"
    read -p "请输入数字(2-9)，默认2号: " x

    if [[ ${x} -ge 2 ]] && [[ ${x} -le 9 ]]; then
       i=$x
    else
       i=2
    fi

    host=$(hostname -s)

    cat /etc/wireguard/wg_${host}_$i.conf | qrencode -o - -t UTF8

    echo -e "${GreenBG}:: 配置文件: wg_${host}_$i.conf 生成二维码，请用手机客户端扫描使用 ${Font}"

}

# 重置 WireGuard 客户端配置和数量
wg_clients()
{
    echo -e "${RedBG}:: 注意原来的客户端配置都会删除，按 Ctrl+ C 可以紧急撤销  ${Font}"
    read -p "请任意键继续:" xx
    wget -O ~/wg100  https://git.io/fp6r0    >/dev/null 2>&1
    bash ~/wg100
}

# 安装Udp2Raw服务TCP伪装，高级的加速伪装脚本以后看情况开源
udp2raw()
{
    wget -qO- https://git.io/fpKnF | bash
    echo -e "${RedBG}:: WireGuard 使用 Udp2Raw 需要把 MTU 设置成1200-1300  ${Font}"
    echo -e "${GreenBG}:: 您可以在本脚本基础上，修改成加速脚本！... 你懂的！${Font}"
}

# 主菜单输入数字 88
# 隐藏功能:从源VPS克隆服务端配置，共用客户端配置
scp_conf()
{
    echo -e "${RedBG}:: 警告: 警告: 警告: VPS服务器已经被GFW防火墙关照，按 Ctrl+ C 可以紧急逃离！  ${Font}"
    echo  "隐藏功能:从源VPS克隆服务端配置，共用客户端配置"
    read -p "请输入源VPS的IP地址(域名):"  vps_ip
    cmd="scp root@${vps_ip}:/etc/wireguard/*  /etc/wireguard/. "
    echo -e "${GreenBG}#  ${cmd}  ${Font}   现在运行scp命令，按提示输入yes，源vps的root密码"
    ${cmd}

    wg-quick down wg0   >/dev/null 2>&1
    wg-quick up wg0     >/dev/null 2>&1
    echo -e "${RedBG}    我真不知道WG服务器端是否已经使用源vps的配置启动!    ${Font}"
}

# 主菜单输入数字 188   隐藏功能: 一键全家桶
onekey_plus()
{
    echo -e "${RedBG}           一键安装设置全家桶    by 蘭雅sRGB             ${Font}"
    cat  <<EOF
  #  Google Cloud Platform GCP实例开启密码与root用户登陆
  wget -qO- git.io/fpQWf | bash

  # 一键安装 vnstat 流量检测   by 蘭雅sRGB
  wget -qO- git.io/fxxlb | bash

  # 一键安装wireguard 脚本 Debian 9  (源:逗比网安装笔记)
  wget -qO- git.io/fptwc | bash

  # 一键 WireGuard 多用户配置共享脚本   by 蘭雅sRGB
  wget -qO- https://git.io/fpnQt | bash

  # 一键安装 SS+Kcp+Udp2Raw 脚本 快速安装 for Debian 9
  wget -qO- git.io/fpZIW | bash

  # 一键安装 SS+Kcp+Udp2Raw 脚本 for Debian 9  Ubuntu (编译安装)
  wget -qO- git.io/fx6UQ | bash

  # Telegram 代理 MTProxy Go版 一键脚本(源:逗比网)
  wget -qO mtproxy_go.sh  git.io/fpWo4 && bash mtproxy_go.sh

  # linux下golang环境搭建自动脚本  by 蘭雅sRGB
  wget -qO- https://git.io/fp4jf | bash

  # SuperBench.sh 一键测试服务器的基本参数
  wget -qO- git.io/superbench.sh | bash

  # 使用BestTrace查看VPS的去程和回程
  wget -qO- git.io/fp5lf | bash

  # qrencode 生成二维码 -o- 参数显示在屏幕 -t utf8 文本格式
  cat wg_vultr_5.conf  | qrencode -o- -t utf8
  
EOF
    echo -e "${GreenBG}    开源项目：https://github.com/hongwenjun/vps_setup    ${Font}"
}

# 更新wgmtu脚本
update()
{
    # 安装 bash wgmtu 脚本用来设置服务器
    wget -O ~/wgmtu  https://raw.githubusercontent.com/hongwenjun/vps_setup/master/Wireguard/wgmtu.sh >/dev/null 2>&1
}

# 设置菜单
start_menu(){
    echo -e "${RedBG}   一键安装 WireGuard 脚本 For Debian_9 Ubuntu Centos_7   ${Font}"
    echo -e "${GreenBG}     开源项目：https://github.com/hongwenjun/vps_setup    ${Font}"
    echo -e "${Green}>  1. 显示手机客户端二维码"
    echo -e ">  2. 修改 WireGuard 服务器端 MTU 值"
    echo -e ">  3. 修改 WireGuard 端口号  (如改端口,菜单5重置客户端配置)"
    echo -e ">  4. 安装Udp2Raw服务TCP伪装 WireGuard 服务端设置"
    echo -e ">  5. 重置 WireGuard 客户端配置和数量，方便修改过端口或者机场大佬"
    echo -e ">  6. 退出设置${Font}"
    echo
    read -p "请输入数字(1-6):" num
    case "$num" in
        1)
        wgconf
        ;;
        2)
        setmtu
        ;;
        3)
        setport
        ;;
        4)
        udp2raw
        ;;
        5)
        wg_clients
        ;;
        6)
        update
        exit 1
        ;;
        88)
        scp_conf
        ;;
        188)
        onekey_plus
        ;;
        *)
        echo
        echo "请输入正确数字"
        ;;
        esac
}

start_menu
