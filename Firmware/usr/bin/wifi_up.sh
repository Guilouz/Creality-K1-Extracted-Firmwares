#!/bin/sh

# 刷新配置内的优先级
sh /usr/bin/refresh_wpa_supplicant.sh

# 使用传参
if [ "$1" != "" ]; then
    wpa_conf=$1

# 使用环境变量
elif [ "${env_wifi_wpa_supplicant_conf}" != "" ]; then
    wpa_conf=${env_wifi_wpa_supplicant_conf}

# 使用默认配置
elif [ -f /usr/data/wpa_supplicant.conf ]; then
    wpa_conf=/usr/data/wpa_supplicant.conf
fi

rfkill unblock wifi
ifconfig wlan0 up

SN_NUM=
if [ "$wpa_conf" != "" ]; then
    wpa_supplicant -B -i wlan0 -c $wpa_conf &
    # 获取sn号
    SN_NUM=$(sh /usr/bin/get_sn_mac.sh sn 2>&1)
    SN_NUM=${SN_NUM:0-4}
    #udhcpc -i wlan0 &
    udhcpc -i wlan0 -x hostname:$(hostname)-${SN_NUM} &
fi
