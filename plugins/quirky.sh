#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Quirky plugin for multicd.sh
#version 20150816
#Copyright (c) 2015 Isaac Schemm
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
quirkyExists () {
	if [ "*.quirky.iso" != "$(echo *.quirky.iso)" ];then
		echo true
	else
		echo false
	fi
}

getQuirkyName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		QRKNAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		QRKNAME="$(cat $BASENAME.defaultname)"
	else
		QRKNAME="$(echo $BASENAME|sed -e 's/\.quirky//g')"
	fi
	#return
	echo ${QRKNAME}
}
#END FUNCTIONS#

puppyExists () {
	if [ "*.quirky.iso" != "$(echo *.quirky.iso)" ];then
		echo true
	else
		echo false
	fi
}

if [ $1 = links ];then
	echo "april-*.iso april.quirky.iso Quirky_*"
elif [ $1 = scan ];then
	if $(quirkyExists);then
		for i in *.debian.iso; do
			getQuirkyName
			echo > "${TAGS}"/$(echo $i|sed -e 's/\.iso/\.needsname/g') #Comment out this line and multicd.sh won't ask for a custom name for this ISO
		done
	fi
elif [ $1 = copy ];then
	if $(quirkyExists);then
		for i in *.quirky.iso; do
			echo "Copying $(getQuirkyName)..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			mkdir "${WORK}"/boot/$BASENAME
			mcdcp "${MNT}"/$BASENAME/vmlinuz "${WORK}"/boot/$BASENAME
			mcdcp "${MNT}"/$BASENAME/init* "${WORK}"/boot/$BASENAME
			mcdcp "${MNT}"/$BASENAME/isolinux.cfg "${WORK}"/boot/$BASENAME/isolinux.cfg
			mcdcp "${MNT}"/$BASENAME/*.msg "${WORK}"/boot/$BASENAME
			umcdmount $BASENAME
		done
	fi
elif [ $1 = writecfg ];then
	if $(quirkyExists);then
		for i in *.quirky.iso; do
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			QRKNAME=$(getQuirkyName)

			echo "label $BASENAME
			menu label >> ^$QRKNAME
			config /boot/$BASENAME/isolinux.cfg /boot/$BASENAME" >> "${WORK}"/boot/isolinux/isolinux.cfg

			echo "label back
			menu label Back to main menu
			config /boot/isolinux/isolinux.cfg /boot/isolinux/
			" >> "${WORK}"/boot/isolinux/$BASENAME.cfg
		done
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
