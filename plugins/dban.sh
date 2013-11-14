#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#DBAN plugin for multicd.sh
#version 20130602
#Copyright (c) 2010-2013 Isaac Schemm
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
	echo "dban-*.iso dban.iso none"
elif [ $1 = scan ];then
	if [ -f dban.iso ];then
		echo "DBAN"
	fi
elif [ $1 = copy ];then
	if [ -f dban.iso ];then
		echo "Copying DBAN..."
		mcdmount dban
		mkdir -p "${WORK}"/boot/dban1
		cp "${MNT}"/dban/[Dd][Bb][Aa][Nn].[Bb][Zz][Ii] "${WORK}"/boot/dban1/dban.bzi
		umcdmount dban
	fi
elif [ $1 = writecfg ];then
#BEGIN DBAN ENTRY#
if [ -f dban.iso ];then
echo "#Most of the DBAN options are commented out on the menu because they're so dangerous.
#Even if you uncomment them, they won't appear on the menu unless you also remove MENU HIDE (you can still press Esc and enter them to boot.)

LABEL  dban
MENU LABEL ^DBAN
KERNEL /boot/dban1/dban.bzi
APPEND nuke=\"dwipe --method prng --rounds 8 --verify off\" floppy=0,16,cmos

#LABEL  autonuke
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --autonuke\" silent
#
#LABEL  dod
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --autonuke --method dod522022m\" silent
#
#LABEL  dod3pass
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --autonuke --method dod3pass\" silent
#
#LABEL  dodshort
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --autonuke --method dodshort\" silent
#
#LABEL  gutmann
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --autonuke --method gutmann\" silent
#
#LABEL  ops2
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --autonuke --method ops2\" silent
#
#LABEL  paranoid
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --autonuke --method prng --rounds 8 --verify all\" silent
#
#LABEL  prng
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --autonuke --method prng --rounds 8\" silent
#
#LABEL  quick
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --autonuke --method quick\" silent
#
#LABEL  zero
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --autonuke --method zero\" silent
#
#LABEL  nofloppy
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe\" floppy=0,16,cmos
#
#LABEL  nosilent
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe\"
#
#LABEL  noverify
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc quiet nuke=\"dwipe --verify off\"
#
#LABEL  debug
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"exec ash\" debug
#
#LABEL  shell
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"exec ash\"
#
#LABEL  verbose
#MENU HIDE
#KERNEL /boot/dban1/kernel.bzi
#APPEND initrd=/boot/dban1/initrd.gz root=/dev/ram0 init=/rc nuke=\"dwipe --method quick\"
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
#END DBAN ENTRY#
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
