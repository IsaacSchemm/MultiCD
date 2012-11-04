#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#INSERT plugin for multicd.sh
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
	if [ -f insert.iso ];then
		echo "INSERT"
	fi
elif [ $1 = copy ];then
	if [ -f insert.iso ];then
		echo "Copying INSERT..."
		mcdmount insert
		cp -r "${MNT}"/insert/INSERT "${WORK}"/ #Compressed filesystem
		mkdir "${WORK}"/boot/insert
		cp "${MNT}"/insert/isolinux/vmlinuz "${WORK}"/boot/insert/vmlinuz
		cp "${MNT}"/insert/isolinux/miniroot.lz "${WORK}"/boot/insert/miniroot.lz
		umcdmount insert
	fi
elif [ $1 = writecfg ];then
if [ -f insert.iso ];then
echo "LABEL insert
menu label ^INSERT
KERNEL /boot/insert/vmlinuz
APPEND ramdisk_size=100000 init=/etc/init lang=en apm=power-off vga=773 initrd=/boot/insert/miniroot.lz nomce noapic dma BOOT_IMAGE=insert
LABEL insert-txt
menu label INSERT (vga=normal)
KERNEL /boot/insert/vmlinuz
APPEND ramdisk_size=100000 init=/etc/init lang=en apm=power-off vga=normal initrd=/boot/insert/miniroot.lz nomce noapic dma BOOT_IMAGE=insert
LABEL expert
menu label INSERT (expert mode)
KERNEL /boot/insert/vmlinuz
APPEND ramdisk_size=100000 init=/etc/init lang=en apm=power-off vga=773 initrd=/boot/insert/miniroot.lz nomce noapic dma BOOT_IMAGE=expert
LABEL failsafe
menu label INSERT (failsafe)
KERNEL /boot/insert/vmlinuz
APPEND ramdisk_size=100000 init=/etc/init lang=en vga=normal atapicd nosound noapic noacpi pnpbios=off acpi=off nofstab noscsi nodma noapm nousb nopcmcia nofirewire noagp nomce nodhcp xmodule=vesa initrd=/boot/insert/miniroot.lz BOOT_IMAGE=insert
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
