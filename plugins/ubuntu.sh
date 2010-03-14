#!/bin/sh
set -e
#Ubuntu plugin for multicd.sh
#version 5.1
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
		cp -R ubuntu/casper multicd-working/ #Live system
		cp -R ubuntu/dists multicd-working/ #Other packages contained on CD
		cp -R ubuntu/pool multicd-working/ #Other packages contained on CD
		cp -R ubuntu/preseed multicd-working/ #Tells the installer what to install
		cp -R ubuntu/README.diskdefines multicd-working/ #Goes along with dists and pool
		#cp -R ubuntu/.disk multicd-working/ #A few more helper files
		ln -s . multicd-working/ubuntu #Because the original disc had it
		umount ubuntu;rmdir ubuntu
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu.iso ];then
if [ -f multicd-working/casper/initrd.lz ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ubuntu-live
  menu label ^Try Ubuntu #1 without any change to your computer
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed boot=casper initrd=/casper/initrd.lz quiet splash ignore_uuid --
label ubuntu-live-install
  menu label ^Install Ubuntu #1
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed boot=casper only-ubiquity initrd=/casper/initrd.lz quiet splash ignore_uuid --
EOF
else
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ubuntu-live
  menu label ^Try Ubuntu #1 without any change to your computer
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed boot=casper initrd=/casper/initrd.gz quiet splash ignore_uuid --
label ubuntu-live-install
  menu label ^Install Ubuntu #1
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed boot=casper only-ubiquity initrd=/casper/initrd.gz quiet splash ignore_uuid --
EOF
fi
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
