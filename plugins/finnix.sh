#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Finnix plugin for multicd.sh
#version 20121204
#Copyright (c) 2012 Isaac Schemm, Rorschach
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
	if [ -f finnix.iso ];then
		echo "Finnix"
	fi
elif [ $1 = copy ];then
	if [ -f finnix.iso ];then
		echo "Copying Finnix..."
		mcdmount finnix
		# Copies compressed filesystem
		cp -r "${MNT}"/finnix/finnix "${WORK}"/
		# Copies kernel, and initramdisk
		mkdir "${WORK}"/boot/finnix
		cp "${MNT}"/finnix/boot/x86/linux "${WORK}"/boot/finnix/
		cp "${MNT}"/finnix/boot/x86/linux64 "${WORK}"/boot/finnix/
		cp "${MNT}"/finnix/boot/x86/initrd.xz "${WORK}"/boot/finnix/
		# Copies memdisk and Smart Boot Manager
		cp "${MNT}"/finnix/boot/x86/memdisk "${WORK}"/boot/finnix/
		cp "${MNT}"/finnix/boot/x86/sbm.imz "${WORK}"/boot/finnix/
		umcdmount finnix
	fi
elif [ $1 = writecfg ];then
if [ -f finnix.iso ];then
echo "menu begin --> ^Finnix

label Finnix
  MENU LABEL ^Finnix (32-bit)
  kernel /boot/finnix/linux
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=791 quiet

label Finnix64
  MENU LABEL Finnix (64-bit)
  kernel /boot/finnix/linux64
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=791 quiet

label FinnixText
  MENU LABEL ^Finnix (32-bit, textmode)
  kernel /boot/finnix/linux
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=normal quiet

label FinnixDebug
  MENU LABEL ^Finnix (32-bit, debug mode)
  kernel /boot/finnix/linux
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=normal debug

label Finnix64Text
  MENU LABEL Finnix (64-bit, textmode)
  kernel /boot/finnix/linux64
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=normal quiet

label Finnix64Debug
  MENU LABEL Finnix (64-bit, debug mode)
  kernel /boot/finnix/linux64
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz apm=power-off vga=normal debug

label FinnixFailsafe
  MENU LABEL ^Finnix (failsafe)
  kernel /boot/finnix/linux
  append finnixfile=/finnix/finnix initrd=/boot/finnix/initrd.xz vga=normal noapic noacpi pnpbios=off acpi=off nofstab nodma noapm nodhcp nolvm nomouse noeject

label FinnixSBM
  MENU LABEL Smart Boot Manager
  kernel /boot/finnix/memdisk
  append initrd=/boot/finnix/sbm.imz

menu end
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
