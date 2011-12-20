#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Sabayon plugin for multicd.sh
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
	echo "Sabayon_Linux_*.iso sabayon.iso none"
elif [ $1 = scan ];then
	if [ -f sabayon.iso ];then
		echo "Sabayon Linux"
	fi
elif [ $1 = copy ];then
	if [ -f sabayon.iso ];then
		echo "Copying Sabayon Linux..."
		mcdmount sabayon
		mkdir "${WORK}"/boot/sabayon
		cp "${MNT}"/sabayon/boot/sabayon "${WORK}"/boot/sabayon/sabayon
		cp "${MNT}"/sabayon/boot/sabayon.igz "${WORK}"/boot/sabayon/sabayon.igz
		cp "${MNT}"/sabayon/livecd "${WORK}"/livecd #Not sure if this is needed
		cp "${MNT}"/sabayon/livecd.squashfs "${WORK}"/boot/sabayon/livecd.squashfs
		cp "${MNT}"/sabayon/pkglist "${WORK}"/pkglist #Not sure if this is needed
		cp "${MNT}"/sabayon/isolinux/txt.cfg "${WORK}"/boot/sabayon/sabayon.cfg
		umcdmount sabayon
	fi
elif [ $1 = writecfg ];then
	if [ -f sabayon.iso ];then
		echo "label sabayon
		menu label --> ^Sabayon Linux$(getVersion) Menu
		com32 menu.c32
		append /boot/sabayon/sabayon.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		sed -i -e 's@default sabayon@default menu\.c32@g' "${WORK}"/boot/sabayon/sabayon.cfg
		sed -i -e 's@/boot/sabayon@/boot/sabayon/sabayon@g' "${WORK}"/boot/sabayon/sabayon.cfg
		sed -i -e 's@/livecd.squashfs@/boot/sabayon/livecd.squashfs@g' "${WORK}"/boot/sabayon/sabayon.cfg
		sed -i -e 's@cdroot_type=udf@cdroot_type=iso9660@g' "${WORK}"/boot/sabayon/sabayon.cfg #MultiCD doesn't use UDF, so this needs to be changed
		echo "label back
		menu label ^Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> "${WORK}"/boot/sabayon/sabayon.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
