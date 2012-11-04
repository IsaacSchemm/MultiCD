#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Scientific Linux installer plugin for multicd.sh
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
	echo "SL-*-boot.iso scientific-boot.iso none"
elif [ $1 = scan ];then
	if [ -f scientific-boot.iso ];then
		echo "Scientific Linux netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f scientific-boot.iso ];then
		echo "Copying Scientific Linux netboot installer..."
		mcdmount scientific-boot
		mkdir "${WORK}"/boot/sci
		if [ -f "${MNT}"/scientific-boot/isolinux/vmlinuz ];then
			cp "${MNT}"/scientific-boot/isolinux/vmlinuz "${WORK}"/boot/sci/vmlinuz
			cp "${MNT}"/scientific-boot/isolinux/initrd.img "${WORK}"/boot/sci/initrd.img
		elif [ -f "${MNT}"/scientific-boot/isolinux/vmlinuz0 ];then
			cp "${MNT}"/scientific-boot/isolinux/vmlinuz0 "${WORK}"/boot/sci/vmlinuz
			cp "${MNT}"/scientific-boot/isolinux/initrd0.img "${WORK}"/boot/sci/initrd.img
		fi
		if [ -d "${WORK}"/images ];then
			echo "There is already an \"images\" folder on the multicd. You might have another Red Hat-based distro on it."
			echo "Scientific Linux's \"images\" folder won't be copied; instead, these files will be downloaded before the installer starts."
		else
			#Commenting out the below line will save about 100MB on the CD, but it will have to be downloaded when you install Scientific Linux
			cp -r "${MNT}"/scientific-boot/images "${WORK}"/
		fi
		umcdmount scientific-boot
	fi
elif [ $1 = writecfg ];then
	if [ -f scientific-boot.iso ];then
		if [ -f scientific-boot.version ] && [ "$(cat scientific-boot.version)" != "" ];then
			VERSION=" $(cat scientific-boot.version)" #Version based on isoaliases()
		fi
		echo "label scilinux-mirror
		menu label ^Install Scientific Linux from UW-Madison's mirror (assuming SciLinux 6)
		kernel /boot/sci/vmlinuz
		append initrd=/boot/sci/initrd.img method=http://mirror.cs.wisc.edu/pub/mirrors/linux/scientificlinux.org/6/i386/os/
		text help
		Scientific Linux version: $VERSION
		endtext

		label scilinux
		menu label ^Install or upgrade Scientific Linux (enter mirror manually)
		kernel /boot/sci/vmlinuz
		append initrd=/boot/sci/initrd.img
		label scivesa
		menu label Install system with ^basic video driver
		kernel /boot/sci/vmlinuz
		append initrd=/boot/sci/initrd.img xdriver=vesa nomodeset
		label scirescue
		menu label ^Rescue installed system
		kernel /boot/sci/vmlinuz
		append initrd=/boot/sci/initrd.img rescue" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
