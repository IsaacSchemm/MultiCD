#!/bin/sh
set -e
#Austrumi plugin for multicd.sh
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
	if [ -f austrumi.iso ];then
		echo "Austrumi"
	elif [ -f al.iso ];then
		echo "Austrumi (moving al.iso to austrumi.iso)"
		mv al.iso austrumi.iso
	fi
elif [ $1 = copy ];then
	if [ -f austrumi.iso ];then
		echo "Copying Austrumi..."
		if [ ! -d austrumi ];then
			mkdir austrumi
		fi
		if grep -q "`pwd`/austrumi" /etc/mtab ; then
			umount austrumi
		fi
		mount -o loop austrumi.iso austrumi/
		cp -r austrumi/austrumi multicd-working/ #This folder also has the kernel and initrd
		cp austrumi/isolinux.cfg multicd-working/boot/isolinux/al.menu
		#These files were moved in 1.9.3
		#cp austrumi/boot/austrumi.fs multicd-working/boot/austrumi.fs
		#cp austrumi/boot/austrumi.tgz multicd-working/boot/austrumi.tgz
		umount austrumi;rmdir austrumi
	fi
elif [ $1 = writecfg ];then
if [ -f austrumi.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label austrumilinux
	menu label ^Austrumi
	com32 vesamenu.c32
	append al.menu
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
