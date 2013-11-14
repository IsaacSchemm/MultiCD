#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Porteus plugin for multicd.sh
#version 20130602
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
	echo "Porteus-*.iso porteus.iso none"
elif [ $1 = scan ];then
	if [ -f porteus.iso ];then
		echo "Porteus"
	fi
elif [ $1 = copy ];then
	if [ -f porteus.iso ];then
		echo "Copying Porteus..."
		mcdmount porteus
		if [ -f "${TAGS}"/porteuslist ];then
			mkdir "${WORK}"/porteus
			for i in `ls "${MNT}"/porteus/porteus|sed -e '/^base$/ d'`;do
				cp -r "${MNT}"/porteus/porteus/$i "${WORK}"/porteus/ #Copy everything but the base modules
			done
			mkdir "${WORK}"/porteus/base
			for i in `cat "${TAGS}"/porteuslist`;do
				cp "${MNT}"/porteus/porteus/base/${i}* "${WORK}"/porteus/base/ #Copy only the modules you wanted
			done
			cp "${MNT}"/porteus/porteus/base/000-* "${WORK}"/porteus/base/ #kernel is required
			cp "${MNT}"/porteus/porteus/base/001-* "${WORK}"/porteus/base/ #core module is required
			rm "${TAGS}"/porteuslist
		else
			cp -r "${MNT}"/porteus/porteus "${WORK}"/ #Copy everything
		fi
		mkdir -p "${WORK}"/boot/porteus
		cp "${MNT}"/porteus/boot/syslinux/vmlinuz "${WORK}"/boot/porteus/vmlinuz
		cp "${MNT}"/porteus/boot/syslinux/initrd.xz "${WORK}"/boot/porteus/initrd.xz
		umcdmount porteus
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
	fi
elif [ $1 = writecfg ];then
	if [ -f porteus.iso ];then
		if [ -f "${WORK}"/porteus/base/002-xorg.xzm ];then
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
