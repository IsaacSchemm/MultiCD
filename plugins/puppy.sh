#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Puppy Linux plugin for multicd.sh
#version 6.9
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
	echo "lupu-*.iso puppy.iso none"
elif [ $1 = scan ];then
	if [ -f puppy.iso ];then
		echo "Puppy Linux"
		#touch "${TAGS}"/puppy.needsname #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		touch "${TAGS}"/puppies/puppy
		mkdir -p "${TAGS}"/puppies
	fi
elif [ $1 = copy ];then
	if [ -f puppy.iso ];then
		echo "Copying Puppy..."
		puppycommon puppy
	fi
elif [ $1 = writecfg ];then
#BEGIN PUPPY ENTRY#
if [ -f puppy.iso ];then
if [ -f "${TAGS}"/puppy.name ] && [ "$(cat "${TAGS}"/puppy.name)" != "" ];then
	PUPNAME=$(cat "${TAGS}"/puppy.name) #User-entered name
elif [ -f puppy.defaultname ] && [ "$(cat puppy.defaultname)" != "" ];then
	PUPNAME=$(cat puppy.defaultname) #Default name based on the automatic links made in isoaliases()
else
	PUPNAME="Puppy Linux" #Fallback name
fi
if [ -f puppy.version ] && [ "$(cat puppy.version)" != "" ];then
	PUPNAME="$PUPNAME $(cat puppy.version)" #Version based on isoaliases()
fi
if [ -d "${WORK}"/puppy ];then
	EXTRAARGS="psubdir=puppy"
	KERNELPATH="/puppy"
else
	EXTRAARGS=""
	KERNELPATH=""
fi
echo "label puppy
menu label ^$PUPNAME
kernel $KERNELPATH/vmlinuz
append pmedia=cd $EXTRAARGS
initrd $KERNELPATH/initrd.gz
#label puppy-nox
#menu label $PUPNAME (boot to command line)
#kernel $KERNELPATH/vmlinuz
#append pmedia=cd pfix=nox $EXTRAARGS
#initrd $KERNELPATH/initrd.gz
#label puppy-noram
#menu label $PUPNAME (don't load to RAM)
#kernel $KERNELPATH/vmlinuz
#append pmedia=cd pfix=noram $EXTRAARGS
#initrd $KERNELPATH/initrd.gz
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
#END PUPPY ENTRY#
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
