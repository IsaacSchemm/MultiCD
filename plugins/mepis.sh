#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Mepis Linux plugin for multicd.sh
#version 20120606
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
if [ $1 = scan ];then
	if [ -f mepis.iso ];then
		echo "Mepis"
	fi
elif [ $1 = copy ];then
	if [ -f mepis.iso ];then
		echo "Copying Mepis..."
		mcdmount mepis
		cp -r "${MNT}"/mepis/mepis "${WORK}"/ #Everything in Mepis but the kernel and initrd
		mkdir -p "${WORK}"/boot/mepis
		cp "${MNT}"/mepis/boot/vmlinuz "${WORK}"/boot/mepis/vmlinuz #Kernel
		cp "${MNT}"/mepis/boot/initrd.gz "${WORK}"/boot/mepis/initrd.gz #Initrd
		umcdmount mepis
	fi
elif [ $1 = writecfg ];then
if [ -f mepis.iso ];then
echo "label Mepis
menu label ^mepis
com32 menu.c32
append mepis.menu" >> "${WORK}"/boot/isolinux/isolinux.cfg
echo "DEFAULT menu.c32
TIMEOUT 0
PROMPT 0
menu title Mepis Options

label  Mepis-Default
menu label ^Mepis-Default
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init quiet nosplash vga=791 aufs  initrd=/boot/mepis/initrd.gz

label  Mepis-Lite-noNet
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init quiet nosplash vga=791 aufs mean lean initrd=/boot/mepis/initrd.gz

label  Mepis-Vesa
menu label Mepis-Vesa (display problem or virtualbox)
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init vga=normal quiet nosplash drvr=vesa aufs lean initrd=/boot/mepis/initrd.gz

label  Mepis-UltraLite-Vesa
menu label Mepis-UltraLite-Vesa (Fast boot)
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init vga=normal quiet nosplash drvr=vesa aufs lean Xtralean initrd=/boot/mepis/initrd.gz

label  Mepis-Failsafe
menu label Mepis-Failsafe (minimum options, small display)
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init quiet nosplash vga=normal nosound noapic noscsi nodma noapm nousb nopcmcia nofirewire noagp nomce nodhcp nodbus nocpufreq nobluetooth drvr=fbdev aufs res=800x600v initrd=/boot/mepis/initrd.gz

label  Mepis-60Hz
menu label Mepis-60Hz (force monitor to 58-62 Hz)
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init vga=791 quiet nosplash vsync=58-62 aufs initrd=/boot/mepis/initrd.gz

label  Mepis-75Hz
menu label Mepis-75Hz (force monitor to 73-77 Hz)
kernel /boot/mepis/vmlinuz
append SELINUX_INIT=NO init=/etc/init vga=791 quiet nosplash vsync=73-77 aufs initrd=/boot/mepis/initrd.gz

label back
menu label ^Back to main menu
com32 menu.c32
append isolinux.cfg
" > "${WORK}"/boot/isolinux/mepis.menu
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
