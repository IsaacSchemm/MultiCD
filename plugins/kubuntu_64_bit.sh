#!/bin/sh
set -e
. ./functions.sh
#Kubuntu (64-bit) plugin for multicd.sh
#version 6.1
#Copyright (c) 2010 libertyernie
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
	echo "kubuntu-*-desktop-amd64.iso kubuntu_64_bit.iso"
elif [ $1 = scan ];then
	if [ -f kubuntu_64_bit.iso ];then
		echo "Kubuntu (64-bit)"
	fi
elif [ $1 = copy ];then
	if [ -f kubuntu_64_bit.iso ];then
		echo "Copying Kubuntu (64-bit)..."
		ubuntucommon kubuntu_64_bit
	fi
elif [ $1 = writecfg ];then
if [ -f kubuntu_64_bit.iso ];then
if [ -f kubuntu_64_bit.version ] && [ "$(cat kubuntu_64_bit.version)" != "" ];then
	KUBUVER=" $(cat kubuntu_64_bit.version)"
else
	KUBUVER=""
fi
echo "label kubuntu_64_bit
menu label --> Kubuntu ($KUBUVER 64-bit)
com32 menu.c32
append /boot/kubuntu_64_bit/kubuntu_64_bit.cfg
" >> multicd-working/boot/isolinux/isolinux.cfg
echo "
label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
" >> multicd-working/boot/kubuntu_64_bit/kubuntu_64_bit.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
