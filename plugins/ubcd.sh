#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Ultimate Boot CD plugin for multicd.sh
#version 20131227
#Copyright (c) 2011-2013 Isaac Schemm
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
if [ $1 = links ];then
	echo "ubcd*.iso ubcd.iso none"
elif [ $1 = scan ];then
	if [ -f ubcd.iso ];then
		echo "Ultimate Boot CD"
	fi
	if [ -f dban.iso ] && [ -f ubcd.iso ];then
		echo "  Note: Ultimate Boot CD includes DBAN, so it is not necessary alone as well. Continuing anyway."
	fi
	if [ -f ntpasswd.iso ] && [ -f ubcd.iso ];then
		echo "  Note: UBCD includes ntpasswd, so it is not necessary alone as well. Continuing anyway."
	fi
	if [ -f pmagic.iso ] && [ -f ubcd.iso ];then
		echo "  Note: UBCD includes Parted Magic, so it is not necessary alone as well. Continuing anyway."
	fi
elif [ $1 = copy ];then
	set -e
	if [ -f ubcd.iso ];then
		echo "Copying Ultimate Boot CD..."
		mcdmount ubcd
		cp -r "${MNT}"/ubcd/ubcd "${WORK}"/
		cp -r "${MNT}"/ubcd/pmagic "${WORK}"/
		mv "${WORK}"/pmagic/boot/syslinux "${WORK}"/pmagic/boot/isolinux
		if [ -d "${MNT}"/ubcd/antivir ];then
			cp -r "${MNT}"/ubcd/antivir "${WORK}"/
		fi
		cp "${MNT}"/ubcd/license.txt "${WORK}"/ubcd-license.txt
		for i in econfig whichsys hdt;do
			if [ -f "${MNT}"/ubcd/boot/syslinux/${i}.c32 ];then
				cp "${MNT}"/ubcd/boot/syslinux/${i}.c32 "${WORK}"/boot/isolinux/
			fi
		done
		cp "${MNT}"/ubcd/boot/syslinux/reboot.c32 "${WORK}"/boot/isolinux/
		for i in "${WORK}"/ubcd/menus/*/*.cfg "${WORK}"/ubcd/menus/*/*/*.cfg "${WORK}"/pmagic/boot/*/*.cfg;do
			sed -i -e 's/\/boot\/syslinux/\/boot\/isolinux/g' "$i"
			sed -i -e 's/^COM32 linux.c32 /KERNEL /g' "$i"
		done
		sed -i -e 's/MENU LABEL GRUB4DOS menu/MENU LABEL Back to main menu/g' -e 's/This entry will bring you to the GRUB4DOS menu./Returns to the MultiCD menu./g' -e 's^BOOT /boot/grub/grldr^COM32 menu.c32\nAPPEND /boot/isolinux/isolinux.cfg^g' "${WORK}"/ubcd/menus/syslinux/main.cfg
		head -n 1 "${MNT}"/ubcd/ubcd/menus/syslinux/defaults.cfg | awk '{ print $6 }'>"${TAGS}"/ubcdver.tmp.txt
		#echo "$VERSION" > "${WORK}"/boot/ubcd/version
		umcdmount ubcd
	fi
elif [ $1 = writecfg ];then
if [ -f ubcd.iso ];then
	VERSION=$(cat "${TAGS}"/ubcdver.tmp.txt)
	rm "${TAGS}"/ubcdver.tmp.txt
	if [ -d "${WORK}"/ubcd/menus/isolinux ];then
		MENUFOLDER=isolinux #older versions
	else
		MENUFOLDER=syslinux #v5.1
	fi
	echo "label ubcd
	menu label --> ^Ultimate Boot CD ($VERSION) - Main menu
	com32 menu.c32
	append /ubcd/menus/${MENUFOLDER}/main.cfg" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
