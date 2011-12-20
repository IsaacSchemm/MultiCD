#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Elastix plugin for multicd.sh
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
if [ $1 = scan ];then
	if [ -f elastix.iso ];then
		echo "Elastix"
		#touch "${TAGS}"/redhats/elastix
	fi
elif [ $1 = copy ];then
	if [ -f elastix.iso ];then
		echo "Copying Elastix..."
		mcdmount elastix
		cp -r "${MNT}"/elastix/isolinux "${WORK}"/boot/elastix
		cp -r "${MNT}"/elastix/Elastix "${WORK}"/
		if [ -d "${WORK}"/images ];then
			echo "There is already a folder called \"images\". Are you adding another Red Hat-based distro?"
			echo "Copying anyway - be warned that on the final CD, something might not work properly."
		fi
		cp -r "${MNT}"/elastix/images "${WORK}"/
		cp -r "${MNT}"/elastix/repodata "${WORK}"/
		cp "${MNT}"/elastix/.discinfo "${WORK}"/
		cp "${MNT}"/elastix/* "${WORK}"/ 2>/dev/null || true
		umcdmount elastix
	fi
elif [ $1 = writecfg ];then
	if [ -f elastix.iso ];then
		echo "label elastixmenu
		menu label --> ^Elastix
		config /boot/isolinux/elastix.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		echo "default linux
		prompt 1
		timeout 600
		display /boot/elastix/boot.msg
		F1 /boot/elastix/boot.msg
		F2 /boot/elastix/options.msg
		F3 /boot/elastix/general.msg
		F4 /boot/elastix/param.msg
		F5 /boot/elastix/rescue.msg
		F7 /boot/elastix/snake.msg
		label advanced
		  kernel /boot/elastix/vmlinuz
		  append ks=cdrom:/ks_advanced.cfg initrd=/boot/elastix/initrd.img ramdisk_size=8192
		label elastix
		  kernel /boot/elastix/vmlinuz
		  append initrd=/boot/elastix/initrd.img ramdisk_size=8192
		label linux
		  kernel /boot/elastix/vmlinuz
		  append ks=cdrom:/ks.cfg initrd=/boot/elastix/initrd.img ramdisk_size=8192
		label rhinoraid
		  kernel /boot/elastix/vmlinuz
		  append ks=cdrom:/ks_rhinoraid.cfg initrd=/boot/elastix/initrd.img ramdisk_size=8192
		label local
		  localboot 1
		label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" > "${WORK}"/boot/isolinux/elastix.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
