#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Linux Mint plugin for multicd.sh
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

#START FUNCTIONS#
linuxmintExists () {
	if [ "*.linuxmint.iso" != "$(echo *.linuxmint.iso)" ];then
		echo true
	else
		echo false
	fi
}

getLinuxmintName () {
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
		UBUNAME="$(cat $BASENAME.defaultname) ${VERSION}"
	else
		UBUNAME="$(echo $BASENAME|sed -e 's/\.ubuntu//g') ${VERSION}"
	fi
	#return
	echo ${UBUNAME}
}
#END FUNCTIONS#

if [ $1 = links ];then
	echo "linuxmint-*.iso mint.linuxmint.iso Linux_Mint"
elif [ $1 = scan ];then
	if $(linuxmintExists);then
		for i in *.linuxmint.iso; do
			getLinuxmintName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		done
	fi
elif [ $1 = copy ];then
	if $(linuxmintExists);then
		for i in *.linuxmint.iso; do
			echo "Copying $(getLinuxmintName)..."
			ubuntucommon $(echo $i|sed -e 's/\.iso//g')
		done
	fi
elif [ $1 = writecfg ];then
	if $(linuxmintExists);then
		for i in *.linuxmint.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			UBUNAME=$(getLinuxmintName)

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
