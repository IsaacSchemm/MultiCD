#!/bin/sh
set -e
. ./functions.sh
#SystemRescueCd plugin for multicd.sh
#version 6.1
#Copyright (c) 2010 maybeway36
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
	if [ -f sysrcd.iso ];then
		echo "SystemRescueCd"
	fi
elif [ $1 = copy ];then
	if [ -f sysrcd.iso ];then
		echo "Copying SystemRescueCd..."
		mcdmount sysrcd
		mkdir multicd-working/boot/sysrcd
		cp $MNT/sysrcd/sysrcd.* multicd-working/boot/sysrcd/ #Compressed filesystem
		cp $MNT/sysrcd/isolinux/altker* multicd-working/boot/sysrcd/ #Kernels
		cp $MNT/sysrcd/isolinux/rescue* multicd-working/boot/sysrcd/ #Kernels
		cp $MNT/sysrcd/isolinux/initram.igz multicd-working/boot/sysrcd/initram.igz #Initrd
		cp $MNT/sysrcd/version multicd-working/boot/sysrcd/version
		umcdmount sysrcd
	fi
elif [ $1 = writecfg ];then
if [ -f sysrcd.iso ];then
VERSION=$(cat multicd-working/boot/sysrcd/version)
echo "menu begin --> ^System Rescue Cd ($VERSION)

label rescuecd0
menu label ^SystemRescueCd 32-bit
kernel /boot/sysrcd/rescuecd
append initrd=/boot/sysrcd/initram.igz subdir=/boot/sysrcd
label rescuecd1
menu label SystemRescueCd 64-bit
kernel /boot/sysrcd/rescue64
append initrd=/boot/sysrcd/initram.igz subdir=/boot/sysrcd
label rescuecd2
menu label SystemRescueCd 32-bit (alternate kernel)
kernel /boot/sysrcd/altker32
append initrd=/boot/sysrcd/initram.igz video=ofonly subdir=/boot/sysrcd
label rescuecd3
menu label SystemRescueCd 64-bit (alternate kernel)
kernel /boot/sysrcd/altker64
append initrd=/boot/sysrcd/initram.igz video=ofonly subdir=/boot/sysrcd
label rescuecd-rootauto
menu label SysRCD: rescue installed Linux (root=auto; 32-bit)
kernel /boot/sysrcd/rescuecd
append initrd=/boot/sysrcd/initram.igz root=auto subdir=/boot/sysrcd

label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg

menu end" >> multicd-working/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
