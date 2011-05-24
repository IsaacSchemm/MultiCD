#!/bin/sh
set -e
. ./functions.sh
#GRML64 plugin for multicd.sh
#version 6.6
#Copyright (c) 2011 Isaac Schemm, T.Ma.X. N060d9
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
	echo "grml64_*.iso grml64.iso none"
elif [ $1 = scan ];then
	if [ -f grml64.iso ];then
		echo "GRML64"
	fi
elif [ $1 = copy ];then
	if [ -f grml64.iso ];then
		echo "Copying GRML64..."
		mcdmount grml64
		mkdir $WORK/grml64
		#mkdir $WORK/conf
		mkdir $WORK/boot/grml64
		cp -r $MNT/grml64/live/* $WORK/grml64 #Compressed filesystem.
		cp $MNT/grml64/boot/grml64/linux26 $WORK/boot/grml64/ #Kernel. See above.
		cp $MNT/grml64/boot/grml64/initrd.gz $WORK/boot/grml64/initrd.gz #Initial ramdisk. See above.
		cp $MNT/grml64/GRML/grml-version $WORK/boot/grml64/grml-version
		#cp $MNT/grml64/conf/bootid.txt $WORK/conf/ #not needed for booting with ignore_bootid
#getting  files into one and with write access:
		cp $MNT/grml64/boot/isolinux/default.cfg $WORK/boot/grml64/grml.cfg #isolinux menufile - temporary
		cat $MNT/grml64/boot/isolinux/grml.cfg >> $WORK/boot/grml64/grml.cfg #adding to menufile
		umcdmount grml64
	fi
elif [ $1 = writecfg ];then
if [ -f grml64.iso ];then
	VERSION=$(awk '{print substr($2,1,7)}' $WORK/boot/grml64/grml-version) #Getting grml Version
	echo "menu begin --> GRML64 $VERSION
	" >> $WORK/boot/isolinux/isolinux.cfg

	sed -i".bak" '1d' $WORK/boot/grml64/grml.cfg #deleting some lines we don't want
	sed -i".bak" '2d' $WORK/boot/grml64/grml.cfg
	sed -i".bak" '/menu end/ i\label back\n   menu label Back to main menu...\n   com32 menu.c32\n'  $WORK/boot/grml64/grml.cfg #insert back to main menu

	sed -i -e 's^boot=live^boot=live live-media-path=/grml ignore_bootid^g' $WORK/boot/grml64/grml.cfg

	if [ -f $WORK/boot/grml64/grml.cfg.bak ];then
		rm $WORK/boot/grml64/grml.cfg.bak #bak file from sed not needed
	fi

	cat $WORK/boot/grml64/grml.cfg >> $WORK/boot/isolinux/isolinux.cfg #putting everything together

	rm $WORK/boot/grml64/grml.cfg #not needed any longer
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
