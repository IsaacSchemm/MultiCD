#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Fusion Linux plugin for multicd.sh
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
	echo "Fusion-Linux-*.iso fusion.iso none"
elif [ $1 = scan ];then
	if [ -f fusion.iso ];then
		echo "Fusion Linux"
	fi
elif [ $1 = copy ];then
	if [ -f fusion.iso ];then
		echo "Copying Fusion Linux..."
		mcdmount fusion
		if [ -d "${WORK}"/LiveOS ];then
			echo "Warning: \$WORK/LiveOS exists. Fusion Linux conflicts with another CD on the ISO."
		fi
		cp -r "${MNT}"/fusion/LiveOS "${WORK}"/
		mkdir -p "${WORK}"/boot/fusion
		cp "${MNT}"/fusion/isolinux/vmlinuz* "${WORK}"/boot/fusion
		cp "${MNT}"/fusion/isolinux/initrd* "${WORK}"/boot/fusion
		cp "${MNT}"/fusion/isolinux/isolinux.cfg "${WORK}"/boot/fusion/fusion.cfg
		cp "${MNT}"/fusion/isolinux/splash.jpg "${WORK}"/boot/fusion/
		umcdmount fusion
	fi
elif [ $1 = writecfg ];then
	if [ -z "$CDLABEL" ];then
		CDLABEL=MCDtest
		echo "$0: warning: \$CDLABEL is empty."
	fi
	if [ -f fusion.iso ];then
		BASENAME=fusion

		echo "label $BASENAME
		menu label --> ^Fusion Linux$(getVersion) Menu
		com32 vesamenu.c32
		append /boot/$BASENAME/$BASENAME.cfg
		" >> "${WORK}"/boot/isolinux/isolinux.cfg

		echo "label back
		menu label --> ^Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> "${WORK}"/boot/$BASENAME/$BASENAME.cfg
		sed -i -e 's^menu background splash^menu background /boot/fusion/splash^g' "${WORK}"/boot/$BASENAME/$BASENAME.cfg
		sed -i -e 's^kernel vmlinuz^kernel /boot/fusion/vmlinuz^g' "${WORK}"/boot/$BASENAME/$BASENAME.cfg
		sed -i -e 's^initrd=initrd^initrd=/boot/fusion/initrd^g' "${WORK}"/boot/$BASENAME/$BASENAME.cfg
		sed -i -e "s/CDLABEL=[^ ]*/CDLABEL=${CDLABEL}/g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
