#!/bin/sh
set -e
. $MCDDIR/functions.sh
#Arch Linux installer plugin for multicd.sh
#version 6.8
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
	echo "archlinux-*-netinstall-i686.iso arch.iso none"
	echo "archlinux-*-netinstall-x86_64.iso arch.iso none"
elif [ $1 = scan ];then
	if [ -f arch.iso ];then
		echo "Arch Linux"
	fi
elif [ $1 = copy ];then
	if [ -f arch.iso ];then
		echo "Copying Arch Linux..."
		mcdmount arch
		cp -r $MNT/arch/arch $WORK/
		rm $WORK/arch/boot/memtest || true
		umcdmount arch
	fi
elif [ $1 = writecfg ];then
if [ -f arch.iso ];then
	echo "label arch
	menu label --> ^Arch Linux ($(getVersion arch))
	CONFIG /arch/boot/syslinux/syslinux.cfg
	APPEND /arch/boot/syslinux/
	" >> $WORK/boot/isolinux/isolinux.cfg
	sed -i -e 's^/arch/boot/memtest^/boot/memtest^g' $WORK/arch/boot/syslinux/syslinux.cfg
	sed -i -e 's^MENU ROWS 6^MENU ROWS 7^g' $WORK/arch/boot/syslinux/syslinux.cfg
	echo "
	label back
	menu label ^Back to main menu
	config /boot/isolinux/isolinux.cfg
	append /boot/isolinux
	" >> $WORK/arch/boot/syslinux/syslinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
