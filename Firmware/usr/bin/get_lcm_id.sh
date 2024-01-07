#!/bin/sh

lcm_id=$(cat /proc/cmdline  | sed -n 's/ /\n/gp' | awk -F '=' -e '{if ($1 == "lcm_id") print $2}')

[ "x$lcm_id" == "x" ] && lcm_id=0

echo "$lcm_id"
