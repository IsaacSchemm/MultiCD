#!/bin/sh
set -e
#RIPLinuX plugin for multicd.sh
#version 5.6
#Copyright (c) 2010 maybeway36
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
	if [ -f riplinux.iso ];then
		echo "RIPLinuX"
	fi
elif [ $1 = copy ];then
	if [ -f riplinux.iso ];then
		if [ ! -d riplinux ];then
echo "Copying RIP Linux..."
			mkdir riplinux
		fi
		if grep -q "`pwd`/riplinux" /etc/mtab ; then
			umount riplinux
		fi
		mount -o loop riplinux.iso riplinux/
		mkdir -p multicd-working/boot/riplinux
		cp -r riplinux/boot/doc multicd-working/boot/ #Documentation
		cp -r riplinux/boot/grub4dos multicd-working/boot/riplinux/ #GRUB4DOS :)
		cp riplinux/boot/kernel32 multicd-working/boot/riplinux/kernel32 #32-bit kernel
		cp riplinux/boot/kernel64 multicd-working/boot/riplinux/kernel64 #64-bit kernel
		cp riplinux/boot/rootfs.cgz multicd-working/boot/riplinux/rootfs.cgz #Initrd
		perl -pi -e 's/\/boot\/kernel/\/boot\/riplinux\/kernel/g' multicd-working/boot/riplinux/grub4dos/menu.lst #Fix the menu.lst
		perl -pi -e 's/\/boot\/rootfs.cgz/\/boot\/riplinux\/rootfs.cgz/g' multicd-working/boot/riplinux/grub4dos/menu.lst #Fix it some more
		umount riplinux
		rmdir riplinux
	fi
elif [ $1 = writecfg ];then
if [ -f riplinux.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label riplinux
menu label ^RIPLinuX
com32 menu.c32
append riplinux.cfg
EOF
cat >> multicd-working/boot/isolinux/riplinux.cfg << "EOF"
DEFAULT menu.c32
PROMPT 0
MENU TITLE RIPLinuX v6.7

LABEL Boot Linux system! (32-bit kernel)
KERNEL /boot/riplinux/kernel32
APPEND vga=normal initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system! (skip keymap prompt)
KERNEL /boot/riplinux/kernel32
APPEND vga=normal nokeymap initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system to X! (32-bit kernel)
KERNEL /boot/riplinux/kernel32
APPEND vga=normal xlogin initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system to X! (skip keymap prompt)
KERNEL /boot/riplinux/kernel32
APPEND vga=normal xlogin nokeymap initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system! (64-bit kernel)
KERNEL /boot/riplinux/kernel64
APPEND vga=normal initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system! (skip keymap prompt)
KERNEL /boot/riplinux/kernel64
APPEND vga=normal nokeymap initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system to X! (64-bit kernel)
KERNEL /boot/riplinux/kernel64
APPEND vga=normal xlogin initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Boot Linux system to X! (skip keymap prompt)
KERNEL /boot/riplinux/kernel64
APPEND vga=normal xlogin nokeymap initrd=/boot/riplinux/rootfs.cgz root=/dev/ram0 rw

LABEL Edit and put Linux partition to boot! (32-bit kernel)
KERNEL /boot/riplinux/kernel
APPEND vga=normal ro root=/dev/XXXX

LABEL Edit and put Linux partition to boot! (64-bit kernel)
KERNEL /boot/riplinux/kernel64
APPEND vga=normal ro root=/dev/XXXX

LABEL Boot memory tester!
KERNEL /boot/memtest
APPEND -

LABEL Boot GRUB bootloader!
KERNEL /boot/riplinux/grub4dos/grub.exe
APPEND --config-file=(cd)/boot/riplinux/grub4dos/menu.lst

LABEL Boot MBR on first hard drive!
KERNEL chain.c32
APPEND hd0 0

LABEL Boot partition #1 on first hard drive!
KERNEL chain.c32
APPEND hd0 1

LABEL Boot partition #2 on first hard drive!
KERNEL chain.c32
APPEND hd0 2

LABEL Boot partition #3 on first hard drive!
KERNEL chain.c32
APPEND hd0 3

LABEL Boot partition #4 on first hard drive!
KERNEL chain.c32
APPEND hd0 4

LABEL Boot MBR on second hard drive!
KERNEL chain.c32
APPEND hd1 0

LABEL Boot partition #1 on second hard drive!
KERNEL chain.c32
APPEND hd1 1

LABEL Boot partition #2 on second hard drive!
KERNEL chain.c32
APPEND hd1 2

LABEL Boot partition #3 on second hard drive!
KERNEL chain.c32
APPEND hd1 3

LABEL Boot partition #4 on second hard drive!
KERNEL chain.c32
APPEND hd1 4

label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
