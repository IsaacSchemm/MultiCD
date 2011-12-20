#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Windows 98 SE Setup plugin for multicd.sh
#version 6.9
#Copyright for this script (c) 2010 Isaac Schemm
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
	if [ -f win98se.iso ];then
		echo "Windows 98 SE (Not open source - do not distribute the final ISO)"
		touch tags/win9x #This tells the interactive option of the script to ask about the add-ons & tools folders
	fi
elif [ $1 = copy ];then
	if [ -f win98se.iso ];then
		echo "Copying Windows 98 SE..."
		mcdmount win98se
		cp -r "${MNT}"/win98se/win98 "${WORK}"/
		rm -r "${WORK}"/win98/ols
		if [ -f "${TAGS}"/9xextras ];then
			cp -r "${MNT}"/win98se/add-ons "${WORK}"/win98/add-ons
			cp -r "${MNT}"/win98se/tools "${WORK}"/win98/tools
		fi
		umcdmount win98se
		dd if=win98se.iso bs=43008 skip=1 count=35 of=/tmp/dat
		dd if=/tmp/dat bs=1474560 count=1 of="${WORK}"/boot/win98se.img
		rm /tmp/dat
		if which mdel > /dev/null;then
			mdel -i "${WORK}"/boot/win98se.img ::JO.SYS #Disable HD/CD boot prompt - not needed, but a nice idea
		fi
	fi
elif [ $1 = writecfg ];then
if [ -f win98se.iso ];then
echo "label win98se
menu label ^Windows 98 Second Edition Setup
kernel memdisk
initrd /boot/win98se.img">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
