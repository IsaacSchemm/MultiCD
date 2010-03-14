#!/bin/sh
set -e
#Linux Mint plugin for multicd.sh
#version 5.1?
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
	if [ -f linuxmint.iso ];then
		if [ -f ubuntu.iso ];then
			echo
			echo "Ubuntu and Linux Mint both use casper. They can't be on the same CD without"
			echo "initrd modifications, which this script does not support."
			echo "Ignoring linuxmint.iso."
		else
			echo "Linux Mint"
		fi
	fi
elif [ $1 = copy ];then
	if [ -f linuxmint.iso ] && [ ! -f ubuntu.iso ];then
		echo "Copying Linux Mint..."
		if [ ! -d linuxmint ];then
			mkdir linuxmint
		fi
		if grep -q "`pwd`/linuxmint" /etc/mtab ; then
			umount linuxmint
		fi
		mount -o loop linuxmint.iso linuxmint/
		cp -R linuxmint/casper multicd-working/ #Live system
		if [ -d linuxmint/drivers ];then cp -R linuxmint/drivers multicd-working/;fi #Drivers added by the Mint team
		cp -R linuxmint/preseed multicd-working/ #Tells the installer what to install
		cp -R linuxmint/.disk multicd-working/ #A few more helper files
		umount linuxmint
		rmdir linuxmint
	fi
elif [ $1 = writecfg ];then
if [ -f linuxmint.iso ] && [ ! -f ubuntu.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label mint-live
  menu label ^Try Linux Mint without any change to your computer
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/mint.seed boot=casper initrd=/casper/initrd.gz quiet splash --
label mint-live-install
  menu label ^Install Linux Mint
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/mint.seed boot=casper only-ubiquity initrd=/casper/initrd.gz quiet splash --
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
