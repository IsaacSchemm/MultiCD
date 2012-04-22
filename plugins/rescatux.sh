#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Rescatux plugin for multicd.sh
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
if [ $1 = links ];then
	echo "rescatux_*.iso rescatux.iso none"
elif [ $1 = scan ];then
	if [ -f rescatux.iso ];then
		echo "Rescatux"
	fi
elif [ $1 = copy ];then
	if [ -f rescatux.iso ];then
		RESCATUX_NEW=rescatux-new
		echo "Copying Rescatux..."
		mcdmount rescatux
		if [ -h $RESCATUX_NEW.iso ];then rm $RESCATUX_NEW.iso;fi
		ln -s "${MNT}"/rescatux/boot/boot-isos/rescatux*.iso $RESCATUX_NEW.iso
		mcdmount $RESCATUX_NEW
		cp "${MNT}"/$RESCATUX_NEW/isolinux/live.cfg "${WORK}"/boot/isolinux/rescatux.cfg
		cp -r "${MNT}"/$RESCATUX_NEW/live "${WORK}"/rescatux
		umcdmount $RESCATUX_NEW
		rm $RESCATUX_NEW.iso
		umcdmount rescatux
	fi
elif [ $1 = writecfg ];then
	if [ -f rescatux.iso ];then
		echo "label rescatux
		menu label >> ^Rescatux
		com32 menu.c32
		append rescatux.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
		sed -i -e 's^/live/^/rescatux/^g' "${WORK}"/boot/isolinux/rescatux.cfg
		sed -i -e 's^boot=live^boot=live live-media-path=/rescatux^g' "${WORK}"/boot/isolinux/rescatux.cfg
		echo "label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> "${WORK}"/boot/isolinux/rescatux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
