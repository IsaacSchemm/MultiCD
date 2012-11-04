#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Fedora 64-bit installer plugin for multicd.sh
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
	echo "Fedora-*-x86_64-netinst.iso fedora-boot64.iso none"
elif [ $1 = scan ];then
	if [ -f fedora-boot64.iso ];then
		echo "Fedora 64-bit netboot installer"
		#touch "${TAGS}"/redhats/fedora-boot64
	fi
elif [ $1 = copy ];then
	if [ -f fedora-boot64.iso ];then
		echo "Copying Fedora 64-bit netboot installer..."
		mcdmount fedora-boot64
		mkdir "${WORK}"/boot/fedora64
		if [ -f "${MNT}"/fedora-boot64/isolinux/vmlinuz ];then
			cp "${MNT}"/fedora-boot64/isolinux/vmlinuz "${WORK}"/boot/fedora64/vmlinuz
			cp "${MNT}"/fedora-boot64/isolinux/initrd.img "${WORK}"/boot/fedora64/initrd.img
		elif [ -f "${MNT}"/fedora-boot64/isolinux/vmlinuz0 ];then
			cp "${MNT}"/fedora-boot64/isolinux/vmlinuz0 "${WORK}"/boot/fedora64/vmlinuz
			cp "${MNT}"/fedora-boot64/isolinux/initrd0.img "${WORK}"/boot/fedora64/initrd.img
		fi
		if [ -d "${WORK}"/images ];then
			echo "There is already an \"images\" folder on the multicd. You might have another Red Hat-based distro on it."
			echo "64-bit Fedora's \"images\" folder won't be copied; instead, these files will be downloaded before the installer starts."
		else
			#Commenting out the below line will save about 100MB on the CD, but it will have to be downloaded when you install Fedora
			cp -r "${MNT}"/fedora-boot64/images "${WORK}"/
		fi
		umcdmount fedora-boot64
	fi
elif [ $1 = writecfg ];then
	if [ -f fedora-boot64.iso ];then
		if [ -f fedora-boot64.version ] && [ "$(cat fedora-boot64.version)" != "" ];then
			VERSION=" $(cat fedora-boot64.version)" #Version based on isoaliases()
		fi
		echo "label flinux64
		  #TIP: If you change the method= entry in the append line, you can change the mirror and version installed.
		  menu label ^Install 64-bit Fedora$VERSION from mirrors.kernel.org (Fedora 13 only)
		  kernel /boot/fedora64/vmlinuz
		  append initrd=/boot/fedora64/initrd.img method=http://mirrors.kernel.org/fedora/releases/13/Fedora/x86_64/os
		label flinux64
		  menu label ^Install or upgrade 64-bit Fedora$VERSION from another mirror
		  kernel /boot/fedora64/vmlinuz
		  append initrd=/boot/fedora64/initrd.img
		label ftext64
		  menu label Install or upgrade 64-bit Fedora$VERSION (text mode)
		  kernel /boot/fedora64/vmlinuz
		  append initrd=/boot/fedora64/initrd.img text
		label frescue64
		  menu label Rescue installed 64-bit Fedora$VERSION system
		  kernel /boot/fedora64/vmlinuz
		  append initrd=/boot/fedora64/initrd.img rescue
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
