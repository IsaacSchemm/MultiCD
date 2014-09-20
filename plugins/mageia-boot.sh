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
	for iso in mageia-boot.iso mageia-boot-*.iso;do
		if [ -f mageia-boot.iso ];then
			echo "Mageia network installer ($iso)"
		fi
	done
elif [ $1 = copy ];then
	for iso in mageia-boot.iso mageia-boot-*.iso;do
		if [ -f "$iso" ];then
			isobase="$(basename -s.iso "$iso")"
			echo -n "Copying Mageia network installer... "
			mcdmount $isobase
			mkdir -p "${WORK}"/boot/mageia-boot
			for i in x86_64 i386;do
				if [ -d "${MNT}"/$isobase/isolinux/$i ];then
					echo -n "($i)"
					mkdir "${WORK}"/boot/mageia-boot/$i
					cp "${MNT}"/$isobase/isolinux/$i/vmlinuz "${WORK}"/boot/mageia-boot/$i/vmlinuz
					cp "${MNT}"/$isobase/isolinux/$i/all.rdz "${WORK}"/boot/mageia-boot/$i/all.rdz
				fi
			done
			echo
			umcdmount $isobase
		fi
	done
elif [ $1 = writecfg ];then
	for i in x86_64 i386;do
		if [ -d "${WORK}"/boot/mageia-boot/$i ];then
			echo "menu begin --> ^ Mageia network installer ($i)

label mageiaboot-linux
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz  vga=788 splash quiet
label mageiaboot-vgalo
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz  vga=785
label mageiaboot-vgahi
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz  vga=791
label mageiaboot-text
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz  text
label mageiaboot-rescue
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz  audit=0 rescue
label mageiaboot-noacpi
  kernel /boot/mageia-boot/$i/vmlinuz
  append initrd=/boot/mageia-boot/$i/all.rdz vga=788 splash quiet acpi=off

menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	done
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
