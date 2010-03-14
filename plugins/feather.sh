#!/bin/sh
set -e
#Feather Linux plugin for multicd.sh
#version 5.0.1
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
	if [ -f feather.iso ];then
		echo "Feather"
	fi
elif [ $1 = copy ];then
	if [ -f feather.iso ];then
		echo "Copying Feather..."
		if [ ! -d feather ];then
			mkdir feather
		fi
		if grep -q "`pwd`/feather" /etc/mtab ; then
			umount feather
		fi
		mount -o loop feather.iso feather/
		mkdir multicd-working/FEATHER
		cp -R feather/KNOPPIX/* multicd-working/FEATHER/ #Compressed filesystem
		mkdir multicd-working/boot/feather
		cp feather/boot/isolinux/linux24 multicd-working/boot/feather/linux24
		cp feather/boot/isolinux/minirt24.gz multicd-working/boot/feather/minirt24.gz
		umount feather
		rmdir feather
	fi
elif [ $1 = writecfg ];then
if [ -f feather.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL feather
MENU LABEL ^Feather Linux
KERNEL /boot/feather/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/feather/minirt24.gz knoppix_dir=FEATHER nomce quiet BOOT_IMAGE=knoppix
LABEL feather-toram
MENU LABEL Feather Linux (load to RAM)
KERNEL /boot/feather/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/feather/minirt24.gz knoppix_dir=FEATHER nomce quiet toram BOOT_IMAGE=knoppix
LABEL feather-2
MENU LABEL Feather Linux (boot to command line)
KERNEL /boot/feather/linux24
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/feather/minirt24.gz knoppix_dir=FEATHER nomce quiet 2 BOOT_IMAGE=knoppix
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
