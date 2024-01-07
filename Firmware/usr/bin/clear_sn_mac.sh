#!/bin/sh

if [ $# -ne 1 ]; then
    exit 1
fi

PARAM=$(echo $1 | tr 'A-Z' 'a-z')

BLK_NUM=$(fdisk -l | grep 'sn_mac' | awk '{print $1}')
BLK=/dev/mmcblk0p${BLK_NUM}

tmp=$(dd if=${BLK} bs=512 count=1 2>/dev/null)

count=$(echo $tmp | awk -F ';' '{print NF-1}')
if [ $count -ne 8 ]; then
    exit 1
fi

SN=$(echo $tmp | awk -F ';' '{print $1}')
MAC=$(echo $tmp | awk -F ';' '{print $2}')
MODEL=$(echo $tmp | awk -F ';' '{print $3}')
BOARD=$(echo $tmp | awk -F ';' '{print $4}')
PCBA_TEST=$(echo $tmp | awk -F ';' '{print $5}')

if [ "$PARAM" = "pcba_test" -a "x$PCBA_TEST" = "x1" ]; then
    output="$SN;$MAC;$MODEL;$BOARD;0;;;;"
    echo -n $output | dd of=$BLK bs=512 count=1 2>/dev/null
    sync
else
    # Caution:
    # We should only support to clear pcba_test flag!
    exit 1
fi
