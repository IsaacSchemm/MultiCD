#!/bin/sh
set -e
#CDlinux plugin for multicd.sh
#version 5.0
#Copyright (c) 2010 PsynoKhi0
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
		if [ ! -d cdlinux ];then
			mkdir cdlinux
		fi
		if grep -q "`pwd`/cdlinux" /etc/mtab ; then
			umount cdlinux
		fi
		mount -o loop cdl.iso cdlinux/
		cp -r cdlinux/CDlinux multicd-working/CDlinux #Everything in one folder
		rm multicd-working/CDlinux/boot/memtest.bin.gz #Remove redundant memtest
		umount cdlinux
		rmdir cdlinux
	fi
elif [ $1 = writecfg ];then
if [ -f cdl.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
#Uncomment extra language options as needed
label cdlinux-sfg
	menu label ^CDlinux Safe Graphics Mode
	kernel /CDlinux/bzImage quiet CDL_SAFEG=yes
	append initrd=/CDlinux/initrd 
#label cdlinux-de_DE
#	menu label ^CDlinux (de_DE) Deutsch
#	kernel /CDlinux/bzImage quiet CDL_LANG=de_DE.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-en_CA
#	menu label ^CDlinux (en_CA) English
#	kernel /CDlinux/bzImage quiet CDL_LANG=en_CA.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-en_GB
#	menu label ^CDlinux (en_GB) English
#	kernel /CDlinux/bzImage quiet CDL_LANG=en_GB.UTF-8
#	append initrd=/CDlinux/initrd
label cdlinux-en_US
	menu label ^CDlinux (en_US) English
	kernel /CDlinux/bzImage quiet CDL_LANG=en_US.UTF-8
	append initrd=/CDlinux/initrd
#label cdlinux-fr_CA
#	menu label ^CDlinux (fr_CA) French
#	kernel /CDlinux/bzImage quiet CDL_LANG=fr_CA.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-fr_CH
#	menu label ^CDlinux (fr_CH) French
#	kernel /CDlinux/bzImage quiet CDL_LANG=fr_CH.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-fr_FR
#	menu label ^CDlinux (fr_FR) French
#	kernel /CDlinux/bzImage quiet CDL_LANG=fr_FR.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-ja_JP
#	menu label ^CDlinux (ja_JP) Japanese
#	kernel /CDlinux/bzImage quiet CDL_LANG=ja_JP.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-ru_RU
#	menu label ^CDlinux (ru_RU) Russian
#	kernel /CDlinux/bzImage quiet CDL_LANG=ru_RU.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-zh_CN
#	menu label ^CDlinux (zh_CN) Chinese
#	kernel /CDlinux/bzImage quiet CDL_LANG=zh_CN.UTF-8
#	append initrd=/CDlinux/initrd
#label cdlinux-zh_TW
#	menu label ^CDlinux (zh_TW) Chinese
#	kernel /CDlinux/bzImage quiet CDL_LANG=zh_TW.UTF-8
#	append initrd=/CDlinux/initrd
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
