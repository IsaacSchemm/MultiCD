#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#RIPLinuX plugin for multicd.sh
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
if [ $1 = links ];then
	echo "RIPLinuX-*.iso riplinux.iso none"
elif [ $1 = scan ];then
	if [ -f riplinux.iso ];then
		echo "RIPLinuX"
	fi
elif [ $1 = copy ];then
	if [ -f riplinux.iso ];then
		echo "Copying RIP Linux..."
		mcdmount riplinux
		mkdir -p "${WORK}"/boot/riplinux
		cp -r "${MNT}"/riplinux/boot/doc "${WORK}"/boot/ #Documentation
		cp -r "${MNT}"/riplinux/boot/grub4dos "${WORK}"/boot/riplinux/ #GRUB4DOS :)
		cp "${MNT}"/riplinux/boot/kernel32 "${WORK}"/boot/riplinux/kernel32 #32-bit kernel
		cp "${MNT}"/riplinux/boot/kernel64 "${WORK}"/boot/riplinux/kernel64 #64-bit kernel
		cp "${MNT}"/riplinux/boot/rootfs.cgz "${WORK}"/boot/riplinux/rootfs.cgz #Initrd
		cp "${MNT}"/riplinux/boot/isolinux/isolinux.cfg "${WORK}"/boot/isolinux/riplinux.cfg
		sed -i -e 's/\/boot\/kernel/\/boot\/riplinux\/kernel/g' "${WORK}"/boot/isolinux/riplinux.cfg #Fix the riplinux.cfg
		sed -i -e 's/\/boot\/rootfs.cgz/\/boot\/riplinux\/rootfs.cgz/g' "${WORK}"/boot/isolinux/riplinux.cfg
		sed -i -e 's/\/boot\/kernel/\/boot\/riplinux\/kernel/g' "${WORK}"/boot/riplinux/grub4dos/menu-cd.lst #Fix the menu.lst
		sed -i -e 's/\/boot\/rootfs.cgz/\/boot\/riplinux\/rootfs.cgz/g' "${WORK}"/boot/riplinux/grub4dos/menu-cd.lst
		umcdmount riplinux
	fi
elif [ $1 = writecfg ];then
	if [ -f riplinux.iso ];then
		echo "label riplinux
		menu label ^RIPLinuX
		com32 menu.c32
		append riplinux.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		echo "label back
		menu label Back to main menu
		com32 menu.c32
		append isolinux.cfg
		" >> "${WORK}"/boot/isolinux/riplinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
