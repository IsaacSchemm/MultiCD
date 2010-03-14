#!/bin/sh
set -e
#GParted Live plugin for multicd.sh
#version 5.3
#Copyright (c) 2009 maybeway36
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
if [ $1 = scan ];then
	if [ -f gparted.iso ];then
		echo "GParted Live"
	fi
elif [ $1 = copy ];then
	if [ -f gparted.iso ];then
		echo "Copying GParted Live..."
		if [ ! -d gparted ];then
			mkdir gparted
		fi
		if grep -q "`pwd`/gparted" /etc/mtab ; then
			umount gparted
		fi
		mount -o loop gparted.iso gparted/
		cp -R gparted/live multicd-working/boot/gparted #Compressed filesystem and kernel/initrd
		rm multicd-working/boot/gparted/memtest #Remember how we needed to do this with Debian Live? They use the same framework
		umount gparted
		rmdir gparted
	fi
elif [ $1 = writecfg ];then
if [ -f gparted.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label GParted Live
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL ^GParted Live (Default settings)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live union=aufs live-media-path=/boot/gparted noswap vga=788 ip=frommedia

label GParted Live (To RAM)
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (To RAM. Boot media can be removed later)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live union=aufs live-media-path=/boot/gparted noswap vga=788 toram ip=frommedia

label GParted Live without framebuffer
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (Safe graphic settings, vga=normal)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live union=aufs live-media-path=/boot/gparted noswap ip=frommedia vga=normal

label GParted Live failsafe mode
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL GParted Live (Failsafe mode)
  # MENU PASSWD
  kernel /boot/gparted/vmlinuz1
  append initrd=/boot/gparted/initrd1.img boot=live union=aufs live-media-path=/boot/gparted noswap acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp ip=frommedia vga=normal
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
