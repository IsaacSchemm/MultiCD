#!/bin/sh
set -e
#NetbootCD 3.x/4.x plugin for multicd.sh
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
	if [ -f netbootcd.iso ];then
		echo "NetbootCD"
	fi
elif [ $1 = copy ];then
	if [ -f netbootcd.iso ];then
		echo "Copying NetbootCD..."
		if [ ! -d netbootcd ];then
			mkdir netbootcd
		fi
		if grep -q "`pwd`/netbootcd" /etc/mtab ; then
			umount netbootcd
		fi
		mount -o loop netbootcd.iso netbootcd/
		mkdir -p multicd-working/boot/nbcd
		cp netbootcd/isolinux/kexec.bzI multicd-working/boot/nbcd/kexec.bzI
		cp netbootcd/isolinux/* multicd-working/boot/nbcd/
		sleep 1;umount netbootcd;rmdir netbootcd
	fi
elif [ $1 = writecfg ];then
#BEGIN NETBOOTCD ENTRY#
if [ -f netbootcd.iso ];then
if [ -f multicd-working/boot/nbcd/nbinit4.lz ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL netbootcd
MENU LABEL ^NetbootCD
KERNEL /boot/nbcd/kexec.bzI
initrd /boot/nbcd/nbinit4.lz
APPEND quiet
EOF
else
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
LABEL netbootcd
MENU LABEL ^NetbootCD
KERNEL /boot/nbcd/kexec.bzI
initrd /boot/nbcd/nbinit3.gz
APPEND quiet
EOF
fi
fi
#END NETBOOTCD ENTRY#
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
