#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Fedora installer plugin for multicd.sh
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
	echo "Fedora-*-i386-netinst.iso fedora-boot.iso none"
elif [ $1 = scan ];then
	if [ -f fedora-boot.iso ];then
		echo "Fedora netboot installer"
		#touch "${TAGS}"/redhats/fedora-boot
	fi
elif [ $1 = copy ];then
	if [ -f fedora-boot.iso ];then
		echo "Copying Fedora netboot installer..."
		mcdmount fedora-boot
		mkdir "${WORK}"/boot/fedora
		if [ -f "${MNT}"/fedora-boot/isolinux/vmlinuz ];then
			cp "${MNT}"/fedora-boot/isolinux/vmlinuz "${WORK}"/boot/fedora/vmlinuz
			cp "${MNT}"/fedora-boot/isolinux/initrd.img "${WORK}"/boot/fedora/initrd.img
		elif [ -f "${MNT}"/fedora-boot/isolinux/vmlinuz0 ];then
			cp "${MNT}"/fedora-boot/isolinux/vmlinuz0 "${WORK}"/boot/fedora/vmlinuz
			cp "${MNT}"/fedora-boot/isolinux/initrd0.img "${WORK}"/boot/fedora/initrd.img
		fi
		if [ -d "${WORK}"/images ];then
			echo "There is already an \"images\" folder on the multicd. You might have another Red Hat-based distro on it."
			echo "Fedora's \"images\" folder won't be copied; instead, these files will be downloaded before the installer starts."
		else
			#Commenting out the below line will save about 100MB on the CD, but it will have to be downloaded when you install Fedora
			cp -r "${MNT}"/fedora-boot/images "${WORK}"/
		fi
		umcdmount fedora-boot
	fi
elif [ $1 = writecfg ];then
	if [ -f fedora-boot.iso ];then
		if [ -f fedora-boot.version ] && [ "$(cat fedora-boot.version)" != "" ];then
			VERSION=" $(cat fedora-boot.version)" #Version based on isoaliases()
		fi
		echo "label flinux
		  #TIP: If you change the method= entry in the append line, you can change the mirror and version installed.
		  menu label ^Install Fedora$VERSION from UW-Madison's mirror (assuming Fedora 15)
		  kernel /boot/fedora/vmlinuz
		  append initrd=/boot/fedora/initrd.img stage2=hd:LABEL=\"Fedora\" http://mirror.cs.wisc.edu/pub/mirrors/linux/download.fedora.redhat.com/pub/fedora/linux/releases/15/Everything/i386/os
		label flinux
		  menu label ^Install or upgrade Fedora$VERSION (enter mirror manually)
		  kernel /boot/fedora/vmlinuz
		  append initrd=/boot/fedora/initrd.img stage2=hd:LABEL=\"Fedora\"
		label ftext
		  menu label Install or upgrade Fedora$VERSION with basic video driver
		  kernel /boot/fedora/vmlinuz
		  append initrd=/boot/fedora/initrd.img stage2=hd:LABEL=\"Fedora\" xdriver=vesa nomodeset
		label frescue
		  menu label Rescue installed Fedora$VERSION system
		  kernel /boot/fedora/vmlinuz
		  append initrd=/boot/fedora/initrd.img stage2=hd:LABEL=\"Fedora\" rescue
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
