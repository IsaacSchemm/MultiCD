#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#NetbootCD 4.8+ plugin for multicd.sh
#version 20160102
#Copyright (c) 2016 Isaac Schemm
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
	echo "NetbootCD-*.iso netbootcd.iso none"
elif [ $1 = scan ];then
	if [ -f netbootcd.iso ];then
		echo "NetbootCD"
	fi
elif [ $1 = copy ];then
	if [ -f netbootcd.iso ];then
		echo "Copying NetbootCD..."
		mcdmount netbootcd
		mkdir -p "${WORK}"/boot/nbcd
		if [ -f "${MNT}"/netbootcd/boot/kexec.bzI ];then
			cp "${MNT}"/netbootcd/boot/kexec.bzI "${WORK}"/boot/nbcd/kexec.bzI
		else # I renamed the kernel back to vmlinuz in 6.1
			cp "${MNT}"/netbootcd/boot/vmlinuz "${WORK}"/boot/nbcd/vmlinuz
		fi
		cp "${MNT}"/netbootcd/boot/nbinit4.gz "${WORK}"/boot/nbcd/nbinit4.gz
		if [ -d "${MNT}"/netbootcd/cde ];then #combined cd with CorePlus
			if [ -d "${WORK}"/cde ];then
				echo "NOTE: combining TCZ folders of TinyCore and NetbootCD+CorePlus."
			fi
			cp -r "${MNT}"/netbootcd/cde "${WORK}"
			for i in `ls -1 *.tcz 2> /dev/null;true`;do
				echo "Copying: $i"
				cp $i "${WORK}"/cde/optional/"$i"
			done
			#regenerate onboot.lst
			true > "${WORK}"/cde/onboot.lst
			for i in "${WORK}"/cde/optional/*.tcz;do
				echo $(basename "$i") >> "${WORK}"/cde/onboot.lst
			done
			cp "${MNT}"/netbootcd/boot/core.gz "${WORK}"/boot/nbcd/
			if [ -f "${MNT}"/netbootcd/boot/ipxe.krn ];then
				cp "${MNT}"/netbootcd/boot/ipxe.krn "${WORK}"/boot/nbcd/
			fi
			VERSION="$(cat netbootcd.version)"
		fi
		cat "${MNT}"/netbootcd/boot/isolinux/isolinux.cfg | grep -A 1000 "LABEL nbcd" | grep -B 1000 "LABEL grub4dos" | sed -e 's/LABEL grub4dos//g' | sed -e 's^/boot/^/boot/nbcd/^g' | sed -e 's/$NBCDVER/6.1/g' | sed -e '/menu default/d' > "${WORK}"/boot/nbcd/include.cfg
		sleep 1;umcdmount netbootcd
	fi
elif [ $1 = writecfg ];then
	if [ -f netbootcd.iso ];then
		echo "INCLUDE /boot/nbcd/include.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
