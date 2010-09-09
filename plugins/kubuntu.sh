#!/bin/sh
set -e
#Kubuntu plugin for multicd.sh
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
	if [ -f kubuntu.iso ];then
		echo "Kubuntu"
	fi
elif [ $1 = copy ];then
	if [ -f kubuntu.iso ];then
		echo "Copying Kubuntu..."
		if [ ! -d kubuntu ];then
			mkdir kubuntu
		fi
		if grep -q "`pwd`/kubuntu" /etc/mtab ; then
			umount kubuntu
		fi
		mount -o loop kubuntu.iso kubuntu/
		cp -R kubuntu/casper multicd-working/boot/kubuntu #Live system
		cp -R kubuntu/preseed multicd-working/boot/kubuntu
		# Fix the isolinux.cfg
		if [ -f kubuntu/isolinux/text.cfg ];then
			cp kubuntu/isolinux/text.cfg multicd-working/boot/kubuntu/kubuntu.cfg
		fi
		if [ -f kubuntu/isolinux/txt.cfg ];then
			cp kubuntu/isolinux/txt.cfg multicd-working/boot/kubuntu/kubuntu.cfg
		fi
		sed -i 's@default live@default menu.c32@g' multicd-working/boot/kubuntu/kubuntu.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/kubuntu/preseed/@g' multicd-working/boot/kubuntu/kubuntu.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/kubuntu ignore_uuid initrd=/boot/kubuntu/^g' multicd-working/boot/kubuntu/kubuntu.cfg
		sed -i 's^kernel /casper/^kernel /boot/kubuntu/^g' multicd-working/boot/kubuntu/kubuntu.cfg
		sed -i 's^splash.jpg^linuxmint.jpg^g' multicd-working/boot/kubuntu/kubuntu.cfg
		umount kubuntu;rmdir kubuntu
	fi
elif [ $1 = writecfg ];then
if [ -f kubuntu.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label kubuntu2
menu label --> Kubuntu #1 Menu
com32 menu.c32
append /boot/kubuntu/kubuntu.cfg

EOF
cat >> multicd-working/boot/kubuntu/kubuntu.cfg << EOF

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
