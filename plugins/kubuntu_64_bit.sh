#!/bin/sh
set -e
#kubuntu_64_bit plugin for multicd.sh
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
	if [ -f kubuntu_64_bit.iso ];then
		echo "kubuntu_64_bit"
	fi
elif [ $1 = copy ];then
	if [ -f kubuntu_64_bit.iso ];then
		echo "Copying kubuntu_64_bit..."
		if [ ! -d kubuntu_64_bit ];then
			mkdir kubuntu_64_bit
		fi
		if grep -q "`pwd`/kubuntu_64_bit" /etc/mtab ; then
			umount kubuntu_64_bit
		fi
		mount -o loop kubuntu_64_bit.iso kubuntu_64_bit/
		cp -R kubuntu_64_bit/casper multicd-working/boot/kubuntu_64_bit #Live system
		cp -R kubuntu_64_bit/preseed multicd-working/boot/kubuntu_64_bit
		# Fix the isolinux.cfg
		if [ -f kubuntu_64_bit/isolinux/text.cfg ];then
			cp kubuntu_64_bit/isolinux/text.cfg multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		fi
		if [ -f kubuntu_64_bit/isolinux/txt.cfg ];then
			cp kubuntu_64_bit/isolinux/txt.cfg multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		fi
		sed -i 's@default live@default menu.c32@g' multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/kubuntu_64_bit/preseed/@g' multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/kubuntu_64_bit ignore_uuid initrd=/boot/kubuntu_64_bit/^g' multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		sed -i 's^kernel /casper/^kernel /boot/kubuntu_64_bit/^g' multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
		if [ $(cat tags/lang) != en ];then
			sed -i "s^--^-- debian-installer/language=$(cat tags/lang) console-setup/layoutcode?=$(cat tags/lang)^g" multicd-working/boot/ubuntu/ubuntu.cfg
		fi
		umount kubuntu_64_bit;rmdir kubuntu_64_bit
	fi
elif [ $1 = writecfg ];then
if [ -f kubuntu_64_bit.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label kubuntu_64_bit2
menu label --> kubuntu_64_bit #1 Menu
com32 menu.c32
append /boot/kubuntu_64_bit/kubuntu_64_bit.cfg

EOF
cat >> multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg << EOF

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
