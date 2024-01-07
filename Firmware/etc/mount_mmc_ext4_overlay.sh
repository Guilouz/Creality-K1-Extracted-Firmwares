#!/bin/sh
#

case "$1" in
  start)
	grep -q overlay /proc/filesystems && {
		mkdir -p /tmp/extroot/overlay
		mount_mmc_ext4.sh rootfs_data /tmp/extroot/overlay

		mount -n /tmp/extroot/overlay -o noatime,move /overlay
		mkdir -p /overlay/upper
		mkdir -p /overlay/work
		mount -n -t overlay overlayfs:/overlay -o rw,sync,noatime,lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work /mnt

		mount -n /proc -o noatime,move /mnt/proc
		pivot_root /mnt /mnt/rom
		mount -n /rom/overlay -o noatime,move /overlay
		mount -n /rom/dev -o noatime,move /dev
		mount -n /rom/tmp -o noatime,move /tmp
		mount -n /rom/run -o noatime,move /run
		mount -n /rom/sys -o noatime,move /sys

		rm -rf /tmp/extroot/
	}

	;;
  stop)
	;;
  restart|reload)
	;;
  *)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
esac

exit $?
