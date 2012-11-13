#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Ubuntu plugin for multicd.sh
#version 20121113
#Copyright (c) 2012 Isaac Schemm
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

#START FUNCTIONS#
ubuntuExists () {
	if [ "*.ubuntu.iso" != "$(echo *.ubuntu.iso)" ];then
		echo true
	else
		echo false
	fi
}

getUbuntuName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get version
	if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
		VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
	else
		VERSION=""
	fi
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		UBUNAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		UBUNAME="$(cat $BASENAME.defaultname)"
	else
		UBUNAME="$(echo $BASENAME|sed -e 's/\.ubuntu//g') ${VERSION}"
	fi
	#return
	echo ${UBUNAME}
}
#END FUNCTIONS#

if [ $1 = links ];then
	echo "ubuntu-*-desktop-i386.iso i386.ubuntu.iso Ubuntu_(32-bit)_*"
	echo "ubuntu-*-desktop-amd64.iso amd64.ubuntu.iso Ubuntu_(64-bit)_*"
	echo "kubuntu-*-desktop-i386.iso i386.k.ubuntu.iso Kubuntu_(32-bit)_*"
	echo "kubuntu-*-desktop-amd64.iso amd64.k.ubuntu.iso Kubuntu_(64-bit)_*"
	echo "xubuntu-*-desktop-i386.iso i386.x.ubuntu.iso Xubuntu_(32-bit)_*"
	echo "xubuntu-*-desktop-amd64.iso amd64.x.ubuntu.iso Xubuntu_(64-bit)_*"
	echo "edubuntu-*-dvd-i386.iso i386.x.ubuntu.iso Edubuntu_(32-bit)_*"
	echo "edubuntu-*-dvd-amd64.iso amd64.x.ubuntu.iso Edubuntu_(64-bit)_*"
	echo "lubuntu-*-desktop-i386.iso i386.l.ubuntu.iso Lubuntu_(32-bit)_*"
	echo "lubuntu-*-desktop-amd64.iso amd64.l.ubuntu.iso Lubuntu_(64-bit)_*"
elif [ $1 = scan ];then
	if $(ubuntuExists);then
		for i in *.ubuntu.iso; do
			getUbuntuName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		done
	fi
elif [ $1 = copy ];then
	if $(ubuntuExists);then
		for i in *.ubuntu.iso; do
			echo "Copying $(getUbuntuName)..."
			ubuntucommon $(echo $i|sed -e 's/\.iso//g')
		done
	fi
elif [ $1 = writecfg ];then
	if $(ubuntuExists);then
		for i in *.ubuntu.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			UBUNAME=$(getUbuntuName)

			echo "label $BASENAME
			menu label --> $UBUNAME Menu
			com32 menu.c32
			append /boot/$BASENAME/$BASENAME.cfg
			" >> "${WORK}"/boot/isolinux/isolinux.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
