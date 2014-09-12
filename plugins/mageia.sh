#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Mandriva Linux plugin for multicd.sh
#version 20140911
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
	echo "Mageia-*.iso mageia.iso none"
elif [ $1 = scan ];then
	if [ -f mageia.iso ];then
		echo "Mageia"
	fi
elif [ $1 = copy ];then
	if [ -f mageia.iso ];then
		echo "Copying Mageia..."
		mcdmount mageia
		if [ -d "${WORK}"/loopbacks ];then
			echo "Warning: \$WORK/loopbacks exists. Mageia conflicts with another CD on the ISO."
		fi
		cp -r "${MNT}"/mageia/loopbacks "${WORK}"/
		mkdir -p "${WORK}"/boot/mageia
		cp "${MNT}"/mageia/boot/vmlinuz "${WORK}"/boot/mageia
		cp "${MNT}"/mageia/boot/cdrom/initrd* "${WORK}"/boot/mageia
		umcdmount mageia
	fi
elif [ $1 = writecfg ];then
	if [ -z "$CDLABEL" ];then
		#this should not happen
		CDLABEL=MCDtest
		echo "$0: warning: \$CDLABEL is empty."
	fi
	if [ -f mageia.iso ];then
		echo "label mageia-live
    menu label Boot ^Mageia
    kernel /boot/mageia/vmlinuz
    append initrd=/boot/mageia/initrd.gz root=mgalive:LABEL=$CDLABEL splash quiet rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788 
label mageia-linux
    menu label Install Mageia
    kernel /boot/mageia/mlinuz
    append initrd=/boot/mageia/initrd.gz root=mgalive:LABEL=$CDLABEL splash quiet rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788 install" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
