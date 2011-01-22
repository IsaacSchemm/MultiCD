#!/bin/sh
set -e
. ./functions.sh
#GRML plugin for multicd.sh
#version 6.3
#Copyright (c) 2010 libertyernie
#modified quick and dirty by T.Ma.X. N060d9 to work with grml
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
	echo "grml_*.iso grml.iso none"
elif [ $1 = scan ];then
	if [ -f grml.iso ];then
		echo "GRML"
	fi
elif [ $1 = copy ];then
	if [ -f grml.iso ];then
		echo "Copying GRML..."
		mcdmount grml
		mkdir $WORK/live
		mkdir $WORK/conf
		mkdir $WORK/boot/grml
		cp -r $MNT/grml/live/* $WORK/live #Compressed filesystem.
		cp $MNT/grml/boot/grml/linux26 $WORK/boot/grml/ #Kernel. See above.
		cp $MNT/grml/boot/grml/initrd.gz $WORK/boot/grml/initrd.gz #Initial ramdisk. See above.
		cp $MNT/grml/GRML/grml-version $WORK/boot/grml/grml-version
		cp $MNT/grml/conf/bootid.txt $WORK/conf/ #needed for booting
#getting  files into one and with write access:
		cp $MNT/grml/boot/isolinux/default.cfg $WORK/boot/grml/grml.cfg #isolinux menufile
		cat $MNT/grml/boot/isolinux/grml.cfg >> $WORK/boot/grml/grml.cfg #isolinux menufile
		umcdmount grml
	fi
elif [ $1 = writecfg ];then
if [ -f grml.iso ];then
VERSION=$(awk '{print substr($2,1,7)}' $WORK/boot/grml/grml-version) #Getting grml Version
echo "menu begin --> GRML $VERSION
" >> $WORK/boot/isolinux/isolinux.cfg

sed -i".bak" '1d' $WORK/boot/grml/grml.cfg #deleting some lines we don't want
sed -i".bak" '2d' $WORK/boot/grml/grml.cfg 
sed -i".bak" '/menu end/ i\label back\n   menu label Back to main menu...\n   com32 menu.c32\n'  $WORK/boot/grml/grml.cfg #insert back to main menu
rm $WORK/boot/grml/grml.cfg.bak #bak file from sed not needed

cat $WORK/boot/grml/grml.cfg >>  $WORK/boot/isolinux/isolinux.cfg #putting everything together

rm $WORK/boot/grml/grml.cfg #not needed any longer

fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
