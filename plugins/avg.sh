#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#AVG Rescue CD plugin for multicd.sh
#version 6.9
#Copyright for this script (c) 2010 Isaac Schemm
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
	echo "avg_*.iso avg.iso none"
elif [ $1 = scan ];then
	if [ -f avg.iso ];then
		echo "AVG Rescue CD"
	fi
elif [ $1 = copy ];then
	if [ -f avg.iso ];then
		echo "Copying AVG Rescue CD..."
		mcdmount avg
		mkdir "${WORK}"/boot/avg
		cp "${MNT}"/avg/isolinux/vmlinuz "${WORK}"/boot/avg/
		cp "${MNT}"/avg/isolinux/initrd.lzm "${WORK}"/boot/avg/
		cp "${MNT}"/avg/CHANGELOG "${WORK}"/boot/avg/
		cp "${MNT}"/avg/arl-version "${WORK}"/
		umcdmount avg
	fi
elif [ $1 = writecfg ];then
if [ -f avg.iso ];then
#if [ -f avg.version ] && [ "$(cat avg.version)" != "" ];then
#	AVGVER=" (avg_$(cat avg.version))"
#else
#	AVGVER=""
#fi
AVGVER=" ($(cat "${WORK}"/arl-version))"
echo "MENU BEGIN --> AVG Rescue CD$AVGVER

label arl
	menu label AVG Rescue CD
	menu default
	kernel /boot/avg/vmlinuz
	initrd /boot/avg/initrd.lzm
	append max_loop=255 vga=791 init=linuxrc

label nofb
	menu label AVG Rescue CD with Disabled Framebuffer
	kernel /boot/avg/vmlinuz
	initrd /boot/avg/initrd.lzm
	append max_loop=255 video=vesafb:off init=linuxrc

label vgask
	menu label AVG Rescue CD with Resolution Selection
	kernel /boot/avg/vmlinuz
	initrd /boot/avg/initrd.lzm
	append max_loop=255 init=linuxrc vga=ask

label back
	menu label Back to main menu
	com32 menu.c32
	append isolinux.cfg
menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
