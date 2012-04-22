#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Generic ISO emulation plugin for multicd.sh
#version 20120421
#Copyright (c) 2012 Isaac Schemm
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

genericExists () {
	if [ "*.generic.iso" != "$(echo *.generic.iso)" ];then
		echo true
	else
		echo false
	fi
}

if [ $1 = scan ];then
	if $(genericExists);then for i in *.generic.iso;do
		echo "Generic: $i"
	done;fi
elif [ $1 = copy ];then
	if $(genericExists);then for i in *.generic.iso;do
		echo "Copying $i..."
		mkdir -p "${WORK}"/generic
		cp "$i" "${WORK}"/generic
	done;fi
elif [ $1 = writecfg ];then
	COUNTER=0
	if $(genericExists);then for i in *.generic.iso;do
		BASENAME=$(echo $i|sed -e 's/\.generic\.iso//g')
		echo "label generic-$COUNTER
		menu label ^$BASENAME
		kernel memdisk
		append iso
		initrd /generic/$i
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
		COUNTER=$(($COUNTER+1))
	done;fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
