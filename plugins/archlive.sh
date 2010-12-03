#!/bin/sh
set -e
. ./functions.sh
#Archiso-live plugin for multicd.sh
#version 6.2
#Copyright (c) 2010 libertyernie
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
	echo "archiso-live-*.iso archlive.iso"
elif [ $1 = scan ];then
	if [ -f archlive.iso ];then
		echo "Archiso-live"
	fi
elif [ $1 = copy ];then
	if [ -f archlive.iso ];then
		echo "Copying Archiso-live..."
		mcdmount archlive
		mkdir $WORK/boot/archlive
		cp $MNT/archlive/boot/vmlinuz $WORK/boot/archlive/vmlinuz
		cp $MNT/archlive/boot/initrd.img $WORK/boot/archlive/initrd.img
		cp -rv $MNT/archlive/archiso-live $WORK/ #Compressed filesystems
		umcdmount archlive
	fi
elif [ $1 = writecfg ];then
if [ -f archlive.iso ];then
if [ -f archlive.version ] && [ "$(cat archlive.version)" != "" ];then
	VERSION=" \($(cat archlive.version)\)" #Version based on isoaliases()
fi
echo "LABEL archlive
TEXT HELP
Boot the Arch Linux live medium. It allows you to install Arch Linux or
perform system maintenance.
ENDTEXT
MENU LABEL Boot Arch Linux$VERSION
KERNEL /boot/archlive/vmlinuz
APPEND initrd=/boot/archlive/initrd.img locale=en_US.UTF-8 load=overlay cdname=archiso-live session=xfce
IPAPPEND 0

LABEL archlivebaseonly
TEXT HELP
Boot the Arch Linux live medium. It allows you to install Arch Linux or
perform system maintenance. Basic LXDE desktop and apps.
ENDTEXT
MENU LABEL Boot Arch Linux with baseonly$VERSION
KERNEL /boot/archlive/vmlinuz
APPEND initrd=/boot/archlive/initrd.img locale=en_US.UTF-8 load=overlay cdname=archiso-live session=lxde baseonly
" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
