#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Mageia plugin for multicd.sh
#version 20161025
#Copyright (c) 2016 Isaac Schemm
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
	echo "Mageia-*.iso mageia.mageia.iso none"
elif [ $1 = scan ];then
	for i in *.mageia.iso;do
		if [ -f $i ];then
			echo "Mageia ($i)"
		fi
	done
elif [ $1 = copy ];then
	for i in *.mageia.iso;do
		if [ -f $i ];then
			echo "Copying Mageia..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			if [ -d "${MNT}"/$BASENAME/loopbacks ];then
				#Live
				if [ -d "${WORK}"/loopbacks ];then
					echo "Error: \$WORK/loopbacks already exists. This Mageia ISO conflicts with another ISO and cannot be added."
					exit 1
				fi
				cp -r "${MNT}"/$BASENAME/loopbacks "${WORK}"/
				mkdir -p "${WORK}"/boot/$BASENAME/cdrom
				cp "${MNT}"/$BASENAME/boot/vmlinuz "${WORK}"/boot/$BASENAME
				cp "${MNT}"/$BASENAME/boot/cdrom/initrd* "${WORK}"/boot/$BASENAME/cdrom
				
				echo "
default /boot/isolinux/menu.c32
prompt 0

label live
	menu label ^Live
    kernel /boot/$BASENAME/vmlinuz
    append initrd=/boot/$BASENAME/cdrom/initrd.gz root=mgalive:LABEL=$CDLABEL splash quiet noiswmd rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788 
label linux
	menu label ^Install
    kernel /boot/$BASENAME/vmlinuz
    append initrd=/boot/$BASENAME/cdrom/initrd.gz root=mgalive:$CDLABEL splash quiet noiswmd rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788  install
label back
	menu label ^Back to main menu
	config /boot/isolinux/isolinux.cfg /boot/isolinux
" > "${WORK}"/boot/$BASENAME/isolinux.cfg
			else
				#Install
				mkdir -p "${WORK}"/boot/$BASENAME
				for arch in i586 x86_64;do
					if [ -d "${MNT}"/$BASENAME/$arch ];then
						if [ -d "${WORK}"/$arch ];then
							echo "Error: \$WORK/$arch already exists. This Mageia ISO conflicts with another ISO and cannot be added."
							exit 1
						fi
						mcdcp -r "${MNT}"/$BASENAME/$arch "${WORK}"/$arch
						mcdcp -r "${MNT}"/$BASENAME/isolinux/$arch "${WORK}"/boot/$BASENAME/$arch
					fi
				done
				cp "${MNT}"/$BASENAME/isolinux/*.cfg "${WORK}"/boot/$BASENAME
				cp "${MNT}"/$BASENAME/isolinux/*.msg "${WORK}"/boot/$BASENAME
				cp "${MNT}"/$BASENAME/isolinux/*.c32 "${WORK}"/boot/$BASENAME
				for j in "${WORK}"/boot/$BASENAME/*.cfg;do
					sed -i -e 's/ui gfxboot.c32 .*//' "$j"
				done
			fi
			umcdmount $BASENAME
		fi
	done
elif [ $1 = writecfg ];then
	MAGEIADIRS="${WORK}"/boot/*.mageia
	for i in "$MAGEIADIRS";do
		BASENAME="$(basename "$i")"
		if [ -d "${WORK}"/boot/$BASENAME ];then
			VER=""
			if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
				VER="$(cat $BASENAME.version)"
			fi
			echo "LABEL $BASENAME
			MENU LABEL ^Mageia $VER
			CONFIG /boot/$BASENAME/isolinux.cfg /boot/$BASENAME" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	done
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
