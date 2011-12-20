#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#TinyMe plugin for multicd.sh
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
	if [ -f tinyme.iso ];then
		echo "TinyMe"
	fi
elif [ $1 = copy ];then
	if [ -f tinyme.iso ];then
		echo "Copying TinyMe..."
		mcdmount tinyme
		cp "${MNT}"/tinyme/livecd.sqfs "${WORK}"/livecd.sqfs #Compressed filesystem
		mkdir -p "${WORK}"/boot/tinyme
		cp "${MNT}"/tinyme/isolinux/vmlinuz "${WORK}"/boot/tinyme/vmlinuz
		cp "${MNT}"/tinyme/isolinux/initrd.gz "${WORK}"/boot/tinyme/initrd.gz
		umcdmount tinyme
	fi
elif [ $1 = writecfg ];then
if [ -f tinyme.iso ];then
cat >> "${WORK}"/boot/isolinux/isolinux.cfg << "EOF"
label LiveCD
    menu label ^TinyMe - LiveCD
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,noauto
label VideoSafeModeFBDev
    menu label TinyMe - VideoSafeModeFBDev
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,noauto framebuffer
label VideoSafeModeVesa
    menu label TinyMe - VideoSafeModeVesa
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,noauto vesa
label Safeboot
    menu label TinyMe - Safeboot
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=off vga=normal keyb=us noapic nolapic noscsi nopcmcia
label Console
    menu label TinyMe - Console
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd 3 initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,noauto
label Copy2ram
    menu label TinyMe - Copy2ram
    kernel /boot/tinyme/vmlinuz
    append livecd=livecd copy2ram initrd=/boot/tinyme/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,noauto splash=verbose
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
