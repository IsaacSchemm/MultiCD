#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Knoppix plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm
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
	echo "KNOPPIX_V*.iso knoppix.iso none"
elif [ $1 = scan ];then
	if [ -f knoppix.iso ];then
		echo "Knoppix"
	fi
elif [ $1 = copy ];then
	if [ -f knoppix.iso ];then
		echo "Copying Knoppix..."
		mcdmount knoppix
		mkdir "${WORK}"/KNOPPIX6
		#Compressed filesystem and docs. We have to call it KNOPPIX6 because DSL uses KNOPPIX, and if we change that DSL's installer won't work.
		for i in $(ls "${MNT}"/knoppix/KNOPPIX*|grep -v '^KNOPPIX2$');do
			cp -r "${MNT}"/knoppix/KNOPPIX/$i "${WORK}"/KNOPPIX6/
		done
		mkdir -p "${WORK}"/boot/knoppix
		cp "${MNT}"/knoppix/boot/isolinux/linux "${WORK}"/boot/knoppix/linux
		cp "${MNT}"/knoppix/boot/isolinux/minirt.gz "${WORK}"/boot/knoppix/minirt.gz
		umcdmount knoppix
	fi
elif [ $1 = writecfg ];then
	if [ -f knoppix.iso ];then
		if [ -f knoppix.version ] && [ "$(cat knoppix.version)" != "" ];then
			KNOPPIXVER=" $(cat knoppix.version)"
		else
			KNOPPIXVER=""
		fi
		if [ -f "${TAGS}"/lang ];then
			LANGCODE=$(cat "${TAGS}"/lang)
		else
			if echo $KNOPPIXVER|grep DE;then
				LANGCODE=de
			else
				LANGCODE=en
			fi
		fi
		echo "MENU BEGIN --> ^Knoppix$KNOPPIXVER

		LABEL knoppix
		MENU LABEL Knoppix
		KERNEL /boot/knoppix/linux
		INITRD /boot/knoppix/minirt.gz
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=791 nomce quiet loglevel=0 tz=localtime knoppix_dir=KNOPPIX6

		LABEL adriane
		MENU LABEL Adriane (Knoppix)
		KERNEL /boot/knoppix/linux
		INITRD /boot/knoppix/minirt.gz
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=791 nomce quiet loglevel=0 tz=localtime knoppix_dir=KNOPPIX6 adriane

		LABEL knoppix-2
		MENU LABEL Knoppix (boot to command line)
		KERNEL /boot/knoppix/linux
		INITRD /boot/knoppix/minirt.gz
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=791 nomce quiet loglevel=0 tz=localtime knoppix_dir=KNOPPIX6 2

		LABEL fb1024x768
		KERNEL linux
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=791 xmodule=fbdev initrd=minirt.gz nomce quiet loglevel=0 tz=localtime
		LABEL fb1280x1024
		KERNEL linux
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=794 xmodule=fbdev initrd=minirt.gz nomce quiet loglevel=0 tz=localtime
		LABEL fb800x600
		KERNEL linux
		APPEND ramdisk_size=100000 lang=$LANGCODE vt.default_utf8=0 apm=power-off vga=788 xmodule=fbdev initrd=minirt.gz nomce quiet loglevel=0 tz=localtime

		label back
		menu label Back to main menu
		com32 menu.c32
		append isolinux.cfg

		MENU END" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
