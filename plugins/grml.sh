#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#GRML (32/64/96) Full plugin for multicd.sh
#version 20131123
#Copyright (c) 2013 Isaac Schemm, others
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
	echo "grml96-full*.iso grml.iso none"
	echo "grml32-full*.iso grml.iso none"
	echo "grml64-full*.iso grml.iso none"
elif [ $1 = scan ];then
	if [ -f grml.iso ];then
		echo "GRML"
	fi
elif [ $1 = copy ];then
	if [ -f grml.iso ];then
		echo "Copying GRML..."
		mcdmount grml
		mkdir "${WORK}"/grml
		mkdir "${WORK}"/conf
		cp -r "${MNT}"/grml/live/* "${WORK}"/grml #Compressed filesystem.
		if [ -d "${MNT}"/grml/boot/grml32full ];then
			mkdir "${WORK}"/boot/grml
			cp "${MNT}"/grml/boot/grml32full/vmlinuz "${WORK}"/boot/grml/ #Kernel. See above.
			cp "${MNT}"/grml/boot/grml32full/initrd.img "${WORK}"/boot/grml/initrd.img #Initial ramdisk. See above.
			cp "${MNT}"/grml/[Gg][Rr][Mm][Ll]/grml32-full/grml-version "${WORK}"/boot/grml/grml-version
		fi
		if [ -d "${MNT}"/grml/boot/grml64full ];then
			mkdir "${WORK}"/boot/grml64
			cp "${MNT}"/grml/boot/grml64full/vmlinuz "${WORK}"/boot/grml64/ #Kernel. See above.
			cp "${MNT}"/grml/boot/grml64full/initrd.img "${WORK}"/boot/grml64/ #Initial ramdisk. See above.
			cp "${MNT}"/grml/[Gg][Rr][Mm][Ll]/grml64-full/grml-version "${WORK}"/boot/grml64/grml-version
		fi
		touch "${WORK}"/boot/grml/grml.cfg
		for f in grml32_full_default.cfg grml32_full_grml.cfg grml32_full_hidden.cfg grml64_full_default.cfg grml64_full_grml.cfg hidden.cfg;do
			if [ -f "${MNT}"/grml/boot/isolinux/$f ];then
				 cat "${MNT}"/grml/boot/isolinux/$f >> "${WORK}"/boot/grml/grml.cfg #adding to menufile
			fi
		done
		umcdmount grml
	fi
elif [ $1 = writecfg ];then
if [ -f grml.iso ];then
	VERSION=$(awk '{print substr($2,1,7)}' "${WORK}"/boot/grml/grml-version) #Getting grml Version
	echo "menu begin --> GRML $VERSION
	" >> "${WORK}"/boot/isolinux/isolinux.cfg

	sed -i".bak" '1d' "${WORK}"/boot/grml/grml.cfg #deleting some lines we don't want
	sed -i".bak" '2d' "${WORK}"/boot/grml/grml.cfg
	sed -i -e '/^menu end$/d' "${WORK}"/boot/grml/grml.cfg
	sed -i -e '/^default .*/d' "${WORK}"/boot/grml/grml.cfg
	echo "label back\n   menu label Back to main menu...\n   com32 menu.c32\n" >> "${WORK}"/boot/grml/grml.cfg #insert back to main menu

	sed -i -e 's^live-media-path=/live/grml^ignore_bootid live-media-path=/grml/grml^g' "${WORK}"/boot/grml/grml.cfg
	sed -i -e 's^/boot/grml32full/^/boot/grml/^g' "${WORK}"/boot/grml/grml.cfg
	sed -i -e 's^/boot/grml64full/^/boot/grml64/^g' "${WORK}"/boot/grml/grml.cfg
	echo "menu end" >> "${WORK}"/boot/grml/grml.cfg

	if [ -f "${WORK}"/boot/grml/grml.cfg.bak ];then
		rm "${WORK}"/boot/grml/grml.cfg.bak #bak file from sed not needed
	fi

	cat "${WORK}"/boot/grml/grml.cfg >> "${WORK}"/boot/isolinux/isolinux.cfg #putting everything together

	rm "${WORK}"/boot/grml/grml.cfg #not needed any longer
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
