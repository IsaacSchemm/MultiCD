#!/bin/sh
set -e
#BackTrack plugin for multicd.sh (designed for BackTrack 4)
#version 5.0
#Copyright (c) 2009 maybeway36
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
		if [ -f ubuntu.iso ] || [ -f linuxmint.iso ];then
			echo "Backtrack uses casper, so it can't be used with Ubuntu or Linux Mint right now. This feature will probably be added later."
		else
			echo "BackTrack"
		fi
	fi
elif [ $1 = copy ];then
	if [ -f backtrack.iso ] && [ ! -f ubuntu.iso ] && [ ! -f linuxmint.iso ];then
		echo "Copying BackTrack..."
		if [ ! -d backtrack ];then
			mkdir backtrack
		fi
		if grep -q "`pwd`/backtrack" /etc/mtab ; then
			umount backtrack
		fi
		mount -o loop backtrack.iso backtrack/
		cp -R backtrack/casper multicd-working/
		mkdir multicd-working/boot/backtrack
		cp backtrack/boot/vmlinuz multicd-working/boot/backtrack/
		cp backtrack/boot/initrd* multicd-working/boot/backtrack/
		umount backtrack
		rmdir backtrack
	fi
elif [ $1 = writecfg ];then
if [ -f backtrack.iso ] && [ ! -f ubuntu.iso ] && [ ! -f linuxmint.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label			backtrack1024
menu label		Start ^BackTrack FrameBuffer (1024x768)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw quiet vga=0x317
initrd			/boot/backtrack/initrd.gz

label			backtrack800
menu label		Start BackTrack FrameBuffer (800x600)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw quiet vga=0x314
initrd			/boot/backtrack/initrd800.gz

label			backtrack-forensics
menu label		Start BackTrack Forensics (no swap)
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent rw vga=0x317
initrd			/boot/backtrack/initrdfr.gz

label			backtrack-safe
menu label 		Start BackTrack in Safe Graphical Mode
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper xforcevesa rw quiet 
initrd			/boot/backtrack/initrd.gz

label			backtrack-persistent
menu label		Start Persistent Backtrack Live CD
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper persistent rw quiet 
initrd			/boot/backtrack/initrd.gz

label			backtrack-text
menu label		Start BackTrack in Text Mode
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper nopersistent textonly rw quiet
initrd			/boot/backtrack/initrd.gz

label			backtrack-ram
menu label		Start BackTrack Graphical Mode from RAM
kernel			/boot/backtrack/vmlinuz
append			BOOT=casper boot=casper toram nopersistent rw quiet 
initrd			/boot/backtrack/initrd.gz
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
