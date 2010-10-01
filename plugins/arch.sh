#!/bin/sh
set -e
#Arch Linux installer plugin for multicd.sh
#version 5.9
#Copyright (c) 2010 maybeway36
#Thanks to jerome_bc for updating this script for the newest Arch
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
	if [ -f arch.iso ];then
		echo "Arch Linux"
	fi
elif [ $1 = copy ];then
	if [ -f arch.iso ];then
		echo "Copying Arch Linux..."
		if [ ! -d $MNT/arch ];then
			mkdir $MNT/arch
		fi
		if grep -q "$MNT/arch" /etc/mtab ; then
			umount $MNT/arch
		fi
		mount -o loop arch.iso $MNT/arch/
		mkdir $WORK/boot/arch
		cp $MNT/arch/boot/vmlinuz26 $WORK/boot/arch/vmlinuz26 #Kernel
		cp $MNT/arch/boot/archiso.img $WORK/boot/arch/archiso.img #initrd
		cp $MNT/arch/*.sqfs $WORK/ #Compressed filesystems
		cp $MNT/arch/isomounts $WORK/ #Text file
		umount $MNT/arch;rmdir $MNT/arch
	fi
elif [ $1 = writecfg ];then
if [ -f arch.iso ];then
echo "label arch
menu label Boot ArchLive
kernel /boot/arch/vmlinuz26
append lang=en locale=en_US.UTF-8 usbdelay=5 ramdisk_size=75% archisolabel=$(cat tags/cdlabel)
initrd /boot/arch/archiso.img
" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
