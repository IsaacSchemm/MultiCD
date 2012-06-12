#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#ConnochaetOS plugin for multicd.sh
#version 20120612
#Copyright (c) 2012 Isaac Schemm
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
	echo "connos-*.iso connos.iso none"
elif [ $1 = scan ];then
	if [ -f connos.iso ];then
		echo "ConnochaetOS"
	fi
elif [ $1 = copy ];then
	if [ -f connos.iso ];then
		echo "Copying ConnochaetOS..."
		mcdmount connos
		mkdir -p "${WORK}/boot/connos"
		cp "${MNT}/connos/boot/isolinux/vmlinuz" "${WORK}/boot/connos"
		cp "${MNT}/connos/boot/isolinux/initrd.img" "${WORK}/boot/connos"
		mkdir -p "${WORK}/os"
		cp "${MNT}"/connos/os/* "${WORK}/os"
		umcdmount connos
	fi
elif [ $1 = writecfg ];then
if [ -f connos.iso ];then
echo "label connos
menu label ^ConnochaetOS
kernel /boot/connos/vmlinuz
initrd /boot/connos/initrd.img" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
