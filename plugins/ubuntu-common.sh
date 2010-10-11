#!/bin/sh
set -e
. ./functions.sh
#Ubuntu/casper common functions for multicd.sh
#version 6.0
#Copyright (c) 2010 maybeway36
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
if [ $1 = scan ] || [ $1 = copy ] || [ $1 = writecfg ] || [ $1 = category ];then
	exit 0 #This is not a plugin itself
fi
if [ ! -z "$1" ] && [ -f $1.iso ];then
	mcdmount $1
	cp -R $MNT/$1/casper $WORK/boot/$1 #Live system
	if [ -d $MNT/$1/preseed ];then
		cp -R $MNT/$1/preseed $WORK/boot/$1
	fi
	# Fix the isolinux.cfg
	if [ -f $MNT/$1/isolinux/text.cfg ];then
		UBUCFG=text.cfg
	elif [ -f $MNT/$1/isolinux/txt.cfg ];then
		UBUCFG=txt.cfg
	else
		UBUCFG=isolinux.cfg #For custom-made live CDs
	fi
	cp $MNT/$1/isolinux/$UBUCFG $WORK/boot/$1/$1.cfg
	sed -i "s@default live@default menu.c32@g" $WORK/boot/$1/$1.cfg #Show menu instead of boot: prompt
	sed -i "s@file=/cdrom/preseed/@file=/cdrom/boot/$1/preseed/@g" $WORK/boot/$1/$1.cfg #Preseed folder moved - not sure if ubiquity uses this
	sed -i "s^initrd=/casper/^live-media-path=/boot/$1 ignore_uuid initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Initrd moved, ignore_uuid added
	sed -i "s^kernel /casper/^kernel /boot/$1/^g" $WORK/boot/$1/$1.cfg #Kernel moved
	if [ $(cat $TAGS/lang) != en ];then
		sed -i "s^initrd=/boot/$1/^debian-installer/language=$(cat $TAGS/lang) console-setup/layoutcode?=$(cat $TAGS/lang) initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Add language codes to cmdline
	fi
	umcdmount $1
else
	echo "$0: \"$1\" is empty or not an ISO"
	exit 1
fi
