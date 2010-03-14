#!/bin/sh
set -e
#Ubuntu installer plugin for multicd.sh
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
	if [ -f ubuntu-mini.iso ];then
		echo "Ubuntu netboot installer"
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu-mini.iso ];then
		echo "Copying Ubuntu netboot installer..."
		if [ ! -d ubuntu-mini ];then
			mkdir ubuntu-mini
		fi
		if grep -q "`pwd`/ubuntu-mini" /etc/mtab ; then
			umount ubuntu-mini
		fi
		mount -o loop ubuntu-mini.iso ubuntu-mini/
		mkdir multicd-working/boot/ubuntu
		cp ubuntu-mini/linux multicd-working/boot/ubuntu/linux
		cp ubuntu-mini/initrd.gz multicd-working/boot/ubuntu/initrd.gz
		umount ubuntu-mini
		rmdir ubuntu-mini
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu-mini.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL uinstall
menu label Install ^Ubuntu
	kernel /boot/ubuntu/linux
	append vga=normal initrd=/boot/ubuntu/initrd.gz -- 
LABEL ucli
menu label Install Ubuntu (CLI)
	kernel /boot/ubuntu/linux
	append tasks=standard pkgsel/language-pack-patterns= pkgsel/install-language-support=false vga=normal initrd=/boot/ubuntu/initrd.gz -- 

LABEL uexpert
menu label Install Ubuntu - expert mode
	kernel /boot/ubuntu/linux
	append priority=low vga=normal initrd=/boot/ubuntu/initrd.gz -- 
LABEL ucli-expert
menu label Install Ubuntu (CLI) - expert mode
	kernel /boot/ubuntu/linux
	append tasks=standard pkgsel/language-pack-patterns= pkgsel/install-language-support=false priority=low vga=normal initrd=/boot/ubuntu/initrd.gz -- 
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
