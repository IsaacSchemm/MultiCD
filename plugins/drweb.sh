#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Dr.Web LiveCD plugin for multicd.sh
#version 7.0 (20120512)
#Copyright for this script (c) 2012 LightDot lightdot@gmail.com
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
	echo "drweb-livecd-*.iso drweb.iso none"
elif [ $1 = scan ];then
	if [ -f drweb.iso ];then
		echo "Dr.Web LiveCD"
	fi
elif [ $1 = copy ];then
	if [ -f drweb.iso ];then
		echo "Copying Dr.Web LiveCD..."
		mcdmount drweb
		mkdir "${WORK}"/boot/drweb
		cp "${MNT}"/drweb/boot/vmlinuz "${WORK}"/boot/drweb/
		cp "${MNT}"/drweb/boot/initrd "${WORK}"/boot/drweb/
		cp "${MNT}"/drweb/boot/config "${WORK}"/boot
		cp -r "${MNT}"/drweb/boot/module "${WORK}"/boot
		cp "${MNT}"/drweb/boot/DrWebLiveCD-* "${WORK}"/boot/drweb/
		umcdmount drweb
	fi
elif [ $1 = writecfg ];then
if [ -f drweb.iso ];then
DRWEBMAJORVER="$(awk 'BEGIN { RS="" ;  FS="=" } ; { print $2 }' "${WORK}"/boot/config)"
DRWEBMINORVER="$(awk 'BEGIN { RS="" ;  FS="=" } ; { print $4 }' "${WORK}"/boot/config)"
DRWEBID="$(awk 'BEGIN { RS="";  FS="=" } ; { print $8 }' "${WORK}"/boot/config)"
echo "MENU BEGIN --> Dr.Web LiveCD $DRWEBMAJORVER.$DRWEBMINORVER

label drweb
	menu label Dr.Web LiveCD (Default)
	menu default
	kernel /boot/drweb/vmlinuz
	initrd /boot/drweb/initrd
	append ID=$DRWEBID root=/dev/ram0 init=linuxrc init_opts=4 quiet vga=791 splash=silent,theme:drweb CONSOLE=/dev/tty1

label drwebadv
	menu label Dr.Web LiveCD (Advanced)
	kernel /boot/drweb/vmlinuz
	initrd /boot/drweb/initrd
	append ID=$DRWEBID root=/dev/ram0 init=linuxrc init_opts=3 quiet CONSOLE=/dev/tty1

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
