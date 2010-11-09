#!/bin/sh
set -e
. ./functions.sh
#Clonezilla plugin for multicd.sh
#version 6.0
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
if [ $1 = scan ];then
	if [ -f clonezilla.iso ];then
		echo "Clonezilla"
	fi
elif [ $1 = copy ];then
	if [ -f clonezilla.iso ];then
		echo "Copying Clonezilla..."
		mcdmount clonezilla
		cp $MNT/clonezilla/isolinux/ocswp.png $WORK/boot/isolinux/ocswp.png #Boot menu logo
		cp -R $MNT/clonezilla/live $WORK/boot/clonezilla #Another Debian Live-based ISO
		sed '/MENU BEGIN Memtest/,/MENU END/d' $MNT/clonezilla/isolinux/isolinux.cfg > $WORK/boot/isolinux/clonezil.cfg #Remove FreeDOS and Memtest
		umcdmount clonezilla
		rm $WORK/boot/clonezilla/memtest
	fi
elif [ $1 = writecfg ];then
if [ -f clonezilla.iso ];then
echo "label clonezilla
menu label --> ^Clonezilla
com32 vesamenu.c32
append clonezil.cfg
" >> $WORK/boot/isolinux/isolinux.cfg
#GNU sed syntax
sed -i -e 's/\/live\//\/boot\/clonezilla\//g' multicd-working/boot/isolinux/clonezil.cfg #Change directory to /boot/clonezilla
sed -i -e 's/append initrd=/append live-media-path=\/boot\/clonezilla initrd=/g' multicd-working/boot/isolinux/clonezil.cfg #Tell the kernel we moved it
echo "label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg
" >> $WORK/boot/isolinux/clonezil.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
