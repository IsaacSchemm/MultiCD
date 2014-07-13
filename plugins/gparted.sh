#!/bin/sh
set -e
. "${MCDDIR}"/functions.sh
#GParted Live plugin for multicd.sh
#version 20140707
#Copyright (c) 2011-2014 Isaac Schemm and others
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
	echo "gparted-live-*-amd64.iso gpartedamd64.iso none"
elif [ $1 = links ] && [ "$2" = "i486" ];then
	echo "gparted-live-*-i486.iso gpartedi486.iso none"
elif [ $1 = scan ];then
	if [ -f gparted$2.iso ];then
		echo "GParted Live for $2"
	fi
elif [ $1 = copy ];then
	if [ -f gparted$2.iso ];then
		echo "Copying GParted Live for $2..."
		mcdmount gparted$2
		mcdcp -r "${MNT}"/gparted$2/live "${WORK}"/boot/gparted$2 #Compressed filesystem and kernel/initrd
		rm "${WORK}"/boot/gparted$2/memtest || true #Remember how we needed to do this with Debian Live? They use the same framework
		umcdmount gparted$2
	fi
elif [ $1 = writecfg ];then
if [ -f gparted$2.iso ];then
	if [ -f "${WORK}"/gparted$2/vmlinuz1 ];then
		AP="1"
	else
		AP=""
	fi
echo "menu begin >> GParted Live $2

# Since no network setting in the squashfs image, therefore if ip=frommedia, the network is disabled. That's what we want.
label GParted Live
  # MENU HIDE
  MENU LABEL GParted Live for $2 (Default settings)
  # MENU PASSWD
  kernel /boot/gparted$2/vmlinuz$AP
  append initrd=/boot/gparted$2/initrd$AP.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset vga=788 ip=frommedia nosplash live-media-path=/boot/gparted$2
  TEXT HELP
  * GParted live version: $(cat gparted$2.version). Live version maintainer: Steven Shiau
  * Disclaimer: GParted live comes with ABSOLUTELY NO WARRANTY
  ENDTEXT

label GParted Live (To RAM)
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live for $2 (To RAM. Boot media can be removed later)
  # MENU PASSWD
  kernel /boot/gparted$2/vmlinuz$AP
  append initrd=/boot/gparted$2/initrd$AP.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset noprompt vga=788 toram=filesystem.squashfs live-media-path=/boot/gparted$2 ip=frommedia  nosplash
  TEXT HELP
  All the programs will be copied to RAM, so you can
  remove boot media (CD or USB flash drive) later
  ENDTEXT

label GParted Live without framebuffer
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live for $2 (Safe graphic settings, vga=normal)
  # MENU PASSWD
  kernel /boot/gparted$2/vmlinuz$AP
  append initrd=/boot/gparted$2/initrd$AP.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset ip=frommedia vga=normal nosplash live-media-path=/boot/gparted$2
  TEXT HELP
  Disable console frame buffer support
  ENDTEXT

label GParted Live failsafe mode
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live for $2 (Failsafe mode)
  # MENU PASSWD
  kernel /boot/gparted$2/vmlinuz$AP
  append initrd=/boot/gparted$2/initrd$AP.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp ip=frommedia vga=normal nosplash live-media-path=/boot/gparted$2
  TEXT HELP
  acpi=off irqpoll noapic noapm nodma nomce nolapic 
  nosmp vga=normal nosplash
  ENDTEXT
MENU END
" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {links|scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
