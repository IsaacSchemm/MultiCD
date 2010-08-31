#!/bin/sh
set -e
#Puppy Linux plugin for multicd.sh
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
	if [ -f puppy.iso ];then
		echo "Puppy Linux"
		touch tags/puppies/puppy
	fi
elif [ $1 = copy ];then
	if [ -f puppy.iso ];then
		echo "Copying Puppy..."
		if [ ! -d puppy ];then
			mkdir puppy
		fi
		if grep -q "`pwd`/puppy" /etc/mtab ; then
			umount puppy
		fi
		mount -o loop puppy.iso puppy/
		#The installer will only work if Puppy is in the root dir of the disc
		if [ ! -f tags/puppies/puppy.inroot ];then
			mkdir multicd-working/puppy
			cp puppy/*.sfs multicd-working/puppy/
			cp puppy/vmlinuz multicd-working/puppy/vmlinuz
			cp puppy/initrd.gz multicd-working/puppy/initrd.gz
		else
			cp puppy/*.sfs multicd-working/
			cp puppy/vmlinuz multicd-working/vmlinuz
			cp puppy/initrd.gz multicd-working/initrd.gz
		fi
		umount puppy
		rmdir puppy
	fi
elif [ $1 = writecfg ];then
#BEGIN PUPPY ENTRY#
if [ -f puppy.iso ];then
if [ -d multicd-working/puppy ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label puppy
menu label ^Puppy Linux
kernel /puppy/vmlinuz
append initrd=/puppy/initrd.gz pmedia=cd pdir=puppy
#label puppy-nox
#menu label Puppy Linux (boot to command line)
#kernel /puppy/vmlinuz
#append initrd=/puppy/initrd.gz pmedia=cd pfix=nox pdir=puppy
#label puppy-noram
#menu label Puppy Linux (don't load to RAM)
#kernel /puppy/vmlinuz
#append initrd=/puppy/initrd.gz pmedia=cd pfix=noram pdir=puppy
EOF
else
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label puppy
menu label ^Puppy Linux
kernel /vmlinuz
append initrd=/initrd.gz pmedia=cd
#label puppy-nox
#menu label Puppy Linux (boot to command line)
#kernel /vmlinuz
#append initrd=/initrd.gz pmedia=cd pfix=nox
#label puppy-noram
#menu label Puppy Linux (don't load to RAM)
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
