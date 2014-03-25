#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Tiny Core Linux (also Core, CorePlus) plugin for multicd.sh
#version 20140325
#Copyright (c) 2014 Isaac Schemm
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
	# Although three aliases are defined, only one ISO will be used.
	echo "CorePlus-*.iso tinycore.iso none"
	echo "TinyCore-*.iso tinycore.iso none"
	echo "Core-*.iso tinycore.iso none"
elif [ $1 = scan ];then
	if [ -f tinycore.iso ];then
		echo "Tiny Core Linux"
	fi
elif [ $1 = copy ];then
	if [ -f tinycore.iso ];then
		echo "Copying Tiny Core..."
		if [ -f tinycore.iso ];then
			mcdmount tinycore
			mkdir "${WORK}"/boot/tinycore
			cp "${MNT}"/tinycore/boot/vmlinuz "${WORK}"/boot/tinycore/vmlinuz #Linux kernel - 4.0 or newer
			cp "${MNT}"/tinycore/boot/core.gz "${WORK}"/boot/tinycore/core.gz
			cp -r "${MNT}"/tinycore/cde "${WORK}"/
			umcdmount tinycore
			for i in `ls -1 *.tcz 2> /dev/null;true`;do
				mkdir -p "${WORK}"/cde
				echo "Copying: $i"
				cp $i "${WORK}"/cde/optional/"$i"
			done
			#regenerate onboot.lst
			true > "${WORK}"/cde/onboot.lst
			for i in "${WORK}"/cde/optional/*;do
				echo $(basename "$i") >> "${WORK}"/cde/onboot.lst
			done
		else
			echo "$0: \"$1\" is empty or not an ISO"
			exit 1
		fi
	fi
elif [ $1 = writecfg ];then
	if [ -f tinycore.iso ];then
		TCVER=""
		if [ -f tinycore.version ] && [ "$(cat tinycore.version)" != "" ];then
			TCVER="$(cat tinycore.version)"
		fi
		echo "LABEL tc
		MENU LABEL Boot TinyCore $TCVER
		TEXT HELP
		Boot TinyCore with extensions loaded from the CDE folder.
		Boot media is removable. Use TAB to edit options.
		ENDTEXT
		KERNEL /boot/tinycore/vmlinuz
		INITRD /boot/tinycore/core.gz
		APPEND loglevel=3 cde

		LABEL tcw
		MENU LABEL Boot TinyCore (on slow devices, waitusb=5)
		TEXT HELP
		Boot TinyCore with CDE extensions, if using a slow device.
		Boot media is removable. Use TAB to edit options.
		ENDTEXT
		KERNEL /boot/tinycore/vmlinuz
		INITRD /boot/tinycore/core.gz
		APPEND loglevel=3 cde waitusb=5

		LABEL core
		MENU LABEL Boot Core (command line only).
		TEXT HELP
		No embedded X/GUI extensions are loaded. User extensions if any
		will be loaded, and will need to provide X/GUI if required.
		ENDTEXT
		KERNEL /boot/tinycore/vmlinuz
		INITRD /boot/tinycore/core.gz
		APPEND loglevel=3

		LABEL corew
		MENU LABEL Boot Core (command line only on slow devices, waitusb=5)
		TEXT HELP
		No embedded X/GUI extensions are loaded. User extensions if any
		will be loaded, and will need to provide X/GUI if required.
		ENDTEXT
		KERNEL /boot/tinycore/vmlinuz
		INITRD /boot/tinycore/core.gz
		APPEND loglevel=3 waitusb=5" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
