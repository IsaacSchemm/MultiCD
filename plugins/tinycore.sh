#!/bin/sh
set -e
#Tiny Core Linux plugin for multicd.sh
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
	if [ -f tinycore.iso ];then
		echo "Tiny Core Linux"
	fi
elif [ $1 = copy ];then
	if [ -f tinycore.iso ];then
		echo "Copying Tiny Core..."
		if [ ! -d tinycore ];then
			mkdir tinycore
		fi
		if grep -q "`pwd`/tinycore" /etc/mtab ; then
			umount tinycore
		fi
		mount -o loop tinycore.iso tinycore/
		mkdir multicd-working/boot/tinycore
		cp tinycore/boot/bzImage multicd-working/boot/tinycore/bzImage #Linux kernel
		cp tinycore/boot/tinycore.gz multicd-working/boot/tinycore/tinycore.gz #Entire Tiny Core image is in this file
		umount tinycore
		rmdir tinycore
	fi
elif [ $1 = writecfg ];then
#BEGIN TINY CORE ENTRY#
if [ -f tinycore.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label tinycore
menu label ^Tiny Core Linux
kernel /boot/tinycore/bzImage
append quiet initrd=/boot/tinycore/tinycore.gz
EOF
fi
#END TINY CORE ENTRY#
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
