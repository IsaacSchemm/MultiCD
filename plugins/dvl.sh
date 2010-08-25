#!/bin/sh
set -e
#Damn Vulnerable Linux plugin for multicd.sh
#version 5.7
#Copyright (c) 2010 maybeway36
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
	if [ -f dvl.iso ];then
		echo "Damn Vulnerable Linux"
	fi
elif [ $1 = copy ];then
	if [ -f dvl.iso ];then
		echo "Copying Damn Vulnerable Linux..."
		if [ ! -d dvl ];then
			mkdir dvl
		fi
		if grep -q "`pwd`/dvl" /etc/mtab ; then
			umount dvl
		fi
		mount -o loop dvl.iso dvl/
		cp -r dvl/BT multicd-working/
		mkdir multicd-working/boot/dvl
		cp dvl/boot/vmlinuz multicd-working/boot/dvl/vmlinuz
		cp dvl/boot/initrd.gz multicd-working/boot/dvl/initrd.gz
		umount dvl;rmdir dvl
	fi
elif [ $1 = writecfg ];then
if [ -f dvl.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label dvl
menu label Damn ^Vulnerable Linux
kernel /boot/dvl/vmlinuz
initrd /boot/dvl/initrd.gz
append vga=0x317 max_loop=255 init=linuxrc load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=4444 root=/dev/ram0 rw

label dvlsafe
menu label Damn Vulnerable Linux (dvlsafe)
kernel /boot/dvl/vmlinuz
initrd /boot/dvl/initrd.gz
append vga=769 max_loop=255 init=linuxrc load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=4444 root=/dev/ram0 rw
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
