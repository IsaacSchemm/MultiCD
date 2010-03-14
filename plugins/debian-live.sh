#!/bin/sh
set -e
#Debian Live plugin for multicd.sh
#version 5.0
#Copyright (c) 2009 maybeway36
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
	if [ -f binary.iso ];then
		echo "Debian Live"
	fi
elif [ $1 = copy ];then
	if [ -f binary.iso ];then
		echo "Copying Debian Live..."
		if [ ! -d dlive ];then
			mkdir dlive
		fi
		if grep -q "`pwd`/dlive" /etc/mtab ; then
			umount dlive
		fi
		mount -o loop binary.iso dlive/
		cp dlive/isolinux/live.cfg /tmp/live.cfg #Copy the menu so we can read it later
		cp -r dlive/live multicd-working/ #Copy live folder - usually all that is needed
		if [ -d dlive/install ];then
			cp -r dlive/install multicd-working/ #Doesn't hurt to check
		fi
		umount dlive
		rmdir dlive
		rm multicd-working/live/memtest||true #We don't need this now; we'll get it later
	fi
elif [ $1 = writecfg ];then
if [ -f binary.iso ];then
cat /tmp/live.cfg|grep -v memtest|grep -v "Memory test">>multicd-working/boot/isolinux/isolinux.cfg
rm /tmp/live.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
