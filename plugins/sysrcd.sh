#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#SystemRescueCd plugin for multicd.sh
#version 20121103
#Copyright (c) 2010-2012 Isaac Schemm and Pascal De Vuyst
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
	echo "systemrescuecd-x86-*.iso sysrcd.iso none"
elif [ $1 = scan ];then
	if [ -f sysrcd.iso ];then
		echo "SystemRescueCd"
	fi
elif [ $1 = copy ];then
	if [ -f sysrcd.iso ];then
		echo "Copying SystemRescueCd..."
		mcdmount sysrcd
		mkdir "${WORK}"/boot/sysrcd
		cp "${MNT}"/sysrcd/sysrcd.* "${WORK}"/boot/sysrcd/ #Compressed filesystem
		cp -r "${MNT}"/sysrcd/bootdisk "${WORK}"/boot/sysrcd/ #PDV system tools from floppy disk image
		cp -r "${MNT}"/sysrcd/ntpasswd "${WORK}"/boot/sysrcd/ #PDV NTPASSWD
		cp "${MNT}"/sysrcd/isolinux/altker* "${WORK}"/boot/sysrcd/ #Kernels
		cp "${MNT}"/sysrcd/isolinux/rescue* "${WORK}"/boot/sysrcd/ #Kernels
		cp "${MNT}"/sysrcd/isolinux/initram.igz "${WORK}"/boot/sysrcd/initram.igz #Initrd
		cp "${MNT}"/sysrcd/version "${WORK}"/boot/sysrcd/version
		cp "${MNT}"/sysrcd/isolinux/isolinux.cfg "${WORK}"/boot/isolinux/sysrcd.cfg #PDV
		cp "${MNT}"/sysrcd/isolinux/*.msg "${WORK}"/boot/isolinux #PDV
		umcdmount sysrcd
	fi
elif [ $1 = writecfg ];then
if [ -f sysrcd.iso ];then
#<PDV>
VERSION=$(cat "${WORK}"/boot/sysrcd/version)
echo "label sysrcd
menu label --> ^SystemRescueCd $VERSION
com32 vesamenu.c32
append sysrcd.cfg
" >> "${WORK}"/boot/isolinux/isolinux.cfg
#GNU sed syntax
sed -i -e 's/LINUX /LINUX \/boot\/sysrcd\//g' -e 's/INITRD /INITRD \/boot\/sysrcd\//g' -e 's/\/bootdisk/\/boot\/sysrcd\/bootdisk/g' -e 's/\/ntpasswd/\/boot\/sysrcd\/ntpasswd/g' "${WORK}"/boot/isolinux/sysrcd.cfg #PDV Change directory to /boot/sysrcd
sed -i -e 's/APPEND maps/append maps/g' "${WORK}"/boot/isolinux/sysrcd.cfg #PDV don't change APPEND maps lines
sed -i -e 's/APPEND rescue64.*rescue32/APPEND initrd=\/boot\/sysrcd\/initram.igz/g' -e 's/ifcpu64.c32/\/boot\/sysrcd\/rescue32/g' "${WORK}"/boot/isolinux/sysrcd.cfg # Remove ifcpu64.c32; just use 32-bit kernel by default
sed -i -e 's/APPEND/APPEND subdir=\/boot\/sysrcd/g' "${WORK}"/boot/isolinux/sysrcd.cfg #PDV Tell the kernel we moved it
if [ -f "${TAGS}"/country ];then #PDV
	sed -i -e 's/APPEND\([[:print:]]*setkmap\)/append\1/g' "${WORK}"/boot/isolinux/sysrcd.cfg #don't change APPEND lines with setkmap
	sed -i -e 's/APPEND/APPEND setkmap='$(cat "${TAGS}"/country)'/g' "${WORK}"/boot/isolinux/sysrcd.cfg #add setkmap=[language]
	sed -i -e 's/append\([[:print:]]*setkmap\)/APPEND\1/g' -e 's/append maps/APPEND maps/g' "${WORK}"/boot/isolinux/sysrcd.cfg #revert changes
fi
sed -i -e '/LABEL local2/,/^$/d' "${WORK}"/boot/isolinux/sysrcd.cfg #PDV remove Boot from second hard disk entry to avoid scrolling
if $MEMTEST; then #PDV remove memtest if already in main menu
	sed -i -e '/LABEL memtest/,/^$/d' "${WORK}"/boot/isolinux/sysrcd.cfg
	rm "${WORK}"/boot/sysrcd/bootdisk/memtestp
fi
echo "label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg" >> "${WORK}"/boot/isolinux/sysrcd.cfg
#</PDV>
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
