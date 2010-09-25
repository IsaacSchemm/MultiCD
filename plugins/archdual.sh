#!/bin/sh
set -e
#Arch Linux (dual i686/x86_64) installer plugin for multicd.sh
#version 5.9
#Copyright (c) 2010 maybeway36
#Thanks to jerome_bc for updating this script for the newest Arch
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
	if [ -f archdual.iso ];then
		echo "Arch Linux Dual"
	fi
elif [ $1 = copy ];then
	if [ -f archdual.iso ];then
		echo "Copying Arch Linux Dual..."
		if [ ! -d $MNT/archdual ];then
			mkdir $MNT/archdual
		fi
		if grep -q "$MNT/archdual" /etc/mtab ; then
			umount $MNT/archdual
		fi
		mount -o loop archdual.iso $MNT/archdual
		mkdir -p $WORK/boot/arch/i686
		mkdir -p $WORK/boot/arch/x86_64
		mkdir $WORK/i686
		mkdir $WORK/x86_64
		cp $MNT/archdual/boot/i686/vmlinuz26 $WORK/boot/arch/i686/vmlinuz26 #i686 Kernel
		cp $MNT/archdual/boot/x86_64/vmlinuz26 $WORK/boot/arch/x86_64/vmlinuz26 #x86_64 Kernel
		cp $MNT/archdual/boot/i686/archiso.img $WORK/boot/arch/i686/archiso.img #i686 initrd
		cp $MNT/archdual/boot/x86_64/archiso.img $WORK/boot/arch/x86_64/archiso.img #x86_64 initrd
		cp $MNT/archdual/i686/*.sqfs $WORK/i686 #i686 Compressed filesystems
		cp $MNT/archdual/x86_64/*.sqfs $WORK/x86_64 #x86_64 Compressed filesystems
		cp $MNT/archdual/isomounts $WORK/ #Text file
		umount $MNT/archdual;rmdir $MNT/archdual
	fi
elif [ $1 = writecfg ];then
if [ -f archdual.iso ];then
echo "label arch1
menu label Boot ArchLive i686
kernel /boot/arch/i686/vmlinuz26
append lang=en locale=en_US.UTF-8 usbdelay=5 ramdisk_size=75% initrd=/boot/arch/i686/archiso.img archisolabel=$(cat tags/cdlabel)

label arch2
menu label Boot ArchLive x86_64
kernel /boot/arch/x86_64/vmlinuz26
append lang=en locale=en_US.UTF-8 usbdelay=5 ramdisk_size=75% initrd=/boot/arch/x86_64/archiso.img archisolabel=$(cat tags/cdlabel)
" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
