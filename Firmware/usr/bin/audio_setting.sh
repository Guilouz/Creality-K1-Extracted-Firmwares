#!/bin/sh

#set -x

ASOUND_STATE=/etc/asound.state

volume_array0="0"
volume_array1="2"
volume_array2="4"
volume_array3="6"
volume_array4="8"
volume_array5="9"
volume_array6="11"
volume_array7="13"
volume_array8="14"
volume_array9="15"
volume_array10="16"

get_volume()
{
    values=$(amixer -Dhw:icodecsoundcard cget name='Master Playback Volume' | grep ": values=" | cut -d '=' -f 2)
    echo $values
}

set_volume()
{
#    echo "set_volume $1"
    amixer -D hw:icodecsoundcard cset name='Master Playback Volume' $1 >/dev/null 2>&1
    [ ! -f $ASOUND_STATE ] && touch $ASOUND_STATE
    alsactl store -f $ASOUND_STATE && sync
}


if [ $# -eq 1 ]; then

    param=$1
#    echo "set volume $param"
    [ $param -gt 10 ] && param=10
    [ $param -lt 0 ] && param=0

    for i in $(seq 0 10)
    do
        [ $i -eq $param ] && {
            eval vol=$"volume_array$i"
            set_volume $vol
            break
        }
    done

    exit 0

elif [ $# -eq 0 ]; then

    cur_vol=$(get_volume)
#    echo "current volume $cur_vol"

    for i in $(seq 0 10)
    do
        eval volume=$"volume_array$i"
        [ "x$cur_vol" = "x$volume" ] && break
    done

    echo "$i"

    exit 0

else

    echo "unsupport operation!"

    exit 1
fi
