#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Avira Rescue CD plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 Isaac Schemm
#modified quick and dirty by T.Ma.X. N060d9 to work with avira Rescue CD
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
	if [ -f avira.iso ];then
		echo "Avira Rescue CD"
	fi
elif [ $1 = copy ];then
	if [ -f avira.iso ];then
		echo "Copying Avira Rescue CD..."
		mcdmount avira
		cp -r "${MNT}"/avira/* "${WORK}"/
				
		mv "${WORK}"/vmlinuz "${WORK}"/boot/isolinux/aviravmlinuz #Kernel
		mv "${WORK}"/initrd.gz "${WORK}"/boot/isolinux/avirainitrd.gz #Initial ramdisk. See above.
		mv "${WORK}"/welcome.msg "${WORK}"/licenses/welcome.msg
		mv "${WORK}"/license.txt "${WORK}"/licenses/license.txt
		mv "${WORK}"/licenses "${WORK}"/aviralicenses
		rm "${WORK}"/boot.cat "${WORK}"/isolinux.bin "${WORK}"/isolinux.cfg 		
		umcdmount avira
	fi
elif [ $1 = writecfg ];then
if [ -f avira.iso ];then
VERSION=$(sed -n '/AVIRA/p' "${WORK}"/aviralicenses/welcome.msg | awk '{print substr($5,1,7)}') #extract Avira Version from file
echo "menu begin --> Avira Rescue CD $VERSION

label 1
 menu label Boot AntiVir Rescue System (default)
    kernel /boot/isolinux/aviravmlinuz
    append nofb initrd=/boot/isolinux/avirainitrd.gz ramdisk_size=108178 root=/dev/ram0 rw  console=/dev/vc/4

label 2
 menu label Advanced Users Antivir Rescue System VGA=ask
    kernel /boot/isolinux/aviravmlinuz
    append vga=ask initrd=/boot/isolinux/avirainitrd.gz ramdisk_size=108178 root=/dev/ram0 rw  console=/dev/vc/4

label debug
 menu label debug
    kernel /boot/isolinux/aviravmlinuz
    append vga=ask initrd=/boot/isolinux/avirainitrd.gz ramdisk_size=108178 root=/dev/ram0 rw

label nogui
 menu label NoGUI
    kernel /boot/isolinux/aviravmlinuz
    append nofb initrd=/boot/ixolinux/initrd.gz ramdisk_size=108178 root=/dev/ram0 rw  console=/dev/vc/4 av-nogui

label back
   menu label Back to main menu...
   com32 menu.c32

MENU END
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
