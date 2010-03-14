#!/bin/sh
set -e
#Linux Mint plugin for multicd.sh
#version 5.3
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
			echo "Linux Mint (8/Helena or newer)"
		fi
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
		cp -R linuxmint/casper multicd-working/linuxmint #Live system
		if [ -d linuxmint/drivers ];then cp -R linuxmint/drivers multicd-working/;fi #Drivers added by the Mint team
		umount linuxmint;rmdir linuxmint
		echo -n "Making initrd..."
		if [ -f multicd-working/linuxmint/initrd.lz ];then
			cp multicd-working/linuxmint/initrd.lz tmpinit.lzma
			lzma -d tmpinit.lzma
		else
			echo "This plugin will only work with Linux Mint 8 or newer."
			exit 1
		fi
		mkdir linuxmint-inittmp
		cd linuxmint-inittmp
		cpio -id < ../tmpinit
		rm ../tmpinit
		perl -pi -e 's/LIVE_MEDIA_PATH=casper/LIVE_MEDIA_PATH=linuxmint/g' scripts/casper
		find . | cpio --create --format='newc' | lzma -c > ../multicd-working/linuxmint/initrd.lz
		cd ..
		rm -r linuxmint-inittmp
		echo " done."	
	fi
elif [ $1 = writecfg ];then
if [ -f linuxmint.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label mint-live
  menu label ^Try Linux Mint without any change to your computer
  kernel /linuxmint/vmlinuz
  append boot=casper initrd=/linuxmint/initrd.lz quiet splash --
label mint-live-install
  menu label ^Install Linux Mint
  kernel /linuxmint/vmlinuz
  append boot=casper only-ubiquity initrd=/linuxmint/initrd.lz quiet splash --
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
