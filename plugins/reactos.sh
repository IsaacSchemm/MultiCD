#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#ReactOS plugin for multicd.sh
#version 20190608
#Copyright (c) 2019 Isaac Schemm
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
	echo "ReactOS-*.iso reactos.iso ReactOS"
elif [ $1 = scan ];then
	if [ -f reactos.iso ];then
		echo "ReactOS"
	fi
elif [ $1 = copy ];then
	if [ -f reactos.iso ];then
		echo "Copying ReactOS..."
		mcdmount reactos
		mcdcp -r -n "${MNT}"/reactos/loader "${WORK}"/
		if [ -d "${MNT}"/reactos/Profiles ];then
			mcdcp -r -n "${MNT}"/reactos/Profiles "${WORK}"/
		fi
		mcdcp -r -n "${MNT}"/reactos/reactos "${WORK}"/
		cp -n "${MNT}"/reactos/freeldr.ini "${WORK}"/
		umcdmount reactos
	fi
elif [ $1 = writecfg ];then
	if [ -f reactos.iso ];then
		echo "label reactos
		menu label ^ReactOS $(getVersion reactos)
		kernel /loader/isoboot.bin" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
fi
