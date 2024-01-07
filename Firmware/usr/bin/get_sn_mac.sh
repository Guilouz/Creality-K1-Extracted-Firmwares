#!/bin/sh

if [ ! $# -eq 1 ]; then
	#echo "without parameter(sn or mac)."
	exit 1
fi

# 传参转为小写
PARAM=$(echo $1 | tr 'A-Z' 'a-z')

# 获取SN_MAC的分区号
BLK_NUM=$(fdisk -l | grep 'sn_mac' | awk '{print $1}')
BLK=/dev/mmcblk0p${BLK_NUM}

# 读取SN_MAC分区号的内容(格式:"sn"14 + ';' + "mac"12 + ';' + 上位机 + ';' + 5个下位机)
tmp=$(dd if=${BLK} count=1 2>/dev/null)

# sn
SN=${tmp%%;*}
# 去掉sn部分
tmp=${tmp#*;}
# mac
MAC=${tmp%%;*}
# 去掉mac部分
tmp=${tmp#*;}
# model
MODEL=${tmp%%;*}
# 去掉model
tmp=${tmp#*;}
# board
BOARD=${tmp%%;*}

# sn校验 -- 长度14，由0-9a-fA-F组成
check_sn()
{
	local result=$(echo $1 | sed -n '/^[0-9A-Fa-f]\{14\}$/ p')
	#echo "result:${result}"
	if [ "${result}" = "" ]; then
	#echo "sn is invalid"
		return 1
	fi
	return 0
}

# mac校验 -- 长度12，由0-9a-fA-F组成
check_mac()
{
	local result=$(echo $1 | sed -n '/^[0-9A-Fa-f]\{12\}$/ p')
	local macaddr=
	#echo "result:${result}"
	if [ "${result}" = "" ]; then
		#echo "mac is invalid"
		return 1
	fi
	return 0
}

if [ $PARAM = "sn" ]; then
	# 获取序列号
	check_sn ${SN}
	if [ $? != 0 ]; then
		echo "00000000000000"
		exit 1
	fi
	echo ${SN}
elif [ $PARAM = "mac" ]; then
	# 获取MAC地址
	check_mac ${MAC}
	if [ $? != 0 ]; then
		# 从macaddr.txt中获取
		if [ -f /usr/data/macaddr.txt ]; then
			MAC=$(cat /usr/data/macaddr.txt | sed 's/[^0-9|a-f|A-F]//g')
			if [ "${#MAC}" = "12" ]; then
				echo ${MAC}
				exit 0
			fi
		fi
		# 从efuse chip_id中获取
		if [ -f /sys/class/misc/efuse-string-version/dev ]; then
			MAC=$(cmd_efuse read CHIP_ID)
			MAC=d03110${MAC:0:6}
			echo ${MAC}
			exit 0
		fi
		# 从随机数中获取
		if [ -f /proc/sys/kernel/random/uuid ]; then
			MAC=$(cat /proc/sys/kernel/random/uuid | sed 's/[^0-9|a-f|A-F]//g')
			MAC=d03110${MAC:0:6}
			echo ${MAC}
			exit 0
		fi
	fi
	echo ${MAC}
elif [ $PARAM = "model" ]; then
	echo ${MODEL}
elif [ $PARAM = "board" ]; then
	echo ${BOARD}
else
#	echo "parameter only \"sn\", \"mac\", \"model\", \"board\""
#	echo "Case-insensitive"
	exit 1
fi
