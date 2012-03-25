#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Kapersky Rescue Disk 10 plugin for multicd.sh
#version 20120325
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
	echo "kav_rescue_*.iso kav.iso none"
elif [ $1 = scan ];then
	if [ -f kav.iso ];then
		echo "Kapersky Rescue Disk"
	fi
elif [ $1 = copy ];then
	if [ -f kav.iso ];then
		echo "Copying Kapersky Rescue Disk..."
		mcdmount kav
		mkdir "${WORK}"/boot/rescue
		# Kernel, initrd
		cp -r "${MNT}"/kav/boot/rescue "${WORK}"/boot/rescue/rescue
		cp -r "${MNT}"/kav/boot/rescue.igz "${WORK}"/boot/rescue/rescue.igz
		# Filesystem
		cp -r "${MNT}"/kav/rescue "${WORK}"
		umcdmount kav
	fi
elif [ $1 = writecfg ];then
	if [ -f kav.iso ];then
		#note: $CDLABEL is set [exported] in multicd.sh
		if [ -f "${TAGS}"/lang ];then
			LANGCODE=$(cat "${TAGS}"/lang)
		else
			LANGCODE=en
		fi
		echo "menu begin --> ^Kapersky Rescue Disk

		label kav
		menu label ^Kaspersky Rescue Disk - Graphic Mode
		kernel /boot/rescue/rescue
		initrd /boot/rescue/rescue.igz
		append root=live:CDLABEL=$CDLABEL rootfstype=auto vga=791 init=/init initrd=rescue.igz kav_lang=$LANGCODE udev liveimg splash quiet doscsi nomodeset

		label kav-rescue-text
		menu label ^Kaspersky Rescue Disk - Text Mode
		kernel /boot/rescue/rescue
		initrd /boot/rescue/rescue.igz
		append root=live:CDLABEL=$CDLABEL rootfstype=auto vga=791 init=/init initrd=rescue.igz kav_lang=$LANGCODE udev liveimg quiet nox kavshell noresume doscsi nomodeset

		label hardware-info
		menu label (Kapersky) Hardware Info
		kernel /boot/rescue/rescue
		initrd /boot/rescue/rescue.igz
		append root=live:CDLABEL=$CDLABEL rootfstype=auto vga=791 init=/init initrd=rescue.igz kav_lang=$LANGCODE udev liveimg quiet softlevel=boot nox hwinfo noresume doscsi nomodeset

		label back
		menu label ^Back to main menu
		com32 menu.c32
		append isolinux.cfg

		menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
