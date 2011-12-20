#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#PING plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 Isaac Schemm
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
if [ $1 = scan ];then
	if [ -f ping.iso ];then
		echo "PING"
	fi
elif [ $1 = copy ];then
	if [ -f ping.iso ];then
		echo "Copying PING..."
		mcdmount ping
		mkdir -p "${WORK}"/boot/ping
		cp "${MNT}"/ping/kernel "${WORK}"/boot/ping/kernel
		cp "${MNT}"/ping/initrd.gz "${WORK}"/boot/ping/initrd.gz
		umcdmount ping
	fi
elif [ $1 = writecfg ];then
if [ -f ping.iso ];then
cat >> "${WORK}"/boot/isolinux/isolinux.cfg << "EOF"
label ping
menu label ^PING (Partimage Is Not Ghost)
kernel /boot/ping/kernel
append vga=normal devfs=nomount pxe ramdisk_size=33000 load_ramdisk=1 init=/linuxrc prompt_ramdisk=0 initrd=/boot/ping/initrd.gz root=/dev/ram0 rw noapic nolapic lba combined_mode=libata ide0=noprobe nomce pci=nommconf pci=nomsi irqpoll
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
