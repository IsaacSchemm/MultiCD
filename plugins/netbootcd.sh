#!/bin/sh
set -e
. $MCDDIR/functions.sh
#NetbootCD 3.x/4.x plugin for multicd.sh
#version 6.6
#Copyright (c) 2011 Isaac Schemm
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
if [ $1 = links ];then
	echo "NetbootCD-*.iso netbootcd.iso none"
elif [ $1 = scan ];then
	if [ -f netbootcd.iso ];then
		echo "NetbootCD"
	fi
elif [ $1 = copy ];then
	if [ -f netbootcd.iso ];then
		echo "Copying NetbootCD..."
		mcdmount netbootcd
		mkdir -p ${WORK}/boot/nbcd
		cp ${MNT}/netbootcd/isolinux/kexec.bzI ${WORK}/boot/nbcd/kexec.bzI
		cp ${MNT}/netbootcd/isolinux/nbinit*.gz ${WORK}/boot/nbcd/nbinit.gz
		sleep 1;umcdmount netbootcd
	fi
elif [ $1 = writecfg ];then
	if [ -f netbootcd.iso ];then
		if [ -f netbootcd.version ] && [ "$(cat netbootcd.version)" != "" ];then
			NBCDVER=" $(cat netbootcd.version)"
		else
			NBCDVER=""
		fi
		echo "LABEL netbootcd
		MENU LABEL ^NetbootCD$NBCDVER
		KERNEL /boot/nbcd/kexec.bzI
		initrd /boot/nbcd/nbinit.gz
		APPEND quiet
		" >> ${WORK}/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
