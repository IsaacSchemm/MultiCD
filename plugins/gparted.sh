#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#GParted Live plugin for multicd.sh
#version 20141214
#Copyright (c) 2011-2014 Isaac Schemm and others
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
if [ $1 = links ] && [ "$2" = "amd64" ];then
	echo "gparted-live-*-amd64.iso gpartedamd64.iso none"
elif [ $1 = links ] && [ "$2" = "i486" ];then
	echo "gparted-live-*-i486.iso gpartedi486.iso none"
elif [ $1 = scan ];then
	if [ -f gparted$2.iso ];then
		echo "GParted Live for $2"
	fi
elif [ $1 = copy ];then
	if [ -f gparted$2.iso ];then
		echo "Copying GParted Live for $2..."
		mcdmount gparted$2
		mkdir "${WORK}"/boot/gparted$2
		mcdcp -r "${MNT}"/gparted$2/live "${WORK}"/boot/gparted$2 #Compressed filesystem and kernel/initrd
		mcdcp -r "${MNT}"/gparted$2/syslinux "${WORK}"/boot/gparted$2
		rm "${WORK}"/boot/gparted$2/live/memtest || true #Remember how we needed to do this with Debian Live? They use the same framework
		umcdmount gparted$2
		sed -i 's|/live/vmlinuz|/boot/gparted/live/vmlinuz|g' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's|initrd=/live/initrd.img|initrd=/boot/gparted/live/initrd.img|g' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/label local/# &/' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/label memtest/# &/' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/timeout/# &/' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/ vga=791//g' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/ vga=normal//g' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's/ quiet//g' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
		sed -i 's|nosplash|& vga=792 nomodeset live-media-path=/boot/gparted/live|' "${WORK}"/boot/gparted$2/syslinux/syslinux.cfg
	fi
elif [ $1 = writecfg ];then
if [ -f gparted$2.iso ];then
	if [ -f "${WORK}"/gparted$2/vmlinuz1 ];then
		AP="1"
	else
		AP=""
	fi
cat <<EOF >> "${WORK}"/boot/isolinux/isolinux.cfg

label gparted
menu label GParted LiveCD
config /boot/gparted/syslinux/syslinux.cfg

EOF
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
