#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#openSUSE live CD/DVD plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm
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
	echo "openSUSE-*-GNOME-LiveCD-i686.iso opensuse-gnome.iso none"
elif [ $1 = scan ];then
	if [ -f opensuse-gnome.iso ];then
		echo "openSUSE GNOME Live CD"
	fi
elif [ $1 = copy ];then
	if [ -f opensuse-gnome.iso ];then
		echo "Copying openSUSE GNOME Live CD..."
		mcdmount opensuse-gnome
		mkdir -p "${WORK}"/boot/opensuse-gnome
		cp "${MNT}"/opensuse-gnome/openSUSE* "${WORK}"/
		cp "${MNT}"/opensuse-gnome/config.isoclient "${WORK}"/
		mkdir "${WORK}"/boot/susegnom
		cp "${MNT}"/opensuse-gnome/boot/i386/loader/linux "${WORK}"/boot/susegnom/linux
		cp "${MNT}"/opensuse-gnome/boot/i386/loader/initrd "${WORK}"/boot/susegnom/initrd
		umcdmount opensuse-gnome
	fi
elif [ $1 = writecfg ];then
if [ -f opensuse-gnome.iso ];then
	if [ -f "${TAGS}"/lang-full ];then
		LANGADD="lang=$(cat "${TAGS}"/lang-full)"
	fi
	echo "label openSUSE_Live_(GNOME)
	  menu label ^openSUSE Live (GNOME)
	  kernel /boot/susegnom/linux
	  initrd /boot/susegnom/initrd
	  append ramdisk_size=512000 ramdisk_blocksize=4096 splash=silent quiet preloadlog=/dev/null showopts $LANGADD
	label linux
	  menu label Install openSUSE (GNOME)
	  kernel /boot/susegnom/linux
	  initrd /boot/susegnom/initrd
	  append ramdisk_size=512000 ramdisk_blocksize=4096 splash=silent quiet preloadlog=/dev/null liveinstall showopts $LANGADD
	" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
