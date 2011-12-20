#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Archiso-live plugin for multicd.sh
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
if [ $1 = links ];then
	echo "archiso-live-*.iso archiso-live.iso none"
elif [ $1 = scan ];then
	if [ -f archiso-live.iso ];then
		echo "Archiso-live"
	fi
elif [ $1 = copy ];then
	if [ -f archiso-live.iso ];then
		echo "Copying Archiso-live..."
		mcdmount archiso-live
		mkdir "${WORK}"/boot/archiso-live
		cp "${MNT}"/archiso-live/boot/vmlinuz "${WORK}"/boot/archiso-live/vmlinuz
		cp "${MNT}"/archiso-live/boot/initrd.img "${WORK}"/boot/archiso-live/initrd.img
		cp -r "${MNT}"/archiso-live/archiso-live "${WORK}"/ #Compressed filesystems
		umcdmount archiso-live
	fi
elif [ $1 = writecfg ];then
if [ -f archiso-live.iso ];then
if [ -f archiso-live.version ] && [ "$(cat archiso-live.version)" != "" ];then
	VERSION=" ($(cat archiso-live.version))" #Version based on isoaliases()
else
	VERSION=""
fi
echo "LABEL archiso-live
TEXT HELP
Boot the Arch Linux live medium. It allows you to install Arch Linux or
perform system maintenance.
ENDTEXT
MENU LABEL Boot ^archiso-live$VERSION
KERNEL /boot/archiso-live/vmlinuz
APPEND initrd=/boot/archiso-live/initrd.img locale=en_US.UTF-8 load=overlay cdname=archiso-live session=xfce
IPAPPEND 0

LABEL archiso-livebaseonly
TEXT HELP
Boot the Arch Linux live medium. It allows you to install Arch Linux or
perform system maintenance. Basic LXDE desktop and apps.
ENDTEXT
MENU LABEL Boot archiso-live with baseonly$VERSION
KERNEL /boot/archiso-live/vmlinuz
APPEND initrd=/boot/archiso-live/initrd.img locale=en_US.UTF-8 load=overlay cdname=archiso-live session=lxde baseonly
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
