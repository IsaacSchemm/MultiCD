#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#GParted Live plugin for multicd.sh
#version 20151111
#Copyright (c) 2011-2015 Isaac Schemm and others
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

getName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		NAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		NAME="$(cat $BASENAME.defaultname)"
	else
		NAME="GParted Live"
	fi
	#return
	echo ${NAME}
}

if [ $1 = links ];then
	echo "gparted.iso auto.gparted.iso none"
	echo "gparted-live-*.iso auto.gparted.iso GParted_*"
elif [ $1 = scan ];then
	for i in *.gparted.iso; do
		if [ -f $i ];then
			getName
		fi
	done
elif [ $1 = copy ];then
	for i in *.gparted.iso; do
		if [ -f $i ];then
			echo "Copying GParted Live ($i)..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			mkdir "${WORK}"/boot/$BASENAME
			mcdcp -r "${MNT}"/$BASENAME/live "${WORK}"/boot/$BASENAME #Compressed filesystem and kernel/initrd
			mcdcp -r "${MNT}"/$BASENAME/syslinux "${WORK}"/boot/$BASENAME
			rm "${WORK}"/boot/$BASENAME/live/memtest || true
			umcdmount $BASENAME
			sed -i "s|/live/vmlinuz|/boot/$BASENAME/live/vmlinuz|g" "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i "s|initrd=/live/initrd.img|initrd=/boot/$BASENAME/live/initrd.img|g" "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/label local/# &/' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/label memtest/# &/' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/timeout/# &/' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/ vga=791//g' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/ vga=normal//g' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i 's/ quiet//g' "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
			sed -i "s|nosplash|& vga=792 nomodeset live-media-path=/boot/$BASENAME/live|" "${WORK}"/boot/$BASENAME/syslinux/syslinux.cfg
		fi
	done
elif [ $1 = writecfg ];then
	j=0
	for i in *.gparted.iso; do
		j=$(($j+1))
		if [ -f $i ];then
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			echo "label gparted$j
			menu label ^$(getName)
			config /boot/$BASENAME/syslinux/syslinux.cfg

			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	done
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
