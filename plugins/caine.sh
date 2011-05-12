#!/bin/bash
set -e
. ./functions.sh
#Caine plugin for multicd.sh
#version 6.6
#Copyright (c) 2011 libertyernie
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
	if [ -f caine.iso ];then
		echo "Caine [note: this is old; it doesn't work for new versions]"
	fi
elif [ $1 = copy ];then
	if [ -f caine.iso ];then
		echo "Copying Caine..."
		mcdmount caine
		cp -R $MNT/caine/casper $WORK/boot/caine #Live system
		cp $MNT/caine/README.diskdefines multicd-working/
		mkdir $WORK/CaineFiles
		cp -R $MNT/caine/{AutoPlay,autorun.exe,autorun.inf,comdlg32.ocx,files,license.txt,page5,preseed,Programs,RegOcx4Vista.bat,rw_common,tabctl32.ocx,vbrun60.exe,WinTaylor.exe} $WORK/CaineFiles
		umcdmount caine
		echo -n "Making initrd(s)..." #This initrd code is common to distros using old versions of casper
		WORKPATH="$(readlink -f "$WORK")"
		if [ -d $MNT/caine-inittmp ];then rm -r $MNT/caine-inittmp;fi
		mkdir $MNT/caine-inittmp
		cd $MNT/caine-inittmp
		gzip -cd $WORKPATH/boot/caine/initrd.gz | cpio -id
		perl -pi -e 's/path\/casper/path\/boot\/caine/g' scripts/casper
		perl -pi -e 's/directory\/casper/directory\/boot\/caine/g' scripts/casper
		find . | cpio --create --format='newc' | gzip -c > $WORKPATH/boot/caine/initrd.gz
		cd -
		rm -r $MNT/caine-inittmp
		echo " done."
	fi
elif [ $1 = writecfg ];then
	if [ -f $TAGS/lang ];then
		LANGCODE=$(cat $TAGS/lang)
	else
		LANGCODE=en
	fi
	if [ -f caine.iso ];then
		echo "label caine2
		kernel /boot/caine/vmlinuz
		initrd /boot/caine/initrd.gz
		append live-media-path=/boot/caine ignore_uuid noprompt persistent BOOT_IMAGE=/casper/vmlinuz file=/cdrom/CaineFiles/custom.seed boot=casper -- debian-installer/language=$LANGCODE console-setup/layoutcode=$(cat $TAGS/lang)
		" >> $WORK/boot/isolinux/isolinux.cfg
	fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
