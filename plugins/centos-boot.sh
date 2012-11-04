#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#CentOS installer plugin for multicd.sh
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
	echo "CentOS-*-netinstall.iso centos-boot.iso none"
elif [ $1 = scan ];then
	if [ -f centos-boot.iso ];then
		echo "CentOS netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f centos-boot.iso ];then
		echo "Copying CentOS netboot installer..."
		mcdmount centos-boot
		mkdir "${WORK}"/boot/centos
		if [ -f "${MNT}"/centos-boot/isolinux/vmlinuz ];then
			cp "${MNT}"/centos-boot/isolinux/vmlinuz "${WORK}"/boot/centos/vmlinuz
			cp "${MNT}"/centos-boot/isolinux/initrd.img "${WORK}"/boot/centos/initrd.img
		elif [ -f "${MNT}"/centos-boot/isolinux/vmlinuz0 ];then
			cp "${MNT}"/centos-boot/isolinux/vmlinuz0 "${WORK}"/boot/centos/vmlinuz
			cp "${MNT}"/centos-boot/isolinux/initrd0.img "${WORK}"/boot/centos/initrd.img
		fi
		if [ -d "${WORK}"/images ];then
			echo "There is already an \"images\" folder on the multicd. You might have another Red Hat-based distro on it."
			echo "CentOS's \"images\" folder won't be copied; instead, these files will be downloaded before the installer starts."
		else
			#Commenting out the below line will save about 100MB on the CD, but it will have to be downloaded when you install Scientific Linux
			cp -r "${MNT}"/centos-boot/images "${WORK}"/
		fi
		umcdmount centos-boot
	fi
elif [ $1 = writecfg ];then
	if [ -f centos-boot.iso ];then
		if [ -f centos-boot.version ] && [ "$(cat centos-boot.version)" != "" ];then
			VERSION=" $(cat centos-boot.version)" #Version based on isoaliases()
		fi
		echo "label centos-mirror
		menu label ^Install CentOS from UW-Madison's mirror (assuming SciLinux 6)
		kernel /boot/centos/vmlinuz
		append initrd=/boot/centos/initrd.img method=http://mirror.cs.wisc.edu/pub/mirrors/linux/centos/6/os/i386/
		label centos
		menu label ^Install or upgrade CentOS (enter mirror manually)
		kernel /boot/centos/vmlinuz
		append initrd=/boot/centos/initrd.img
		label centosvesa
		menu label Install CentOS system with ^basic video driver
		kernel /boot/centos/vmlinuz
		append initrd=/boot/centos/initrd.img xdriver=vesa nomodeset
		label centosrescue
		menu label ^Rescue installed CentOS system
		kernel /boot/centos/vmlinuz
		append initrd=/boot/centos/initrd.img rescue" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
