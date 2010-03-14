#!/bin/sh
set -e
#Parted Magic plugin for multicd.sh
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
	if [ -f pmagic.iso ];then
		echo "Parted Magic"
	fi
elif [ $1 = copy ];then
	if [ -f pmagic.iso ];then
	echo "Copying Parted Magic..."
	if [ ! -d pmagic ];then
		mkdir pmagic
	fi
	if grep -q "`pwd`/pmagic" /etc/mtab ; then
		umount pmagic
	fi
	mount -o loop pmagic.iso pmagic/
	#Sudo is needed b/c of weird permissions on 4.7 ISO for the initrd
	sudo cp -r pmagic/pmagic multicd-working/ #Compressed filesystem and kernel/initrd
	umount pmagic
	rmdir pmagic
	fi
elif [ $1 = writecfg ];then
if [ -f pmagic.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL normal
MENU LABEL ^Parted Magic: Default settings (Runs from RAM / Ejects CD)
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=791 sleep=10 loglevel=0 keymap=us

LABEL live
MENU LABEL ^Parted Magic: Live with default settings (USB not usable)
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=791 sleep=10 livemedia noeject loglevel=0 keymap=us

LABEL lowram
MENU LABEL ^Parted Magic: Live with low RAM settings
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=normal sleep=10 lowram livemedia noeject nogpm nolvm nonfs nofstabdaemon nosmart noacpid nodmeventd nohal loglevel=0 xvesa keymap=us

LABEL xvesa
MENU LABEL ^Parted Magic: Alternate graphical server
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=791 sleep=10 xvesa loglevel=0 keymap=us

LABEL normal-vga
MENU LABEL ^Parted Magic: Safe Graphics Settings (vga=normal)
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=normal sleep=10 loglevel=0 keymap=us

LABEL failsafe
MENU LABEL ^Parted Magic: Failsafe Settings
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=normal sleep=10 acpi=off noapic nolapic nopcmcia noscsi nogpm consoleboot nosmart keymap=us

LABEL console
MENU LABEL ^Parted Magic: Console (boots to the shell)
KERNEL /pmagic/bzImage
APPEND noapic initrd=/pmagic/initramfs load_ramdisk=1 prompt_ramdisk=0 rw vga=normal sleep=10 consoleboot keymap=us
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
