#!/bin/sh
set -e
#DeLi Linux plugin for multicd.sh
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
	if [ -f deli.iso ];then
		echo "DeLi Linux"
	fi
elif [ $1 = copy ];then
	if [ -f deli.iso ];then
		echo "Copying DeLi Linux..."
		if [ ! -d deli ];then
			mkdir deli
		fi
		if grep -q "`pwd`/deli" /etc/mtab ; then
			umount deli
		fi
		mount -o loop deli.iso deli/
		cp -r deli/isolinux multicd-working/ #Kernel and filesystem
		cp -r deli/pkg multicd-working/ #Packages
		umount deli
		rmdir deli
	fi
elif [ $1 = writecfg ];then
if [ -f deli.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label deli-ide
	menu label ^DeLi Linux
	kernel /isolinux/bzImage
	append initrd=/isolinux/initrd.gz load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=6464 rw root=/dev/ram

label deli-scsi
	menu label ^DeLi Linux - SCSI
	kernel /isolinux/scsi
	append initrd=/isolinux/initrd.gz load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=6464 rw root=/dev/ram
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
