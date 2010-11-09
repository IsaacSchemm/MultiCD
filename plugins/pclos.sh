#!/bin/sh
set -e
#PCLinuxOS plugin for multicd.sh
#version 5.2
#Copyright (c) 2010 libertyernie, PsynoKhi0
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
	if [ -f pclos.iso ];then
		echo "PCLinuxOS"
	fi
elif [ $1 = copy ];then
	if [ -f pclos.iso ];then
		echo "Copying PCLinuxOS..."
		if [ ! -d pclinuxos ];then
			mkdir pclinuxos
		fi
		if grep -q `pwd`/pclinuxos /etc/mtab ; then
			umount pclinuxos
		fi
		mount -o loop pclos.iso pclinuxos/
		mkdir multicd-working/PCLinuxOS
		# Kernel, initrd
		cp -r pclinuxos/isolinux multicd-working/PCLinuxOS/isolinux
		# Empty boot folder, don't ask me...
		# cp -r pclinuxos/boot multicd-working/PCLinuxOS/boot
		# Filesystem
		cp pclinuxos/livecd.sqfs multicd-working/PCLinuxOS/livecd.sqfs
		# Remove memtest and mediacheck
		if [ -f multicd-working/PCLinuxOS/isolinux/memtest ];then
			rm multicd-working/PCLinuxOS/isolinux/memtest
		fi
		if [ -f multicd-working/PCLinuxOS/isolinux/mediacheck ];then
			rm multicd-working/PCLinuxOS/isolinux/mediacheck
		fi
		umount pclinuxos
		rmdir pclinuxos
	fi
elif [ $1 = writecfg ];then
if [ -f pclos.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label LiveCD
    menu label ^PCLinuxOS Live
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto noscsi
label LiveCD_sata_probe
    menu label ^PCLinuxOS Live - SATA probe
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto
label Video_SafeMode_FBDevice
    menu label ^PCLinuxOS Live - SafeMode FBDevice
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto framebuffer
label Video_SafeMode_Vesa
    menu label ^PCLinuxOS Live - SafeMode VESA
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto vesa
label Safeboot
    menu label ^PCLinuxOS Live - Safeboot
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=off vga=normal keyb=us noscsi nopcmcia
label Console
    menu label ^PCLinuxOS Live - Console
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd 3 initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto
label Copy_to_ram
    menu label ^PCLinuxOS Live - Copy to RAM
    kernel /PCLinuxOS/isolinux/vmlinuz
    append livecd=/PCLinuxOS/livecd copy2ram initrd=/PCLinuxOS/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto splash=verbose
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
