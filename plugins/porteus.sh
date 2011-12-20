#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#Porteus plugin for multicd.sh
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
				cp -R "${MNT}"/porteus/porteus/$i "${WORK}"/porteus/ #Copy everything but the base modules
			done
			mkdir "${WORK}"/porteus/base
			for i in `cat "${TAGS}"/porteuslist`;do
				cp "${MNT}"/porteus/porteus/base/${i}* "${WORK}"/porteus/base/ #Copy only the modules you wanted
			done
			cp "${MNT}"/porteus/porteus/base/000-* "${WORK}"/porteus/base/ #kernel is required
			cp "${MNT}"/porteus/porteus/base/001-* "${WORK}"/porteus/base/ #core module is required
			rm "${TAGS}"/porteuslist
		else
			cp -R "${MNT}"/porteus/porteus "${WORK}"/ #Copy everything
		fi
		mkdir -p "${WORK}"/boot/porteus
		cp "${MNT}"/porteus/boot/vmlinuz "${WORK}"/boot/porteus/vmlinuz
		cp "${MNT}"/porteus/boot/initrd.xz "${WORK}"/boot/porteus/initrd.xz
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
			echo "LABEL p-xconf
			MENU LABEL ^Porteus$PORTEUSVER Graphics mode (KDE).
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz vga=791 splash=silent quiet autoexec=xconf;telinit~4 changes=/porteus/
			TEXT HELP
			    Run Porteus the best way we can.
			    Try to autoconfigure graphics
			    card and use the maximum
			    allowed resolution
			ENDTEXT

			LABEL p-lxde
			MENU LABEL Porteus$PORTEUSVER Graphics mode (LXDE).
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz vga=791 splash=silent quiet autoexec=lxde;xconf;telinit~4 changes=/porteus/
			TEXT HELP
			    Run Porteus the same as above.
			    Lightweight LXDE to be
			    launched as default desktop
			ENDTEXT

			LABEL p-fresh
			MENU LABEL Porteus$PORTEUSVER Always Fresh
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz autoexec=xconf;telinit~4
			TEXT HELP
			    Normally Porteus saves all changes
			    to the /porteus/changes/ directory
			    on the boot media (if writable)
			    and restores them next boot.
			    Use this option to start a fresh
			    system, no changes are neither
			    read nor written anywhere
			ENDTEXT

			LABEL p-cp2ram
			MENU LABEL Porteus$PORTEUSVER Copy To RAM
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz vga=791 splash=silent quiet copy2ram autoexec=xconf;telinit~4
			TEXT HELP
			    Run Porteus the same as above,
			    but first copy all data to RAM
			    to get huge speed (needs >300MB)
			ENDTEXT

			LABEL p-startx
			MENU LABEL Porteus$PORTEUSVER Graphics VESA mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz autoexec=telinit~4 changes=/poreus/
			TEXT HELP
			    Run Porteus with KDE, but skip
			    gfx-card config. Force 1024x768
			    using standard VESA driver
			ENDTEXT

			LABEL p-text
			MENU LABEL Porteus$PORTEUSVER Text mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/initrd.xz
			TEXT HELP
			    Run Porteus in textmode and start
			    command prompt only
			ENDTEXT

			LABEL p-pxe
			MENU LABEL Porteus$PORTEUSVER Porteus as PXE server
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/porteus/initrd.xz autoexec=pxe-boot;xconf;telinit~4
			TEXT HELP
			    Run Porteus as usual, but also
			    initialize PXE server.
			    This will allow you to boot Porteus
			    on other computers over network
			ENDTEXT

			LABEL p-plop
			MENU LABEL PLoP BootManager
			KERNEL /boot/porteus/plpbt
			TEXT HELP
			    Run the plop boot manager.
			    This utility provides handy boot-USB options for
			    machines with vintage/defective BIOS
			ENDTEXT" >> "${WORK}"/boot/isolinux/isolinux.cfg
		else
			echo "LABEL p-text
			MENU LABEL Porteus$PORTEUSVER Text mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/initrd.xz
			TEXT HELP
			    Run Porteus in textmode and start
			    command prompt only
			ENDTEXT
			
			LABEL p-cp2ram
			MENU LABEL Porteus$PORTEUSVER Text mode
			KERNEL /boot/porteus/vmlinuz
			APPEND initrd=/boot/initrd.xz copy2ram
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
