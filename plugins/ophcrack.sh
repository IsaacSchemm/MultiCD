#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#ophcrack plugin for multicd.sh
#version 6.9
#Copyright (c) 2011 yogurt06/Isaac Schemm
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
if [ $1 = scan ];then
	if [ -f ophxp.iso ] && [ ! -f ophvista.iso ];then
		echo "OPH Crack XP"
	fi
	if [ ! -f ophxp.iso ] && [ -f ophvista.iso ];then
		echo "OPH Crack Vista/7"
	fi
	if [ -f ophxp.iso ] && [ -f ophvista.iso ];then
		echo "OPH Crack XP/Vista/7"
	fi
elif [ $1 = copy ];then
	if [ -f ophxp.iso ];then
		echo "Copying OPH Crack XP..."
		mcdmount ophxp
		mkdir "${WORK}"/boot/ophcrack/
		cp -r "${MNT}"/ophxp/tables "${WORK}"/tables
		cp "${MNT}"/ophxp/boot/bzImage "${WORK}"/boot/ophcrack/bzImage
		cp "${MNT}"/ophxp/boot/isolinux/ophcrack.cfg "${WORK}"/boot/ophcrack/ophcrack.cfg
		cp "${MNT}"/ophxp/boot/isolinux/splash.png "${WORK}"/boot/ophcrack/splash.png
		cp "${MNT}"/ophxp/boot/rootfs.gz "${WORK}"/boot/ophcrack/rootfs.gz
		umcdmount ophxp
	fi
	if [ -f ophvista.iso ] && [ ! -f ophxp.iso ];then
		echo "Copying OPH Crack Vista/7..."
		mcdmount ophvista
		mkdir "${WORK}"/boot/ophcrack/
		cp -r "${MNT}"/ophvista/tables "${WORK}"/tables
		cp "${MNT}"/ophvista/boot/bzImage "${WORK}"/boot/ophcrack/bzImage
		cp "${MNT}"/ophvista/boot/isolinux/ophcrack.cfg "${WORK}"/boot/ophcrack/ophcrack.cfg
		cp "${MNT}"/ophvista/boot/isolinux/splash.png "${WORK}"/boot/ophcrack/splash.png
		cp "${MNT}"/ophvista/boot/rootfs.gz "${WORK}"/boot/ophcrack/rootfs.gz
		umcdmount ophvista
	fi
	if [ -f ophvista.iso ] && [ -f ophxp.iso ];then
		echo "Getting OPH Crack Vista/7 tables..."
		mcdmount ophvista
		cp -r "${MNT}"/ophvista/tables "${WORK}"
		umcdmount ophvista
	fi
elif [ $1 = writecfg ];then
	name=""
	if [ -f ophxp.iso ] && [ ! -f ophvista.iso ];then
		name="XP"
	fi
	if [ ! -f ophxp.iso ] && [ -f ophvista.iso ];then
		name="Vista/7"
	fi
	if [ -f ophxp.iso ] && [ -f ophvista.iso ];then
		name="XP/Vista/7"
	fi

	if [ -f ophxp.iso ] || [ -f ophvista.iso ];then
		echo "label ophcrack
		menu label --> ophcrack $name
		com32 vesamenu.c32
		append ophcrack.menu" >> "${WORK}"/boot/isolinux/isolinux.cfg

		sed 's/\/boot\//\/boot\/ophcrack\//g' "${WORK}"/boot/ophcrack/ophcrack.cfg > "${WORK}"/boot/isolinux/ophcrack.menu
		
		echo "
		label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg" >> "${WORK}"/boot/isolinux/ophcrack.menu

		rm "${WORK}"/boot/ophcrack/ophcrack.cfg
	fi
#elif [ $1 = category ];then
#	echo "tools"
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Dont use this plugin script on its own!"
fi
