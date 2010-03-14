#!/bin/sh
set -e
#INSERT plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 maybeway36
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
	if [ ! -d insert ];then
		mkdir insert
	fi
	if grep -q "`pwd`/insert" /etc/mtab ; then
		umount insert
	fi
	mount -o loop insert.iso insert/
	cp -R insert/INSERT multicd-working/ #Compressed filesystem
	mkdir multicd-working/boot/insert
	cp insert/isolinux/vmlinuz multicd-working/boot/insert/vmlinuz
	cp insert/isolinux/miniroot.lz multicd-working/boot/insert/miniroot.lz
	umount insert
	rmdir insert
	fi
elif [ $1 = writecfg ];then
if [ -f insert.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL insert
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
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
