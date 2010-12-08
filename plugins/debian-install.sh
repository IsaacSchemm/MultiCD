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
	#Note the 5 - only Lenny picked up
	echo "debian-5*.iso debian-install.iso"
elif [ $1 = scan ];then
	if [ -f debian-install.iso ];then
		echo "Debian installer"
	fi
elif [ $1 = copy ];then
	if [ -f debian-install.iso ];then
		echo "Copying Debian installer..."
		mcdmount debian-install
		cp -r $MNT/debian-install/.disk $WORK
		cp -r $MNT/debian-install/dists $WORK
		cp -r $MNT/debian-install/install.386 $WORK
		cp -r $MNT/debian-install/pool $WORK
		cp $MNT/debian-install/dedication.txt $WORK || true
		umcdmount debian-install
	fi
elif [ $1 = writecfg ];then
if [ -f debian-install.iso ];then
if [ -f debian-install.version ] && [ "$(cat debian-install.version)" != "" ];then
	VERSION=" (5$(cat debian-install.version))" #The 5 here is intentional
else
	VERSION=""
fi
echo "menu begin --> ^Debian GNU/Linux installer$VERSION

label install
	menu label ^Install
	menu default
	kernel /install.386/vmlinuz
	append vga=normal initrd=/install.386/initrd.gz -- quiet 
label expert
	menu label ^Expert install
	kernel /install.386/vmlinuz
	append priority=low vga=normal initrd=/install.386/initrd.gz -- 
label rescue
	menu label ^Rescue mode
	kernel /install.386/vmlinuz
	append vga=normal initrd=/install.386/initrd.gz rescue/enable=true -- quiet 
label auto
	menu label ^Automated install
	kernel /install.386/vmlinuz
	append auto=true priority=critical vga=normal initrd=/install.386/initrd.gz -- quiet 
label installgui
	menu label ^Graphical install
	kernel /install.386/vmlinuz
	append video=vesa:ywrap,mtrr vga=788 initrd=/install.386/gtk/initrd.gz -- quiet 
label expertgui
	menu label Graphical expert install
	kernel /install.386/vmlinuz
	append priority=low video=vesa:ywrap,mtrr vga=788 initrd=/install.386/gtk/initrd.gz -- 
label rescuegui
	menu label Graphical rescue mode
	kernel /install.386/vmlinuz
	append video=vesa:ywrap,mtrr vga=788 initrd=/install.386/gtk/initrd.gz rescue/enable=true -- quiet  
label autogui
	menu label Graphical automated install
	kernel /install.386/vmlinuz
	append auto=true priority=critical video=vesa:ywrap,mtrr vga=788 initrd=/install.386/gtk/initrd.gz -- quiet 
label Back to main menu
	com32 menu.c32
	append isolinux.cfg

menu end" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
