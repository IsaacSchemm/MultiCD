#!/bin/sh
set -e
. ./functions.sh
#Debian install CD/DVD plugin for multicd.sh
#version 6.2
#Copyright (c) 2010 libertyernie
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
if [ $1 = links ];then
	echo "ubuntu-*.iso ubuntu-alternate.iso Ubuntu_alternate_installer_(32-bit)"
elif [ $1 = scan ];then
	if [ -f ubuntu-alternate.iso ];then
		echo -n "Ubuntu alternate installer (only one of these can be included)"
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu-alternate.iso ];then
		if [ -d $WORK/pool ];then
			echo "NOT copying Ubuntu alternate installer - some sort of Ubuntu/Debian installer is already present."
			touch $TAGS/ubuntu-not-copied
		else
			echo "Copying Ubuntu alternate installer..."
			mcdmount ubuntu-alternate
			cp $MNT/ubuntu-alternate/cdromupgrade $WORK || true #Not essential
			cp -r $MNT/ubuntu-alternate/.disk $WORK
			cp -r $MNT/ubuntu-alternate/dists $WORK
			cp -r $MNT/ubuntu-alternate/doc $WORK || true
			cp -r $MNT/ubuntu-alternate/install $WORK
			cp -r $MNT/ubuntu-alternate/pool $WORK
			cp -r $MNT/ubuntu-alternate/preseed $WORK
			cp -r $MNT/ubuntu-alternate/README.diskdefines $WORK
			cp -r $MNT/ubuntu-alternate/ubuntu $WORK
			umcdmount ubuntu-alternate
		fi
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu-alternate.iso ] && [ ! -f $TAGS/ubuntu-not-copied ];then
if [ -f $WORK/README.diskdefines ];then
	CDNAME="$(grep DISKNAME a/README.diskdefines|awk '{for (i=3; i<NF+1; i++) { printf $i; printf " " } printf "\n" }')"
else
	CDNAME="Ubuntu alternate installer"
fi
echo "menu begin --> ^$CDNAME

label install
  menu label ^Install Ubuntu
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed vga=788 initrd=/install/initrd.gz quiet --

label expert
  menu label ^Expert install
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed priority=low vga=788 initrd=/install/initrd.gz --
label rescue
  menu label ^Rescue a broken system
  kernel /install/vmlinuz
  append  rescue/enable=true vga=788 initrd=/install/initrd.gz --

menu end" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
