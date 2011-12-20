#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#PCLinuxOS LXDE plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 Isaac Schemm, PsynoKhi0
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
	echo "pclinuxos-lxde-*.iso pclx.iso none"
elif [ $1 = scan ];then
	if [ -f pclx.iso ];then
		echo "PCLinuxOS LXDE"
	fi
elif [ $1 = copy ];then
	if [ -f pclx.iso ];then
		echo "Copying PCLinuxOS LXDE..."
		mcdmount pclx
		mkdir "${WORK}"/pclosLXDE
		# Kernel, initrd
		cp -r "${MNT}"/pclx/isolinux "${WORK}"/pclosLXDE/isolinux
		# Empty boot folder, don't ask me...
		# cp -r pclinuxos/boot "${WORK}"/pclosLXDE/boot
		# Filesystem
		cp "${MNT}"/pclx/livecd.sqfs "${WORK}"/pclosLXDE/livecd.sqfs
		# Remove memtest and mediacheck
		if [ -f "${WORK}"/pclosLXDE/isolinux/memtest ];then
			rm "${WORK}"/pclosLXDE/isolinux/memtest 
		fi
		if [ -f "${WORK}"/pclosLXDE/isolinux/mediacheck ];then
			rm "${WORK}"/pclosLXDE/isolinux/mediacheck
		fi
		umcdmount pclx
	fi
elif [ $1 = writecfg ];then
if [ -f pclx.iso ];then
cat >> "${WORK}"/boot/isolinux/isolinux.cfg << "EOF"
label LiveCD
    menu label ^PCLinuxOS LXDE Live
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto noscsi
label LiveCD_sata_probe
    menu label ^PCLinuxOS LXDE Live - SATA probe
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto
label Video_SafeMode_FBDevice
    menu label ^PCLinuxOS LXDE Live - SafeMode FBDevice
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto framebuffer
label Video_SafeMode_Vesa
    menu label ^PCLinuxOS LXDE Live - SafeMode VESA
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto vesa
label Safeboot
    menu label ^PCLinuxOS LXDE Live - Safeboot
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=off vga=normal keyb=us noscsi nopcmcia
label Console
    menu label ^PCLinuxOS LXDE Live - Console
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd 3 initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto
label Copy_to_ram
    menu label ^PCLinuxOS LXDE Live - Copy to RAM
    kernel /pclosLXDE/isolinux/vmlinuz
    append livecd=/pclosLXDE/livecd copy2ram initrd=/pclosLXDE/isolinux/initrd.gz root=/dev/rd/3 acpi=on vga=788 keyb=us splash=silent fstab=rw,auto splash=verbose
EOF
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
