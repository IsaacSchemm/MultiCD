#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#NetbootCD 4.8+ plugin for multicd.sh
#version 7.1
#Copyright (c) 2011 Isaac Schemm
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
		cp "${MNT}"/netbootcd/boot/kexec.bzI "${WORK}"/boot/nbcd/kexec.bzI
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
			#	cd $(dirname "$i")
			#	VAR="$(md5sum $i)"
			#	cd -
			#	echo "$VAR" > $i.md5.txt
			#	echo > $i.dep
			done
			cp "${MNT}"/netbootcd/boot/core.gz "${WORK}"/boot/nbcd/
			echo "LABEL nbcd-tinycore
			menu label Start CorePlus 4.2.1 on top of NetbootCD 4.8
			kernel /boot/nbcd/kexec.bzI
			initrd /boot/nbcd/nbinit4.gz
			append quiet cde showapps
			text help
	Uses the initrd of NetbootCD with the TCZ extensions of
	CorePlus. The result is that CorePlus is loaded first,
	and NetbootCD is run when you choose \"Exit To Prompt\".
			endtext
			
			LABEL nbcd
			menu label Start ^NetbootCD 4.8
			kernel /boot/nbcd/kexec.bzI
			initrd /boot/nbcd/nbinit4.gz
			append quiet showapps
			
			LABEL core-kexec
			menu label Start ^Core 4.2.1
			kernel /boot/nbcd/kexec.bzI
			initrd /boot/nbcd/core.gz
			append quiet showapps
			
			LABEL tinycore-kexec
			menu label Start Core^Plus 4.2.1 (with desktop)
			kernel /boot/nbcd/kexec.bzI
			initrd /boot/nbcd/core.gz
			append quiet cde showapps" > "${WORK}"/boot/nbcd/include.cfg
		else
			echo "LABEL nbcd
			menu label Start ^NetbootCD 4.8
			kernel /boot/nbcd/kexec.bzI
			initrd /boot/nbcd/nbinit4.gz
			append quiet showapps" > "${WORK}"/boot/nbcd/include.cfg
		fi
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
