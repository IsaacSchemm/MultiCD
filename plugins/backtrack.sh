#!/bin/sh
set -e
. ./functions.sh
#BackTrack plugin for multicd.sh (designed for BackTrack 4)
#version 5.7
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
if [ $1 = scan ];then
	if [ -f backtrack.iso ];then
		echo "BackTrack"
	fi
elif [ $1 = copy ];then
	if [ -f backtrack.iso ];then
		echo "Copying BackTrack..."
		mcdmount backtrack
		cp -R $MNT/backtrack/casper $WORK/boot/backtrack
		cp $MNT/backtrack/boot/vmlinuz $WORK/boot/backtrack/
		cp $MNT/backtrack/boot/initrd* $WORK/boot/backtrack/
		umcdmount backtrack
		echo -n "Making initrd(s)..." #This initrd code is common to distros using old versions of casper
		for i in initrd.gz initrd800.gz initrdfr.gz;do
			if [ -d $MNT/initrd-tmp-mount ];then rm -r $MNT/initrd-tmp-mount;fi
			mkdir $MNT/initrd-tmp-mount
			cd $MNT/initrd-tmp-mount
			gzip -cd $WORK/boot/backtrack/$i | cpio -id
			perl -pi -e 's/path\/casper/path\/boot\/backtrack/g' scripts/casper
			perl -pi -e 's/directory\/casper/directory\/boot\/backtrack/g' scripts/casper
			find . | cpio --create --format='newc' | gzip -c > $WORK/boot/backtrack/$i
			cd -
			rm -r $MNT/initrd-tmp-mount
		done
		echo " done."
	fi
elif [ $1 = writecfg ];then
if [ -f backtrack.iso ];then
cat >> $WORK/boot/isolinux/isolinux.cfg << "EOF"
label			backtrack1024
menu label		Start ^BackTrack FrameBuffer (1024x768)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw quiet vga=0x317 ignore_uuid
initrd			/boot/backtrack/initrd.gz

label			backtrack800
menu label		Start BackTrack FrameBuffer (800x600)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw quiet vga=0x314 ignore_uuid
initrd			/boot/backtrack/initrd800.gz

label			backtrack-forensics
menu label		Start BackTrack Forensics (no swap)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw vga=0x317 ignore_uuid
initrd			/boot/backtrack/initrdfr.gz

label			backtrack-safe
menu label 		Start BackTrack in Safe Graphical Mode
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper xforcevesa rw quiet ignore_uuid
initrd			/boot/backtrack/initrd.gz

label			backtrack-persistent
menu label		Start Persistent Backtrack Live CD
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper persistent rw quiet ignore_uuid
initrd			/boot/backtrack/initrd.gz

label			backtrack-text
menu label		Start BackTrack in Text Mode
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent textonly rw quiet ignore_uuid
initrd			/boot/backtrack/initrd.gz

label			backtrack-ram
menu label		Start BackTrack Graphical Mode from RAM
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper toram nopersistent rw quiet ignore_uuid
initrd			/boot/backtrack/initrd.gz
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
