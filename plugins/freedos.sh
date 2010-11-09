#!/bin/sh
set -e
. ./functions.sh
#FreeDOS installer plugin for multicd.sh
#version 6.1
#Copyright (c) 2010 libertyernie
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
	if [ -f fdfullcd.iso ] || [ -f fdbasecd.iso ];then
		echo "FreeDOS"
	fi
elif [ $1 = copy ];then
	if [ -f fdfullcd.iso ] || [ -f fdbasecd.iso ];then
		echo "Copying FreeDOS..."
		if [ ! -d $MNT/freedos ];then
			mkdir $MNT/freedos
		fi
		if grep -q "$MNT/freedos" /etc/mtab ; then
			umount $MNT/freedos
		fi
		if [ -f fdfullcd.iso ];then
			mount -o loop fdfullcd.iso $MNT/freedos/ #It might be fdbasecd or fdfullcd
		else
			mount -o loop fdbasecd.iso $MNT/freedos/
		fi
		mkdir multicd-working/boot/freedos
		cp -r $MNT/freedos/freedos multicd-working/ #Core directory with the packages
		cp $MNT/freedos/setup.bat multicd-working/setup.bat #FreeDOS setup
		cp $MNT/freedos/isolinux/data/fdboot.img multicd-working/boot/freedos/fdboot.img #Initial DOS boot image
		if [ -d $MNT/freedos/fdos ];then
			cp -r $MNT/freedos/fdos multicd-working/ #Live CD
		fi
		if [ -d $MNT/freedos/gemapps ];then
			cp -r $MNT/freedos/gemapps multicd-working/ #OpenGEM
		fi
		if [ -f $MNT/freedos/gem.bat ];then
			cp -r $MNT/freedos/gem.bat multicd-working/ #OpenGEM setup
		fi
		umcdmount freedos
	fi
elif [ $1 = writecfg ];then
if [ -f fdfullcd.iso ];then
echo "label fdos
menu label ^FreeDOS 1.0 (full)
kernel memdisk
append initrd=/boot/freedos/fdboot.img
" >> multicd-working/boot/isolinux/isolinux.cfg
elif [ -f fdbasecd.iso ];then
echo "label fdos
menu label ^FreeDOS 1.0 (base)
kernel memdisk
append initrd=/boot/freedos/fdboot.img
" >> multicd-working/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
