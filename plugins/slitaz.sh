#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#SliTaz plugin for multicd.sh
#version 20150821
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
		mcdcp "${MNT}"/slitaz/boot/rootfs*.gz "${WORK}"/boot/slitaz/ #Root filesystem
		mcdcp "${MNT}"/slitaz/boot/*pxe "${WORK}"/boot/slitaz/ #PXE bootloader
		umcdmount slitaz
	fi
elif [ $1 = writecfg ];then
if [ -f slitaz.iso ];then
	if [ -f "${TAGS}"/lang-full ];then
		LANGCODE=$(cat "${TAGS}"/lang-full)
	else
		LANGCODE=en
	fi
	if [ -f "${WORK}/boot/slitaz/rootfs.gz" ];then
		# new version 5.0
		echo "LABEL slitaz
			MENU LABEL ^SliTaz Live
			KERNEL /boot/slitaz/bzImage
			APPEND initrd=/boot/slitaz/rootfs.gz rw root=/dev/null autologin lang=$LANGCODE

		label web zeb
			menu label Web Boot
			kernel /boot/slitaz/ipxe" >> "${WORK}"/boot/isolinux/isolinux.cfg
	else
		#old version 4.0
		cat >> "${WORK}"/boot/isolinux/isolinux.cfg << "EOF"
		menu begin --> SliTaz GNU/Linux

		label core
			menu label SliTaz core Live
			kernel /boot/slitaz/bzImage
			append initrd=/boot/slitaz/rootfs4.gz,/boot/slitaz/rootfs3.gz,/boot/slitaz/rootfs2.gz,/boot/slitaz/rootfs1.gz rw root=/dev/null vga=normal autologin

		label gtkonly
			menu label SliTaz gtkonly Live
			kernel /boot/slitaz/bzImage
			append initrd=/boot/slitaz/rootfs4.gz,/boot/slitaz/rootfs3.gz,/boot/slitaz/rootfs2.gz rw root=/dev/null vga=normal autologin

		label justx
			menu label SliTaz justx Live
			kernel /boot/slitaz/bzImage
			append initrd=/boot/slitaz/rootfs4.gz,/boot/slitaz/rootfs3.gz rw root=/dev/null vga=normal autologin

		label base
			menu label SliTaz base Live
			kernel /boot/slitaz/bzImage
			append initrd=/boot/slitaz/rootfs4.gz rw root=/dev/null vga=normal autologin

		label web zeb
			menu label Web Boot
			kernel /boot/slitaz/gpxe

		label back
			menu label Back to main menu
			com32 menu.c32

		menu end
EOF
	fi
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
