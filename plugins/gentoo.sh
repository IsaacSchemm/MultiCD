#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Gentoo live CD plugin for multicd.sh
#version 20140302
#Copyright (c) 2014 Isaac Schemm
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
	echo "livedvd-amd64-multilib-*.iso gentoo.iso none"
elif [ $1 = scan ];then
	if [ -f gentoo.iso ];then
		echo "Gentoo"
	fi
elif [ $1 = copy ];then
	if [ -f gentoo.iso ];then
		echo "Copying Gentoo..."
		mcdmount gentoo
		mkdir "${WORK}"/boot/gentoo
		cp "${MNT}"/gentoo/image.squashfs "${WORK}"/boot/gentoo/
		cp -r "${MNT}"/gentoo/boot/* "${WORK}"/boot/gentoo/
		cp "${MNT}"/gentoo/isolinux/*.cfg "${WORK}"/boot/gentoo/
		cp "${MNT}"/gentoo/isolinux/*.msg "${WORK}"/boot/gentoo/
		cp "${MNT}"/gentoo/isolinux/*.png "${WORK}"/boot/gentoo/
		rm "${WORK}"/boot/gentoo/memdisk || true
		touch "${WORK}"/livecd
		umcdmount gentoo
	fi
elif [ $1 = writecfg ];then
	if [ -f gentoo.iso ];then
		cat "${WORK}"/boot/gentoo/isolinux.cfg |
			sed -e 's^/boot/^/boot/gentoo/^g' -e 's^/boot/gentoo/memdisk^/boot/isolinux/memdisk^g' -e 's, cdroot, cdroot loop=/boot/gentoo/image.squashfs,g' |
			perl -pe 's, ([^ ]*?)\.msg, /boot/gentoo/$1\.msg,g' |
			perl -pe 's, ([^ ]*?)\.png, /boot/gentoo/$1\.png,g' > /tmp/isolinux.cfg
		cat /tmp/isolinux.cfg > "${WORK}"/boot/gentoo/isolinux.cfg
		rm /tmp/isolinux.cfg

		echo "label gentoo
menu label ^Gentoo
com32 vesamenu.c32
append /boot/gentoo/isolinux.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
