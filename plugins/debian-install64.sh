#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Debian netinst (amd64) plugin for multicd.sh
#version 20121017
#Copyright (c) 2012 Isaac Schemm
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
	echo "debian-*-amd64-netinst.iso debian-install64.iso none"
elif [ $1 = scan ];then
	if [ -f debian-install64.iso ];then
		echo "Debian netinst (amd64)"
	fi
elif [ $1 = copy ];then
	if [ -f debian-install64.iso ];then
		echo "Copying Debian netinst (amd64)..."
		mcdmount debian-install64
		if [ ! -d "${WORK}"/.disk ];then
			cp -r "${MNT}"/debian-install64/.disk "${WORK}"
		else
			echo "Debian GNU/Linux - Unofficial Installation Media (MultiCD) $(date -u)" > "${WORK}"/.disk/info
		fi
		cp -r "${MNT}"/debian-install64/dists "${WORK}"
		cp -r "${MNT}"/debian-install64/install.amd "${WORK}"
		cp -r "${MNT}"/debian-install64/pool "${WORK}"
		umcdmount debian-install64
	fi
elif [ $1 = writecfg ];then
	if [ -f debian-install64.iso ];then
		DEBNAME="Debian GNU/Linux netinst (amd64)"
		if [ -f debian-install64.version ] && [ "$(cat debian-install64.version)" != "" ];then
			DEBNAME="$DEBNAME $(cat debian-install64.version)"
		fi

		DIR="install.amd"

		echo "menu begin --> ^$DEBNAME

		label install
			menu label ^Install
			menu default
			kernel /$DIR/vmlinuz
			append vga=normal initrd=/$DIR/initrd.gz -- quiet 
		label expert
			menu label ^Expert install
			kernel /$DIR/vmlinuz
			append priority=low vga=normal initrd=/$DIR/initrd.gz -- 
		label rescue
			menu label ^Rescue mode
			kernel /$DIR/vmlinuz
			append vga=normal initrd=/$DIR/initrd.gz rescue/enable=true -- quiet 
		label auto
			menu label ^Automated install
			kernel /$DIR/vmlinuz
			append auto=true priority=critical vga=normal initrd=/$DIR/initrd.gz -- quiet 
		label installgui
			menu label ^Graphical install
			kernel /$DIR/vmlinuz
			append video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- quiet 
		label expertgui
			menu label Graphical expert install
			kernel /$DIR/vmlinuz
			append priority=low video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- 
		label rescuegui
			menu label Graphical rescue mode
			kernel /$DIR/vmlinuz
			append video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz rescue/enable=true -- quiet  
		label autogui
			menu label Graphical automated install
			kernel /$DIR/vmlinuz
			append auto=true priority=critical video=vesa:ywrap,mtrr vga=788 initrd=/$DIR/gtk/initrd.gz -- quiet 
		label Back to main menu
			com32 menu.c32
			append isolinux.cfg

		menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
