#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Clonezilla plugin for multicd.sh
#version 20151111
#Copyright (c) 2010-2015 Isaac Schemm and others
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

getName () {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	#get name
	if [ -f "${TAGS}"/$BASENAME.name ] && [ "$(cat "${TAGS}"/$BASENAME.name)" != "" ];then
		NAME=$(cat "${TAGS}"/$BASENAME.name)
	elif [ -f $BASENAME.defaultname ] && [ "$(cat $BASENAME.defaultname)" != "" ];then
		NAME="$(cat $BASENAME.defaultname)"
	else
		NAME="Clonezilla"
	fi
	#return
	echo ${NAME}
}

if [ $1 = links ];then
	echo "clonezilla.iso auto.clonezilla.iso none"
	echo "clonezilla-live-*.iso auto.clonezilla.iso Clonezilla_*"
elif [ $1 = scan ];then
	for i in *.clonezilla.iso; do
		if [ -f $i ];then
			getName
		fi
	done
elif [ $1 = copy ];then
	for i in *.clonezilla.iso; do
		if [ -f $i ];then
			echo "Copying Clonezilla ($i)..."
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			mcdmount $BASENAME
			cp "${MNT}"/$BASENAME/*linux/ocswp.png "${WORK}"/boot/isolinux/ocswp.png || true #Boot menu logo
			cp -r "${MNT}"/$BASENAME/live "${WORK}"/boot/$BASENAME #Another Debian Live-based ISO
			cp "${MNT}"/$BASENAME/Clonezilla-Live-Version "${WORK}"/boot/$BASENAME #PDV Clonezilla-Live-Version file
			cp "${MNT}"/$BASENAME/GPL "${WORK}"/boot/$BASENAME #PDV GPL file
			cp "${MNT}"/$BASENAME/*linux/isolinux.cfg "${WORK}"/boot/isolinux/cz-$BASENAME.cfg #PDV
			umcdmount $BASENAME
		fi
	done
elif [ $1 = writecfg ];then
	for i in *.clonezilla.iso; do
		if [ -f $i ];then
			BASENAME=$(echo $i|sed -e 's/\.iso//g')
			echo "menu begin >> $(getName)" >> "${WORK}"/boot/isolinux/isolinux.cfg
			#sed -i -e "s/^ *MENU LABEL/  MENU LABEL ($BASENAME)/g" "${WORK}"/boot/isolinux/cz-$BASENAME.cfg
			sed -i -e 's/\/live\//\/boot\/'$BASENAME'\//g' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg #Change directory to /boot/clonezilla
			sed -i -e 's/append initrd=/append live-media-path=\/boot\/'$BASENAME' initrd=/g' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg #Tell the kernel we moved it
			if [ -f "${TAGS}"/country ]; then #PDV
				sed -i -e 's/keyboard-layouts=/keyboard-layouts="'$(cat "${TAGS}"/country)'"/' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg #set keymap
			fi
			if [ -f "${TAGS}"/lang-full ]; then #PDV
				sed -i -e 's/locales=/locales="'$(cat "${TAGS}"/lang-full)'.UTF-8"/' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg #menu language
			fi
			ls "${WORK}"/boot/isolinux/cz-$BASENAME.cfg
			if $MEMTEST; then #PDV remove memtest if already in main menu
				sed -i -e '/MENU BEGIN Memtest/,/MENU END/ s/MENU END//' -e '/MENU BEGIN Memtest/,/ENDTEXT/d' -e '/./,/^$/!d' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg
				rm "${WORK}"/boot/$BASENAME/memtest
			fi
			ls "${WORK}"/boot/isolinux/cz-$BASENAME.cfg
			sed -n '/label .*/,$p' "${WORK}"/boot/isolinux/cz-$BASENAME.cfg >> "${WORK}"/boot/isolinux/isolinux.cfg
			rm "${WORK}"/boot/isolinux/cz-$BASENAME.cfg
			echo "
			MENU END" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	done
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
