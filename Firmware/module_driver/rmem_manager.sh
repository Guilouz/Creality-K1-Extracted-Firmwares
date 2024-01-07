#!/bin/sh

rmem_start=0
rmem_size=0

cmdline=`cat /proc/cmdline`

for str in $cmdline;
do
    if [ "${str#rmem=}" = "$str" ]; then
        continue
    fi

    str=${str#rmem=}

    if [ "${str%%M@*}" = "$str" ]; then
        continue
    fi

    rmem_size=${str%M@*}
    rmem_start=${str#*M@}

    let rmem_start=rmem_start+0
    if [ $? != 0 ]; then
        rmem_start=0
        rmem_size=0
        continue
    fi

    let rmem_size=rmem_size*1024*1024
    if [ $? != 0 ]; then
        rmem_start=0
        rmem_size=0
        continue
    fi

    break
done

insmod rmem_manager.ko  rmem_start=$rmem_start rmem_size=$rmem_size
