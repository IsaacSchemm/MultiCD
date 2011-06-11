#!/bin/sh
set -e
. $MCDDIR/functions.sh
#RIPLinuX plugin for multicd.sh
#version 6.6 (last functional change: 5.6.1)
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
	if [ -f riplinux.iso ];then
		echo "RIPLinuX"
	fi
elif [ $1 = copy ];then
	if [ -f riplinux.iso ];then
		echo "Copying RIP Linux..."
		mcdmount riplinux
		mkdir -p $WORK/boot/riplinux
		cp -r $MNT/riplinux/boot/doc $WORK/boot/ #Documentation
		cp -r $MNT/riplinux/boot/grub4dos $WORK/boot/riplinux/ #GRUB4DOS :)
		cp $MNT/riplinux/boot/kernel32 $WORK/boot/riplinux/kernel32 #32-bit kernel
		cp $MNT/riplinux/boot/kernel64 $WORK/boot/riplinux/kernel64 #64-bit kernel
		cp $MNT/riplinux/boot/rootfs.cgz $WORK/boot/riplinux/rootfs.cgz #Initrd
		perl -pi -e 's/\/boot\/kernel/\/boot\/riplinux\/kernel/g' $WORK/boot/riplinux/grub4dos/menu-cd.lst #Fix the menu.lst
		perl -pi -e 's/\/boot\/rootfs.cgz/\/boot\/riplinux\/rootfs.cgz/g' $WORK/boot/riplinux/grub4dos/menu-cd.lst #Fix it some more
		umcdmount riplinux
	fi
elif [ $1 = writecfg ];then
if [ -f riplinux.iso ];then
cat >> $WORK/boot/isolinux/isolinux.cfg << "EOF"
label riplinux
menu label ^RIPLinuX
com32 menu.c32
append riplinux.cfg
EOF
cat >> $WORK/boot/isolinux/riplinux.cfg << "EOF"
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
APPEND --config-file=(cd)/boot/riplinux/grub4dos/menu-cd.lst

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
