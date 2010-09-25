#!/bin/sh
set -e
#Austrumi plugin for multicd.sh
#version 5.9
#Copyright (c) 2010 maybeway36
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
	fi
elif [ $1 = copy ];then
	if [ -f austrumi.iso ];then
		echo "Copying Austrumi..."
		if [ ! -d $MNT/austrumi ];then
			mkdir $MNT/austrumi
		fi
		if grep -q "$MNT/austrumi" /etc/mtab ; then
			umount $MNT/austrumi
		fi
		mount -o loop austrumi.iso $MNT/austrumi/
		cp -r $MNT/austrumi/austrumi $WORK/ #This folder also has the kernel and initrd
		cp $MNT/austrumi/isolinux.cfg $WORK/boot/isolinux/al.menu
		#These files were moved in 1.9.3
		#cp $MNT/austrumi/boot/austrumi.fs $WORK/boot/austrumi.fs
		#cp $MNT/austrumi/boot/austrumi.tgz $WORK/boot/austrumi.tgz
		umount $MNT/austrumi;$MNT/rmdir austrumi
	fi
elif [ $1 = writecfg ];then
if [ -f austrumi.iso ];then
echo "label austrumilinux
	menu label ^Austrumi
	com32 vesamenu.c32
	append al.menu
" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
