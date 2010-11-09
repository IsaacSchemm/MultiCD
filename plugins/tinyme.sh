#!/bin/sh
set -e
#TinyMe plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 libertyernie
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
		if [ ! -d tinyme ];then
			mkdir tinyme
		fi
		if grep -q "`pwd`/tinyme" /etc/mtab ; then
			umount tinyme
		fi
		mount -o loop tinyme.iso tinyme/
		cp tinyme/livecd.sqfs multicd-working/livecd.sqfs #Compressed filesystem
		mkdir -p multicd-working/boot/tinyme
		cp tinyme/isolinux/vmlinuz multicd-working/boot/tinyme/vmlinuz
		cp tinyme/isolinux/initrd.gz multicd-working/boot/tinyme/initrd.gz
		umount tinyme
		rmdir tinyme
	fi
elif [ $1 = writecfg ];then
if [ -f tinyme.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
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
