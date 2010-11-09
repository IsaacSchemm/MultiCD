#!/bin/sh
set -e
. ./functions.sh
#Ubuntu (64-bit) plugin for multicd.sh
#version 6.1
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
if [ $1 = links ];then
	echo "ubuntu-*-desktop-amd64.iso ubuntu_64_bit.iso"
elif [ $1 = scan ];then
	if [ -f ubuntu_64_bit.iso ];then
		echo "Ubuntu (64-bit)"
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu_64_bit.iso ];then
		echo "Copying Ubuntu (64-bit)..."
		ubuntucommon ubuntu_64_bit
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu_64_bit.iso ];then
if [ -f ubuntu_64_bit.version ] && [ "$(cat ubuntu_64_bit.version)" != "" ];then
	UBUVER=" $(cat ubuntu_64_bit.version)"
else
	UBUVER=""
fi
echo "label ubuntu_64_bit
menu label --> Ubuntu ($UBUVER 64-bit)
com32 menu.c32
append /boot/ubuntu_64_bit/ubuntu_64_bit.cfg
" >> multicd-working/boot/isolinux/isolinux.cfg
echo "
label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
" >> multicd-working/boot/ubuntu_64_bit/ubuntu_64_bit.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
