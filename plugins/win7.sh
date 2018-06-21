#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Windows 7 Disc plugin for multicd.sh
#version 20170620
#Copyright for this script (c) 2011-2017 Isaac Schemm et al
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
	echo "HBCD_PE_*.iso win7.iso Hiren's_BootCD_PE"
elif [ $1 = scan ];then
	if [ -f win7.iso ];then
		echo "Windows 7+"
		touch "${TAGS}/win7.needsname"
	fi
elif [ $1 = copy ];then
	if [ -f win7.iso ];then
		echo "Copying Windows 7+..."
		mcdmount win7
		if [ -d "${MNT}"/win7/HBCD_PE.ini ];then
			cp "${MNT}"/win7/HBCD_PE.ini "${WORK}"/
			cp "${MNT}"/win7/Version.txt "${WORK}"/hirens.txt || true
		fi
		cp -r "${MNT}"/win7/[Bb]oot/* "${WORK}"/boot/
		cp -r "${MNT}"/win7/sources "${WORK}"/
		cp "${MNT}"/win7/bootmgr "${WORK}"/
		umcdmount win7
	fi
elif [ $1 = writecfg ];then
if [ -f win7.iso ];then
	DISPLAYNAME="$(cat "${TAGS}"/win7.name)"
	if [ -z "$DISPLAYNAME" ];then
	DISPLAYNAME="Windows 7+"
		if which isoinfo &> /dev/null;then
			if isoinfo -d -i win7.iso;then
				DISPLAYNAME="Windows 7+ (64-bit)"
			else
				DISPLAYNAME="Windows 7+ (32-bit)"
			fi
		fi
	fi
	echo "label win7
	menu label $DISPLAYNAME
	kernel chain.c32
	append boot ntldr=/bootmgr">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
