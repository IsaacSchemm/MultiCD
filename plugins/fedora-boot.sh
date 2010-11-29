#!/bin/sh
set -e
. ./functions.sh
#Fedora installer plugin for multicd.sh
#version 6.2
#Copyright (c) 2010 libertyernie
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
	echo "Fedora-14-i386-netinst.iso fedora-boot.iso"
if [ $1 = scan ];then
	if [ -f fedora-boot.iso ];then
		echo "Fedora netboot installer"
		touch $TAGS/redhats/fedora-boot
	fi
elif [ $1 = copy ];then
	if [ -f fedora-boot.iso ];then
		echo "Copying Fedora netboot installer..."
		mcdmount fedora-boot
		mkdir multicd-working/boot/fedora
		cp $MNT/fedora-boot/isolinux/vmlinuz multicd-working/boot/fedora/vmlinuz
		cp $MNT/fedora-boot/isolinux/initrd.img multicd-working/boot/fedora/initrd.img
		if [ -d multicd-working/images ];then
			echo "There is already an \"images\" folder on the multicd. You might have another Red Hat-based distro on it."
			echo "Fedora's \"images\" folder won't be copied; instead, these files will be downloaded before the installer starts."
		else
			#Commenting out the below line will save about 100MB on the CD, but it will have to be downloaded when you install Fedora
			cp -R $MNT/fedora-boot/images multicd-working/
		fi
		umcdmount fedora-boot
	fi
elif [ $1 = writecfg ];then
if [ -f fedora-boot.iso ];then
echo "label flinux
  #TIP: If you change the method= entry in the append line, you can change the mirror and version installed.
  menu label ^Install Fedora from mirrors.kernel.org (Fedora 13 only)
  kernel /boot/fedora/vmlinuz
  append initrd=/boot/fedora/initrd.img method=http://mirrors.kernel.org/fedora/releases/13/Fedora/i386/os
label flinux
  menu label ^Install or upgrade Fedora from another mirror
  kernel /boot/fedora/vmlinuz
  append initrd=/boot/fedora/initrd.img
label ftext
  menu label Install or upgrade Fedora (text mode)
  kernel /boot/fedora/vmlinuz
  append initrd=/boot/fedora/initrd.img text
label frescue
  menu label Rescue installed Fedora system
  kernel /boot/fedora/vmlinuz
  append initrd=/boot/fedora/initrd.img rescue
" >> multicd-working/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
