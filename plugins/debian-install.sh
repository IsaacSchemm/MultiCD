#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Debian netinst (i386) plugin for multicd.sh
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
	echo "debian-*-i386-netinst.iso debian-install.iso none"
elif [ $1 = scan ];then
	if [ -f debian-install.iso ];then
		echo "Debian netinst"
	fi
elif [ $1 = copy ];then
	if [ -f debian-install.iso ];then
		echo "Copying Debian netinst..."
		mcdmount debian-install
		if [ ! -d "${WORK}"/.disk ];then
			cp -r "${MNT}"/debian-install/.disk "${WORK}"
		else
			echo "Debian GNU/Linux (MultiCD) $(date -u)" > "${WORK}"/.disk/info
		fi
		cp -r "${MNT}"/debian-install/dists "${WORK}"
		cp -r "${MNT}"/debian-install/install.386 "${WORK}"
		cp -r "${MNT}"/debian-install/pool "${WORK}"
		umcdmount debian-install
	fi
elif [ $1 = writecfg ];then
	if [ -f debian-install.iso ];then
		DEBNAME="Debian GNU/Linux netinst (i386)"
		if [ -f debian-install.version ] && [ "$(cat debian-install.version)" != "" ];then
			DEBNAME="$DEBNAME $(cat debian-install.version)"
		fi

		DIR="install.386"

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
