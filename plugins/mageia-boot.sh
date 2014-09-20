#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Mageia network installer plugin for multicd.sh
#version 20140920
#Copyright (c) 2014 Isaac Schemm
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
	if [ -f mageia-boot.iso ];then
		echo "Mageia network installer"
	fi
elif [ $1 = copy ];then
	if [ -f mageia-boot.iso ];then
		echo "Copying Mageia network installer..."
		mcdmount mageia-boot
		mkdir "${WORK}"/boot/mageia-boot
		for i in x86_64;do
			if [ -d "${MNT}"/mageia-boot/isolinux/$i ];then
				mkdir "${WORK}"/boot/mageia-boot/$i
				cp "${MNT}"/mageia-boot/isolinux/$i/vmlinuz "${WORK}"/boot/mageia-boot/$i/vmlinuz
				cp "${MNT}"/mageia-boot/isolinux/$i/all.rdz "${WORK}"/boot/mageia-boot/$i/all.rdz
				ech
			fi
		done
		umcdmount mageia-boot
	fi
elif [ $1 = writecfg ];then
if [ -f mageia-boot.iso ];then
	for i in x86_64;do
		if [ -d "${WORK}"/boot/mageia-boot/$i ];then
			echo "menu begin --> ^ Mageia network installer

label mageiaboot-linux
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz  vga=788 splash quiet
label mageiaboot-vgalo
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz  vga=785
label mageiaboot-vgahi
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz  vga=791
label mageiaboot-text
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz  text
label mageiaboot-rescue
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz  audit=0 rescue
label mageiaboot-noacpi
  kernel mageia-boot/$i/vmlinuz
  append initrd=mageia-boot/$i/all.rdz vga=788 splash quiet acpi=off

menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	done
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
