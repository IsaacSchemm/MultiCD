#!/bin/bash
if [ $(whoami) != "root" ];then
	if uname|grep -qi CYGWIN;then
		echo "Cygwin is not supported at the moment."
	else
		echo "This script must be run as root, so it can mount ISO images on the filesystem during the building process."
		exit 1
	fi
fi
set -e
#multicd.sh 5.8
#Copyright (c) 2010 maybeway36
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

if [ -d tags ];then rm -r tags;fi
mkdir -p tags/puppies
chmod -R 777 tags

if echo $* | grep -q "\bmd5\b";then
 MD5=1
else
 if echo $* | grep -q "\bc\b";then
  MD5=1
 else
  MD5=0
 fi
fi
if echo $* | grep -q "\bm\b";then
 MEMTEST=0
else
 MEMTEST=1
fi
if echo $* | grep -q "\bv\b";then
 VERBOSE=1
 echo > tags/verbose
else
 VERBOSE=0
fi
if echo $* | grep -q "\bcondeb\b";then
 CONDEB=1
else
 CONDEB=0
fi
if echo $* | grep -q "\bi\b";then
 INTERACTIVE=1
else
 INTERACTIVE=0
fi

#START PREPARE#
UNKNOWNS="$(md5sum -c plugins.md5|grep FAILED|awk -F: '{print $1}') $(for i in plugins/*.sh;do grep -q $i plugins.md5||echo $i;done)"
if [ "$UNKNOWNS" != " " ];then
	echo
	echo "Plugins that are not from the official release: $UNKNOWNS"
	echo "Make sure you trust every script in the plugins folder - all these scripts will get root access!"
	echo
fi

#Make the scripts executable.
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
done
#END PREPARE#

#Now we run through the plugins first, as a non-root user.
echo "List of boot options that will be included:"
echo '#!/bin/sh
#START SCAN
for i in plugins/*;do
	$i scan
done
#END SCAN
'>/tmp/run-as-nobody.sh
chmod +x /tmp/run-as-nobody.sh
su nobody -c /tmp/run-as-nobody.sh
rm /tmp/run-as-nobody.sh

for i in *.im[agz]; do
 test -r "$i" || continue
 echo $i|sed 's/\.im.//'
done
GAMES=0 #Will be changed if there are games
for i in games/*.im[agz]; do
 test -r "$i" || continue
 echo Game: $(echo $i|sed 's/\.im.//'|sed 's/games\///')
 GAMES=1
done
if [ -f grub.exe ];then
 echo "GRUB4DOS"
fi
if [ $MEMTEST = 1 ];then
 echo "Memtest86+"
fi

echo
echo "Continuing in 3 seconds - press Ctrl+C to cancel"
sleep 3

if [ $INTERACTIVE = 1 ];then
	if ! which dialog &> /dev/null;then
		echo "You must install dialog to use the interactive options."
		exit 1
	fi
	dialog --inputbox "What would you like the title of the CD's main menu to be?" 8 70 "MultiCD - Created $(date +"%b %d, %Y")" 2> /tmp/cdtitle
	CDTITLE=$(cat /tmp/cdtitle)
	rm /tmp/cdtitle
	if [ -f trk.iso ];then
		CDLABEL=TRK_3.3
	else
		dialog --inputbox "What would you like the CD label to be?" 9 40 "MultiCD" 2> /tmp/cdlabel
		CDLABEL=$(cat /tmp/cdlabel)
		rm /tmp/cdlabel
	fi
	dialog --menu "What menu color would you like?" 0 0 0 40 black 41 red 42 green 43 brown 44 blue 45 magenta 46 cyan 2> /tmp/color
	MENUCOLOR=$(cat /tmp/color)
	echo $(echo -e "\r\033[0;$(cat /tmp/color)m")Color chosen.$(echo -e '\033[0;39m')
	rm /tmp/color
	dialog --inputbox "Enter the two-letter language code for the language you would like to use." 9 50 "en" 2> tags/lang
	if [ -f slax.iso ];then
		dialog --checklist "Slax modules to include:" 13 45 6 \
		002 Xorg on \
		003 KDE on \
		004 "KDE applications" on \
		005 "KDE Office" on \
		006 Development on \
		007 Firefox on \
		2> ./slaxlist0
		echo >> ./slaxlist0
		cat ./slaxlist0|sed -e 's/"//g' -e 's/ /\n/g'>./slaxlist
		rm ./slaxlist0
		if [ "$(wc -c slaxlist)" = "24 slaxlist" ];then rm slaxlist;fi #If they are all checked, delete the file
	fi
	if [ -f win98se.iso ] || [ -f winme.iso ];then
		if dialog --yesno "Would you like to copy the \"tools\" and \"add-ons\" folders from the Windows 9x/Me CD?" 0 0;then
			touch tags/9xextras
		fi
	fi
	if [ $(find tags/puppies -maxdepth 1 -type f|wc -l) -gt 1 ] && which dialog &> /dev/null;then
		echo "dialog --radiolist \"Which Puppy variant would you like to be installable to HD from the disc?\" 13 45 6 \\">puppychooser
		for i in tags/puppies/*;do
			echo $(echo $i|sed -e 's/tags\/puppies\///g') \"\" off \\ >> puppychooser
		done
		echo "2> puppyresult" >> puppychooser
		sh puppychooser
		touch tags/puppies/$(cat puppyresult).inroot
		rm puppychooser puppyresult
	fi
	if [ $(find tags/puppies -maxdepth 1 -type f|wc -l) -eq 1 ];then
		NAME=$(ls tags/puppies)
		true>$(find tags/puppies -maxdepth 1 -type f).inroot
	fi
	if which dialog &> /dev/null;then
		for i in $(find tags -maxdepth 1 -name ubuntu\*);do
			dialog --inputbox "What would you like $(echo $i|sed -e 's/tags\///g') to be called on the CD boot menu? $(echo $i|sed -e 's/tags\///g')" 8 70 2> $i.name
		done
	fi
else
	CDTITLE="MultiCD - Created $(date +"%b %d, %Y")"
	if [ -f trk.iso ];then
		CDLABEL=TRK_3.3
	else
		CDLABEL=MultiCD
	fi
	MENUCOLOR=44
	echo en > tags/lang
	touch tags/9xextras
	if [ $(find tags/puppies -maxdepth 1 -type f|wc -l) -ge 1 ] && which dialog &> /dev/null;then #Greater or equal to 1 puppy installed
		touch $(find tags/puppies -maxdepth 1 -type f|head -n 1) #The first one alphabetically will be in the root dir - now if only I could make this look nicer. Also, does lucid puppy still put its files here?
	fi
fi

if [ -d multicd-working ];then
 rm -r multicd-working/*
else
 mkdir multicd-working
fi

#Make sure it exists, you need to put stuff there later
mkdir -p multicd-working/boot/isolinux

#START COPY
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i copy
done
#END COPY

#The below chunk copies floppy images.
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	cp "$i" multicd-working/boot/$j.img
	if [ $VERBOSE = 1 ];then
		echo "Saved as "$j".img."
	else
		echo
	fi
	j=$( expr $j + 1 )
done

#This chunk copies floppy images in the "games" folder. They will have their own submenu.
if [ $GAMES = 1 ];then
	k="0"
	mkdir -p multicd-working/boot/games
	for i in games/*.im[agz]; do
		test -r "$i" || continue
		echo -n Copying $(echo $i|sed 's/\.im.//'|sed 's/games\///')"... "
		cp "$i" multicd-working/boot/games/$k.img
		if [ $VERBOSE = 1 ];then
			echo "Saved as games/"$k".img."
		else
			echo
		fi
		k=$( expr $k + 1 )
	done
fi

if [ -f grub.exe ];then
 echo "Copying GRUB4DOS..."
 cp grub.exe multicd-working/boot/grub.exe
fi

echo "Downloading SYSLINUX..."
if [ ! -f syslinux.tar.gz ];then
	if [ $VERBOSE != 0 ];then
		wget -O syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.02.tar.gz
	else
		wget -qO syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.02.tar.gz
	fi
fi
if [ $? = 0 ];then
	echo "Unpacking and copying files..."
	tar -C /tmp -xzf syslinux.tar.gz
	cp /tmp/syslinux-*/core/isolinux.bin multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/memdisk/memdisk multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/menu.c32 multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/vesamenu.c32 multicd-working/boot/isolinux/
	cp /tmp/syslinux-*/com32/modules/chain.c32 multicd-working/boot/isolinux/
	rm -r /tmp/syslinux-*/
else
	echo "Downloading of SYSLINUX failed."
	exit 1
fi

if [ $MEMTEST = 1 ];then
 if [ -f memtest ];then
  cp memtest multicd-working/boot/memtest
 else
  echo "Downloading memtest86+ 4.10 from memtest.org..."
  if [ $VERBOSE != 0 ];then
   wget -O- http://memtest.org/download/4.10/memtest86+-4.10.bin.gz|gzip -cd>memtest
  else
   wget -qO- http://memtest.org/download/4.10/memtest86+-4.10.bin.gz|gzip -cd>memtest
  fi
  cp memtest multicd-working/boot/memtest
 fi
fi

echo "Writing isolinux.cfg..."

##BEGIN ISOLINUX MENU CODE##
#The ISOLINUX menu can be rearranged by renaming your plugin scripts - they are processed in alphabetical order.

#BEGIN HEADER#
#Don't move this part. You can change the timeout and menu title, however.
echo "DEFAULT menu.c32
TIMEOUT 0
PROMPT 0
menu title $CDTITLE" > multicd-working/boot/isolinux/isolinux.cfg
#END HEADER#

#BEGIN COLOR CODE#
	if [ $MENUCOLOR = 40 ];then
		BORDERCOLOR=37
	else
		BORDERCOLOR=30
	fi
	echo "	menu color screen 37;40
	menu color border 30;44
	menu color title 1;36;44
	menu color unsel 37;44
	menu color hotkey 1;37;44
	menu color sel 7;37;40
	menu color hotsel 1;7;37;40
	menu color disabled 1;30;44
	menu color scrollbar 30;44
	menu color tabmsg 31;40
	menu color cmdmark 1;36;40
	menu color cmdline 37;40
	menu color pwdborder 30;47
	menu color pwdheader 31;47
	menu color pwdentry 30;47
	menu color timeout_msg 37;40
	menu color timeout 1;37;40
	menu color help 37;40
	menu color msg07 37;40"|sed -e "s/30/$BORDERCOLOR/g" -e "s/44/$MENUCOLOR/g">>multicd-working/boot/isolinux/isolinux.cfg
#END COLOR CODE#

#BEGIN HD BOOT OPTION#
#If this bugs you, get rid of it.
echo "label local
menu label Boot from ^hard drive
kernel chain.c32
append hd0" >> multicd-working/boot/isolinux/isolinux.cfg
#END HD BOOT OPTION#

#START WRITE
for i in plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i writecfg
done
#END WRITE

#BEGIN DISK IMAGE ENTRY#
j="0"
for i in *.im[agz]; do
  test -r "$i" || continue
  BASICNAME=$(echo $i|sed 's/\.im.//')
  echo label "$BASICNAME" >> multicd-working/boot/isolinux/isolinux.cfg
  echo kernel memdisk >> multicd-working/boot/isolinux/isolinux.cfg
  echo append initrd=/boot/$j.img >> multicd-working/boot/isolinux/isolinux.cfg
  j=$( expr $j + 1 )
done
#END DISK IMAGE ENTRY#

#BEGIN GRUB4DOS ENTRY#
if [ -f multicd-working/boot/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/grub.exe">>multicd-working/boot/isolinux/isolinux.cfg
elif [ -f multicd-working/boot/riplinux/grub4dos/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/riplinux/grub4dos/grub.exe">>multicd-working/boot/isolinux/isolinux.cfg
fi
#END GRUB4DOS ENTRY#

#BEGIN GAMES ENTRY#
if [ $GAMES = 1 ];then
echo "label games
menu label ^Games on disk images
com32 menu.c32
append games.cfg">>multicd-working/boot/isolinux/isolinux.cfg
fi
#END GAMES ENTRY#

#BEGIN MEMTEST ENTRY#
if [ -f multicd-working/boot/memtest ];then
echo "label memtest
menu label ^Memtest86+
kernel /boot/memtest">>multicd-working/boot/isolinux/isolinux.cfg
fi
#END MEMTEST ENTRY#
##END ISOLINUX MENU CODE##

if [ $GAMES = 1 ];then
k="0"
cat > multicd-working/boot/isolinux/games.cfg << "EOF"
default menu.c32
timeout 300

menu title "Choose a game to play:"
EOF
for i in games/*.im[agz]; do
  test -r "$i" || continue
  BASICNAME=$(echo $i|sed 's/\.im.//'|sed 's/games\///')
  echo label "$BASICNAME" >> multicd-working/boot/isolinux/games.cfg
  echo kernel memdisk >> multicd-working/boot/isolinux/games.cfg
  echo append initrd=/boot/games/$k.img >> multicd-working/boot/isolinux/games.cfg
  k=$( expr $k + 1 )
done
echo "label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg">>multicd-working/boot/isolinux/games.cfg
fi

if [ -d includes ];then
 echo "Copying includes..."
 cp -r includes/* multicd-working/
fi

if [ $MD5 = 1 ];then
 echo "Generating MD5 checksums..."
 if [ $VERBOSE != 0 ];then
  find multicd-working/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin \
  -exec md5sum '{}' \; | sed 's/multicd-working\///g' | tee multicd-working/md5sum.txt
 else
  find multicd-working/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin\
  -exec md5sum '{}' \; | sed 's/multicd-working\///g' > multicd-working/md5sum.txt
 fi
fi

if which genisoimage > /dev/null;then
 GENERATOR="genisoimage"
elif which mkisofs > /dev/null;then
 GENERATOR="mkisofs"
else
 echo "Neither genisoimage nor mkisofs was found."
 exit 1
fi
EXTRAARGS=""
if [ $VERBOSE = 0 ];then
	EXTRAARGS="$EXTRAARGS -quiet"
fi
if [ ! -f tags/win9x ];then
	EXTRAARGS="$EXTRAARGS -iso-level 4" #To ensure that Windows 9x installation CDs boot properly
fi
echo "Building CD image..."
$GENERATOR -o multicd.iso \
-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
-no-emul-boot -boot-load-size 4 -boot-info-table \
-r -J -joliet-long $EXTRAARGS -D \
-l -V "$CDLABEL" multicd-working/
rm -r multicd-working/
chmod 666 multicd.iso
rm -r tags
#END SCRIPT
