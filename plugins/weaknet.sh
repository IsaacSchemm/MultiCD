#!/bin/sh
set -e
#WeakNet Linux plugin for multicd.sh
#version 5.3
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
	if [ -f weaknet.iso ];then
		echo "WeakNet Linux"
	fi
elif [ $1 = copy ];then
	if [ -f weaknet.iso ];then
		echo "Copying WeakNet Linux..."
		if [ ! -d weaknet ];then
			mkdir weaknet
		fi
		if grep -q "`pwd`/weaknet" /etc/mtab ; then
			umount weaknet
		fi
		mount -o loop weaknet.iso weaknet/
		mkdir multicd-working/boot/weaknet
		cp -R weaknet/casper/* multicd-working/boot/weaknet/
		echo -n "Making initrd..."
		mkdir weaknet-inittmp
		cd weaknet-inittmp
		gzip -cd ../multicd-working/boot/weaknet/initrd.gz|cpio -id
		perl -pi -e 's/path\/casper/path\/boot\/weaknet/g' scripts/casper
		perl -pi -e 's/directory\/casper/directory\/boot\/weaknet/g' scripts/casper
		find . | cpio --create --format='newc' | gzip -c > ../multicd-working/boot/weaknet/initrd.gz
		cd ..
		echo " done."
		rm -r weaknet-inittmp
		umount weaknet
		rmdir weaknet
	fi
elif [ $1 = writecfg ];then
if [ -f weaknet.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL live
  menu label ^WeakNet Linux (live)
  kernel /boot/weaknet/vmlinuz
  append  file=/cdrom/preseed/custom.seed boot=casper initrd=/boot/weaknet/initrd.gz quiet splash ignore_uuid --
LABEL xforcevesa
  menu label WeakNet Linux (safe graphics mode)
  kernel /boot/weaknet/vmlinuz
  append  file=/cdrom/preseed/custom.seed boot=casper xforcevesa initrd=/boot/weaknet/initrd.gz quiet splash ignore_uuid --
LABEL install
  menu label Install WeakNet Linux
  kernel /boot/weaknet/vmlinuz
  append  file=/cdrom/preseed/custom.seed boot=casper only-ubiquity initrd=/boot/weaknet/initrd.gz quiet splash ignore_uuid --
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
