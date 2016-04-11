#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Antergos Linux installer plugin for multicd.sh
#version 20160410
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
if [ $1 = links ];then
	#Only one will be included
	echo "antergos-*-i686.iso antergos.iso none"
	echo "antergos-*-x86_64.iso antergos.iso none"
elif [ $1 = scan ];then
	if [ -f antergos.iso ];then
		echo "Antergos Linux"
	fi
elif [ $1 = copy ];then
	if [ -f antergos.iso ];then
		echo "Copying Antergos Linux..."
		mcdmount antergos
		mcdcp -r -T "${MNT}"/antergos/arch "${WORK}"/antergos
		umcdmount antergos
	fi
elif [ $1 = writecfg ];then
	if [ -f antergos.iso ];then
		echo "label antergos
	menu label Antergos Linux ($(getVersion antergos))
	kernel /antergos/boot/vmlinuz
	append initrd=/antergos/boot/intel_ucode.img,/antergos/boot/archiso.img archisobasedir=antergos archisolabel=${CDLABEL} earlymodules=loop modules-load=loop rd.modules-load=loop udev.log-priority=crit rd.udev.log-priority=crit quiet splash" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
