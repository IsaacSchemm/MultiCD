#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Slax 6 plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 Isaac Schemm
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
	echo "slax-*.iso slax.iso none"
elif [ $1 = scan ];then
	if [ -f slax.iso ];then
		echo "Slax"
	fi
elif [ $1 = copy ];then
	if [ -f slax.iso ];then
		echo "Copying Slax..."
		mcdmount slax
		if [ -f "${TAGS}"/slaxlist ];then
			mkdir "${WORK}"/slax
			for i in `ls "${MNT}"/slax/slax|sed -e '/^base$/ d'`;do
				cp -r "${MNT}"/slax/slax/$i "${WORK}"/slax/ #Copy everything but the base modules
			done
			mkdir "${WORK}"/slax/base
			for i in `cat "${TAGS}"/slaxlist`;do
				cp "${MNT}"/slax/slax/base/${i}* "${WORK}"/slax/base/ #Copy only the modules you wanted
			done
			cp "${MNT}"/slax/slax/base/001-*.lzm "${WORK}"/slax/base/ #Don't forget the core module!
			rm "${TAGS}"/slaxlist
		else
			cp -r "${MNT}"/slax/slax "${WORK}"/ #Copy everything
		fi
		mkdir -p "${WORK}"/boot/slax
		cp "${MNT}"/slax/boot/vmlinuz "${WORK}"/boot/slax/vmlinuz
		if [ -f "${MNT}"/slax/boot/initrd.lz ];then
			SUFFIX=lz
		else
			SUFFIX=gz
		fi
		cp "${MNT}"/slax/boot/initrd.$SUFFIX "${WORK}"/boot/slax/initrd.$SUFFIX
		umcdmount slax
		##########
		if [ "`ls -1 *.lzm 2> /dev/null;true`" != "" ];then
			echo "Copying Slax modules..."
		fi
		for i in `ls -1 *.lzm 2> /dev/null;true`; do
			if (! echo $i|grep -q ".sq4.lzm");then
				cp $i "${WORK}"/slax/modules/ #Copy the .lzm module to the modules folder
				if $VERBOSE;then
					echo \(Copied $i\)
				fi
			fi
		done
	fi
elif [ $1 = writecfg ];then
#BEGIN SLAX ENTRY#
if [ -f slax.iso ];then
	if [ -f "${MNT}"/slax/boot/initrd.lz ];then
		SUFFIX=lz
	else
		SUFFIX=gz
	fi
	if [ -f slax.version ] && [ "$(cat slax.version)" != "" ];then
		SLAXVER=" $(cat slax.version)"
	else
		SLAXVER=""
	fi
	if [ -f "${WORK}"/slax/base/002-xorg.lzm ];then
		echo "LABEL xconf
		MENU LABEL ^Slax$SLAXVER Graphics mode (KDE)
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw vga=791 splash=silent quiet autoexec=xconf;telinit~4  changes=/slax/

		LABEL lxde
		MENU LABEL Slax$SLAXVER (LXDE) (if available)
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw vga=791 splash=silent quiet autoexec=lxde;xconf;telinit~4 changes=/slax/

		LABEL copy2ram
		MENU LABEL Slax$SLAXVER Graphics mode, Copy To RAM
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw vga=791 splash=silent quiet copy2ram autoexec=xconf;telinit~4

		LABEL startx
		MENU LABEL Slax$SLAXVER Graphics VESA mode
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw autoexec=telinit~4  changes=/slax/

		LABEL slax
		MENU LABEL Slax$SLAXVER Text mode
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw  changes=/slax/" >> "${WORK}"/boot/isolinux/isolinux.cfg
	else
		echo "LABEL slax
		MENU LABEL ^Slax$SLAXVER Text mode
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw  changes=/slax/

		LABEL slax2ram
		MENU LABEL Slax$SLAXVER Text mode, Copy To RAM
		KERNEL /boot/slax/vmlinuz
		APPEND initrd=/boot/slax/initrd.$SUFFIX ramdisk_size=6666 root=/dev/ram0 rw copy2ram" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
fi
#END SLAX ENTRY#
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
