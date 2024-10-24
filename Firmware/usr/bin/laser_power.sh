#!/bin/sh

INFO_FILE=/usr/data/creality/userdata/config/laser_info.json

get_en_pin()
{
    if [ "$(jq -e 'has("laser")' $INFO_FILE)" = "true" ]; then
        pin=$(jq -r '.laser.power_en_pin' $INFO_FILE)
        echo "$pin"
    fi
}

output_high()
{
    cmd_gpio set_func $1 output1
}

output_low()
{
    cmd_gpio set_func $1 output0
}

if [ $# -eq 1 ]; then

    power_en_pin=$(get_en_pin)
    if [ -z $power_en_pin ]; then
        #echo "get null power en pin"
        exit 1
    else
        #echo "get pin $power_en_pin"
        if [ "x$1" = "xon" ]; then
            output_high ${power_en_pin}
        elif [ "x$1" = "xoff" ]; then
            output_low ${power_en_pin}
        elif [ "x$1" = "xrestart" ]; then
            output_low ${power_en_pin}
            sleep 1
            output_high ${power_en_pin}
        fi
    fi
else
    exit 1
fi
