#!/bin/sh
set -e
#TCNet plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 libertyernie
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
	if [ -f tcnet.iso ];then
		echo "TCNet"
	fi
elif [ $1 = copy ];then
	if [ -f tcnet.iso ];then
		echo "Copying TCNet..."
		if [ ! -d tcnet ];then
			mkdir tcnet
		fi
		if grep -q "`pwd`/tcnet" /etc/mtab ; then
			umount tcnet
		fi
		mount -o loop tcnet.iso tcnet/
		mkdir multicd-working/boot/tcnet
		cp tcnet/boot/bzImage multicd-working/boot/tcnet/bzImage #Linux kernel
		cp tcnet/boot/tcnet.gz multicd-working/boot/tcnet/tcnet.gz #TCNet image w/o apps - must load them from TCEs
		cp tcnet/boot/tcntfull.gz multicd-working/boot/tcnet/tcntfull.gz #TCNet image w/o apps - must have 192 MB RAM or more
		umount tcnet
		rmdir tcnet
	fi
elif [ $1 = writecfg ];then
#BEGIN TCNET ENTRY#
if [ -f tcnet.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label tcnet-hdc
	menu label ^Boot TCNet (128 MB RAM or less; CD drive must be IDE secondary master)
	kernel /boot/bzImage
	append initrd=/boot/tcnet.gz max_loop=255 norestore tce=hdc/tcnet
label tcnet-full
	menu label ^Boot TCNet (192 MB RAM or more; everything loaded to RAM)
	kernel /boot/bzImage
	append initrd=/boot/tcntfull.gz max_loop=255 norestore base
EOF
fi
#END TCNET ENTRY#
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
