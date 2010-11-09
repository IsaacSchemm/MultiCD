#!/bin/sh
set -e
. ./functions.sh
#Tiny Core Linux #2 plugin for multicd.sh
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
if [ $1 = scan ];then
	if [ -f tinycore2.iso ];then
		echo "Tiny Core Linux"
		touch $TAGS/tinycore2.needsname #Comment out this line and multicd.sh won't ask for a custom name for this ISO
	fi
elif [ $1 = copy ];then
	if [ -f tinycore2.iso ];then
		echo "Copying Tiny Core..."
		tinycorecommon tinycore2
	fi
elif [ $1 = writecfg ];then
#BEGIN TINY CORE 2 ENTRY#
if [ -f tinycore2.iso ];then
	if [ -f $TAGS/tinycore2.name ] && [ "$(cat $TAGS/tinycore2.name)" != "" ];then
		TCNAME=$(cat $TAGS/tinycore2.name)
	elif [ -f tinycore2.defaultname ] && [ "$(cat tinycore2.defaultname)" != "" ];then
		TCNAME=$(cat tinycore2.defaultname)
	else
		TCNAME="Tiny Core Linux #2"
	fi
	if [ -f tinycore2.version ] && [ "$(cat tinycore2.version)" != "" ];then
		TCNAME="$TCNAME $(cat tinycore2.version)"
	fi
	for i in $(ls $WORK/boot/tinycore2|grep '\.gz');do
		echo "label tinycore2-$i
		menu label ^$TCNAME
		kernel /boot/tinycore2/bzImage
		append quiet
		initrd /boot/tinycore2/$(basename $i)">>multicd-working/boot/isolinux/isolinux.cfg
	done
fi
#END TINY CORE 2 ENTRY#
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
