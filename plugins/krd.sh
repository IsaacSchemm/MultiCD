#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Kapersky Rescue Disk 18 plugin for multicd.sh
#version 20180621
#Copyright (c) 2018 Isaac Schemm
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
	if [ -f krd.iso ];then
		echo "Kapersky Rescue Disk"
	fi
elif [ $1 = copy ];then
	if [ -f krd.iso ];then
		echo "Copying Kapersky Rescue Disk..."
		mcdmount krd
		mkdir "${WORK}"/boot/krd
		# Kernel, initrd
		mcdcp "${MNT}"/krd/boot/grub/k-x86 "${WORK}"/boot/krd
		mcdcp "${MNT}"/krd/boot/grub/k-x86_64 "${WORK}"/boot/krd
		mcdcp "${MNT}"/krd/boot/grub/initrd.xz "${WORK}"/boot/krd
		# Filesystem
		mcdcp -r "${MNT}"/krd/data "${WORK}"
		umcdmount krd
	fi
elif [ $1 = writecfg ];then
	if [ -f krd.iso ];then
		if [ -f "${TAGS}"/lang ];then
			LANGCODE=$(cat "${TAGS}"/lang)
		else
			LANGCODE=en
		fi
		echo "menu begin --> ^Kapersky Rescue Disk

		label kav64
		menu label (x86_64) Kaspersky Rescue Disk. Graphic mode
		kernel /boot/krd/k-x86_64
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 lang=$LANGCODE dostartx

		label kav64nomodeset
		menu label (x86_64) Kaspersky Rescue Disk. Limited graphic mode
		kernel /boot/krd/k-x86_64
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 nomodeset lang=$LANGCODE dostartx

		label kav64hardwareinfo
		menu label (x86_64) Hardware Info
		kernel /boot/krd/k-x86_64
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 lang=$LANGCODE docache loadsrm=000-core.srm,003-kl.srm nox hwinfo docheck

		label kav32
		menu label (x86) Kaspersky Rescue Disk. Graphic mode
		kernel /boot/krd/k-x86
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 lang=$LANGCODE dostartx

		label kav32nomodeset
		menu label (x86) Kaspersky Rescue Disk. Limited graphic mode
		kernel /boot/krd/k-x86
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 nomodeset lang=$LANGCODE dostartx

		label kav32hardwareinfo
		menu label (x86) Hardware Info
		kernel /boot/krd/k-x86
		initrd /boot/krd/initrd.xz
		append net.ifnames=0 lang=$LANGCODE docache loadsrm=000-core.srm,003-kl.srm nox hwinfo docheck

		label back
		menu label ^Back to main menu
		com32 menu.c32
		append isolinux.cfg

		menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
