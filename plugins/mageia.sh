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
		if [ -f $i.iso ];then
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
				if [ -d "${WORK}"/loopbacks ];then
					echo "Error: \$WORK/loopbacks already exists. This Mageia ISO conflicts with another ISO and cannot be added."
					exit 1
				fi
				cp -r "${MNT}"/$BASENAME/loopbacks "${WORK}"/
				mkdir -p "${WORK}"/boot/$BASENAME
				cp "${MNT}"/$BASENAME/boot/vmlinuz "${WORK}"/boot/$BASENAME
				cp "${MNT}"/$BASENAME/boot/cdrom/initrd* "${WORK}"/boot/$BASENAME
			else
				echo "Error: Mageia traditional installation ISOs are not supported yet. Only live CD/DVDs will work."
				exit 1
			fi
			umcdmount $BASENAME
		fi
	done
elif [ $1 = writecfg ];then
	MAGEIADIR=$(basename "${WORK}"/boot/*.mageia)
	if [ -d "${WORK}"/boot/$MAGEIADIR ];then
		echo "
		label mageia-live
		menu label Boot ^Mageia
		kernel /boot/$MAGEIADIR/vmlinuz
		append initrd=/boot/$MAGEIADIR/initrd.gz root=mgalive:LABEL=$CDLABEL splash quiet rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788
		
		label mageia-linux
		menu label Install Mageia
		kernel /boot/$MAGEIADIR/mlinuz
		append initrd=/boot/$MAGEIADIR/initrd.gz root=mgalive:LABEL=$CDLABEL splash quiet rd.luks=0 rd.lvm=0 rd.md=0 rd.dm=0 vga=788 install" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
