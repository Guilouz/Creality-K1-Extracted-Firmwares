#!/bin/sh

#set -x

. /usr/share/libubox/jshn.sh

PROG=/usr/bin/cam_app
MJPG_STREAMER=/usr/bin/mjpg_streamer
VERSION_FILE=/tmp/.cam_version
FW_ROOT_DIR=/usr/share/uvc/fw

MAIN_CAM=0
MAIN_PORT=8080
MAIN_PIC_WIDTH=1280
MAIN_PIC_HEIGHT=720
MAIN_PIC_FPS=15

SUB_CAM=1
SUB_PORT=8081
SUB_PIC_WIDTH=640
SUB_PIC_HEIGHT=480
SUB_PIC_FPS=15

echo_console()
{
    printf "$*" > /dev/console
}

fw_info()
{
    [ -x /usr/bin/cam_util ] && {
        FwVersion=$(cam_util -i $1 -g | grep -w FwVersion | awk -F ' ' -e '{print $2}')
        if [ "x$FwVersion" != "x" ]; then
            manufactory=${FwVersion:15:9}
            cur_version=${FwVersion:25:6}

            case $manufactory in
                "STsmart_-" | "STJC-000I")
                    if [ $(ls ${FW_ROOT_DIR}/STsmart/*.src | wc -l) -eq 1 ]; then
                        fw_path=$(ls ${FW_ROOT_DIR}/STsmart/*.src)
                        tmp=$(basename $fw_path)
                        tmp=${tmp%.src}
                        fw_version=${tmp##*_}
                    else
                        fw_version=0
                        fw_path=
                        echo_console "we should keep only one firmware file for STsmart!"
                    fi
                    ;;
                *)
                    ;;
            esac

            json_init
            json_add_object "main_cam"
            json_add_string "video_node" $1
            json_add_string "manufactory" $manufactory
            json_add_string "cur_version" $cur_version
            json_add_string "newest_fw_path" $fw_path
            if [ $fw_version -gt $cur_version ]; then
                json_add_boolean "can_update" 1
            else
                json_add_boolean "can_update" 0
            fi
            json_close_object
            json_dump > $VERSION_FILE
            json_cleanup
        fi
    }
}

start_uvc()
{
    case $1 in
        main-video*)
            echo_console "start cam_app service for $1 : "

            [ $(v4l2-ctl -d /dev/v4l/by-id/$1 --list-framesizes MJPG 2>&1 | wc -l) -eq 1 ] && {
                echo_console "$1 not support MJPG format!"
                return
            }

            fw_info /dev/v4l/by-id/$1

            start-stop-daemon -S -b -m -p /var/run/$1.pid \
                --exec $PROG -- -i /dev/v4l/by-id/$1 -t $MAIN_CAM \
                -w $MAIN_PIC_WIDTH -h $MAIN_PIC_HEIGHT -f $MAIN_PIC_FPS \
                -c
            [ $? = 0 ] && echo_console "OK\n" || echo_console "FAIL\n"

            sleep 1

            LD_LIBRARY_PATH=/usr/lib/mjpg-streamer/ \
            start-stop-daemon -S -b -m -p /var/run/$1_mjpg.pid \
                --exec $MJPG_STREAMER -- -i "input_memfd.so -t $MAIN_CAM" \
                -o "output_http.so -w /usr/share/mjpg-streamer/www/ -p $MAIN_PORT"
        ;;
        sub-video*)
            echo_console "start cam_app service for $1 : "

            [ $(v4l2-ctl -d /dev/v4l/by-id/$1 --list-framesizes MJPG 2>&1 | wc -l) -eq 1 ] && {
                echo_console "$1 not support MJPG format!"
                return
            }

            start-stop-daemon -S -b -m -p /var/run/$1.pid \
                --exec $PROG -- -i /dev/v4l/by-id/$1 -t $SUB_CAM \
                -w $SUB_PIC_WIDTH -h $SUB_PIC_HEIGHT -f $SUB_PIC_FPS
            [ $? = 0 ] && echo_console "OK\n" || echo_console "FAIL\n"

            sleep 1

            LD_LIBRARY_PATH=/usr/lib/mjpg-streamer/ \
            start-stop-daemon -S -b -m -p /var/run/$1_mjpg.pid \
                --exec $MJPG_STREAMER -- -i "input_memfd.so -t $SUB_CAM" \
                -o "output_http.so -w /usr/share/mjpg-streamer/www/ -p $SUB_PORT"
        ;;
    esac
}

stop_uvc()
{
    case $1 in
        main-video* | sub-video*)
            echo_console "stop cam_app service for $1 : "

            start-stop-daemon -K -p /var/run/$1.pid

            if [ $? = 0 ]; then
                echo_console "OK\n"

                # wait for process exit
                while true
                do
                    if [ -d /proc/$(cat /var/run/$1.pid) ]; then
                        sleep 0.2
                    else
                        break
                    fi
                done

            else
                echo_console "FAIL\n"
            fi

            start-stop-daemon -K -p /var/run/$1_mjpg.pid

        ;;
    esac
}

reload_uvc()
{
    [ -d /dev/v4l/by-id ] && {
        DEVS=$(ls /dev/v4l/by-id)
        if [ "x$DEVS" != "x" ]; then
            for dev in $DEVS
            do
                stop_uvc $dev
                start_uvc $dev
            done
        fi
    }
}

stop_all_uvc()
{
    [ -d /dev/v4l/by-id ] && {
        DEVS=$(ls /dev/v4l/by-id)
        if [ "x$DEVS" != "x" ]; then
            for dev in $DEVS
            do
                stop_uvc $dev
            done
        fi
    }
}

#echo_console "MDEV=$MDEV ; ACTION=$ACTION ; DEVPATH=$DEVPATH\n"

sync && echo 3 > /proc/sys/vm/drop_caches

case "${ACTION}" in
add)
        start_uvc ${MDEV}
        ;;
remove)
        stop_uvc ${MDEV}

        rm -rf $VERSION_FILE
        ;;
# cmd: ACTION=reload /usr/bin/auto_uvc.sh
reload)
        reload_uvc
        ;;
# cmd: ACTION=stop /usr/bin/auto_uvc.sh
stop)
        stop_all_uvc
        ;;
esac

exit 0
