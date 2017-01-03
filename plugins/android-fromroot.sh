#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Android-x86 (from root) plugin for multicd.sh
#http://www.android-x86.org/
#version 20151010
#Copyright (c) 2015 Isaac Schemm
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
	if [ -f android-fromroot.iso ];then
		echo "Android-x86 (run from root)"
	fi
elif [ $1 = copy ];then
	if [ -f android-fromroot.iso ];then
		echo "Copying Android (run from root)..."
		mcdmount android-fromroot
		mkdir "${WORK}"/boot/android-fromroot
		mcdcp -r "${MNT}"/android-fromroot/kernel "${WORK}"/boot/android-fromroot/kernel
		mcdcp -r "${MNT}"/android-fromroot/initrd.img "${WORK}"/boot/android-fromroot/initrd.img
		mcdcp "${MNT}"/android-fromroot/install.img "${WORK}"/install.img
		mcdcp "${MNT}"/android-fromroot/ramdisk.img "${WORK}"/ramdisk.img
		mcdcp "${MNT}"/android-fromroot/system.* "${WORK}"/
		umcdmount android-fromroot
	fi
elif [ $1 = writecfg ];then
	if [ -f android-fromroot.iso ];then
		if [ -f android-fromroot.version ] && [ "$(cat android-fromroot.version)" != "" ];then
			VERSION=" $(cat android-fromroot.version)" #Version based on isoaliases()
		else
			VERSION=""
		fi
		echo "
		label android-fromroot-livem
			menu label ^Android-x86$VERSION - run without installation
			kernel /boot/android-fromroot/kernel
			append initrd=/boot/android-fromroot/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 quiet SRC= DATA=

		label android-fromroot-vesa
			menu label ^Android-x86$VERSION - ^VESA mode
			kernel /boot/android-fromroot/kernel
			append initrd=/boot/android-fromroot/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 quiet nomodeset vga=788 SRC= DATA=

		label android-fromroot-debug
			menu label ^Android-x86$VERSION - ^Debug mode
			kernel /boot/android-fromroot/kernel
			append initrd=/boot/android-fromroot/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 vga=788 DEBUG=2 SRC= DATA=

		label android-fromroot-install
			menu label ^Android-x86$VERSION - ^Install to harddisk
			kernel /boot/android-fromroot/kernel
			append initrd=/boot/android-fromroot/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 INSTALL=1 DEBUG=
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
