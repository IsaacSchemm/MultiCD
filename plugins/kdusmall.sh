#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#KDu-Small plugin for multicd.sh
#version 6.9
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
	echo "KDu-Small-*.iso kdusmall.iso none"
elif [ $1 = scan ];then
	if [ -f kdusmall.iso ];then
		echo "KDu-Small"
	fi
elif [ $1 = copy ];then
	if [ -f kdusmall.iso ];then
		echo "Copying KDu-Small..."
		ubuntucommon kdusmall
	fi
elif [ $1 = writecfg ];then
	 if [ -f kdusmall.iso ];then
		if [ -f kdusmall.version ];then
			KDUVER=" $(cat kdusmall.version)"
			if [ "$KDUVER" == "" ];then
				KDUVER=""
			fi
		else
			KDUVER=""
		fi
		echo "label kdusmall
		menu label --> KDu-Small$KDUVER Menu
		com32 menu.c32
		append /boot/kdusmall/kdusmall.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
