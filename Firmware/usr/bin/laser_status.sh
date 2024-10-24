#!/bin/sh

. /usr/share/libubox/jshn.sh

FW_PATH=/usr/share/laser/fw
LOG_FILE=/tmp/laser_update.log
FLAG_FILE=/tmp/.laser_updating
INFO_FILE=/usr/data/creality/userdata/config/laser_info.json
PWR_FILE=/usr/bin/laser_power.sh
LOAD_DONE=/tmp/load_done

NO_REPORT=0
DO_REPORT=1

write_log()
{
    [ -e $LOG_FILE ] || touch $LOG_FILE
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> $LOG_FILE
}

update_fw()
{
    local fw_bin
    local output
    local ret

    if [ $(ls $FW_PATH/*.bin | wc -l) -eq 1 ]; then
        fw_bin=$(ls $FW_PATH/*.bin)
        touch $FLAG_FILE
        output=$(laser_ota_util /dev/serial/by-id/creality-laser $fw_bin)
        ret=$?
        rm -f $FLAG_FILE && sync
        if [ $ret -eq 0 ]; then
            write_log "laser fw update none!"
            echo $DO_REPORT
        elif [ $ret -eq 1 ]; then
            write_log "laser fw update success!"
            echo $NO_REPORT
        else
            write_log "$output"
            write_log "laser fw update fail, ret=$ret!"
            echo $DO_REPORT
        fi
    else
        write_log "we should keep only one laser firmware file!"
        echo $DO_REPORT
    fi
}

#echo "MDEV=$MDEV ; ACTION=$ACTION ; DEVPATH=$DEVPATH ; ID_PATH_TAG=$ID_PATH_TAG" > /dev/console

case "${ACTION}" in
add)
    ret=$(update_fw)
    if [ $ret -eq $DO_REPORT ]; then
        ubus call laser set_state '{"laser_plugged": 1}'

        case $ID_PATH_TAG in
            platform-13500000_otg_new-usb-0_1_1*)
                power_en_pin="PA14"
            ;;

            platform-13500000_otg_new-usb-0_1_2*)
                power_en_pin="PA15"
            ;;

            platform-13500000_otg_new-usb-0_1_3*)
                power_en_pin="PA16"
            ;;
        esac

        json_init
        json_add_object "laser"
        json_add_string "power_en_pin" $power_en_pin
        json_close_object
        json_dump > $INFO_FILE
        json_cleanup
        sync

#        [ -f $LOAD_DONE ] || $PWR_FILE off
    fi
    ;;
remove)
    ubus call laser set_state '{"laser_plugged": 0}'
    ;;
esac
