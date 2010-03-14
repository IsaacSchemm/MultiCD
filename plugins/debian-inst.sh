#!/bin/sh
set -e
#Debian installer plugin for multicd.sh
#version 5.0.3
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
	if [ -f debian-mini.iso ];then
		echo "Debian netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f debian-mini.iso ];then
		echo "Copying Debian netboot installer..."
		if [ ! -d debian-mini ];then
			mkdir debian-mini
		fi
		if grep -q "`pwd`/debian-mini" /etc/mtab ; then
			umount debian-mini
		fi
		mount -o loop debian-mini.iso debian-mini/
		mkdir multicd-working/boot/debian
		cp debian-mini/linux multicd-working/boot/debian/linux
		cp debian-mini/initrd.gz multicd-working/boot/debian/initrd.gz
		umount debian-mini
		rmdir debian-mini
	fi
elif [ $1 = writecfg ];then
if [ -f debian-mini.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL dinstall
menu label ^Install Debian
	kernel /boot/debian/linux
	append vga=normal initrd=/boot/debian/initrd.gz -- quiet 
LABEL dexpert
menu label Install Debian - expert mode
	kernel /boot/debian/linux
	append priority=low vga=normal initrd=/boot/debian/initrd.gz -- 
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
