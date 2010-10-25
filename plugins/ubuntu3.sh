#!/bin/sh
set -e
#Ubuntu Custom #3 plugin for multicd.sh
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
	if [ -f ubuntu3.iso ];then
		echo "Ubuntu custom #3 (for using multiple versions on one disc - 9.10 or newer)"
		echo > $TAGS/ubuntu3.needsname #Comment out this line and multicd.sh won't ask for a custom name for this ISO
	fi
elif [ $1 = copy ];then
	if [ -f ubuntu3.iso ];then
		echo "Copying Ubuntu Custom #3..."
		ubuntu-common ubuntu3
	fi
elif [ $1 = writecfg ];then
if [ -f ubuntu3.iso ];then
if [ -f $TAGS/ubuntu3.name ] && [ "$(cat $TAGS/ubuntu3.name)" != "" ];then
	UBUNAME=$(cat $TAGS/ubuntu3.name)
else
	UBUNAME="Ubuntu #3"
fi
echo "label ubuntu3
menu label --> $UBUNAME Menu
com32 menu.c32
append /boot/ubuntu3/ubuntu3.cfg
" >> multicd-working/boot/isolinux/isolinux.cfg
echo "label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
" >> multicd-working/boot/ubuntu3/ubuntu3.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
