#!/bin/sh
set -e
#Linux Mint plugin for multicd.sh
#version 5.4
#Copyright (c) 2010 maybeway36, Zirafarafa
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
	if [ -f linuxmint.iso ];then
		echo "Linux Mint (8/Helena or newer)"
	fi
elif [ $1 = copy ];then
	if [ -f linuxmint.iso ];then
		echo "Copying Linux Mint..."
		if [ ! -d linuxmint ];then
			mkdir linuxmint
		fi
		if grep -q "`pwd`/linuxmint" /etc/mtab ; then
			umount linuxmint
		fi
		mount -o loop linuxmint.iso linuxmint/
		cp -R linuxmint/casper multicd-working/boot/linuxmint #Live system
	        #if [ -d linuxmint/drivers ];then cp -R linuxmint/drivers multicd-working/;fi #These don't exist anymore as of Mint 8
	        cp -R linuxmint/preseed multicd-working/boot/linuxmint
	        #cp -R linuxmint/.disk multicd-working/ #The UUID isn't needed when ignore_uuid is used
	        cp -R linuxmint/isolinux/splash.jpg multicd-working/boot/isolinux/linuxmint.jpg #A few more helper files
		# Fix the isolinux.cfg
		cp linuxmint/isolinux/isolinux.cfg multicd-working/boot/linuxmint/linuxmint.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/linuxmint/preseed/@g' multicd-working/boot/linuxmint/linuxmint.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/linuxmint ignore_uuid initrd=/boot/linuxmint/^g' multicd-working/boot/linuxmint/linuxmint.cfg
		sed -i 's^kernel /casper/^kernel /boot/linuxmint/^g' multicd-working/boot/linuxmint/linuxmint.cfg
		sed -i 's^splash.jpg^linuxmint.jpg^g' multicd-working/boot/linuxmint/linuxmint.cfg
		umount linuxmint;rmdir linuxmint
	fi
elif [ $1 = writecfg ];then
if [ -f linuxmint.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label linuxmint
menu label --> Linux ^Mint Menu
com32 vesamenu.c32
append /boot/linuxmint/linuxmint.cfg

EOF
cat >> multicd-working/boot/linuxmint/linuxmint.cfg << EOF

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
