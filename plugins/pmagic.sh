#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Parted Magic plugin for multicd.sh
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
if [ $1 = links ];then
	echo "pmagic-*.iso pmagic.iso none"
elif [ $1 = scan ];then
	if [ -f pmagic.iso ];then
		echo "Parted Magic"
	fi
elif [ $1 = copy ];then
	if [ -f pmagic.iso ];then
		echo "Copying Parted Magic..."
		mcdmount pmagic
		cp -r "${MNT}"/pmagic/pmagic "${WORK}"/ #kernel/initrd & modules
		if [ ! -f "${WORK}"/boot/isolinux/linux.c32 ];then
			cp "${MNT}"/pmagic/boot/syslinux/linux.c32 "${WORK}"/boot/isolinux
		fi
		cp "${MNT}"/pmagic/boot/syslinux/syslinux.cfg "${WORK}"/boot/isolinux/pmagic.cfg
		if [ -f "${MNT}"/pmagic/mkgriso ];then cp "${MNT}"/pmagic/mkgriso "${WORK}";fi
		umcdmount pmagic
	fi
elif [ $1 = writecfg ];then
if [ -f pmagic.iso ];then
	if [ -f pmagic.version ] && [ "$(cat pmagic.version)" != "" ];then
		VERSION=" $(cat pmagic.version)"
	else
		VERSION=""
	fi
	echo "label pmagic
	menu label ^Parted Magic$VERSION
	com32 menu.c32
	append /boot/isolinux/pmagic.cfg
	" >> "${WORK}"/boot/isolinux/isolinux.cfg

	echo "label back
	menu label Back to main menu
	com32 menu.c32
	append /boot/isolinux/isolinux.cfg
	" >> "${WORK}"/boot/isolinux/pmagic.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
