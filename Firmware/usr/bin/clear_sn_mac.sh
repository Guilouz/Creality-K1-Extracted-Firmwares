#!/bin/sh

get_str_len()
{
    local len=$(echo -n $1 | wc -c)
    echo -n $len
}

if [ $# -eq 1  -o $# -eq 2 ]; then

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
    MACHINE_SN=$(echo $tmp | awk -F ';' '{print $6}')

    if [ $# -eq 1 ]; then
        if [ "$PARAM" = "pcba_test" -a "x$PCBA_TEST" = "x1" ]; then
            output="$SN;$MAC;$MODEL;$BOARD;0;;;;"
            echo -n $output | dd of=$BLK bs=512 count=1 2>/dev/null
            sync
        else
            # Caution:
            # We should only support to clear pcba_test flag!
            exit 1
        fi
    elif [ $# -eq 2 ]; then
        if [ "$PARAM" = "machine_sn" -a "x$2" != "x" ]; then
            if [ $(get_str_len $MACHINE_SN) -le $(get_str_len $2) ]; then
                output="$SN;$MAC;$MODEL;$BOARD;$PCBA_TEST;$2;;;"
                echo -n $output | dd of=$BLK bs=512 count=1 2>/dev/null
                sync
            else
                # Caution:
                # If the len of new string is less than old string, we
                # should clear all first, and then write!
                exit 1
            fi
        fi
    fi

else
    exit 1
fi
