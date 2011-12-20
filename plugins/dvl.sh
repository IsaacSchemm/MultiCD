#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Damn Vulnerable Linux plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm
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
	if [ -f dvl.iso ];then
		echo "Damn Vulnerable Linux"
	fi
elif [ $1 = copy ];then
	if [ -f dvl.iso ];then
		echo "Copying Damn Vulnerable Linux..."
		mcdmount dvl
		cp -r "${MNT}"/dvl/BT "${WORK}"/
		mkdir "${WORK}"/boot/dvl
		cp "${MNT}"/dvl/boot/vmlinuz "${WORK}"/boot/dvl/vmlinuz
		cp "${MNT}"/boot/initrd.gz "${WORK}"/boot/dvl/initrd.gz
		umcdmount dvl
	fi
elif [ $1 = writecfg ];then
if [ -f dvl.iso ];then
echo "label dvl
menu label Damn ^Vulnerable Linux
kernel /boot/dvl/vmlinuz
initrd /boot/dvl/initrd.gz
append vga=0x317 max_loop=255 init=linuxrc load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=4444 root=/dev/ram0 rw

label dvlsafe
menu label Damn Vulnerable Linux (dvlsafe)
kernel /boot/dvl/vmlinuz
initrd /boot/dvl/initrd.gz
append vga=769 max_loop=255 init=linuxrc load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=4444 root=/dev/ram0 rw
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
