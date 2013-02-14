#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

export DRACUT_SYSTEMD=1
export NEWROOT="/sysroot"
[ -d $NEWROOT ] || mkdir -p -m 0755 $NEWROOT
[ -d /run/initramfs ] || mkdir -p -m 0755 /run/initramfs
[ -d /run/lock ] || mkdir -p -m 0755 /run/lock
[ -d /run/log ] || mkdir -p -m 0755 /run/log

if [ -f /dracut-state.sh ]; then
    . /dracut-state.sh 2>/dev/null
fi
type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

[ -f /etc/initrd-release ] && . /etc/initrd-release
[ -n "$VERSION" ] && info "dracut-$VERSION"

getargbool 0 rd.udev.log-priority=info -d rd.udev.info -d -n -y rdudevinfo && echo 'udev_log="info"' >> /etc/udev/udev.conf
getargbool 0 rd.udev.log-priority=debug -d rd.udev.debug -d -n -y rdudevdebug && echo 'udev_log="debug"' >> /etc/udev/udev.conf

source_conf /etc/conf.d

make_trace_mem "hook cmdline" '1+:mem' '1+:iomem' '3+:slab'
# run scriptlets to parse the command line
getarg 'rd.break=cmdline' -d 'rdbreak=cmdline' && emergency_shell -n cmdline "Break before cmdline"
source_hook cmdline

[ -z "$root" ] && die "No or empty root= argument"
[ -z "$rootok" ] && die "Don't know how to handle 'root=$root'"

export root rflags fstype netroot NEWROOT

export -p > /dracut-state.sh
exit 0