#!/bin/sh
set -e
. ./functions.sh
#Debian Live plugin for multicd.sh
#version 6.0
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
	if [ -f binary.iso ];then
		echo "Debian Live"
	fi
elif [ $1 = copy ];then
	if [ -f binary.iso ];then
		echo "Copying Debian Live..."
		mcdmount binary
		cp $MNT/binary/isolinux/live.cfg $WORK/boot/isolinux/dlive.cfg
		cp -r $MNT/binary/live $WORK/ #Copy live folder - usually all that is needed
		if [ -d dlive/install ];then
			cp -r $MNT/binary/install $WORK/ #Doesn't hurt to check
		fi
		umcdmount binary
		rm $WORK/live/memtest||true
	fi
elif [ $1 = writecfg ];then
if [ -f binary.iso ];then
echo "label debian-live
menu label >> ^Debian Live
com32 menu.c32
append dlive.cfg" >> $WORK/boot/isolinux/dlive.cfg
sed -i '/memtest/d' '/Memory test/d' $WORK/boot/isolinux/dlive.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
