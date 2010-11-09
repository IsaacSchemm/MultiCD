#!/bin/sh
set -e
#Wolvix plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 libertyernie
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
	if [ -f wolvix.iso ];then
		echo "Wolvix"
	fi
elif [ $1 = copy ];then
	if [ -f wolvix.iso ];then
		echo "Copying Wolvix..."
		if [ ! -d wolvix ];then
			mkdir wolvix
		fi
		if grep -q "`pwd`/wolvix" /etc/mtab ; then
			umount wolvix
		fi
		mount -o loop wolvix.iso wolvix/
		cp -r wolvix/wolvix multicd-working/ #The Wolvix folder with all its files
		mkdir -p multicd-working/boot/wolvix
		#The kernel/initrd must be here for the installer
		cp wolvix/boot/vmlinuz multicd-working/boot/vmlinuz
		cp wolvix/boot/initrd.gz multicd-working/boot/initrd.gz
		umount wolvix
		rmdir wolvix
	fi
elif [ $1 = writecfg ];then
if [ -f wolvix.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label wolvix
menu label ^Wolvix GNU/Linux (login as root, password is toor)
kernel /boot/vmlinuz
append changes=wolvixsave.xfs max_loop=255 initrd=/boot/initrd.gz ramdisk_size=6666 root=/dev/ram0 rw vga=791 splash=silent
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
