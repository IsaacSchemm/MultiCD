#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Trinity Rescue Kit plugin for multicd.sh
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
	echo "trinity-rescue-kit.*.iso trk.iso none"
elif [ $1 = scan ];then
	if [ -f trk.iso ];then
		echo "Trinity Rescue Kit"
	fi
elif [ $1 = copy ];then
	if [ -f trk.iso ];then
		echo "Copying Trinity Rescue Kit..."
		mcdmount trk
		cp -r "${MNT}"/trk/trk3 "${WORK}"/ #TRK files
		mkdir "${WORK}"/boot/trinity
		cp "${MNT}"/trk/isolinux.cfg "${WORK}"/boot/isolinux/trk.menu
		cp "${MNT}"/trk/kernel.trk "${WORK}"/boot/trinity/kernel.trk
		cp "${MNT}"/trk/initrd.trk "${WORK}"/boot/trinity/initrd.trk
		cp "${MNT}"/trk/bootlogo.jpg "${WORK}"/boot/isolinux/trklogo.jpg #Boot logo
		umcdmount trk
	fi
elif [ $1 = writecfg ];then
if [ -f trk.iso ];then
echo "label trk
menu label --> ^Trinity Rescue Kit
com32 vesamenu.c32
append trk.menu
" >> "${WORK}"/boot/isolinux/isolinux.cfg
#REQUIRES GNU sed to work (usage of -i option.)
sed -i -e 's^bootlogo.jpg^trklogo.jpg^g' "${WORK}"/boot/isolinux/trk.menu
sed -i -e 's^kernel kernel.trk^kernel /boot/trinity/kernel.trk^g' "${WORK}"/boot/isolinux/trk.menu
sed -i -e "s^initrd=initrd.trk^initrd=/boot/trinity/initrd.trk vollabel=$CDLABEL^g" "${WORK}"/boot/isolinux/trk.menu #This line both changes the initrd path and adds the volume label argument ($CDLABEL is set [exported] in multicd.sh)
sed -i '/^label t$/d' "${WORK}"/boot/isolinux/trk.menu #Remove memtest part1
sed -i '/Memory tester/d' "${WORK}"/boot/isolinux/trk.menu #Remove memtest part2
sed -i '/memtest/d' "${WORK}"/boot/isolinux/trk.menu #Remove memtest part3
echo "
label back
menu label ^Back to main menu
com32 menu.c32
append isolinux.cfg" >> "${WORK}"/boot/isolinux/trk.menu
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
