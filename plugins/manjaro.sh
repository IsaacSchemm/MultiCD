#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Manjaro plugin for multicd.sh
#version 20170526
#Copyright (c) 2017 Isaac Schemm
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
	echo "manjaro-*.iso manjaro.iso Manjaro_(*)"
elif [ $1 = scan ];then
	if [ -f manjaro.iso ];then
		echo "Manjaro"
	fi
elif [ $1 = copy ];then
	if [ -f manjaro.iso ];then
		echo "Copying Manjaro..."
		mcdmount manjaro
		if [ -d "${WORK}"/manjaro ];then
			echo "Cannot put more than one Manjaro on the same disc."
			exit 1
		fi
		mcdcp -r "${MNT}"/manjaro/manjaro "${WORK}"
		if [ -f "${MNT}"/manjaro/boot/grub/i386-pc/eltorito.img ];then
			# Build a miniature ISO with GRUB and the kernel and initrd, and load it with memdisk. The rest of the OS will be loaded once the kernel boots.
			SMALLISODIR=/tmp/manjaro-boot-$(date +%s)
			mkdir $SMALLISODIR
			mcdcp -r "${MNT}"/manjaro/boot $SMALLISODIR
			cp $SMALLISODIR/boot/grub/kernels.cfg old.cfg
			sed -i -e "s/misolabel=[^ ]*/misolabel=$CDLABEL/g" $SMALLISODIR/boot/grub/kernels.cfg
			cp $SMALLISODIR/boot/grub/kernels.cfg new.cfg
			GENERATOR=genisoimage
			if ! which genisoimage && which mkisofs;then
				GENERATOR=mkisofs
			fi
			$GENERATOR -R -b boot/grub/i386-pc/eltorito.img -no-emul-boot -boot-load-size 4 -boot-info-table -c boot.catalog -o "${WORK}"/manjaro/multicd-boot.iso $SMALLISODIR
			rm -r $SMALLISODIR
		else
			cat "${MNT}"/manjaro/isolinux/isolinux.cfg | sed -e 's/^ui.*//g' -e 's/isolinux\.msg/manjaro\.msg/g' -e "s/misolabel=[^ ]*/misolabel=$CDLABEL/g" > "${WORK}"/boot/isolinux/manjaro.cfg
			cat "${MNT}"/manjaro/isolinux/isolinux.msg | sed -e '/^hdt/d' -e '/^harddisk.*/d' -e '/^memtest/d' > "${WORK}"/boot/isolinux/manjaro.msg
		fi
		touch "${WORK}"/.miso
		umcdmount manjaro
	fi
elif [ $1 = writecfg ];then
	if [ -f manjaro.iso ];then
		if [ -f "${WORK}"/manjaro/multicd-boot.iso ];then
			echo "label Manjaro
				menu label ^Manjaro
				kernel memdisk
				append iso
				initrd /manjaro/multicd-boot.iso" >> "${WORK}"/boot/isolinux/isolinux.cfg
		else
			echo "label Manjaro
				menu label >> ^Manjaro
				config /boot/isolinux/manjaro.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg

				echo "label back
				menu label Back to main menu
				config /boot/isolinux/isolinux.cfg /boot/isolinux/
				" >> "${WORK}"/boot/isolinux/manjaro.cfg
		fi
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
