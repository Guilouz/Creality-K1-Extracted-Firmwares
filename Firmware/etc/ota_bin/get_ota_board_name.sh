#!/bin/sh

grep 'ota_board_name' '/etc/ota_info' | awk -F'=' '{print $2}'

