#!/bin/sh

grep 'ota_version' '/etc/ota_info' | awk -F'=' '{print $2}'

