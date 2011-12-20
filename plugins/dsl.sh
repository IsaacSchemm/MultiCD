#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#DSL plugin for multicd.sh
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
	if [ -f dsl.iso ];then
		echo "Damn Small Linux"
	fi
elif [ $1 = copy ];then
	if [ -f dsl.iso ];then
		echo "Copying Damn Small Linux..."
		mcdmount dsl
		mkdir "${WORK}"/KNOPPIX
		cp -r "${MNT}"/dsl/KNOPPIX/* "${WORK}"/KNOPPIX/ #Compressed filesystem. We put it here so DSL's installer can find it.
		cp "${MNT}"/dsl/boot/isolinux/linux24 "${WORK}"/boot/isolinux/linux24 #Kernel. See above.
		cp "${MNT}"/dsl/boot/isolinux/minirt24.gz "${WORK}"/boot/isolinux/minirt24.gz #Initial ramdisk. See above.
		umcdmount dsl
	fi
elif [ $1 = writecfg ];then
if [ -f dsl.iso ];then
echo "menu begin --> ^DSL

LABEL dsl
MENU LABEL DSL
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/isolinux/minirt24.gz nomce noapic quiet BOOT_IMAGE=knoppix

LABEL dsl-toram
MENU LABEL DSL (load to RAM)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/isolinux/minirt24.gz nomce noapic quiet toram BOOT_IMAGE=knoppix

LABEL dsl-2
MENU LABEL DSL (boot to command line)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/isolinux/minirt24.gz nomce noapic quiet 2 BOOT_IMAGE=knoppix

LABEL dsl-expert
MENU LABEL DSL (expert mode)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/isolinux/minirt24.gz nomce BOOT_IMAGE=expert

LABEL dsl-fb1280x1024
MENU LABEL DSL (1280x1024 framebuffer)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=794 xmodule=fbdev initrd=/boot/isolinux/minirt24.gz nomce noapic quiet BOOT_IMAGE=knoppix

LABEL dsl-fb1024x768
MENU LABEL DSL (1024x768 framebuffer)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 xmodule=fbdev initrd=/boot/isolinux/minirt24.gz nomce noapic quiet BOOT_IMAGE=knoppix

LABEL dsl-fb800x600
MENU LABEL DSL (800x600 framebuffer)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=788 xmodule=fbdev initrd=/boot/isolinux/minirt24.gz nomce noapic quiet BOOT_IMAGE=knoppix

LABEL dsl-lowram
MENU LABEL DSL (for low RAM)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=normal initrd=/boot/isolinux/minirt24.gz noscsi noideraid nosound nousb nofirewire noicons minimal nomce noapic noapm lowram quiet BOOT_IMAGE=knoppix

LABEL dsl-install
MENU LABEL Install DSL
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=normal initrd=/boot/isolinux/minirt24.gz noscsi noideraid nosound nofirewire legacy base norestore _install_ nomce noapic noapm quiet BOOT_IMAGE=knoppix

LABEL dsl-failsafe
MENU LABEL DSL (failsafe)
KERNEL /boot/isolinux/linux24
APPEND ramdisk_size=100000 init=/etc/init 2 lang=us vga=normal atapicd nosound noscsi nousb nopcmcia nofirewire noagp nomce nodhcp xmodule=vesa initrd=/boot/isolinux/minirt24.gz BOOT_IMAGE=knoppix base norestore legacy

label back
menu label ^Back to main menu
com32 menu.c32
append isolinux.cfg

MENU END
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
