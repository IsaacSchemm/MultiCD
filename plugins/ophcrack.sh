#!/bin/sh
set -e
#ophcrack plugin for multicd.sh
#version 5.8
#Copyright (c) 2010 yogurt06
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
	if [ -f ophxp.iso ] && [ ! -f ophvista.iso ];then
		echo "OPH Crack XP"
	fi
	if [ ! -f ophxp.iso ] && [ -f ophvista.iso ];then
		echo "OPH Crack Vista"
	fi
	if [ -f ophxp.iso ] && [ -f ophvista.iso ];then
		echo "OPH Crack XP/Vista"
	fi
elif [ $1 = copy ];then
	if [ -f ophxp.iso ];then
		echo "Copying OPH Crack XP..."
		if [ ! -d ophxp ];then
			mkdir ophxp
		fi
		if grep -q "`pwd`/ophxp" /etc/mtab ; then
			umount ophxp
		fi
		mount -o loop ophxp.iso ophxp/
		mkdir multicd-working/boot/ophcrack/
		cp -r ophxp/tables multicd-working/tables
		cp ophxp/boot/bzImage multicd-working/boot/ophcrack/bzImage
		cp ophxp/boot/ophcrack.cfg multicd-working/boot/ophcrack/ophcrack.cfg
		cp ophxp/boot/splash.png multicd-working/boot/ophcrack/splash.png
		cp ophxp/boot/rootfs.gz multicd-working/boot/ophcrack/rootfs.gz
		umount ophxp
		rmdir ophxp
	fi
	if [ -f ophvista.iso ] && [ ! -f ophxp.iso ];then
		echo "Copying OPH Crack Vista..."
		if [ ! -d ophvista ];then
			mkdir ophvista
		fi
		if grep -q "`pwd`/ophvista" /etc/mtab ; then
			umount ophvista
		fi
		mount -o loop ophvista.iso ophvista/
		mkdir multicd-working/boot/ophcrack/
		cp -r ophvista/tables multicd-working/tables
		cp ophvista/boot/bzImage multicd-working/boot/ophcrack/bzImage
		cp ophvista/boot/ophcrack.cfg multicd-working/boot/ophcrack/ophcrack.cfg
		cp ophvista/boot/splash.png multicd-working/boot/ophcrack/splash.png
		cp ophvista/boot/rootfs.gz multicd-working/boot/ophcrack/rootfs.gz
		umount ophvista
		rmdir ophvista
	fi
	if [ -f ophvista.iso ] && [ -f ophxp.iso ];then
		echo "Getting OPH Crack Vista tables..."
		if [ ! -d ophvista ];then
			mkdir ophvista
		fi
		if grep -q "`pwd`/ophvista" /etc/mtab ; then
			umount ophvista
		fi
		mount -o loop ophvista.iso ophvista/
		cp -r ophvista/tables multicd-working
		umount ophvista
		rmdir ophvista
	fi
elif [ $1 = writecfg ];then
	name=""
	if [ -f ophxp.iso ] && [ ! -f ophvista.iso ];then
		name="XP"
	fi
	if [ ! -f ophxp.iso ] && [ -f ophvista.iso ];then
		name="Vista"
	fi
	if [ -f ophxp.iso ] && [ -f ophvista.iso ];then
		name="XP/Vista"
	fi

	if [ -f ophxp.iso ] || [ -f ophvista.iso ];then
		echo "label ophcrack
		menu label --> ophcrack $name
		com32 vesamenu.c32
		append ophcrack.menu" >> multicd-working/boot/isolinux/isolinux.cfg

		sed 's/\/boot\//\/boot\/ophcrack\//g' multicd-working/boot/ophcrack/ophcrack.cfg > multicd-working/boot/isolinux/ophcrack.menu
		
		echo "
		label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg" >> multicd-working/boot/isolinux/ophcrack.menu

		rm multicd-working/boot/ophcrack/ophcrack.cfg
	fi
#elif [ $1 = category ];then
#	echo "tools"
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Dont use this plugin script on its own!"
fi
