#!/bin/sh
set -e
. ./functions.sh
#Puppy Linux common functions for multicd.sh
#version 6.0
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
if [ $1 = scan ] || [ $1 = copy ] || [ $1 = writecfg ] || [ $1 = category ];then
	exit 0 #This is not a plugin itself
fi
if [ ! -z "$1" ] && [ -f $1.iso ];then
	mcdmount $1
	#The installer will only work if Puppy is in the root dir of the disc
	if [ -f $TAGS/puppies/$1.inroot ];then
		cp $MNT/$1/*.sfs $WORK/
		cp $MNT/$1/vmlinuz $WORK/vmlinuz
		cp $MNT/$1/initrd.gz $WORK/initrd.gz
	else
		mkdir $WORK/$1
		cp $MNT/$1/*.sfs $WORK/$1/
		cp $MNT/$1/vmlinuz $WORK/$1/vmlinuz
		cp $MNT/$1/initrd.gz $WORK/$1/initrd.gz
	fi
	umcdmount $1
else
	echo "$0: \"$1\" is empty or not an ISO"
	exit 1
fi
