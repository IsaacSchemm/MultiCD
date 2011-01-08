#!/bin/sh
set -e
. ./functions.sh
#Debian Live plugin for multicd.sh
#version 6.0
#Copyright (c) 2010 libertyernie
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
	if [ -f binary.iso ];then
		echo "DoudouLinux"
	fi
elif [ $1 = copy ];then
	if [ -f binary.iso ];then
		echo "Copying DoudouLinux..."
		mcdmount doudoulinux
		cp -r $MNT/binary/live $WORK/ #Copy live folder - usually all that is needed
		if [ -d dlive/install ];then
			cp -r $MNT/binary/install $WORK/ #Doesn't hurt to check
		fi
		umcdmount binary
		rm $WORK/live/memtest||true
	fi
elif [ $1 = writecfg ];then
	if [ -f binary.iso ];then
		if [ -f doudoulinux.version ] && [ "$(cat doudoulinux.version)" != "" ];then
			DOUDOUVER=" $(cat doudoulinux.version)"
		else
			DOUDOUVER=""
		fi
		SUPPORTEDLANGUAGES="ar en es fr ro ru sr sr@latin uk de it nl pl pt tr vi"
		if [ -f $TAGS/lang ];then
			LANG=$(cat $TAGS/lang)
		else
			LANG=en #Just in case it can't be found, default to en
			for i in $SUPPORTEDLANGUAGES;do
				if echo $DOUDOUVER|grep -q $i;then
					LANG=$i
				fi
			done
		fi
		if [ $LANG = fr ];then #Actually determines the args to use for each language. Only fr and en are in here right now.
			LOCALE_ARGS="locale=fr_FR.UTF-8 keyb=fr klayout=fr kvariant=oss koptions=lv3:ralt_switch,compose:menu"
		else
			LOCALE_ARGS="locale=en_US.UTF-8 keyb=us klayout=us"
		fi
		echo "label live
		menu label Start DoudouLinux
		kernel /live/vmlinuz
		append initrd=/live/initrd.img boot=live $LOCALE_ARGS notimezone noxautologin persistent persistent-subtext=doudoulinux live-media=removable edd=off username=tux hostname=doudoulinux union=aufs 

		label livefailsafe
		menu label Start DoudouLinux without persistence
		kernel /live/vmlinuz
		append initrd=/live/initrd.img boot=live $LOCALE_ARGS notimezone noxautologin username=tux hostname=doudoulinux union=aufs" >> $WORK/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
