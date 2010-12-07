#!/bin/sh
set -e
. ./functions.sh
#GParted Live plugin for multicd.sh
#version 6.2
#Copyright (c) 2010 libertyernie
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
	echo "gparted-live-*.iso gparted.iso"
elif [ $1 = scan ];then
	if [ -f gparted.iso ];then
		echo "GParted Live"
	fi
elif [ $1 = copy ];then
	if [ -f gparted.iso ];then
		echo "Copying GParted Live..."
		mcdmount gparted
		cp -R $MNT/gparted/live $WORK/boot/gparted #Compressed filesystem and kernel/initrd
		rm $WORK/boot/gparted/memtest || true #Remember how we needed to do this with Debian Live? They use the same framework
		umcdmount gparted
	fi
elif [ $1 = writecfg ];then
if [ -f gparted.iso ];then
echo "# Since no network setting in the squashfs image, therefore if ip=frommedia, the network is disabled. That's what we want.
label GParted Live
  # MENU HIDE
  MENU LABEL GParted Live (Default settings)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset vga=788 ip=frommedia nosplash live-media-path=/boot/gparted
  TEXT HELP
  * GParted live version: 0.6.4-1. Live version maintainer: Steven Shiau
  * Disclaimer: GParted live comes with ABSOLUTELY NO WARRANTY
  ENDTEXT

MENU BEGIN Other modes of GParted Live
label GParted Live (To RAM)
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (To RAM. Boot media can be removed later)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset noprompt vga=788 toram=filesystem.squashfs live-media-path=/boot/gparted ip=frommedia  nosplash
  TEXT HELP
  All the programs will be copied to RAM, so you can
  remove boot media (CD or USB flash drive) later
  ENDTEXT

label GParted Live without framebuffer
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (Safe graphic settings, vga=normal)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset ip=frommedia vga=normal nosplash live-media-path=/boot/gparted
  TEXT HELP
  Disable console frame buffer support
  ENDTEXT

label GParted Live failsafe mode
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (Failsafe mode)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live config i915.modeset=0 xforcevesa radeon.modeset=0 noswap nomodeset acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp ip=frommedia vga=normal nosplash live-media-path=/boot/gparted
  TEXT HELP
  acpi=off irqpoll noapic noapm nodma nomce nolapic 
  nosmp vga=normal nosplash
  ENDTEXT
MENU END
" >> $WORK/boot/isolinux/isolinux.cfg
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
