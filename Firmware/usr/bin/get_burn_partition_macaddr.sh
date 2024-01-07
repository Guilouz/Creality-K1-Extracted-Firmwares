#!/bin/sh
is_digital()
{
    local d=$1
    local tmp=$1

    let d=d+1 2>/dev/null
    if [ $d = $tmp ]; then
        return 1
    fi

    d=$tmp

    let d=d+0 2>/dev/null
    if [ $tmp != $d ]; then
        return 1
    fi

    return 0
}

get_word()
{
    local str="$1"
    local n=$2
    local i=0

    for word in $str
    do
        if [ $i = $n ]; then
            echo $word
            return 0
        fi
        let i=i+1
    done

    return 1
}

############ mmc ############
mmc_name_to_dev()
{
    local partition_name=$1

    while read line;
    do
        line=`echo "$line" | grep mmcblk`
        if [ "$line" = "" ]; then
            continue
        fi

        str=`get_word "$line" 3`
        is_digital ${str#mmcblk}
        if [ $? != 0 ]; then
            continue
        fi

        dev=/dev/$str
        str=`fdisk -l $dev | grep -w $partition_name`
        if [ "$str" = "" ]; then
            continue
        fi

        tmp=`get_word "$str" 5`
        if [ "$tmp" = "" ]; then
        tmp=`get_word "$str" 4`
        fi

        if [ "$tmp" != "$partition_name" ]; then
            continue
        fi

        is_ok=0
        is_digital `get_word "$str" 0` && \
        is_digital `get_word "$str" 1` && \
        is_digital `get_word "$str" 2` && \
        is_ok=1

        if [ $is_ok != 1 ]; then
            continue
        fi

        detect_dev=${dev}p`get_word "$str" 0`
        break;
    done < /proc/partitions

    echo $detect_dev
}

mmc_read_str()
{
    local partition_name=$1
    local dev

    dev=`mmc_name_to_dev "$partition_name"`
    if [ $? != 0 ]; then
        return 1
    fi

    dd if=$dev bs=1 count=12
    if [ $? != 0 ]; then
        return 1
    fi

    return 0
}
############ mmc ############

############ mtd ############
mtd_name_to_num()
{
    local partition_name=$1
    local mtd_info=`cat /proc/mtd | grep \""$partition_name"\"`
    if [ "$mtd_info" = "" ]; then
        echo "mtd partition not find: $partition_name" 1>&2
        return 1
    fi

    local mtd_n=${mtd_info%%:*}
    if [ "$mtd_info" = "$mtd_n" ]; then
        echo "mtd_info not ok: $mtd_info" 1>&2
        return 1
    fi

    local n=${mtd_n#mtd}
    if [ "$n" = "$mtd_n" ]; then
        echo "mtd_info not ok2: $mtd_n" 1>&2
        return 1
    fi

    echo $n
}

mtd_name_to_dev()
{
    local partition_name=$1
    local num

    num=`mtd_name_to_num $partition_name`
    if [ $? != 0 ]; then
        return 1
    fi

    local dev=/dev/mtd$num
    if [ ! -e $dev ]; then
        echo "why $dev not exist" 1>&2
        return 1
    fi

    echo $dev
}

mtd_read_str()
{
    local partition_name=$1
    local dev

    dev=`mtd_name_to_dev "$partition_name"`
    if [ $? != 0 ]; then
        return 1
    fi

    nanddump -s 0 -l 12 $dev -a
    if [ $? != 0 ]; then
        return 1
    fi

    return 0
}
############ mtd ############

macaddr=`mtd_read_str "mac"` 2>/dev/null
if [ $? != 0 ]; then
    #macaddr=`mmc_read_str "mac"` 2>/dev/null
    macaddr=`get_sn_mac.sh mac`
    if [ $? != 0 ]; then
        # echo "error can't find mac partition!" 1>&2
        exit 1
    fi
fi

if [ ${#macaddr} != 12 ]; then
    echo "Please burn valibe macaddr!\n" 1>&2
    exit 1
fi

macaddr=$(echo $macaddr | sed 's/[^0-9|a-f|A-F]//g')

if [ ${#macaddr} != 12 ]; then
    echo "Please burn valibe macaddr!\n" 1>&2
    exit 1
fi

echo $macaddr
