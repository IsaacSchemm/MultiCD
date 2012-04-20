#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#SliTaz plugin for multicd.sh
#version 6.9
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
	if [ -f slitaz.iso ];then
		echo "SliTaz"
	fi
elif [ $1 = copy ];then
	if [ -f slitaz.iso ];then
		echo "Copying SliTaz..."
		mcdmount slitaz
		mkdir -p "${WORK}"/boot/slitaz
		cp "${MNT}"/slitaz/boot/bzImage "${WORK}"/boot/slitaz/bzImage #Kernel
		cp "${MNT}"/slitaz/boot/rootfs1.gz "${WORK}"/boot/slitaz/rootfs1.gz #Root filesystem 1
		cp "${MNT}"/slitaz/boot/rootfs2.gz "${WORK}"/boot/slitaz/rootfs2.gz #Root filesystem 2
		cp "${MNT}"/slitaz/boot/rootfs3.gz "${WORK}"/boot/slitaz/rootfs3.gz #Root filesystem 3
		cp "${MNT}"/slitaz/boot/rootfs4.gz "${WORK}"/boot/slitaz/rootfs4.gz #Root filesystem 4
		cp "${MNT}"/slitaz/boot/gpxe "${WORK}"/boot/slitaz/gpxe #PXE bootloader
		umcdmount slitaz
	fi
elif [ $1 = writecfg ];then
if [ -f slitaz.iso ];then
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
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
