#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#CDlinux plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 PsynoKhi0, Isaac Schemm
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
	if [ -f cdl.iso ];then
		echo "CDlinux"
	fi
elif [ $1 = copy ];then
	if [ -f cdl.iso ];then
		echo "Copying CDlinux..."
		mcdmount cdl
		cp -r "${MNT}"/cdl/CDlinux "${WORK}"/CDlinux #Everything in one folder
		rm "${WORK}"/CDlinux/boot/memtest.bin.gz #Remove redundant memtest
		umcdmount cdl
	fi
elif [ $1 = writecfg ];then
if [ -f cdl.iso ];then
#CDLinux uses country codes longer than two letters, so I don't think I'll get much out of "${TAGS}"/lang here.
echo "menu begin --> ^CDlinux

label cdlinux-en_US
	menu label ^CDlinux (en_US) English
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=en_US.UTF-8
	initrd /CDlinux/initrd
label cdlinux-de_DE
	menu label ^CDlinux (de_DE) Deutsch
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=de_DE.UTF-8
	initrd /CDlinux/initrd
label cdlinux-en_CA
	menu label ^CDlinux (en_CA) English
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=en_CA.UTF-8
	initrd /CDlinux/initrd
label cdlinux-en_GB
	menu label ^CDlinux (en_GB) English
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=en_GB.UTF-8
	initrd /CDlinux/initrd
label cdlinux-fr_CA
	menu label ^CDlinux (fr_CA) French
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=fr_CA.UTF-8
	initrd /CDlinux/initrd
label cdlinux-fr_CH
	menu label ^CDlinux (fr_CH) French
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=fr_CH.UTF-8
	initrd /CDlinux/initrd
label cdlinux-fr_FR
	menu label ^CDlinux (fr_FR) French
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=fr_FR.UTF-8
	initrd /CDlinux/initrd
label cdlinux-ja_JP
	menu label ^CDlinux (ja_JP) Japanese
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=ja_JP.UTF-8
	initrd /CDlinux/initrd
label cdlinux-ru_RU
	menu label ^CDlinux (ru_RU) Russian
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=ru_RU.UTF-8
	initrd /CDlinux/initrd
label cdlinux-zh_CN
	menu label ^CDlinux (zh_CN) Chinese
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=zh_CN.UTF-8
	initrd /CDlinux/initrd
label cdlinux-zh_TW
	menu label ^CDlinux (zh_TW) Chinese
	kernel /CDlinux/bzImage
	append quiet CDL_LANG=zh_TW.UTF-8
	initrd /CDlinux/initrd
label cdlinux-sfg
	menu label ^CDlinux Safe Graphics Mode
	kernel /CDlinux/bzImage
	append quiet CDL_SAFEG=yes
	initrd /CDlinux/initrd 
label back
	menu label Back to Main Menu
	com32 menu.c32
	append isolinux.cfg
menu end
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
