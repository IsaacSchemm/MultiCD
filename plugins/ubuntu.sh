#!/bin/sh
set -e
#Ubuntu #2 plugin for multicd.sh
#version 5.4
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
	if [ -f ubuntu.iso ];then
		echo "Ubuntu"
		echo > tags/ubuntu1
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu.iso ];then
		echo "Copying Ubuntu..."
		if [ ! -d ubuntu ];then
			mkdir ubuntu
		fi
		if grep -q "`pwd`/ubuntu" /etc/mtab ; then
			umount ubuntu
		fi
		mount -o loop ubuntu.iso ubuntu/
		cp -R ubuntu/casper multicd-working/boot/ubuntu #Live system
		cp -R ubuntu/preseed multicd-working/boot/ubuntu
		# Fix the isolinux.cfg
		cp ubuntu/isolinux/text.cfg multicd-working/boot/ubuntu/ubuntu.cfg
		sed -i 's@default live@default menu.c32@g' multicd-working/boot/ubuntu/ubuntu.cfg
		sed -i 's@file=/cdrom/preseed/@file=/cdrom/boot/ubuntu/preseed/@g' multicd-working/boot/ubuntu/ubuntu.cfg
		sed -i 's^initrd=/casper/^live-media-path=/boot/ubuntu ignore_uuid initrd=/boot/ubuntu/^g' multicd-working/boot/ubuntu/ubuntu.cfg
		sed -i 's^kernel /casper/^kernel /boot/ubuntu/^g' multicd-working/boot/ubuntu/ubuntu.cfg
		sed -i 's^splash.jpg^linuxmint.jpg^g' multicd-working/boot/ubuntu/ubuntu.cfg
		umount ubuntu;rmdir ubuntu
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label ubuntu2
menu label --> Ubuntu #1 Menu
com32 menu.c32
append /boot/ubuntu/ubuntu.cfg

EOF
cat >> multicd-working/boot/ubuntu/ubuntu.cfg << EOF

label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
EOF
if [ -f tags/ubuntu1.name ];then
	perl -pi -e "s/Ubuntu\ \#1/$(cat tags/ubuntu1.name)/g" multicd-working/boot/isolinux/isolinux.cfg
else
	perl -pi -e "s/Ubuntu\ \#1/Ubuntu/g" multicd-working/boot/isolinux/isolinux.cfg
fi
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
