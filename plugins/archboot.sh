#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Arch Linux archboot.iso installer plugin for multicd.sh
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
	echo "archlinux-*-archboot.iso archboot.iso none"
elif [ $1 = scan ];then
	if [ -f archboot.iso ];then
		echo "Arch Linux Installer"
	fi
elif [ $1 = copy ];then
	if [ -f archboot.iso ];then
		echo "Copying Arch Linux Installer..."
		mcdmount archboot
		mkdir -p "${WORK}"/boot/archboot
		for i in vmlinuz_i686 vmlinuz_i686_lts vmlinuz_x86_64 vmlinuz_x86_64_lts initramfs_i686.img initramfs_x86_64.img;do
			cp "${MNT}"/archboot/boot/$i "${WORK}"/boot/archboot/$i
		done
		cp -r "${MNT}"/archboot/packages "${WORK}"/ #packages
		umcdmount archboot
	fi
elif [ $1 = writecfg ];then
	if [ -f archboot.iso ];then
		if [ -f "${TAGS}"/lang-full ];then
			LANG="$(cat "${TAGS}"/lang-full)"
		else
			LANG="en_US"
		fi
		if [ -f archboot.version ];then
			VERSION="$(cat archboot.version)"
		else
			VERSION=""
		fi
		echo "menu begin --> ^Arch Linux$VERSION Installer

		LABEL arch
		TEXT HELP
		Boot the Arch Linux (i686) archboot medium. 
		It allows you to install Arch Linux or perform system maintenance.
		ENDTEXT
		MENU LABEL Boot Arch Linux (i686)
		LINUX /boot/archboot/vmlinuz_i686
		APPEND initrd=/boot/archboot/initramfs_i686.img rootdelay=10

		LABEL arch64
		TEXT HELP
		Boot the Arch Linux (x86_64) archboot medium. 
		It allows you to install Arch Linux or perform system maintenance.
		ENDTEXT
		MENU LABEL Boot Arch Linux (x86_64)
		LINUX /boot/archboot/vmlinuz_x86_64
		APPEND initrd=/boot/archboot/initramfs_x86_64.img rootdelay=10

		LABEL arch-lts
		TEXT HELP
		Boot the Arch Linux LTS (i686) archboot medium. 
		It allows you to install Arch Linux or perform system maintenance.
		ENDTEXT
		MENU LABEL Boot Arch Linux LTS (i686)
		LINUX /boot/archboot/vmlinuz_i686_lts
		APPEND initrd=/boot/archboot/initramfs_i686.img rootdelay=10

		LABEL arch64-lts
		TEXT HELP
		Boot the Arch Linux LTS (x86_64) archboot medium. 
		It allows you to install Arch Linux or perform system maintenance.
		ENDTEXT
		MENU LABEL Boot Arch Linux LTS (x86_64)
		LINUX /boot/archboot/vmlinuz_x86_64_lts
		APPEND initrd=/boot/archboot/initramfs_x86_64.img rootdelay=10
	
		menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
