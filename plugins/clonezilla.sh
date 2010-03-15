#!/bin/sh
set -e
#Clonezilla plugin for multicd.sh
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
	if [ -f clonezilla.iso ];then
		echo "Clonezilla"
	fi
elif [ $1 = copy ];then
	if [ -f clonezilla.iso ];then
		echo "Copying Clonezilla..."
		if [ ! -d clonezilla ];then
			mkdir clonezilla
		fi
		if grep -q "`pwd`/clonezilla" /etc/mtab ; then
			umount clonezilla
		fi
		mount -o loop clonezilla.iso clonezilla/
		cp clonezilla/isolinux/ocswp.png multicd-working/boot/isolinux/ocswp.png #Boot menu logo
		cp -R clonezilla/live multicd-working/boot/clonezilla #Another Debian Live-based ISO
		sed '/MENU BEGIN Memtest/,/MENU END/d' clonezilla/isolinux/isolinux.cfg > multicd-working/boot/isolinux/clonezil.cfg #Remove FreeDOS and Memtest
		umount clonezilla
		rmdir clonezilla
		rm multicd-working/boot/clonezilla/memtest
	fi
elif [ $1 = writecfg ];then
if [ -f clonezilla.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label clonezilla
menu label ^Clonezilla
com32 vesamenu.c32
append clonezil.cfg
EOF
perl -pi -e 's/\/live\/vmlinuz/\/boot\/clonezilla\/vmlinuz/g' multicd-working/boot/isolinux/clonezil.cfg
perl -pi -e 's/\/live\/initrd/\/boot\/clonezilla\/initrd/g' multicd-working/boot/isolinux/clonezil.cfg
perl -pi -e 's/append initrd=/append live-media-path=\/boot\/clonezilla initrd=/g' multicd-working/boot/isolinux/clonezil.cfg
cat >> multicd-working/boot/isolinux/clonezil.cfg << "EOF"

label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
