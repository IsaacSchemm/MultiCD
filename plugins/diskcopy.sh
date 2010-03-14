#!/bin/sh
set -e
#EASEUS Disk Copy plugin for multicd.sh
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
	if [ -f diskcopy.iso ];then
		echo "EASEUS Disk Copy"
		DCISO=1
	else
		if [ -f DC2.iso ];then
			ln -s DC2.iso diskcopy.iso
			echo "EASEUS Disk Copy (note: made link from DC2.iso to diskcopy.iso)"
			DCISO=1
		else
			DCISO=0
		fi
	fi
elif [ $1 = copy ];then
	if [ -f diskcopy.iso ];then
		if [ ! -d diskcopy ];then
			mkdir diskcopy
		fi
		if grep -q "`pwd`/diskcopy" /etc/mtab ; then
			umount diskcopy
		fi
		mount -o loop diskcopy.iso diskcopy/
		mkdir -p multicd-working/boot/diskcopy
		cp diskcopy/boot/bzImage multicd-working/boot/diskcopy/bzImage
		cp diskcopy/boot/initrd.img multicd-working/boot/diskcopy/initrd.img
		umount diskcopy
		rmdir diskcopy
	fi
elif [ $1 = writecfg ];then
if [ -f diskcopy.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label diskcopy
menu label ^EASEUS Disk Copy
kernel /boot/diskcopy/bzImage
append initrd=/boot/diskcopy/initrd.img
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
