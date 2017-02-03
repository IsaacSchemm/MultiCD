#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#FreeDOS installer plugin for multicd.sh
#version 20170125
#Copyright (c) 2012 Isaac Schemm
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
	#Only one will be included
	echo "FD12CD.iso freedos.iso FreeDOS_1.2"
	echo "fd11src.iso freedos.iso FreeDOS_1.1"
	echo "fdfullcd.iso freedos.iso FreeDOS_Full_CD"
	echo "fdbasecd.iso freedos.iso FreeDOS_Base_CD"
elif [ $1 = scan ];then
	if [ -f freedos.iso ];then
		echo "FreeDOS"
	fi
elif [ $1 = copy ];then
	if [ -f freedos.iso ];then
		echo "Copying FreeDOS..."
		mcdmount freedos
		mkdir "${WORK}"/boot/freedos
		if [ -d "${MNT}"/freedos/ISOLINUX ];then
			if [ -f "${MNT}"/freedos/ISOLINUX/FDBOOT.IMG ];then
				cp "${MNT}"/freedos/ISOLINUX/FDBOOT.IMG "${WORK}"/boot/freedos/fdboot.img #Initial DOS boot image
			elif [ -f "${MNT}"/freedos/ISOLINUX/FDBOOT.img ];then
				cp "${MNT}"/freedos/ISOLINUX/FDBOOT.img "${WORK}"/boot/freedos/fdboot.img #Initial DOS boot image
			else
				cp "${MNT}"/freedos/DATA/FDBOOT.IMG "${WORK}"/boot/freedos/fdboot.img
			fi
			if [ -d "${MNT}"/freedos/FREEDOS ];then
				#FreeDOS 1.1 or earlier
				cp -r "${MNT}"/freedos/FREEDOS "${WORK}"/ #Core directory with the packages
				cp "${MNT}"/freedos/SETUP.BAT "${WORK}"/setup.bat #FreeDOS setup
				if [ -d "${MNT}"/freedos/FDOS ];then
					cp -r "${MNT}"/freedos/FDOS "${WORK}"/ #Live CD
				fi
				if [ -d "${MNT}"/freedos/GEMAPPS ];then
					cp -r "${MNT}"/freedos/GEMAPPS "${WORK}"/ #OpenGEM
				fi
				if [ -f "${MNT}"/freedos/GEM.BAT ];then
					cp -r "${MNT}"/freedos/GEM.BAT "${WORK}"/ #OpenGEM setup
				fi
			fi
		else
			if [ -f "${MNT}"/freedos/isolinux/fdboot.img ];then
				cp "${MNT}"/freedos/isolinux/fdboot.img "${WORK}"/boot/freedos/fdboot.img #Initial DOS boot image
			else
				cp "${MNT}"/freedos/data/fdboot.img "${WORK}"/boot/freedos/fdboot.img
			fi
			if [ -d "${MNT}"/freedos/FREEDOS ];then
				#FreeDOS 1.1 or earlier
				cp -r "${MNT}"/freedos/freedos "${WORK}"/ #Core directory with the packages
				cp "${MNT}"/freedos/setup.bat "${WORK}"/setup.bat #FreeDOS setup
				if [ -d "${MNT}"/freedos/fdos ];then
					cp -r "${MNT}"/freedos/fdos "${WORK}"/ #Live CD
				fi
				if [ -d "${MNT}"/freedos/gemapps ];then
					cp -r "${MNT}"/freedos/gemapps "${WORK}"/ #OpenGEM
				fi
				if [ -f "${MNT}"/freedos/gem.bat ];then
					cp -r "${MNT}"/freedos/gem.bat "${WORK}"/ #OpenGEM setup
				fi
			fi
		fi
		for u in ARCHIVER BASE BOOT DEVEL EDIT GAMES NET PKGINFO SOUND UTIL;do
			#FreeDOS 1.2
			l=$(echo $x | tr '[:upper:]' '[:lower:]')
			if [ -d "${MNT}"/freedos/$u ];then
				mkdir -p "${WORK}"/$l
				cp -r "${MNT}"/freedos/$u "${WORK}"/$l
			elif [ -d "${MNT}"/freedos/$l ];then
				mkdir -p "${WORK}"/$l
				cp -r "${MNT}"/freedos/$l "${WORK}"/$l
			fi
		done
		umcdmount freedos
	fi
elif [ $1 = writecfg ];then
	if [ -f freedos.iso ];then
		if [ -f freedos.defaultname ] && [ "$(cat freedos.defaultname)" != "" ];then
			NAME=$(cat freedos.defaultname) #Default name based on the automatic links made in isoaliases()
		else
			NAME="FreeDOS CD" #Fallback name
		fi
		echo "label fdos
		menu label ^$NAME
		kernel memdisk
		append initrd=/boot/freedos/fdboot.img
		" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
