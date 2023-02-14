#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#SystemRescueCd plugin for multicd.sh
#version 20190303
#Copyright (c) 2010-2019 Isaac Schemm and Pascal De Vuyst
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
	echo "systemrescuecd-6*.iso sysresccd.iso none"
elif [ $1 = scan ];then
	if [ -f sysresccd.iso ];then
		echo "SystemRescueCd"
	fi
elif [ $1 = copy ];then
	if [ -f sysresccd.iso ];then
		echo "Copying SystemRescueCd..."
		mcdmount sysresccd
		mkdir "${WORK}"/sysresccd
		mcdcp -r "${MNT}"/sysresccd/sysresccd/* "${WORK}"/sysresccd
		for i in "${WORK}"/sysresccd/boot/syslinux/*.cfg;do
			sed -i -e "s/archisolabel=/archisolabel=$CDLABEL originalwas=/g" "$i"
		done
		umcdmount sysresccd
	fi
elif [ $1 = writecfg ];then
if [ -f sysresccd.iso ];then
echo "label sysresccd
menu label --> ^SystemRescueCd
config /sysresccd/boot/syslinux/sysresccd.cfg /sysresccd
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
