#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Wolvix plugin for multicd.sh
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
	if [ -f wolvix.iso ];then
		echo "Wolvix"
	fi
elif [ $1 = copy ];then
	if [ -f wolvix.iso ];then
		echo "Copying Wolvix..."
		mcdmount wolvix
		cp -r "${MNT}"/wolvix/wolvix "${WORK}"/ #The Wolvix folder with all its files
		#The kernel/initrd must be here for the installer
		if [ ! -f "${WORK}"/boot/vmlinuz ]] && [ ! -f "${WORK}"/boot/initrd.gz ];then
			cp "${MNT}"/wolvix/boot/vmlinuz "${WORK}"/boot/vmlinuz
			cp "${MNT}"/wolvix/boot/initrd.gz "${WORK}"/boot/initrd.gz
		else
			mkdir -p "${WORK}"/boot/wolvix
			cp "${MNT}"/wolvix/boot/vmlinuz "${WORK}"/boot/wolvix/vmlinuz
			cp "${MNT}"/wolvix/boot/initrd.gz "${WORK}"/boot/wolvix/initrd.gz
		fi
		umcdmount wolvix
	fi
elif [ $1 = writecfg ];then
if [ -f wolvix.iso ];then
	if [ -f "${WORK}"/boot/wolvix/vmlinuz ];then
		KERNELPATH="/boot/wolvix"
	else
		KERNELPATH="/boot"
	fi
	echo "label wolvix
	menu label ^Wolvix GNU/Linux (login as root, password is toor)
	kernel $KERNELPATH/vmlinuz
	append changes=wolvixsave.xfs max_loop=255 initrd=$KERNELPATH/initrd.gz ramdisk_size=6666 root=/dev/ram0 rw vga=791 splash=silent
	" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
