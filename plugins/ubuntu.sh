#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Ubuntu plugin for multicd.sh
#version 20170609
#Copyright (c) 2012-2017 Isaac Schemm et al
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
	for i in *ubuntu*.iso; do
		# stheno - This processes the iso name into usable chunks for other purposes.
		# This is key in the start for allowing multiple Ubuntu desktop flavors.
		BASENAME=$(echo $i|sed -e 's/\.iso//g')
		TYPETEMP=`echo $BASENAME | sed 's/ubuntu.*//g'`
		VERSIONPRE=`echo $BASENAME | sed 's/.*ubuntu-//g'`
		VERSIONPOST=`echo $VERSIONPRE | sed 's/-.*//g'`
		ARCHPRE=`echo $BASENAME | sed "s/.*ubuntu-"${VERSIONPOST}"-//g"`
		ARCHPOST=`echo $ARCHPRE | sed 's/.*-//g'`
		PLATPRE=`echo $BASENAME | sed "s/.*ubuntu-"${VERSIONPOST}"-//g"`
		PLATPOST=`echo $PLATPRE | sed 's/-.*//g'`
		if [ "${TYPETEMP}" ];then
			TYPE="${TYPETEMP}."
			TYPELABEL=$(echo $TYPETEMP | sed 's/./\U&/')u
		else
			TYPE=""
			TYPELABEL="U"
		fi
		if [ "${ARCHPOST}" = "i386" ];then
			ARCHLABEL="(32-bit)"
		elif [ "${ARCHPOST}" = "amd64" ];then
			ARCHLABEL="(64-bit)"
		else
			ARCHLABEL=""
		fi
		# stheno - writes temp file to parse new menu title.
		case "$BASENAME" in
			*desktop*)
				if [ ! "${PLATPOST}" = "server" ];then
					echo "${TYPELABEL}buntu_${VERSIONPOST}_${PLATPOST}_${ARCHLABEL}" > "${VERSIONPOST}.${ARCHPOST}.${PLATPOST}.${TYPE}ubuntu.title"
					# stheno - This covers ALL links available on discovered files.
					# No need to write entries that do not exist and be bound to only them.
					# This facilitates multiple iso files of similar flavor but different versions or arch.
					echo "${TYPETEMP}ubuntu-${VERSIONPOST}-${PLATPOST}-${ARCHPOST}.iso ${VERSIONPOST}.${ARCHPOST}.${PLATPOST}.${TYPE}ubuntu.iso ${TYPELABEL}buntu_${VERSIONPOST}_${PLATPOST}_${ARCHLABEL}"
				fi
			;;

			*server*)
			;;
		esac
	done

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
				# stheno - Look for what types of Ubuntu installer iso we have.
				# Then build accordingly, final stage in allowing multiple flavors.
				case "$BASENAME" in
					*desktop*)
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
						
						MENUTITLETEMP=`cat $BASENAME.title`
						MENUTITLE=$(echo "$MENUTITLETEMP" | sed 's/_/ /g')
						
						CFGFILE=`cat "${WORK}""/boot/$BASENAME/$BASENAME".cfg`

						EDITS=$(echo "$CFGFILE" | \
							sed '/default live/a menu title '"$MENUTITLE" | \
							sed 's/default live/default menu.c32/g' | \
							sed 's/\/casper\//\/boot\/'"$BASENAME"'\//g' | \
							sed 's/\/cdrom\//\/boot\/'"$BASENAME"'\//g' | \
							sed 's/casper initrd/casper live-media-path=\/boot\/'"$BASENAME"' ignore_uuid initrd/g' | \
							sed 's/ubiquity initrd/ubiquity live-media-path=\/boot\/'"$BASENAME"' ignore_uuid initrd/g' | \
							sed 's/check initrd/check live-media-path=\/boot\/'"$BASENAME"' ignore_uuid initrd/g' | \
							sed 's/\/install\//\/boot\/'"$BASENAME"'\//g' | \
							sed '$ a label back' | \
							sed '$ a menu label Back to main menu' | \
							sed '$ a com32 menu.c32' | \
							sed 's/menu title/    menu title/g' | \
							sed 's/menu label/  menu label/g' | \
							sed 's/kernel /  kernel /g' | \
							sed 's/KERNEL /  KERNEL /g' | \
							sed 's/localboot/  localboot/g' | \
							sed 's/append  /  append /g' | \
							sed '$ a append /boot/isolinux/isolinux.cfg' | \
							sed 's/append \/boot/    append \/boot/g' | \
							sed 's/menu label Back/  menu label Back/g' | \
							sed 's/com32 menu.c32/    com32 menu.c32/g'
						)
						echo "$EDITS" > "${WORK}"/boot/$BASENAME/$BASENAME.cfg

						if [ -f "${TAGS}"/lang ];then
							echo added lang
							sed -i "s^initrd=/boot/$BASENAME/^debian-installer/language=$(cat "${TAGS}"/lang) initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Add language codes to cmdline
						fi
						if [ -f "${TAGS}"/country ];then
							echo added country
							sed -i "s^initrd=/boot/$BASENAME/^console-setup/layoutcode?=$(cat "${TAGS}"/country) initrd=/boot/$BASENAME/^g" "${WORK}"/boot/$BASENAME/$BASENAME.cfg #Add language codes to cmdline
						fi
						
						umcdmount $BASENAME
					;;

					*server*)
					;;
				esac
			else
				echo "$0: \"$BASENAME\" is empty or not an ISO"
				exit 1
			fi
			rm $BASENAME.title
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
