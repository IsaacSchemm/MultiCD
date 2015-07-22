#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#SliTaz plugin for multicd.sh
#version 20150721
#Copyright (c) 2015 Isaac Schemm
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
	echo "slitaz-*.iso slitaz.iso none"
elif [ $1 = scan ];then
	if [ -f slitaz.iso ];then
		echo "SliTaz"
	fi
elif [ $1 = copy ];then
	if [ -f slitaz.iso ];then
		echo "Copying SliTaz..."
		mcdmount slitaz
		mkdir -p "${WORK}"/boot/slitaz
		mcdcp "${MNT}"/slitaz/boot/bzImage "${WORK}"/boot/slitaz/bzImage #Kernel
		mcdcp "${MNT}"/slitaz/boot/rootfs.gz "${WORK}"/boot/slitaz/rootfs.gz #Root filesystem
		mcdcp "${MNT}"/slitaz/boot/ipxe "${WORK}"/boot/slitaz/ipxe #PXE bootloader
		umcdmount slitaz
	fi
elif [ $1 = writecfg ];then
if [ -f slitaz.iso ];then
	if [ -f "${TAGS}"/lang-full ];then
		LANGCODE=$(cat "${TAGS}"/lang-full)
	else
		LANGCODE=en
	fi
echo "LABEL slitaz
	MENU LABEL ^SliTaz Live
	KERNEL /boot/slitaz/bzImage
	APPEND initrd=/boot/slitaz/rootfs.gz rw root=/dev/null autologin lang=$LANGCODE
	" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
