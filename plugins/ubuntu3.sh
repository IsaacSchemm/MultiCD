#!/bin/sh
set -e
#Ubuntu Custom #3 plugin for multicd.sh
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
	if [ -f ubuntu3.iso ];then
		echo "Ubuntu custom #3 (for using multiple versions on one disc - 9.10 or newer)"
		echo > tags/ubuntu-custom3
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu3.iso ];then
		echo "Copying Ubuntu #3..."
		if [ ! -d ubuntu3 ];then
			mkdir ubuntu3
		fi
		if grep -q "`pwd`/ubuntu3" /etc/mtab ; then
			umount ubuntu3
		fi
		mount -o loop ubuntu3.iso ubuntu3/
		cp -R ubuntu3/casper multicd-working/boot/ubuntu3 #Live system
		cp -R ubuntu3/preseed multicd-working/boot/ubuntu3
		# Fix the isolinux.cfg
		if [ -f ubuntu3/isolinux/text.cfg ];then
			cp ubuntu3/isolinux/text.cfg multicd-working/boot/ubuntu3/ubuntu3.cfg
		fi
		if [ -f ubuntu3/isolinux/txt.cfg ];then
			cp ubuntu3/isolinux/txt.cfg multicd-working/boot/ubuntu3/ubuntu3.cfg
		fi
		sed -i 's@default live@default menu.c32@g' multicd-working/boot/ubuntu3/ubuntu3.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/ubuntu3/preseed/@g' multicd-working/boot/ubuntu3/ubuntu3.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/ubuntu3 ignore_uuid initrd=/boot/ubuntu3/^g' multicd-working/boot/ubuntu3/ubuntu3.cfg
		sed -i 's^kernel /casper/^kernel /boot/ubuntu3/^g' multicd-working/boot/ubuntu3/ubuntu3.cfg
		sed -i 's^splash.jpg^linuxmint.jpg^g' multicd-working/boot/ubuntu3/ubuntu3.cfg
		umount ubuntu3;rmdir ubuntu3
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu3.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label ubuntu3
menu label --> Ubuntu Custom #3 Menu
com32 menu.c32
append /boot/ubuntu3/ubuntu3.cfg

EOF
cat >> multicd-working/boot/ubuntu3/ubuntu3.cfg << EOF

label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
EOF
if [ -f tags/ubuntu-custom3.name ];then
	perl -pi -e "s/Ubuntu\ Custom\ \#3/$(cat tags/ubuntu-custom3.name)/g" multicd-working/boot/isolinux/isolinux.cfg
fi
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
