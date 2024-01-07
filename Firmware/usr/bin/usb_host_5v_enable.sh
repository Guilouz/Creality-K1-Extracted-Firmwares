#!/bin/sh

USB_P_EN1=PA14
USB_P_EN2=PA16

board=$(get_sn_mac.sh board)

[ "x${board}" = "xCR4CU220812S12" ] && {
    cmd_gpio set_func ${USB_P_EN1} output1
    cmd_gpio set_func ${USB_P_EN2} output1
}
