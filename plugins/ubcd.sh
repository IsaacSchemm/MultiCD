#!/bin/sh
set -e
#Ultimate Boot CD plugin for multicd.sh
#version 5.3
#Copyright (c) 2009 maybeway36
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
	if [ -f ubcd.iso ];then
		echo "Ultimate Boot CD"
	fi
	if [ -f dban.iso ] && [ -f ubcd.iso ];then
		echo
		echo "Note: Ultimate Boot CD includes DBAN, so it is not necessary alone as well."
		echo "Continuing anyway."
	fi
	if [ -f ntpasswd.iso ] && [ -f ubcd.iso ];then
		echo
		echo "Note: UBCD includes NT Password & Registry Editor, so it is not necessary alone as well."
		echo "Continuing anyway."
	fi
elif [ $1 = copy ];then
	set -e
	if [ -f ubcd.iso ];then
		echo "Copying Ultimate Boot CD..."
		if [ ! -d ubcd ];then
			mkdir ubcd
		fi
		if grep -q "`pwd`/ubcd" /etc/mtab ; then
			umount ubcd
		fi
		mount -o loop ubcd.iso ubcd/
		mkdir -p multicd-working/boot/ubcd/
        cp -r ubcd/dosapps multicd-working/boot/ubcd/
        cp -r ubcd/images multicd-working/boot/ubcd/
        cp -r ubcd/menus multicd-working/boot/ubcd/
        sed -i 's^/boot/^/boot/ubcd/boot/^g' multicd-working/boot/ubcd/menus/*
        sed -i 's^/menus/^/boot/ubcd/menus/^g' multicd-working/boot/ubcd/menus/*
        sed -i 's^/images/^/boot/ubcd/images/^g' multicd-working/boot/ubcd/menus/*
        cp -r ubcd/boot multicd-working/boot/ubcd/ #Some boot files needed for UBCD
		cp ubcd/isolinux/sbm.cbt multicd-working/boot/isolinux/sbm.cbt #Smart Boot Manager
		VERSION=$(head -n 1 ubcd/menus/defaults.cfg | awk '{ print $6 }')
		echo "$VERSION" > multicd-working/boot/ubcd/version
		umount ubcd
		rmdir ubcd
	fi
elif [ $1 = writecfg ];then
if [ -f ubcd.iso ];then
VERSION=$(cat multicd-working/boot/ubcd/version)
cat >> multicd-working/boot/isolinux/isolinux.cfg << EOF
label ubcd
menu label --> ^Ultimate Boot CD ($VERSION) - Main menu
com32 menu.c32
append /boot/ubcd/menus/main.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
