#!/bin/sh

file=$1
times=$2
delay=$3

usage()
{
    echo "usage: $0 file [times] [delay_for_each_sleep]" 1>&2
    exit $1
}

if [ "$file" = "" ] || [ $# -gt 3 ]; then
    usage 1
fi

if [ "$times" = "" ]; then
    if [ $file = "-h" ] || [ $file = "--help" ]; then
        usage 0
    fi
fi

if [ "$delay" = "" ]; then
    delay=0.01
fi

i=0
while true;
do
    if [ -e $file ]; then
        exit 0
    fi

    if [ "$i" = "$times" ]; then
        echo "failed to wait: $file" 1>&2
        exit 1;
    fi

    let i=i+1
    sleep $delay
done

exit 0
