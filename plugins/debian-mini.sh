#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Debian installer plugin for multicd.sh
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
	if [ -f debian-mini.iso ];then
		echo "Debian netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f debian-mini.iso ];then
		echo "Copying Debian netboot installer..."
		mcdmount debian-mini
		mkdir "${WORK}"/boot/debian
		cp "${MNT}"/debian-mini/linux "${WORK}"/boot/debian/linux
		cp "${MNT}"/debian-mini/initrd.gz "${WORK}"/boot/debian/initrd.gz
		umcdmount debian-mini
	fi
elif [ $1 = writecfg ];then
if [ -f debian-mini.iso ];then
DEBNAME="Debian GNU/Linux mini netinst (i386)"
echo "menu begin -->^DEBNAME

label ^Install Debian
	kernel /boot/debian/linux
	append vga=normal initrd=/boot/debian/initrd.gz -- quiet 
label Install Debian - expert mode
	kernel /boot/debian/linux
	append priority=low vga=normal initrd=/boot/debian/initrd.gz -- 

menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
