#!/bin/sh
set -e
#Clonezilla plugin for multicd.sh
#version 5.0
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
	if [ -f clonezilla.iso ];then
		echo "Clonezilla"
	fi
elif [ $1 = copy ];then
	if [ -f clonezilla.iso ];then
		echo "Copying Clonezilla..."
		if [ ! -d clonezilla ];then
			mkdir clonezilla
		fi
		if grep -q "`pwd`/clonezilla" /etc/mtab ; then
			umount clonezilla
		fi
		mount -o loop clonezilla.iso clonezilla/
		cp clonezilla/isolinux/ocswp.png multicd-working/boot/isolinux/ocswp.png #Boot menu logo
		cp -R clonezilla/live multicd-working/boot/clonezilla #Another Debian Live-based ISO
		umount clonezilla
		rmdir clonezilla
		rm multicd-working/boot/clonezilla/memtest
	fi
elif [ $1 = writecfg ];then
if [ -f clonezilla.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label clonezilla
menu label ^Clonezilla
com32 vesamenu.c32
append clonezil.cfg
EOF
cat >> multicd-working/boot/isolinux/clonezil.cfg << "EOF"
# Created by generate-pxe-menu! Do NOT edit unless you know what you are doing! 
# Keep those comment "MENU DEFAULT" and "MENU HIDE"! Do NOT remove them.
# Note!!! If "serial" directive exists, it must be the first directive
default vesamenu.c32
timeout 300
prompt 0
noescape 1
MENU MARGIN 5
 MENU BACKGROUND ocswp.png
# Set the color for unselected menu item and timout message
 MENU COLOR UNSEL 7;32;41 #c0000090 #00000000
 MENU COLOR TIMEOUT_MSG 7;32;41 #c0000090 #00000000
 MENU COLOR TIMEOUT 7;32;41 #c0000090 #00000000
 MENU COLOR HELP 7;32;41 #c0000090 #00000000

# MENU MASTER PASSWD

say **********************************************************************
say Clonezilla, the OpenSource Clone System.
say NCHC Free Software Labs, Taiwan.
say clonezilla.sourceforge.net, clonezilla.nchc.org.tw
say THIS SOFTWARE COMES WITH ABSOLUTELY NO WARRANTY! USE AT YOUR OWN RISK! 
say **********************************************************************

# Allow client to edit the parameters
ALLOWOPTIONS 1

# simple menu title
MENU TITLE clonezilla.sourceforge.net, clonezilla.nchc.org.tw

# Since no network setting in the squashfs image, therefore if ip=frommedia, the network is disabled. That's what we want.
label Clonezilla live
  MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (Default settings, VGA 1024x768)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" vga=791 ip=frommedia nolocales
  TEXT HELP
  * Clonezilla live version: 1.2.1-23. (C) 2003-2008, NCHC, Taiwan
  * Disclaimer: Clonezilla comes with ABSOLUTE NO WARRANTY
  ENDTEXT

label Clonezilla live 800x600
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (Default settings, VGA 800x600)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" vga=788 ip=frommedia nolocales
  TEXT HELP
  VGA mode 800x600. OK for most of VGA cards.
  ENDTEXT

label Clonezilla live 640x480
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (Default settings, VGA 640x480)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" vga=785 ip=frommedia nolocales
  TEXT HELP
  VGA mode 640x480. OK for most of VGA cards.
  ENDTEXT

label Clonezilla live (To RAM)
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (To RAM. Boot media can be removed later)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" vga=791 toram ip=frommedia nolocales
  TEXT HELP
  All the programs will be copied to RAM, so you can
  remove boot media (CD or USB flash drive) later
  ENDTEXT

label Clonezilla live without framebuffer
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (Safe graphic settings, vga=normal)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" ip=frommedia nolocales vga=normal
  TEXT HELP
  Disable console frame buffer support
  ENDTEXT

label Clonezilla live failsafe mode
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Clonezilla live (Failsafe mode)
  # MENU PASSWD
  kernel /boot/clonezilla/vmlinuz1
  append initrd=/boot/clonezilla/initrd1.img boot=live union=aufs live-media-path=/boot/clonezilla ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_keymap="" ocs_live_batch="no" ocs_lang="" acpi=off irqpoll noapic noapm nodma nomce nolapic nosmp ip=frommedia nolocales vga=normal
  TEXT HELP
  acpi=off irqpoll noapic noapm nodma nomce nolapic 
  nosmp vga=normal
  ENDTEXT

label local
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Local operating system in harddrive (if available)
  # MENU PASSWD
  # 2 method to boot local device:
  # (1) For localboot 0, it is decided by boot order in BIOS, so uncomment the follow 1 line if you want this method:
  # localboot 0

  # (2) For chain.c32, you can assign the boot device.
  # Ref: extlinux.doc from syslinux
  # Syntax: APPEND [hd|fd]<number> [<partition>]
  # [<partition>] is optional.
  # Ex:
  # Second partition (2) on the first hard disk (hd0);
  # Linux would *typically* call this /dev/hda2 or /dev/sda2, then it's "APPEND hd0 2"
  #
  kernel chain.c32
  append hd0
  TEXT HELP
  Boot local OS from first hard disk if it's available
  ENDTEXT

# Note! *.bin is specially purpose for syslinux, 
# Do NOT use memtest.bin, use memtest instead of memtest.bin
label memtest
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Memory test using Memtest86+
  # MENU PASSWD
  kernel /boot/isoliux/memtest
  TEXT HELP
  Run memory test using Memtest86+
  ENDTEXT

label FreeDOS
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL FreeDOS
  # MENU PASSWD
  kernel memdisk
  append initrd=/boot/clonezilla/freedos.img
  TEXT HELP
  Run FreeDOS
  ENDTEXT

label etherboot
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Network boot via etherboot
  # MENU PASSWD
  kernel /boot/clonezilla/eb.zli
  TEXT HELP
  Run Etherbot to enable network (PXE) boot
  ENDTEXT

label gPXE
  # MENU DEFAULT
  # MENU HIDE
  MENU LABEL Network boot via gPXE
  # MENU PASSWD
  kernel /boot/clonezilla/gpxe.lkn
  TEXT HELP
  Run gPXE to enable network (PXE) boot
  ENDTEXT

label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
