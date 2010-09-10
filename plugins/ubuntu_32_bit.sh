#!/bin/sh
set -e
#ubuntu_32_bit plugin for multicd.sh
#version 5.6
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
	if [ -f ubuntu_32_bit.iso ];then
		echo "ubuntu_32_bit"
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu_32_bit.iso ];then
		echo "Copying ubuntu_32_bit..."
		if [ ! -d ubuntu_32_bit ];then
			mkdir ubuntu_32_bit
		fi
		if grep -q "`pwd`/ubuntu_32_bit" /etc/mtab ; then
			umount ubuntu_32_bit
		fi
		mount -o loop ubuntu_32_bit.iso ubuntu_32_bit/
		cp -R ubuntu_32_bit/casper multicd-working/boot/ubuntu_32_bit #Live system
		cp -R ubuntu_32_bit/preseed multicd-working/boot/ubuntu_32_bit
		# Fix the isolinux.cfg
		if [ -f ubuntu_32_bit/isolinux/text.cfg ];then
			cp ubuntu_32_bit/isolinux/text.cfg multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		fi
		if [ -f ubuntu_32_bit/isolinux/txt.cfg ];then
			cp ubuntu_32_bit/isolinux/txt.cfg multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		fi
		sed -i 's@default live@default menu.c32@g' multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/ubuntu_32_bit/preseed/@g' multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/ubuntu_32_bit ignore_uuid initrd=/boot/ubuntu_32_bit/^g' multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		sed -i 's^kernel /casper/^kernel /boot/ubuntu_32_bit/^g' multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg
		if [ $(cat tags/lang) != en ];then
			sed -i "s^--^-- debian-installer/language=$(cat tags/lang) console-setup/layoutcode?=$(cat tags/lang)^g" multicd-working/boot/ubuntu/ubuntu.cfg
		fi
		umount ubuntu_32_bit;rmdir ubuntu_32_bit
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu_32_bit.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label ubuntu_32_bit2
menu label --> ubuntu_32_bit #1 Menu
com32 menu.c32
append /boot/ubuntu_32_bit/ubuntu_32_bit.cfg

EOF
cat >> multicd-working/boot/ubuntu_32_bit/ubuntu_32_bit.cfg << EOF

label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
