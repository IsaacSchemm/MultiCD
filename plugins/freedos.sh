#!/bin/sh
set -e
#FreeDOS installer plugin for multicd.sh
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
	if [ -f fdfullcd.iso ] || [ -f fdbasecd.iso ];then
		echo "FreeDOS"
	fi
elif [ $1 = copy ];then
	if [ -f fdfullcd.iso ] || [ -f fdbasecd.iso ];then
		echo "Copying FreeDOS..."
		if [ ! -d freedos ];then
			mkdir freedos
		fi
		if grep -q "`pwd`/freedos" /etc/mtab ; then
			umount freedos
		fi
		if [ -f fdfullcd.iso ];then mount -o loop fdfullcd.iso freedos/ #It might be fdbasecd or fdfullcd
		else mount -o loop fdbasecd.iso freedos/;fi
			mkdir multicd-working/boot/freedos
		cp -r freedos/freedos multicd-working/ #Core directory with the packages
		cp freedos/setup.bat multicd-working/setup.bat #FreeDOS setup
		cp freedos/isolinux/data/fdboot.img multicd-working/boot/freedos/fdboot.img #Initial DOS boot image
		if [ -d freedos/fdos ];then
			cp -r freedos/fdos multicd-working/ #Live CD
		fi
		if [ -d freedos/gemapps ];then
			cp -r freedos/gemapps multicd-working/ #OpenGEM
		fi
		if [ -f freedos/gem.bat ];then
			cp -r freedos/gem.bat multicd-working/ #OpenGEM setup
		fi
		umount freedos
		rmdir freedos
	fi
elif [ $1 = writecfg ];then
if [ -f freedos.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label fdos
menu label ^FreeDOS 1.0
kernel memdisk
append initrd=/boot/freedos/fdboot.img
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
