#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#DoudouLinux plugin for multicd.sh
#version 6.9
#Copyright (c) 2010 Isaac Schemm
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
	echo "doudoulinux-*.iso doudoulinux.iso none"
elif [ $1 = scan ];then
	if [ -f doudoulinux.iso ];then
		echo "DoudouLinux"
	fi
elif [ $1 = copy ];then
	if [ -f doudoulinux.iso ];then
		echo "Copying DoudouLinux..."
		mcdmount doudoulinux
		cp -r "${MNT}"/doudoulinux/live "${WORK}"/boot/doudou #Copy live folder - usually all that is needed
		cp "${MNT}"/doudoulinux/isolinux/live.cfg "${TAGS}"/doudou.cfg
		umcdmount doudoulinux
		rm "${WORK}"/live/memtest||true
	fi
elif [ $1 = writecfg ];then
	if [ -f doudoulinux.iso ];then
		if [ -f doudoulinux.version ] && [ "$(cat doudoulinux.version)" != "" ];then
			DOUDOUVER=" $(cat doudoulinux.version)"
		else
			DOUDOUVER=""
		fi
		sed -i -e "s/DoudouLinux/DoudouLinux $DOUDOUVER/g" "${TAGS}"/doudou.cfg
		sed -i -e "s^/live/^/boot/doudou/^g" "${TAGS}"/doudou.cfg
		sed -i -e "s^boot=live^boot=live live-media-path=/boot/doudou^g" "${TAGS}"/doudou.cfg
		cat "${TAGS}"/doudou.cfg >> "${WORK}"/boot/isolinux/isolinux.cfg
		rm "${TAGS}"/doudou.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
