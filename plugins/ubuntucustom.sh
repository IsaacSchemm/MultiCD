#!/bin/sh
set -e
. ./functions.sh
#Ubuntu plugin for multicd.sh
#version 6.2
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
if [ $1 = scan ];then
	if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do
		echo $(echo $i|sed -e 's/\.ubuntu\.iso//g')
		echo > $TAGS/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
	done;fi
elif [ $1 = copy ];then
	if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do
		echo "Copying $i..."
		ubuntucommon $(echo $i|sed -e 's/\.iso//g')
	done;fi
elif [ $1 = writecfg ];then
if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do
BASENAME=$(echo $i|sed -e 's/\.iso//g')
if [ -f $TAGS/$BASENAME.name ] && [ "$(cat $TAGS/$BASENAME.name)" != "" ];then
	UBUNAME="$(cat $TAGS/$BASENAME.name)"
else
	UBUNAME=$(echo $i|sed -e 's/\.ubuntu\.iso//g')
fi
echo "label ubuntu
menu label --> $UBUNAME Menu
com32 menu.c32
append /boot/$BASENAME/$BASENAME.cfg
" >> multicd-working/boot/isolinux/isolinux.cfg
echo "label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
" >> multicd-working/boot/$BASENAME/$BASENAME.cfg
done;fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
