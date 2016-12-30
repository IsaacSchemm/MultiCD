#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Bitdefender Rescue CD plugin for multicd.sh
#version 20161228
#Copyright (c) 2016 Isaac Schemm
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
	if [ -f bitdefender-rescue-cd.iso ];then
		echo "Bitdefender Rescue CD"
	fi
elif [ $1 = copy ];then
	if [ -f bitdefender-rescue-cd.iso ];then
		echo "Copying Bitdefender Rescue CD..."
		if [ -d "${WORK}"/boot/grub ] || [ -d "${WORK}"/rescue ];then
			echo "Cannot copy Bitdefender - there is already a /boot/grub or a /rescue folder on the image."
			exit 1
		fi
		mcdmount bitdefender-rescue-cd
		cp -n "${MNT}"/bitdefender-rescue-cd/boot/grub*.* "${WORK}"/boot
		cp -n "${MNT}"/bitdefender-rescue-cd/boot/kernel*.* "${WORK}"/boot
		cp -n "${MNT}"/bitdefender-rescue-cd/boot/initfs*.* "${WORK}"/boot
		mcdcp -r "${MNT}"/bitdefender-rescue-cd/boot/grub "${WORK}"/boot/grub
		mcdcp -r "${MNT}"/bitdefender-rescue-cd/rescue "${WORK}"/rescue
		umcdmount bitdefender-rescue-cd
	fi
elif [ $1 = writecfg ];then
	if [ -f bitdefender-rescue-cd.iso ];then
		echo "label bitdefender-rescue-cd
		menu label ^Bitdefender Rescue CD
		kernel /boot/grubi386.pc
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
