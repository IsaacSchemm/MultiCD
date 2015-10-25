#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Slax 7 plugin for multicd.sh
#version 20151025
#Copyright (c) 2015 Isaac Schemm
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
	echo "slax-*.iso slax.iso none"
elif [ $1 = scan ];then
	if [ -f slax.iso ];then
		echo "Slax"
	fi
elif [ $1 = copy ];then
	if [ -f slax.iso ];then
		echo "Copying Slax..."
		mcdmount slax
		cp -r "${MNT}"/slax/slax "${WORK}"/ #Copy everything
		mkdir -p "${WORK}"/boot/slax
		umcdmount slax
		
		if [ "`ls -1 *.sb 2> /dev/null;true`" != "" ];then
			echo "Copying Slax modules..."
		fi
		for i in `ls -1 *.sb 2> /dev/null;true`; do
			cp $i "${WORK}"/slax/modules/ #Copy the .sb module to the modules folder
			if $VERBOSE;then
				echo \(Copied $i\)
			fi
		done
	fi
elif [ $1 = writecfg ];then
	if [ -f slax.iso ];then
		echo "LABEL slax
		MENU LABEL ^Slax$SLAXVER
		CONFIG /slax/boot/syslinux.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
		
		sed -i -e 's^UI /slax/boot/vesamenu.c32^DEFAULT /boot/isolinux/vesamenu.c32^g' "${WORK}"/slax/boot/syslinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
