#!/bin/sh
set -e
#Ubuntu #2 plugin for multicd.sh
#version 5.0.4
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
	if [ -f ubuntu2.iso ];then
		echo "Ubuntu #2 (for using multiple versions on one disc)*"
		echo "  *Note: this plugin only works with Ubuntu 9.10 or newer (or distros based on Ubuntu 9.10 or newer)."
		echo > tags/ubuntu2
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu2.iso ];then
		echo "Copying Ubuntu #2..."
		if [ ! -d ubuntu2 ];then
			mkdir ubuntu2
		fi
		if grep -q "`pwd`/ubuntu2" /etc/mtab ; then
			umount ubuntu2
		fi
		mount -o loop ubuntu2.iso ubuntu2/
		cp -R ubuntu2/casper multicd-working/ubuntu2 #Live system
		#cp -R ubuntu2/.disk multicd-working/.disk-ubuntu2 #.disk
		umount ubuntu2;rmdir ubuntu2
		echo -n "Making initrd..."
		if [ -f multicd-working/ubuntu2/initrd.lz ];then
			cp multicd-working/ubuntu2/initrd.lz tmpinit.lzma
			lzma -d tmpinit.lzma
		else
			gzip -cd multicd-working/ubuntu2/initrd.gz>tmpinit
		fi
		mkdir ubuntu2-inittmp
		cd ubuntu2-inittmp
		cpio -id < ../tmpinit
		rm ../tmpinit
		perl -pi -e 's/LIVE_MEDIA_PATH=casper/LIVE_MEDIA_PATH=ubuntu2/g' scripts/casper
		find . | cpio --create --format='newc' | gzip -c > ../multicd-working/ubuntu2/initrd.gz
		rm ../multicd-working/ubuntu2/initrd.lz||true
		cd ..
		rm -r ubuntu2-inittmp
		echo " done."
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu2.iso ];then
if [ -f multicd-working/ubuntu2/initrd.lz ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ubuntu2-live
  menu label ^Try Ubuntu #2 without any change to your computer
  kernel /ubuntu2/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed initrd=/ubuntu2/initrd.lz quiet splash --
label ubuntu2-live-install
  menu label ^Install Ubuntu #2
  kernel /ubuntu2/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed only-ubiquity initrd=/ubuntu2/initrd.lz quiet splash --
EOF
else
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label ubuntu2-live
  menu label ^Try Ubuntu #2 without any change to your computer
  kernel /ubuntu2/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed initrd=/ubuntu2/initrd.gz quiet splash --
label ubuntu2-live-install
  menu label ^Install Ubuntu #2
  kernel /ubuntu2/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed only-ubiquity initrd=/ubuntu2/initrd.gz quiet splash --
EOF
fi
if [ -f tags/ubuntu2.name ];then
	perl -pi -e "s/Ubuntu\ \#2/$(cat tags/ubuntu2.name)/g" multicd-working/boot/isolinux/isolinux.cfg
fi
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
