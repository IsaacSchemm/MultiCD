#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#PCLinuxOS plugin for multicd.sh
#version 6.9+bugfix1
#Copyright (c) 2012 Isaac Schemm, PsynoKhi0
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
	echo "pclinuxos-kde-*.iso pclos.iso none"
elif [ $1 = scan ];then
	if [ -f pclos.iso ];then
		echo "PCLinuxOS"
	fi
elif [ $1 = copy ];then
	if [ -f pclos.iso ];then
		echo "Copying PCLinuxOS..."
		mcdmount pclos
		mkdir "${WORK}"/PCLinuxOS
		# Kernel, initrd
		cp -r "${MNT}"/pclos/isolinux "${WORK}"/PCLinuxOS/isolinux
		# Filesystem
		cp "${MNT}"/pclos/livecd.sqfs "${WORK}"/PCLinuxOS/livecd.sqfs
		# Remove memtest and mediacheck
		if [ -f "${WORK}"/PCLinuxOS/isolinux/memtest ];then
			rm "${WORK}"/PCLinuxOS/isolinux/memtest
		fi
		if [ -f "${WORK}"/PCLinuxOS/isolinux/mediacheck ];then
			rm "${WORK}"/PCLinuxOS/isolinux/mediacheck
		fi
		umcdmount pclos
	fi
elif [ $1 = writecfg ];then
if [ -f pclos.iso ];then
echo "menu begin --> ^PCLinuxOS

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
label back
    menu label ^Back to main menu
    com32 menu.c32
    append isolinux.cfg
menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
