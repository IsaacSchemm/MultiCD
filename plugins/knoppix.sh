#!/bin/sh
set -e
#Knoppix plugin for multicd.sh
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
	if [ -f knoppix.iso ];then
		echo "Knoppix"
		export KNOPPIX=1
	fi
elif [ $1 = copy ];then
	if [ -f knoppix.iso ];then
		echo "Copying Knoppix..."
		if [ ! -d knoppix ];then
			mkdir knoppix
		fi
		if grep -q "`pwd`/knoppix" /etc/mtab ; then
			umount knoppix
		fi
		mount -o loop knoppix.iso knoppix/
		mkdir multicd-working/KNOPPIX5
		#Compressed filesystem and docs. We have to call it KNOPPIX5 because DSL uses KNOPPIX, and if we change that DSL's installer won't work.
		for i in $(ls knoppix/KNOPPIX*|grep -v '^KNOPPIX2$');do
			cp -r knoppix/KNOPPIX/$i multicd-working/KNOPPIX5/
		done
		mkdir -p multicd-working/boot/knoppix
		cp knoppix/boot/isolinux/linux multicd-working/boot/knoppix/linux
		cp knoppix/boot/isolinux/minirt.gz multicd-working/boot/knoppix/minirt.gz
		umount knoppix;rmdir knoppix
	fi
elif [ $1 = writecfg ];then
if [ -f knoppix.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL knoppix
MENU LABEL Knoppix
KERNEL /boot/knoppix/linux
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/knoppix/minirt.gz knoppix_dir=KNOPPIX5 nomce highres=off loglevel=0 libata.atapi_enabled=1 quiet SELINUX_INIT=NO nmi_watchdog=0 BOOT_IMAGE=knoppix

LABEL adriane
MENU LABEL Adriane (Knoppix)
KERNEL /boot/knoppix/linux
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=785 initrd=/boot/knoppix/minirt.gz knoppix_dir=KNOPPIX5 nomce highres=off loglevel=0 libata.atapi_enabled=1 quiet SELINUX_INIT=NO nmi_watchdog=0 BOOT_IMAGE=adriane

LABEL knoppix-2
MENU LABEL Knoppix (boot to command line)
KERNEL /boot/knoppix/linux
APPEND ramdisk_size=100000 init=/etc/init lang=us apm=power-off vga=791 initrd=/boot/knoppix/minirt.gz knoppix_dir=KNOPPIX5 nomce highres=off loglevel=0 libata.atapi_enabled=1 quiet SELINUX_INIT=NO nmi_watchdog=0 BOOT_IMAGE=knoppix 2
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
