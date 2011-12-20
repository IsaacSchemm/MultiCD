#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Vyatta plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm, PsynoKhi0
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
	if [ -f vyatta.iso ];then
		echo "Vyatta"
	fi
elif [ $1 = copy ];then
	if [ -f vyatta.iso ];then
		echo "Copying Vyatta..."
		mcdmount vyatta
		cp -r "${MNT}"/vyatta/live "${WORK}"/Vyatta #Pretty much everything except documentation/help
		umcdmount vyatta
	fi
elif [ $1 = writecfg ];then
if [ -f vyatta.iso ];then
cat >> "${WORK}"/boot/isolinux/isolinux.cfg << "EOF"
label vyatta-live
	menu label ^Vyatta - Live
	kernel /Vyatta/vmlinuz1
	append console=ttyS0 console=tty0 quiet initrd=/Vyatta/initrd1.img boot=live nopersistent noautologin nonetworking nouser hostname=vyatta live-media-path=/Vyatta
label vyatta-console
	menu label ^Vyatta - VGA Console
	kernel /Vyatta/vmlinuz1
	append quiet initrd=/Vyatta/initrd1.img boot=live nopersistent noautologin nonetworking nouser hostname=vyatta live-media-path=/Vyatta
label vyatta-serial
	menu label ^Vyatta - Serial Console
	kernel /Vyatta/vmlinuz1
	append console=ttyS0 quiet initrd=/Vyatta/initrd1.img boot=live nopersistent noautologin nonetworking nouser hostname=vyatta live-media-path=/Vyatta
label vyatta-debug
	menu label ^Vyatta - Debug
	kernel /Vyatta/vmlinuz1
	append console=ttyS0 console=tty0 debug verbose initrd=/Vyatta/initrd1.img boot=live nopersistent noautologin nonetworking nouser hostname=vyatta  live-media-path=/Vyatta
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
