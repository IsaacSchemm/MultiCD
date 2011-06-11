#!/bin/sh
set -e
. $MCDDIR/functions.sh
#Windows 7 Recovery Disc (from RAM) plugin for multicd.sh
#version 6.6
#Copyright for this script (c) 2011 Isaac Schemm
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
	if [ -f win7recovery-ram.iso ];then
		echo "Windows 7 Recovery Disc - from RAM (Not open source)"
	fi
elif [ $1 = copy ];then
	if [ -f win7recovery-ram.iso ];then
		echo "Copying Windows 7 Recovery Disc..."
		cp win7recovery-ram.iso $WORK/
	fi
elif [ $1 = writecfg ];then
if [ -f win7recovery-ram.iso ];then
	if which isoinfo &> /dev/null;then
		if isoinfo -d -i win7recovery-ram.iso|grep '32_BIT';then
			TYPE=" 32-bit"
		else
			TYPE=" 64-bit"
		fi
	else
		TYPE=""
	fi
	echo "label win7recovery-ram
	menu label Windows ^7 Recovery Disc (load ISO to RAM)
	kernel memdisk
	initrd /win7recovery-ram.iso
	append iso">>$WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
