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
if [ $1 = scan ];then
	if [ -f win7.iso ];then
		echo "Windows 7 Disc (Not open source)"
	fi
elif [ $1 = copy ];then
	if [ -f win7.iso ];then
		echo "Copying Windows 7 Disc..."
		mcdmount win7
		if [ ! -d "${MNT}"/win7/boot ];then
			echo "Could not find \"boot\" folder - maybe it wasn't extracted properly." >&2
			echo "On Linux, running this script again as root should fix it." >&2
			exit 1
		fi
		cp -r "${MNT}"/win7/boot/* "${WORK}"/boot/
		cp -r "${MNT}"/win7/sources "${WORK}"/
		cp "${MNT}"/win7/bootmgr "${WORK}"/
		umcdmount win7
	fi
elif [ $1 = writecfg ];then
if [ -f win7.iso ];then
	if which isoinfo &> /dev/null;then
		if isoinfo -d -i win7.iso;then
			TYPE=" 64-bit"
		else
			TYPE=" 32-bit"
		fi
	else
		TYPE=""
	fi
	echo "label win7
	menu label Windows ^7$TYPE Disc (direct from CD)
	kernel chain.c32
	append boot ntldr=/bootmgr">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
