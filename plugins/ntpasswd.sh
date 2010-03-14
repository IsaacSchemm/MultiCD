#!/bin/sh
set -e
#NT Password Editor plugin for multicd.sh
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
	if [ -f ntpasswd.iso ];then
		echo "NT Password Editor"
	fi
elif [ $1 = copy ];then
	if [ -f ntpasswd.iso ];then
		if [ ! -d ntpasswd ];then
			mkdir ntpasswd
		fi
		if grep -q "`pwd`/ntpasswd" /etc/mtab ; then
			umount ntpasswd
		fi
		mount -o loop ntpasswd.iso ntpasswd/
		mkdir multicd-working/boot/ntpasswd
		cp ntpasswd/vmlinuz multicd-working/boot/ntpasswd/vmlinuz
		cp ntpasswd/initrd.cgz multicd-working/boot/ntpasswd/initrd.cgz
		cp ntpasswd/scsi.cgz multicd-working/boot/ntpasswd/scsi.cgz #Alternate initrd
		umount ntpasswd
		rmdir ntpasswd
	fi
elif [ $1 = writecfg ];then
if [ -f ntpasswd.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ntpasswd
menu label ^NT Offline Password & Registry Editor
kernel /boot/ntpasswd/vmlinuz
append rw vga=1 init=/linuxrc initrd=/boot/ntpasswd/initrd.cgz,/boot/ntpasswd/scsi.cgz
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
