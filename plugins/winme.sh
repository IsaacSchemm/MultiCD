#!/bin/sh
set -e
#Windows Me Setup plugin for multicd.sh
#version 5.7
#Copyright for this script (c) 2010 maybeway36
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
	if [ -f winme.iso ];then
		echo "Windows Me (Not open source - do not distribute)"
		touch tags/win9x
	fi
elif [ $1 = copy ];then
	if [ -f winme.iso ];then
		echo "Copying Windows Me..."
		if [ ! -d winme ];then
			mkdir winme
		fi
		if grep -q "`pwd`/winme" /etc/mtab ; then
			umount winme
		fi
		mount -o loop winme.iso winme/
		cp -r winme/win9x multicd-working/
		rm -r multicd-working/win9x/ols
		if [ -f tags/9xextras ];then
			cp -r winme/add-ons multicd-working/win9x/add-ons
			cp -r winme/tools multicd-working/win9x/tools
		fi
		umount winme;rmdir winme
		dd if=winme.iso bs=716800 skip=1 count=3 of=/tmp/dat
		dd if=/tmp/dat bs=1474560 count=1 of=multicd-working/boot/winme.img
		rm /tmp/dat
	fi
elif [ $1 = writecfg ];then
if [ -f winme.iso ];then
echo "label winme
menu label ^Windows Me Setup
kernel memdisk
initrd /boot/winme.img">>multicd-working/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
