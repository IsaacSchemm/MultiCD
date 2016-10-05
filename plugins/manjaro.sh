#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Manjaro plugin for multicd.sh
#version 20161005
#Copyright (c) 2016 Isaac Schemm
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
	echo "manjaro-*.iso manjaro.iso Manjaro_(*)"
elif [ $1 = scan ];then
	if [ -f manjaro.iso ];then
		echo "Manjaro"
	fi
elif [ $1 = copy ];then
	if [ -f manjaro.iso ];then
		echo "Copying Manjaro..."
		mcdmount manjaro
		if [ -d "${WORK}"/manjaro ];then
			echo "Cannot put more than one Manjaro on the same disc."
			exit 1
		fi
		mcdcp -r "${MNT}"/manjaro/manjaro "${WORK}"
		cat "${MNT}"/manjaro/isolinux/isolinux.cfg | sed -e 's/^ui.*//g' -e 's/isolinux\.msg/manjaro\.msg/g' -e "s/misolabel=[^ ]*/misolabel=$CDLABEL/g" > "${WORK}"/boot/isolinux/manjaro.cfg
		cat "${MNT}"/manjaro/isolinux/isolinux.msg | sed -e '/^hdt/d' -e '/^harddisk.*/d' -e '/^memtest/d' > "${WORK}"/boot/isolinux/manjaro.msg
		touch "${WORK}"/.miso
		umcdmount manjaro
	fi
elif [ $1 = writecfg ];then
	if [ -f manjaro.iso ];then
		echo "label Manjaro
			menu label >> ^Manjaro
			config /boot/isolinux/manjaro.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg

			echo "label back
			menu label Back to main menu
			config /boot/isolinux/isolinux.cfg /boot/isolinux/
			" >> "${WORK}"/boot/isolinux/manjaro.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
