#!/bin/sh
set -e
#Finnix plugin for multicd.sh
#version 5.3
#Copyright (c) 2010 Rorschach
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
		if [ ! -d finnix ];then
			mkdir finnix
		fi
		if grep -q "`pwd`/finnix" /etc/mtab ; then
			umount finnix
		fi
		mount -o loop finnix.iso finnix/
		# Copies compressed filesystem
		cp -r finnix/FINNIX multicd-working/
		# Copies kernel, and initramdisk
		mkdir multicd-working/boot/finnix
		cp finnix/isolinux/linux multicd-working/boot/finnix/
		cp finnix/isolinux/linux64 multicd-working/boot/finnix/
		cp finnix/isolinux/minirt multicd-working/boot/finnix/
		# Copies memdisk and Smart Boot Manager
		cp finnix/isolinux/memdisk multicd-working/boot/finnix/
		cp finnix/isolinux/sbm.imz multicd-working/boot/finnix/
		umount finnix
		rmdir finnix
	fi
elif [ $1 = writecfg ];then
if [ -f finnix.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label Finnix
  MENU LABEL ^Finnix (x86)
  kernel /boot/finnix/linux
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=791 quiet

label Finnix64
  MENU LABEL Finnix (AMD64)
  kernel /boot/finnix/linux64
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=791 quiet

label FinnixText
  MENU LABEL ^Finnix (x86, textmode)
  kernel /boot/finnix/linux
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=normal quiet

label FinnixDebug
  MENU LABEL ^Finnix (x86, debug mode)
  kernel /boot/finnix/linux
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=normal debug

label Finnix64Text
  MENU LABEL Finnix (AMD64, textmode)
  kernel /boot/finnix/linux64
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=normal quiet

label Finnix64Debug
  MENU LABEL Finnix (AMD64, debug mode)
  kernel /boot/finnix/linux64
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt apm=power-off vga=normal debug

label FinnixFailsafe
  MENU LABEL ^Finnix (failsafe)
  kernel /boot/finnix/linux
  append finnixfile=/FINNIX/FINNIX initrd=/boot/finnix/minirt vga=normal noapic noacpi pnpbios=off acpi=off nofstab nodma noapm nodhcp nolvm nomouse noeject

label sbm
  MENU LABEL Smart Boot Manager
  kernel /boot/finnix/memdisk
  append initrd=/boot/finnix/sbm.imz
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
