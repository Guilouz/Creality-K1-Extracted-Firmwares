#!/bin/sh

#set -x
FILE=/usr/data/wpa_supplicant.conf

# 取priority的所在行信息
grep -n '^\	priority=' ${FILE} > /tmp/.tmp.log

# 保留行号和priority值，格式：line:priority
sed 's/\tpriority=//' /tmp/.tmp.log > /tmp/.tmp1.log

# 将priority进行排序
sort -n -t':' -k 2 /tmp/.tmp1.log > /tmp/.tmp2.log

# 替换priority值
line_max=$(cat /tmp/.tmp2.log | wc -l)
line=
priority=
n=1
while [ ${n} -le ${line_max} ]
do
	line=$(sed -n ${n}p /tmp/.tmp2.log | awk -F':' '{print $1}')
	priority=$(sed -n ${n}p /tmp/.tmp2.log | awk -F':' '{print $2}')
	# 替换priority值
	sed -i "${line}c\	priority=${n}" ${FILE}
	n=$(expr ${n} + 1)
done

rm /tmp/.tmp.log /tmp/.tmp1.log /tmp/.tmp2.log
