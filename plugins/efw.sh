#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Endian Firewall Community Edition plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 PsynoKhi0, Isaac Schemm
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
	if [ -f efw.iso ];then
		echo "Endian Firewall"
	fi
elif [ $1 = copy ];then
	if [ -f efw.iso ];then
		echo "Copying Endian Firewall..."
		mcdmount efw
		mkdir -p "${WORK}"/boot/endian/
		cp "${MNT}"/efw/boot/isolinux/vmlinuz "${WORK}"/boot/endian/ #Kernel
		cp "${MNT}"/efw/boot/isolinux/instroot.gz "${WORK}"/boot/endian/ #Filesystem
		cp -r "${MNT}"/efw/data "${WORK}"/ #data and rpms folders are located
		cp -r "${MNT}"/efw/rpms "${WORK}"/ #at the root of the original CD
		cp "${MNT}"/efw/LICENSE.txt "${WORK}"/EFW-LICENSE.txt #License terms
		cp "${MNT}"/efw/README.txt "${WORK}"/EFW-README.txt
		umcdmount efw
	fi
elif [ $1 = writecfg ];then
if [ -f efw.iso ];then
echo "menu begin ^Endian Firewall

label endianfirewall
	menu label ^Endian Firewall - Default
	kernel /boot/endian/vmlinuz 
	append initrd=/boot/endian/instroot.gz root=/dev/ram0 rw
label endianfirewall_unattended 
	menu label ^Endian Firewall - Unattended
	kernel /boot/endian/vmlinuz
	append initrd=/boot/endian/instroot.gz root=/dev/ram0 rw unattended
label endianfirewall_nopcmcia 
	menu label ^Endian Firewall - No PCMCIA
	kernel /boot/endian/vmlinuz
	append ide=nodma initrd=/boot/endian/instroot.gz root=/dev/ram0 rw nopcmcia
label endianfirewall_nousb
	menu label ^Endian Firewall - No USB
	kernel /boot/endian/vmlinuz
	append ide=nodma initrd=/boot/endian/instroot.gz root=/dev/ram0 rw nousb
label endianfirewall_nousborpcmcia
	menu label ^Endian Firewall - No USB nor PCMCIA
	kernel /boot/endian/vmlinuz
	append ide=nodma initrd=/boot/endian/instroot.gz root=/dev/ram0 rw nousb nopcmcia
label back
	menu label ^Back to main menu
	com32 menu.c32
	append isolinux.cfg
menu end
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
