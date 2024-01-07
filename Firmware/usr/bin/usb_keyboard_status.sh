#!/bin/sh

#echo "MDEV=$MDEV ; ACTION=$ACTION ; DEVPATH=$DEVPATH" > /dev/console

case "${ACTION}" in
add)
    ubus call usb_keyboard set_state '{"usb_keyboard_plugged": 1}'
    ;;
remove)
    ubus call usb_keyboard set_state '{"usb_keyboard_plugged": 0}'
    ;;
esac
