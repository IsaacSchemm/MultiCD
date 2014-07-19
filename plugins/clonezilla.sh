#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Clonezilla plugin for multicd.sh
#version 20140707
#Copyright (c) 2010-2014 Isaac Schemm and others
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
if [ $1 = links ] && [ "$2" = "amd64" ];then
	echo "clonezilla-live-*-amd64.iso clonezillaamd64.iso none"
elif [ $1 = links ] && [ "$2" = "i686" ];then
	echo "clonezilla-live-*-i686-pae.iso clonezillai686.iso none"
elif [ $1 = links ] && [ "$2" = "i486" ];then
	echo "clonezilla-live-*-i486.iso clonezillai486.iso none"
elif [ $1 = scan ];then
	if [ -f clonezilla$2.iso ];then
		echo "Clonezilla $2"
	fi
elif [ $1 = copy ];then
	if [ -f clonezilla$2.iso ];then
		echo "Copying Clonezilla $2..."
		mcdmount clonezilla$2
		cp "${MNT}"/clonezilla$2/*linux/ocswp.png "${WORK}"/boot/isolinux/ocswp.png #Boot menu logo
		cp -r "${MNT}"/clonezilla$2/live "${WORK}"/boot/clonezilla$2 #Another Debian Live-based ISO
		cp "${MNT}"/clonezilla$2/C* "${WORK}"/boot/clonezilla$2 #PDV Clonezilla-Live-Version and COPYING files
		cp "${MNT}"/clonezilla$2/*linux/isolinux.cfg "${WORK}"/boot/isolinux/cz-$2.cfg #PDV
		umcdmount clonezilla$2
	fi
elif [ $1 = writecfg ];then
if [ -f clonezilla$2.iso ];then
VERSION=$(sed -e 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*-[0-9]*\).*$/\1/' "${WORK}"/boot/clonezilla$2/Clonezilla-Live-Version | head -n1)
if [ -z $2 ];then
	echo "menu begin >> ^Clonezilla Live $VERSION" >> "${WORK}"/boot/isolinux/isolinux.cfg
else
	echo "menu begin >> Clonezilla Live $VERSION for ^$2 CPU" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
#GNU sed syntax
sed -i -e "s/^ *MENU LABEL/  MENU LABEL ($2)/g" "${WORK}"/boot/isolinux/cz-$2.cfg
sed -i -e 's/\/live\//\/boot\/clonezilla'$2'\//g' "${WORK}"/boot/isolinux/cz-$2.cfg #Change directory to /boot/clonezilla
sed -i -e 's/append initrd=/append live-media-path=\/boot\/clonezilla'$2' initrd=/g' "${WORK}"/boot/isolinux/cz-$2.cfg #Tell the kernel we moved it
if [ -f "${TAGS}"/country ]; then #PDV
	if [ $(cat "${TAGS}"/country) = "be" ];then
		sed -i -e 's/ocs_live_keymap=""/ocs_live_keymap="\/usr\/share\/keymaps\/i386\/azerty\/be2-latin1.kmap.gz"/' "${WORK}"/boot/isolinux/cz-$2.cfg #set keymap
	fi
fi
if [ -f "${TAGS}"/lang-full ]; then #PDV
	sed -i -e 's/ocs_lang=""/ocs_lang="'$(cat "${TAGS}"/lang-full)'.UTF-8"/' "${WORK}"/boot/isolinux/cz-$2.cfg #menu language
fi
##sed -i -e 's/[[:blank:]]ip=frommedia[[:blank:]]/ /' "${WORK}"/boot/isolinux/clonezil$2.cfg #PDV get ip via dhcp
if $MEMTEST; then #PDV remove memtest if already in main menu
	sed -i -e '/MENU BEGIN Memtest/,/MENU END/ s/MENU END//' -e '/MENU BEGIN Memtest/,/ENDTEXT/d' -e '/./,/^$/!d' "${WORK}"/boot/isolinux/cz-$2.cfg
	rm "${WORK}"/boot/clonezilla$2/memtest
fi
sed -n '/label .*/,$p' "${WORK}"/boot/isolinux/cz-$2.cfg >> "${WORK}"/boot/isolinux/isolinux.cfg
rm "${WORK}"/boot/isolinux/cz-$2.cfg
echo "
MENU END" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
