#!/bin/sh
set -e
#Macpup plugin for multicd.sh
#version 5.7
#Copyright (c) 2010 maybeway36
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
	if [ -f macpup.iso ];then
		echo "Macpup"
		touch $TAGS/puppies/macpup
	fi
elif [ $1 = copy ];then
	if [ -f macpup.iso ];then
		echo "Copying Macpup..."
		if [ ! -d macpup ];then
			mkdir macpup
		fi
		if grep -q "`pwd`/macpup" /etc/mtab ; then
			umount macpup
		fi
		mount -o loop macpup.iso macpup/
		#The installer will only work if Macpup is in the root dir of the disc
		if [ ! -f tags/puppies/macpup.inroot ];then
			mkdir multicd-working/macpup
			cp macpup/*.sfs multicd-working/macpup/
			cp macpup/vmlinuz multicd-working/macpup/vmlinuz
			cp macpup/initrd.gz multicd-working/macpup/initrd.gz
		else
			cp macpup/*.sfs multicd-working/
			cp macpup/vmlinuz multicd-working/vmlinuz
			cp macpup/initrd.gz multicd-working/initrd.gz
		fi
		umount macpup
		rmdir macpup
	fi
elif [ $1 = writecfg ];then
#BEGIN PUPPY ENTRY#
if [ -f macpup.iso ];then
if [ -d multicd-working/macpup ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label macpup
menu label ^Macpup
kernel /macpup/vmlinuz
append initrd=/macpup/initrd.gz pmedia=cd pdir=macpup
#label macpup-nox
#menu label Macpup (boot to command line)
#kernel /macpup/vmlinuz
#append initrd=/macpup/initrd.gz pmedia=cd pfix=nox pdir=macpup
#label macpup-noram
#menu label Macpup (don't load to RAM)
#kernel /macpup/vmlinuz
#append initrd=/macpup/initrd.gz pmedia=cd pfix=noram pdir=macpup
EOF
else
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label macpup
menu label ^Macpup
kernel /vmlinuz
append initrd=/initrd.gz pmedia=cd
#label macpup-nox
#menu label Macpup (boot to command line)
#kernel /vmlinuz
#append initrd=/initrd.gz pmedia=cd pfix=nox
#label macpup-noram
#menu label Macpup (don't load to RAM)
#kernel /vmlinuz
#append initrd=/initrd.gz pmedia=cd pfix=noram
EOF
fi
fi
#END PUPPY ENTRY#
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
