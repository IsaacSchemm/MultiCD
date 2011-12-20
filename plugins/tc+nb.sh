#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#NetbootCD 4.x tc+nb.iso plugin for multicd.sh
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
if [ $1 = scan ];then
	if [ -f tc+nb.iso ];then
		echo "NetbootCD / Tiny Core / GRUB4DOS"
	fi
elif [ $1 = copy ];then
	if [ -f tc+nb.iso ];then
		echo "Copying NetbootCD / Tiny Core / GRUB4DOS..."
		mcdmount tc+nb
		mkdir -p "${WORK}"/boot/tc+nb
		cp "${MNT}"/tc+nb/isolinux/kexec.bzI "${WORK}"/boot/tc+nb/
		cp "${MNT}"/tc+nb/isolinux/nbinit*.gz "${WORK}"/boot/tc+nb/nbinit.gz
		cp "${MNT}"/tc+nb/isolinux/tinycore.gz "${WORK}"/boot/tc+nb/
		cp "${MNT}"/tc+nb/isolinux/grub.exe "${WORK}"/boot/tc+nb/
		sleep 1;umcdmount tc+nb
	fi
elif [ $1 = writecfg ];then
	if [ -f tc+nb.iso ];then
		echo "LABEL tc+nb
		MENU LABEL ^NetbootCD (tc+nb.iso)
		KERNEL /boot/tc+nb/kexec.bzI
		initrd /boot/tc+nb/nbinit.gz
		APPEND quiet
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		if [ -f "${WORK}"/boot/tc+nb/tinycore.gz ];then
			echo "LABEL tc+nb-tinycore
			MENU LABEL ^Tiny Core Linux (tc+nb.iso)
			KERNEL /boot/tc+nb/kexec.bzI
			INITRD /boot/tc+nb/tinycore.gz
			APPEND quiet
			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
		if [ -f "${WORK}"/boot/tc+nb/grub.exe ];then
			echo "LABEL tc+nb-grub
			MENU LABEL ^GRUB4DOS (tc+nb.iso)
			KERNEL /boot/tc+nb/grub.exe
			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
