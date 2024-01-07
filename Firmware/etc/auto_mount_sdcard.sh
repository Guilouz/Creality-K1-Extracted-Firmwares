#!/bin/sh

destdir=/tmp/sdcard

mount_ntfs()
{
    case "$1" in
        sda*)
            /usr/bin/ntfs-3g /dev/$1 "${destdir}/$1" -o rw,noatime,nodiratime,nosuid,nodev
            if [ $? -eq 0 ]; then
                exit 0;
            fi
            ;;
        *)
            ;;
    esac
}

my_umount()
{
    if grep -qs "^/dev/$1 " /proc/mounts ; then
        umount "${destdir}/$1";
    fi

    [ -d "${destdir}/$1" ] && rmdir "${destdir}/$1"
}

my_mount()
{
    mkdir -p "${destdir}/$1" || exit 1

    if [ -x "/usr/bin/ntfs-3g" -a -x "/usr/bin/ntfs-3g.probe" ]; then
        /usr/bin/ntfs-3g.probe --readwrite "/dev/$1" &> /dev/null
        case $? in
            0)
                mount_ntfs $1
                ;;
            12)
                echo "$1 doesn't have a NTFS filesystem"
                ;;
            16)
                echo "The volume is already exclusively opened and in use by a kernel driver or software."
                ;;
            *)
                echo "Something wrong on file system of $1. Fixing. Please wait for a few seconds"
                [ -x "/usr/bin/ntfsfix" ] && /usr/bin/ntfsfix "/dev/$1"
                mount_ntfs $1
                ;;
        esac
    fi

    if ! mount -t auto -o sync "/dev/$1" "${destdir}/$1"; then
        # failed to mount, clean up mountpoint
        rmdir "${destdir}/$1"
        exit 1
    fi
}

#echo "MDEV=$MDEV ; ACTION=$ACTION ; DEVPATH=$DEVPATH" > /dev/console

case "${ACTION}" in
    add|"")
        my_umount ${MDEV}
        my_mount ${MDEV}
        ;;
    remove)
        my_umount ${MDEV}
        ;;
esac
