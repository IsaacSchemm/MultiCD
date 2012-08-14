#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Debian Live plugin for multicd.sh
#version 20120813
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
debianExists () {
	if [ "*.debian.iso" != "$(echo *.debian.iso)" ];then
		echo true
	else
		echo false
	fi
}

getDebianName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get version
	if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
		VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
	else
		VERSION=""
	fi
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		DEBNAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		DEBNAME="$(cat $BASENAME.defaultname) ${VERSION}"
	else
		DEBNAME="$(echo $BASENAME|sed -e 's/\.debian//g') ${VERSION}"
	fi
	#return
	echo ${DEBNAME}
}
#END FUNCTIONS#

if [ $1 = links ];then
	echo "binary.iso binary.debian.iso none"
	echo "debian-live-*.iso debian-live.debian.iso Debian_Live:_*"
elif [ $1 = scan ];then
	if $(debianExists);then
		for i in *.debian.iso; do
			getDebianName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		done
	fi
elif [ $1 = copy ];then
	if $(debianExists);then
		for i in *.debian.iso; do
			echo "Copying $(getDebianName)..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			cp "${MNT}"/$BASENAME/isolinux/live.cfg "${WORK}"/boot/isolinux/$BASENAME.cfg
			cp -r "${MNT}"/$BASENAME/live "${WORK}"/$BASENAME #Copy live folder - usually all that is needed
			if [ -d "${MNT}"/$BASENAME/install ] && [ ! -d "${WORK}"/install ];then
				cp -r "${MNT}"/$BASENAME/install "${WORK}"/ #Doesn't hurt to check
			fi
			umcdmount $BASENAME
		done
		rm "${WORK}"/live/memtest||true
	fi
elif [ $1 = writecfg ];then
	if $(debianExists);then
		for i in *.debian.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			DEBNAME=$(getDebianName)

			echo "label $BASENAME
			menu label >> ^$DEBNAME
			com32 menu.c32
			append $BASENAME.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg

			cat "${WORK}"/boot/isolinux/$BASENAME.cfg | sed '/memtest/d' | sed '/Memory test/d' | \
			sed -e "s^/live/^/$BASENAME/^g" | \
			sed -e "s/boot=live/boot=live live-media-path=\/$BASENAME/g" > /tmp/$BASENAME.cfg
			mv /tmp/$BASENAME.cfg "${WORK}"/boot/isolinux/$BASENAME.cfg

			echo "label back
			menu label Back to main menu
			com32 menu.c32
			append /boot/isolinux/isolinux.cfg
			" >> "${WORK}"/boot/isolinux/$BASENAME.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
