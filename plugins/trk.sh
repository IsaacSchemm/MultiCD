#!/bin/sh
set -e
#Trinity Rescue Kit plugin for multicd.sh
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
	if [ -f trk.iso ];then
		echo "Trinity Rescue Kit"
	fi
elif [ $1 = copy ];then
	if [ -f trk.iso ];then
		echo "Copying Trinity Rescue Kit..."
		if [ ! -d trinity ];then
			mkdir trinity
		fi
		if grep -q "`pwd`/trinity" /etc/mtab ; then
			umount trinity
		fi
		mount -o loop trk.iso trinity/
		cp -r trinity/trk3 multicd-working/ #TRK files
		mkdir multicd-working/boot/trinity
		cp trinity/kernel.trk multicd-working/boot/trinity/kernel.trk
		cp trinity/initrd.trk multicd-working/boot/trinity/initrd.trk
		cp trinity/bootlogo.jpg multicd-working/boot/isolinux/trklogo.jpg #Boot logo
		umount trinity;rmdir trinity
	fi
elif [ $1 = writecfg ];then
if [ -f trk.iso ];then
cat >> multicd-working/boot/isolinux/isolinux.cfg << "EOF"
label trk
menu label --> ^Trinity Rescue Kit
com32 vesamenu.c32
append trk.menu
EOF
cat > multicd-working/boot/isolinux/trk.menu << "EOF"
prompt 0

menu title     build 318
menu background trklogo.jpg
menu color tabmsg 37;40      #80ffffff #00000000
menu color hotsel 30;47      #40000000 #20ffffff
menu color sel 30;47      #40000000 #20ffffff
menu color scrollbar 30;47      #40000000 #20ffffff

MENU WIDTH 75
MENU MARGIN 5
MENU PASSWORDMARGIN 3
MENU ROWS 18
MENU TABMSGROW 22
MENU CMDLINEROW 22
MENU ENDROW 24
MENU PASSWORDROW 11
MENU TIMEOUTROW 23

label trk3
menu label Run ^Trinity Rescue Kit 3.3 (default)
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1

label trk3-1
menu label ^1 : TRK 3.3 as bootserver to boot other TRK clients
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 trkbootnet

label trk3-2
menu label ^2 : TRK 3.3 running from RAM (best >= 512mb, 256mb min)
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 trkinmem

label trk3-3
menu label ^3 : TRK 3.3 with bigger screenfont
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 normalfont

label trk3-4
menu label ^4 : TRK 3.3 in simple VGA mode (debugging of kernel output)
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=1 pci=conf1 splash=off

label trk3-5
kernel /boot/trinity/kernel.trk
menu label ^5 : TRK 3.3 with Belgian keyboard (see docs for other)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 keyb_be

label trk3-6
kernel /boot/trinity/kernel.trk
menu label ^6 : TRK 3.3 - Virusscan all drives (non interactive)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 virusscan

label trk3-7
kernel /boot/trinity/kernel.trk
menu label ^7 : TRK 3.3 - Try more pcmcia and usb nics (when not detected)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 pcmcia

label trk3-8
kernel /boot/trinity/kernel.trk
menu label ^8 : TRK 3.3 - Try more SCSI drivers (when disks not detected)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 scsidrv

label trk3-9
kernel /boot/trinity/kernel.trk
menu label ^9 : TRK 3.3 with a secure shell server enabled
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 sshd

label trk3-10
kernel /boot/trinity/kernel.trk
menu label ^10 : TRK 3.3 - Execute local scripts on harddrive of PC
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 locscr

label trk3-11
kernel /boot/trinity/kernel.trk
menu label 11: TRK 3.3 - ^Fileshare all drives, secured with user
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 smbsec

label trk3-12
kernel /boot/trinity/kernel.trk
menu label 11: TRK 3.3 - Fileshare all drives as ^guest, no security
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 smbguest


label trk3-0
kernel /boot/trinity/kernel.trk
menu label 13: TRK 3.3 - ^Single user mode
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 runlevel 1

label trk3-noacpi
kernel /boot/trinity/kernel.trk
menu label 14: TRK 3.3 - Acpi=off, noapic  PCI=^bios (Alternate boot 1)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose acpi=off noapic pci=bios

label trk3-pcinormal
kernel /boot/trinity/kernel.trk
menu label 15: TRK 3.3 - ^Acpi=off, noapic PCI=any (Alternate boot 2)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose acpi=off noapic

label trk3-pciconf1
kernel /boot/trinity/kernel.trk
menu label 16: TRK 3.3 - ^PCI=conf2 (Alternate boot 3)
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf2

label trk3-debug
menu label 17: TRK 3.3 - ^Verbose startup for debugging after initial bootfase
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 debugging

label trk3-18
menu label 18: TRK 3.3 - SSH server and run from ^RAM
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 sshd trkinmem

label trk3-19
menu label 19: TRK 3.3 - SSH server, run from RAM, act as a ^secure fileserver
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 sshd trkinmem smbsec

label trk3-20
menu label 20 : TRK 3.3 with ^proxyserver support enabled
kernel /boot/trinity/kernel.trk
append initrd=/boot/trinity/initrd.trk ramdisk_size=49152 root=/dev/ram0 vga=788 splash=verbose pci=conf1 proxy

label back
menu label ^Back to main menu
com32 menu.c32
append isolinux.cfg
EOF
fi
else
	echo "Usage: $0 {scan|copy|writecfg}"
	echo "Use only from within multicd.sh or a compatible script!"
	echo "Don't use this plugin script on its own!"
fi
