#!/bin/sh

#set -x

MAX_BRIGHTNESS=/sys/class/backlight/backlight_pwm0/max_brightness
BRIGHTNESS=/sys/class/backlight/backlight_pwm0/brightness
DARK_BRIGHTNESS=30

if [ $# -eq 1 ]; then

    [ $1 -lt 0 -o $1 -gt 100 ] && echo "invalid brightness" && exit 1

    #echo "set brightness level $1"
    if [ $1 -eq 0 ]; then
        set_pwm=0
    elif [ $1 -eq 100 ]; then
        set_pwm=$(cat $MAX_BRIGHTNESS)
    elif [ $1 -gt 0 -a $1 -lt 10 ]; then
        set_pwm=$DARK_BRIGHTNESS
    else
        set_pwm=$(( $(cat $MAX_BRIGHTNESS) * $1 / 100 ))
    fi
    #echo "set_pwm: $set_pwm"

    echo $set_pwm > $BRIGHTNESS

    exit 0

elif [ $# -eq 0 ]; then

    cur_pwm=$(cat $BRIGHTNESS)

    #echo "current brightness $cur_pwm"
    if [ $cur_pwm -eq 0 ]; then
        cur_level=0
    elif [ $cur_pwm -eq $(cat $MAX_BRIGHTNESS) ]; then
        cur_level=100
    elif [ $cur_pwm -le $DARK_BRIGHTNESS ]; then
        cur_level=1
    else
        cur_level=$(( $cur_pwm * 100 / $(cat $MAX_BRIGHTNESS) ))
    fi

    echo "$cur_level"

    exit 0

else

    echo "unsupport operation!"

    exit 1

fi
