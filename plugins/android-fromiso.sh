#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Android-x86 (from iso) plugin for multicd.sh
#version 20151010
#Copyright (c) 2015 Isaac Schemm
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
	echo "android-x86-*.iso a.android-fromiso.iso none"
elif [ $1 = scan ];then
	if [ "*.android-fromiso.iso" != "$(echo *.android-fromiso.iso)" ];then
		for i in *.android-fromiso.iso;do
			echo "Android ($i) (try to run from .iso)"
		done
	fi
elif [ $1 = copy ];then
	if [ "*.android-fromiso.iso" != "$(echo *.android-fromiso.iso)" ];then
		for i in *.android-fromiso.iso;do
			echo "Copying Android ($i)..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			mkdir "${WORK}"/boot/$BASENAME
			mcdcp -r "${MNT}"/$BASENAME/kernel "${WORK}"/boot/$BASENAME/kernel
			mcdcp -r "${MNT}"/$BASENAME/initrd.img "${WORK}"/boot/$BASENAME/initrd.img
			umcdmount $BASENAME
			cp $BASENAME.iso "${WORK}"/boot/$BASENAME/android-fromiso.iso
		done
	fi
elif [ $1 = writecfg ];then
	if [ "*.android-fromiso.iso" != "$(echo *.android-fromiso.iso)" ];then
		for i in *.android-fromiso.iso;do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
				VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
			else
				VERSION=""
			fi
			echo "
			label android-$VERSION-livem
				menu label ^Android-x86$VERSION - run without installation
				kernel /boot/$BASENAME/kernel
				append initrd=/boot/$BASENAME/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 iso-scan/filename=/boot/$BASENAME/android-fromiso.iso quiet SRC= DATA=

			label android-$VERSION-vesa
				menu label ^Android-x86$VERSION - ^VESA mode
				kernel /boot/$BASENAME/kernel
				append initrd=/boot/$BASENAME/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 iso-scan/filename=/boot/$BASENAME/android-fromiso.iso quiet nomodeset vga=788 SRC= DATA=

			label android-$VERSION-debug
				menu label ^Android-x86$VERSION - ^Debug mode
				kernel /boot/$BASENAME/kernel
				append initrd=/boot/$BASENAME/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 iso-scan/filename=/boot/$BASENAME/android-fromiso.iso vga=788 DEBUG=2 SRC= DATA=

			label android-$VERSION-install
				menu label ^Android-x86$VERSION - ^Install to harddisk
				kernel /boot/$BASENAME/kernel
				append initrd=/boot/$BASENAME/initrd.img root=/dev/ram0 androidboot.hardware=android_x86 iso-scan/filename=/boot/$BASENAME/android-fromiso.iso INSTALL=1 DEBUG=
			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
