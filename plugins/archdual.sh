#!/bin/sh
set -e
. ./functions.sh
#Arch Linux (dual i686/x86_64) installer plugin for multicd.sh
#version 6.7
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
	if [ -f archdual.iso ];then
		echo "Arch Linux Dual"
	fi
elif [ $1 = copy ];then
	if [ -f archdual.iso ];then
		echo "Copying Arch Linux Dual..."
		mcdmount archdual
		mkdir -p $WORK/boot/arch
		for i in vmlinuz vmlts vm64 vm64lts initrd.img initrdlts.img initrd64.img initrd64lts.img;do
			cp $MNT/archdual/boot/$i $WORK/boot/arch/$i
		done
		cp $MNT/archdual/core-* $WORK/ #packages
		cp $MNT/archdual/isomounts $WORK/ #Text file
		umcdmount archdual
	fi
elif [ $1 = writecfg ];then
if [ -f archdual.iso ];then
	if [ -f $TAGS/lang-full ];then
		LANG="$(cat $TAGS/lang-full)"
	else
		LANG="en_US"
	fi
	echo "label arch1
	menu label Boot ArchLive i686
	kernel /boot/arch/i686/vmlinuz26
	append lang=en locale=$LANG.UTF-8 usbdelay=5 ramdisk_size=75% archisolabel=$(cat $TAGS/cdlabel)
	initrd /boot/arch/i686/archiso.img

	label arch2
	menu label Boot ArchLive x86_64
	kernel /boot/arch/x86_64/vmlinuz26
	append lang=en locale=$LANG.UTF-8 usbdelay=5 ramdisk_size=75% archisolabel=$(cat $TAGS/cdlabel)
	initrd /boot/arch/x86_64/archiso.img
	" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
