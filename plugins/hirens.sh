#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Hiren's BootCD (11.0) plugin for multicd.sh
#version 20120424
#Copyright for this script (c) 2012 Isaac Schemm
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
	echo "Hiren's.BootCD.*.iso hirens.iso none"
elif [ $1 = scan ];then
	if [ -f hirens.iso ];then
		echo "Hiren's BootCD (Not open source - do not distribute)"
		DUPLICATES=false #Initialize variable
		for i in riplinux dban konboot ntpasswd;do
			if [ -f $i.iso ];then
				echo "  Note: Hiren's BootCD already includes $i. Continuing anyway."
				DUPLICATES=true
			fi
		done
	fi
elif [ $1 = copy ];then
	if [ -f hirens.iso ];then
		echo "Copying Hiren's BootCD..."
		mcdmount hirens
		if [ -f hirens/BootCD.txt ];then
			head -n 1 "${MNT}"/hirens/BootCD.txt |sed -e 's/\t//g'>"${TAGS}"/hirens.name
		else
			echo "Warning: No BootCD.txt in hirens.iso" 1>&2
			echo "Hiren's BootCD" > "${TAGS}"/hirens.name
		fi
		cp -r "${MNT}"/hirens/HBCD "${WORK}"/
		umcdmount hirens
	fi
elif [ $1 = writecfg ];then
if [ -f hirens.iso ];then
echo "label hirens
menu label --> ^$(cat "${TAGS}"/hirens.name) - main menu
com32 menu.c32
append /HBCD/isolinux.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
rm "${TAGS}"/hirens.name
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
