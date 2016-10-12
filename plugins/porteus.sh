#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Porteus plugin for multicd.sh
#version 20161010
#Copyright (c) 2016 Isaac Schemm
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
	echo "Porteus-*.iso porteus.iso none"
elif [ $1 = scan ];then
	if [ -f porteus.iso ];then
		echo "Porteus"
	fi
elif [ $1 = copy ];then
	if [ -f porteus.iso ];then
		echo "Copying Porteus..."
		mcdmount porteus
		if [ -d "${MNT}"/porteus/porteus ];then
			mcdcp -r "${MNT}"/porteus/porteus "${WORK}"/ #Copy everything
			mkdir -p "${WORK}"/boot/porteus
			cp "${MNT}"/porteus/boot/syslinux/vmlinuz "${WORK}"/boot/porteus/vmlinuz
			cp "${MNT}"/porteus/boot/syslinux/initrd.xz "${WORK}"/boot/porteus/initrd.xz
			##########
			if [ "$(ls -1 *.xzm 2> /dev/null;true)" != "" ];then
				echo "Copying Porteus modules..."
				mkdir -p "${WORK}/porteus/modules"
			fi
			for i in `ls -1 *.xzm 2> /dev/null;true`; do
				cp "${i}" "${WORK}"/porteus/modules/ #Copy the .xzm module to the modules folder
				if $VERBOSE;then
					echo \(Copied $i\)
				fi
			done
		else
			mkdir -p "${WORK}"/boot/porteus-kiosk
			mcdcp "${MNT}"/porteus/boot/vmlinuz "${WORK}"/boot/porteus-kiosk/vmlinuz
			mkdir -p "${WORK}"/xzm
			mcdcp -r "${MNT}"/porteus/xzm/* "${WORK}"/xzm
			mkdir -p "${WORK}"/docs
			mcdcp -r "${MNT}"/porteus/docs/* "${WORK}"/docs
			
			#Replace string "Kiosk" with last 5 characters of CD label
			LAST5=$(echo -n .?.?.?"$CDLABEL"|tail -c 5)
			xz -cd "${MNT}"/porteus/boot/initrd.xz | sed -e "s/LABEL=\"\.\*Kiosk\"/LABEL=\"\.\*$LAST5\"/g" > "${WORK}"/boot/porteus-kiosk/initrd.img

			if [ "$(ls -1 *.xzm 2> /dev/null;true)" != "" ];then
				echo "Copying Porteus modules..."
			fi
			for i in `ls -1 *.xzm 2> /dev/null;true`; do
				cp "${i}" "${WORK}"/porteus/xzm/ #Copy the .xzm module to the xzm folder (not tested with kiosk ISO)
				if $VERBOSE;then
					echo \(Copied $i\)
				fi
			done
		fi
		umcdmount porteus
	fi
elif [ $1 = writecfg ];then
	if [ -f porteus.iso ];then
		if [ -d "${WORK}"/boot/porteus-kiosk ];then
			PORTEUSVER=""
			if [ -f "${WORK}"/docs/version ];then
				PORTEUSVER="$(cat "${WORK}"/docs/version)"
			fi
			echo "LABEL porteus-kiosk
				MENU LABEL ^Porteus Kiosk $PORTEUSVER
				KERNEL /boot/porteus-kiosk/vmlinuz
				APPEND initrd=/boot/porteus-kiosk/initrd.img quiet first_run
				" >> "${WORK}"/boot/isolinux/isolinux.cfg
		elif [ -f "${WORK}"/porteus/base/002-xorg.xzm ];then
			if [ -f porteus.version ] && [ "$(cat porteus.version)" != "" ];then
				PORTEUSVER=" $(cat porteus.version)"
			else
				PORTEUSVER=""
			fi
			echo "menu begin --> ^Porteus$PORTEUSVER

			LABEL razor
			MENU LABEL Graphics mode (Razor)
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz changes=/porteus 
			TEXT HELP
				Run Porteus the best way we can.
				Try to autoconfigure graphics
				card and use the maximum
				allowed resolution
			ENDTEXT

			LABEL fresh
			MENU LABEL Always Fresh
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz nomagic base_only norootcopy 
			TEXT HELP
				Normally Porteus saves all changes
				to the /porteus/changes/ directory
				on the boot media (if writable)
				and restores them next boot.
				Use this option to start a fresh
				system, changes are not read from
				or written to any device
			ENDTEXT

			LABEL copy2ram
			MENU LABEL Copy To RAM
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz copy2ram 
			TEXT HELP
				Run Porteus the same as above,
				but first copy all data to RAM
				to get a huge speed increase
				(needs >256MB)
			ENDTEXT

			LABEL text
			MENU LABEL Text mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz 3 
			TEXT HELP
				Run Porteus in text mode and
				start the command prompt only
			ENDTEXT

			LABEL pxe-boot
			MENU LABEL Porteus as PXE server
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz autoexec=pxe-boot~& 
			TEXT HELP
				Run Porteus as usual, but also
				initialize a PXE server.
				This will allow you to boot Porteus
				on other computers over a network
			ENDTEXT

			LABEL plop
			MENU LABEL PLoP BootManager
			KERNEL plpbt
			TEXT HELP
				Run the plop boot manager.
				This utility provides handy
				boot-USB options for machines
				with vintage/defective BIOS
			ENDTEXT

			menu end" >> "${WORK}"/boot/isolinux/isolinux.cfg
		else
			echo "LABEL text
			MENU LABEL ^Porteus$PORTEUSVER - Text mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz 3 
			TEXT HELP
				Run Porteus in text mode and
				start the command prompt only
			ENDTEXT
			
			LABEL text
			MENU LABEL ^Porteus$PORTEUSVER - Text mode (copy to RAM)
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz 3 copy2ram 
			TEXT HELP
				Run Porteus the same as above,
				but first copy all data to RAM
				to get huge speed
			ENDTEXT" >> "${WORK}"/boot/isolinux/isolinux.cfg
		fi
	fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
