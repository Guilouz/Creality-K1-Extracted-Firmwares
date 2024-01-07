#!/bin/sh

#set -x

# modes like this:
# U:480x800p-60

xres=0
yres=0

get_fb_info()
{
    [ -f /sys/class/graphics/fb0/modes ] || {
        echo "0"
        exit 1
    }

    modes=$(cat /sys/class/graphics/fb0/modes)

    xres=${modes#U:}
    xres=${xres%x*}

    yres=${modes%p*}
    yres=${yres#*x}
}

print_usage()
{
    echo "Usage: "
    echo "  get_fb_info.sh <width|height>"
}

if [ $# -eq 1 ]; then

    get_fb_info

    case $1 in
        width)
            echo "$xres"
        ;;

        height)
            echo "$yres"
        ;;
    esac
else
    print_usage
fi
