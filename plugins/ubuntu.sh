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
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			if [ ! -z "$BASENAME" ] && [ -f $BASENAME.iso ];then
				mcdmount $BASENAME
				mkdir -p "${WORK}"/boot/$BASENAME
				if [ -d "${MNT}"/$BASENAME/casper ];then
					mcdcp -R "${MNT}"/$BASENAME/casper/* "${WORK}"/boot/$BASENAME/ #Live system
				#elif [ -d "${MNT}/$BASENAME/live" ];then
				#	mcdcp -R "${MNT}"/$BASENAME/live/* "${WORK}"/boot/$BASENAME/ #Debian live (for Linux Mint Debian)
				else
					echo "Could not find a \"casper\" folder in "${MNT}"/$BASENAME."
					return 1
				fi
				if [ -d "${MNT}"/$BASENAME/preseed ];then
					cp -R "${MNT}"/$BASENAME/preseed "${WORK}"/boot/$BASENAME
				fi
				# Fix the isolinux.cfg
				if [ -f "${MNT}"/$BASENAME/isolinux/text.cfg ];then
					UBUCFG=text.cfg
				elif [ -f "${MNT}"/$BASENAME/isolinux/txt.cfg ];then
					UBUCFG=txt.cfg
				else
					UBUCFG=isolinux.cfg #For custom-made live CDs like Weaknet and Zorin
				fi
				cp "${MNT}"/$BASENAME/isolinux/splash.* \
				"${MNT}"/$BASENAME/isolinux/bg_redo.png \
				"${WORK}"/boot/$BASENAME/ 2> /dev/null || true #Splash screen - only if the filename is splash.something or bg_redo.png
				cp "${MNT}"/$BASENAME/isolinux/$UBUCFG "${WORK}"/boot/$BASENAME/$BASENAME.cfg
				echo "label back
				menu label Back to main menu
				com32 menu.c32
				append /boot/isolinux/isolinux.cfg
				" >> "${WORK}"/boot/$BASENAME/$BASENAME.cfg
				cp "${WORK}"/boot/$BASENAME/$BASENAME.cfg a.cfg
				sed -i "s@menu background @menu background /boot/$BASENAME/@g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #If it uses a splash screen, update the .cfg to show the new location
				sed -i "s@MENU BACKGROUND @MENU BACKGROUND /boot/$BASENAME/@g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #uppercase
				sed -i "s@default live@default menu.c32@g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Show menu instead of boot: prompt
				sed -i "s@file=/cdrom/preseed/@file=/cdrom/boot/$BASENAME/preseed/@g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Preseed folder moved - not sure if ubiquity uses this

				#Remove reference to previous live media path
				sed -i "s^live-media-path=[^ ]*^^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg

				sed -i "s^initrd=/casper/^live-media-path=/boot/$BASENAME ignore_uuid initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Initrd moved, ignore_uuid added
				sed -i "s^kernel /casper/^kernel /boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Kernel moved
				sed -i "s^KERNEL /casper/^KERNEL /boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #For uppercase KERNEL

				#Equivalents for Mint Debian
				#sed -i "s^initrd=/live/^live-media-path=/boot/$BASENAME ignore_uuid initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg
				#sed -i "s^kernel /live/^kernel /boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg
				#sed -i "s^KERNEL /live/^KERNEL /boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg

				if [ -f "${TAGS}"/lang ];then
					echo added lang
					sed -i "s^initrd=/boot/$BASENAME/^debian-installer/language=$(cat "${TAGS}"/lang) initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Add language codes to cmdline
				fi
				if [ -f "${TAGS}"/country ];then
					echo added country
					sed -i "s^initrd=/boot/$BASENAME/^console-setup/layoutcode?=$(cat "${TAGS}"/country) initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Add language codes to cmdline
				fi
				cp "${WORK}"/boot/$BASENAME/$BASENAME.cfg b.cfg
				umcdmount $BASENAME
			else
				echo "$0: \"$BASENAME\" is empty or not an ISO"
				exit 1
			fi
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
