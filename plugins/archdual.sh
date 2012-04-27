#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Arch Linux (dual i686/x86_64) installer plugin for multicd.sh
#version 20120426
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
	if [ -f archdual.iso ];then
		echo "Arch Linux Dual"
	fi
elif [ $1 = copy ];then
	if [ -f archdual.iso ];then
		echo "Copying Arch Linux Dual..."
		mcdmount archdual
		cp -r "${MNT}"/archdual/arch "${WORK}"/archdual
		umcdmount archdual
	fi
elif [ $1 = writecfg ];then
	if [ -f archdual.iso ];then
		echo "label arch
		menu label --> ^Arch Linux ($(getVersion archdual))
		KERNEL /archdual/boot/syslinux/ifcpu64.c32
		APPEND have64 -- nohave64
	
		LABEL have64
		MENU HIDE
		CONFIG /archdual/boot/syslinux/syslinux_both.cfg
		APPEND /archdual/boot/syslinux/
	
		LABEL nohave64
		MENU HIDE
		CONFIG /archdual/boot/syslinux/syslinux_32only.cfg
		APPEND /archdual/boot/syslinux/
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		for i in 32 64;do
			sed -i -e 's^/arch/boot^/archdual/boot^g' "${WORK}"/archdual/boot/syslinux/syslinux_arch${i}.cfg
			sed -i -e 's^archisobasedir=arch^archisobasedir=archdual^g' "${WORK}"/archdual/boot/syslinux/syslinux_arch${i}.cfg
			sed -i -e "s^archisolabel=ARCH_201108^archisolabel=$CDLABEL^g" "${WORK}"/archdual/boot/syslinux/syslinux_arch${i}.cfg
		done
		sed -i -e 's^/arch/boot/memtest^/boot/memtest^g' "${WORK}"/archdual/boot/syslinux/syslinux_tail.cfg
		sed -i -e 's^MENU ROWS 7^MENU ROWS 8^g' "${WORK}"/archdual/boot/syslinux/syslinux_head.cfg
		echo "
		label back
		menu label ^Back to main menu
		config /boot/isolinux/isolinux.cfg
		append /boot/isolinux
		" >> "${WORK}"/archdual/boot/syslinux/syslinux_tail.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
