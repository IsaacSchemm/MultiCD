#!/bin/sh
set -e
. ./functions.sh
#Ubuntu plugin for multicd.sh
#version 6.2
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

ubuname() {
#Function to define $BASENAME and $UBUNAME
BASENAME=$(echo $1|sed -e 's/\.iso//g')
if [ -f $TAGS/$BASENAME.name ] && [ "$(cat $TAGS/$BASENAME.name)" != "" ];then
	UBUNAME="$(cat $TAGS/$BASENAME.name)"
else
	UBUNAME=$(echo $1|sed -e 's/\.ubuntu\.iso//g') #No custom name found
fi
}

if [ $1 = links ];then
	echo "ubuntu-*-desktop-i386.iso i386.ubuntu.iso Ubuntu_(32-bit)"
	echo "ubuntu-*-desktop-amd64.iso amd64.ubuntu.iso Ubuntu_(64-bit)"
	echo "kubuntu-*-desktop-i386.iso i386.k.ubuntu.iso Kubuntu_(32-bit)"
	echo "kubuntu-*-desktop-amd64.iso amd64.k.ubuntu.iso Kubuntu_(64-bit)"
	echo "xubuntu-*-desktop-i386.iso i386.x.ubuntu.iso Xubuntu_(32-bit)"
	echo "xubuntu-*-desktop-amd64.iso amd64.x.ubuntu.iso Xubuntu_(64-bit)"
	echo "edubuntu-*-dvd-i386.iso i386.x.ubuntu.iso Edubuntu_(32-bit)"
	echo "edubuntu-*-dvd-amd64.iso amd64.x.ubuntu.iso Edubuntu_(64-bit)"
elif [ $1 = scan ];then
	if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do
		if [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
			cat $BASENAME.defaultname
		else
			echo $i
		fi
		echo > $TAGS/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
	done;fi
elif [ $1 = copy ];then
	if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do
		ubuname $i
		echo "Copying $UBUNAME..."
		ubuntucommon $(echo $i|sed -e 's/\.iso//g')
	done;fi
elif [ $1 = writecfg ];then
if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then for i in *.ubuntu.iso; do

ubuname $i

if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
	VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
else
	VERSION=""
fi

echo "label ubuntu
menu label --> $UBUNAME$VERSION Menu
com32 menu.c32
append /boot/$BASENAME/$BASENAME.cfg
" >> multicd-working/boot/isolinux/isolinux.cfg
echo "label back
menu label Back to main menu
com32 menu.c32
append /boot/isolinux/isolinux.cfg
" >> multicd-working/boot/$BASENAME/$BASENAME.cfg
done;fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
