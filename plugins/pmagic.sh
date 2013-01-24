#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Parted Magic plugin for multicd.sh
#version 20130129
#Copyright (c) 2011-2013 Isaac Schemm and Pascal De Vuyst
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
	echo "pmagic-*.iso pmagic.iso none"
elif [ $1 = scan ];then
	if [ -f pmagic.iso ];then
		echo "Parted Magic"
	fi
elif [ $1 = copy ];then
	if [ -f pmagic.iso ];then
		echo "Copying Parted Magic..."
		mcdmount pmagic
		cp -r "${MNT}"/pmagic/pmagic "${WORK}"/boot/ #kernel/initrd & modules
		if [ ! -f "${WORK}"/boot/isolinux/linux.c32 ];then
			cp "${MNT}"/pmagic/boot/syslinux/linux.c32 "${WORK}"/boot/isolinux
		fi
		if [ ! -f "${WORK}"/boot/isolinux/reboot.c32 ];then #PDV
			cp "${MNT}"/pmagic/boot/syslinux/reboot.c32 "${WORK}"/boot/isolinux
		fi
		cp -r "${MNT}"/pmagic/boot/* "${WORK}"/boot/pmagic #PDV Extras
		cp "${MNT}"/pmagic/boot/syslinux/hdt* "${WORK}"/boot/pmagic #PDV add hdt
		if [ $MEMTEST = "false" ]; then #PDV add memtest
			cp "${MNT}"/pmagic/boot/syslinux/memtest "${WORK}"/boot/pmagic
		fi
		rm -r "$WORK"/boot/pmagic/syslinux #PDV remove syslinux
		cp "${MNT}"/pmagic/boot/syslinux/syslinux.cfg "${WORK}"/boot/isolinux/pmagic.cfg
		cp "${MNT}"/pmagic/boot/syslinux/*.txt "${WORK}"/boot/isolinux #PDV
		#if [ -f "${MNT}"/pmagic/mkgriso ];then cp "${MNT}"/pmagic/mkgriso "${WORK}";fi
		umcdmount pmagic
	fi
elif [ $1 = writecfg ];then
if [ -f pmagic.iso ];then
	if [ -f "${WORK}"/boot/pmagic/pmodules/*.SQFS ];then #PDV
		cd "${WORK}"/boot/pmagic/pmodules/
		VERSION=" $(ls *.SQFS | sed -e 's/PMAGIC_//' -e 's/.SQFS//')"
	else
		VERSION=""
	fi
	echo "label pmagic
	menu label --> ^Parted Magic$VERSION
	com32 menu.c32
	append /boot/isolinux/pmagic.cfg
	" >> "${WORK}"/boot/isolinux/isolinux.cfg
	#<PDV>
	#GNU sed syntax
	sed -i -e 's/\/boot/\/boot\/pmagic/g' -e 's/\/pmagic/\/boot\/pmagic/g' -e 's/\/boot\/boot/\/boot/g' "${WORK}"/boot/isolinux/pmagic.cfg #Change directory to /boot/pmagic
	sed -i -e 's/\/boot\/pmagic\/syslinux/\/boot\/isolinux/g' "${WORK}"/boot/isolinux/pmagic.cfg #Change directory to /boot/isolinux
 	# hier muss noch das 64bit Image berücksichtigt werden
 	sed -i -e 's/APPEND \/boot\/pmagic\/bzImage64 /APPEND \/boot\/pmagic\/bzImage64 directory=\/boot /g' "${WORK}"/boot/isolinux/pmagic.cfg
 	sed -i -e 's/APPEND \/boot\/pmagic\/bzImage /APPEND \/boot\/pmagic\/bzImage directory=\/boot /g' "${WORK}"/boot/isolinux/pmagic.cfg
	sed -i -e 's/\/boot\/isolinux\/hdt/\/boot\/pmagic\/hdt/' "${WORK}"/boot/isolinux/pmagic.cfg #Change directory to /boot/pmagic
	if [ -f "${TAGS}"/country ];then
		sed -i -e 's/APPEND \/boot\/pmagic\/bzImage\([[:print:]]*keymap\)/append \/boot\/pmagic\/bzImage\1/g' "${WORK}"/boot/isolinux/pmagic.cfg #don't change APPEND lines that already have keymap and language
		if [ -f "${TAGS}"/lang-full ]; then
			LNG=$(cat "${TAGS}"/lang-full)
		else
			LNG=""
		fi
		if [ $(cat "${TAGS}"/country) = "be" ];then
			sed -i -e 's/APPEND \/boot\/pmagic\/bzImage/APPEND \/boot\/pmagic\/bzImage keymap=be-latin1 '$LNG'/' "${WORK}"/boot/isolinux/pmagic.cfg #set keymap and language
		fi
		sed -i -e 's/append \/boot\/pmagic\/bzImage\([[:print:]]*keymap\)/APPEND \/boot\/pmagic\/bzImage\1/g' "${WORK}"/boot/isolinux/pmagic.cfg #revert changes
	fi
	if $MEMTEST;then
		sed -i -e '/LABEL memtest/,/^$/d' "${WORK}"/boot/isolinux/pmagic.cfg #remove memtest if already in main menu
	else
		sed -i -e 's/\/boot\/isolinux\/memtest/\/boot\/pmagic\/memtest/g' "${WORK}"/boot/isolinux/pmagic.cfg #Change directory to /boot/pmagic
	fi
	#</PDV>
	echo "
MENU SEPARATOR

label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg" >> "${WORK}"/boot/isolinux/pmagic.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
