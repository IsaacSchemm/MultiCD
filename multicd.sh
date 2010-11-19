#!/bin/bash
set -e
. ./functions.sh
#multicd.sh 6.1
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

#MCDDIR: directory where plugins.md5 and plugins folder are expected to be.
MCDDIR=$(pwd)
#WORK: the directory that the eventual CD/DVD contents will be stored temporarily.
export WORK=$(pwd)/multicd-working
#MNT: the directory inside which new folders will be made to mount the ISO images.
mkdir -p /tmp/multicd-$USER
export MNT=/tmp/multicd-$USER
#TAGS: used to store small text files (temporary)
export TAGS=$MNT/tags


if echo $* | grep -q "\bcleanlinks\b";then
	ls -la |grep ^l |awk '{ print $8,$10 }'|while read i;do
		if echo $i|awk '{print $2}'|grep -qv "/";then
			rm -v $(echo $i|awk '{print $1}')
		fi
	done
	rm -fv *.defaultname 2> /dev/null
	rm -fv *.version 2> /dev/null
	exit 0
fi

if !(uname|grep -q Linux);then
	echo "Only Linux kernels are supported at the moment (due to heavy use of \"-o loop\")."
fi
if [ $(whoami) != "root" ];then
	echo "This script must be run as root, so it can mount ISO images on the filesystem during the building process."
	exit 1
fi

if [ -d $TAGS ];then rm -r $TAGS;fi
mkdir -p $TAGS
mkdir $TAGS/puppies
chmod -R 777 $TAGS

if ( echo $* | grep -q "\bmd5\b" ) || ( echo $* | grep -q "\bc\b" );then
	MD5=true
else
	MD5=false
fi
if echo $* | grep -q "\bm\b";then
	MEMTEST=false
else
	MEMTEST=true
fi
if echo $* | grep -q "\bv\b";then
	export VERBOSE=true
else
	export VERBOSE=false
fi
if echo $* | grep -q "\bi\b";then
	INTERACTIVE=true
else
	INTERACTIVE=false
fi
if ( echo $* | grep -q "\bw\b" ) || ( echo $* | grep -q "\bwait\b" );then
	WAIT=true
else
	WAIT=false
fi

#START PREPARE#
#One parenthesis is for md5sums that don't match; the other is for plugins that are not listed in plugins.md5
UNKNOWNS="$(md5sum -c $MCDDIR/plugins.md5|grep FAILED|awk -F: '{print $1}') $(for i in $MCDDIR/plugins/*.sh;do grep -q $(basename $i) $MCDDIR/plugins.md5||echo $i;done)"
if [ "$UNKNOWNS" != " " ];then
	echo
	echo "Plugins that are not from the official release: $UNKNOWNS"
	echo "Make sure you trust every script in the plugins folder - all these scripts will get root access!"
	echo "Press Ctrl+C to cancel"
	echo
	sleep 2
fi

#Make the scripts executable.
for i in $MCDDIR/plugins/*;do
	[ ! -x $i ]&&chmod +x $i
done
#END PREPARE#

isoaliases #This function is in functions.sh

#START SCAN
for i in $MCDDIR/plugins/*;do
	$i scan
done
#END SCAN

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
if $MEMTEST;then
 echo "Memtest86+"
fi

echo
echo "Continuing in 2 seconds - press Ctrl+C to cancel"
sleep 2

if $INTERACTIVE;then
	if ! which dialog &> /dev/null;then
		echo "You must install dialog to use the interactive options."
		exit 1
	fi
	dialog --inputbox "What would you like the title of the CD's main menu to be?" 8 70 "MultiCD - Created $(date +"%b %d, %Y")" 2> /tmp/cdtitle
	CDTITLE=$(cat /tmp/cdtitle)
	rm /tmp/cdtitle
	dialog --inputbox "What would you like the CD label to be?" 9 40 "MultiCD" 2> /tmp/cdlabel
	export CDLABEL=$(cat /tmp/cdlabel)
	rm /tmp/cdlabel
	dialog --menu "What menu color would you like?" 0 0 0 40 black 41 red 42 green 43 brown 44 blue 45 magenta 46 cyan 2> /tmp/color
	MENUCOLOR=$(cat /tmp/color)
	echo $(echo -e "\r\033[0;$(cat /tmp/color)m")Color chosen.$(echo -e '\033[0;39m')
	rm /tmp/color
	dialog --inputbox "Enter the two-letter language code for the language you would like to use." 9 50 "en" 2> $TAGS/lang
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
		cat ./slaxlist0|sed -e 's/"//g' -e 's/ /\n/g'>$TAGS/slaxlist
		rm ./slaxlist0
		if wc -c $TAGS/slaxlist|grep -q 24;then #24 bytes means they are all checked
			rm $TAGS/slaxlist #If they are all checked, delete the file
		fi
	fi
	if [ -f win98se.iso ] || [ -f winme.iso ];then
		if dialog --yesno "Would you like to copy the \"tools\" and \"add-ons\" folders from the Windows 9x/Me CD?" 0 0;then
			touch $TAGS/9xextras
		fi
	fi
	if [ $(find $TAGS/puppies -maxdepth 1 -type f|wc -l) -gt 1 ] && which dialog &> /dev/null;then
		echo "dialog --radiolist \"Which Puppy variant would you like to be installable to HD from the disc?\" 13 45 6 \\">puppychooser
		for i in $TAGS/puppies/*;do
			echo $(basename $i) \"\" off \\ >> puppychooser
		done
		echo "2> puppyresult" >> puppychooser
		sh puppychooser
		touch $TAGS/puppies/$(cat puppyresult).inroot
		rm puppychooser puppyresult
	fi
	if [ $(find $TAGS/puppies -maxdepth 1 -type f|wc -l) -eq 1 ];then
		NAME=$(ls $TAGS/puppies)
		true>$(find $TAGS/puppies -maxdepth 1 -type f).inroot
	fi
	if which dialog &> /dev/null;then
		for i in $(find $TAGS -maxdepth 1 -name \*.needsname);do
			BASENAME=$(basename $i|sed -e 's/\.needsname//g')
			if [ -f $BASENAME.defaultname ];then
				DEFUALTTEXT=$(cat $BASENAME.defaultname)
			else
				DEFAULTTEXT=""
			fi
			dialog --inputbox "What would you like $BASENAME to be called on the CD boot menu?\n(Leave blank for the default.)" 10 70 \
			2> $(echo $i|sed -e 's/needsname/name/g')
		done
	fi
else
	CDTITLE="MultiCD - Created $(date +"%b %d, %Y")"
	export CDLABEL=MultiCD
	MENUCOLOR=44
	echo en > $TAGS/lang
	touch $TAGS/9xextras
	if [ $(find $TAGS/puppies -maxdepth 1 -type f|wc -l) -ge 1 ] && which dialog &> /dev/null;then #Greater or equal to 1 puppy installed
		touch $(find $TAGS/puppies -maxdepth 1 -type f|head -n 1) #This way, the first one alphabetically will be in the root dir
	fi
fi

if [ -d $WORK ];then
 rm -r $WORK/*
else
 mkdir $WORK
fi

#Make sure it exists, you need to put stuff there later
mkdir -p $WORK/boot/isolinux

#START COPY
for i in $MCDDIR/plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i copy
done
#END COPY

#The below chunk copies floppy images.
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	cp "$i" $WORK/boot/$j.img
	echo -n Copying $(echo $i|sed 's/\.im.//')"... "
	if $VERBOSE;then
		echo "Saved as "$j".img."
	else
		echo
	fi
	j=$( expr $j + 1 )
done

#This chunk copies floppy images in the "games" folder. They will have their own submenu.
if [ $GAMES = 1 ];then
	k="0"
	mkdir -p $WORK/boot/games
	for i in games/*.im[agz]; do
		test -r "$i" || continue
		echo -n Copying $(echo $i|sed 's/\.im.//'|sed 's/games\///')"... "
		cp "$i" $WORK/boot/games/$k.img
		if $VERBOSE;then
			echo "Saved as games/"$k".img."
		else
			echo
		fi
		k=$( expr $k + 1 )
	done
fi

if [ -f grub.exe ];then
 echo "Copying GRUB4DOS..."
 cp grub.exe $WORK/boot/grub.exe
fi

echo "Downloading SYSLINUX..." #Option 1 is to use an already present syslinux.tar.gz
if [ ! -f syslinux.tar.gz ] && [ -d /usr/lib/syslinux ];then #Option 2: Use installed syslinux
	#This will only be run if there is no syslinux.tar.gz file in the current dir.
	cp /usr/lib/syslinux/isolinux.bin $WORK/boot/isolinux/
	cp /usr/lib/syslinux/memdisk $WORK/boot/isolinux/
	cp /usr/lib/syslinux/menu.c32 $WORK/boot/isolinux/
	cp /usr/lib/syslinux/vesamenu.c32 $WORK/boot/isolinux/
	cp /usr/lib/syslinux/chain.c32 $WORK/boot/isolinux/
else
	if [ ! -f syslinux.tar.gz ];then #Option 3: Get syslinux.tar.gz and save it here
		if $VERBOSE ;then #These will only be run if there is no syslinux.tar.gz AND if syslinux is not installed on your PC
			#Both of these need to be changed when a new version of syslinux comes out.
			wget -O syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.03.tar.gz
		else
			wget -qO syslinux.tar.gz ftp://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.03.tar.gz
		fi
	fi
	echo "Unpacking and copying files..."
	tar -C /tmp -xzf syslinux.tar.gz
	cp /tmp/syslinux-*/core/isolinux.bin $WORK/boot/isolinux/
	cp /tmp/syslinux-*/memdisk/memdisk $WORK/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/menu.c32 $WORK/boot/isolinux/
	cp /tmp/syslinux-*/com32/menu/vesamenu.c32 $WORK/boot/isolinux/
	cp /tmp/syslinux-*/com32/modules/chain.c32 $WORK/boot/isolinux/
	cp /tmp/syslinux-*/utils/isohybrid $TAGS/isohybrid; PATH=$PATH:$TAGS
	rm -r /tmp/syslinux-*/
fi

if $MEMTEST;then
	if [ -f memtest ];then
		cp memtest $WORK/boot/memtest
	elif [ -f /boot/memtest86+.bin ];then
		cp /boot/memtest86+.bin $WORK/boot/memtest
	else
		echo "Downloading memtest86+ 4.10 from memtest.org..."
		if $VERBOSE;then
			wget -O- http://memtest.org/download/4.10/memtest86+-4.10.bin.gz|gzip -cd>memtest
		else
			wget -qO- http://memtest.org/download/4.10/memtest86+-4.10.bin.gz|gzip -cd>memtest
		fi
		cp memtest $WORK/boot/memtest
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
menu title $CDTITLE" > $WORK/boot/isolinux/isolinux.cfg
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
	menu color msg07 37;40"|sed -e "s/30/$BORDERCOLOR/g" -e "s/44/$MENUCOLOR/g">>$WORK/boot/isolinux/isolinux.cfg
#END COLOR CODE#

#BEGIN HD BOOT OPTION#
#If this bugs you, get rid of it.
echo "label local
menu label Boot from ^hard drive
kernel chain.c32
append hd0" >> $WORK/boot/isolinux/isolinux.cfg
#END HD BOOT OPTION#
#START WRITE
for i in $MCDDIR/plugins/*;do
	[ ! -x $i ]&&chmod +x $i
	$i writecfg
done
#END WRITE

#BEGIN DISK IMAGE ENTRY#
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	BASICNAME=$(echo $i|sed 's/\.im.//')
	echo label "$BASICNAME" >> $WORK/boot/isolinux/isolinux.cfg
	echo kernel memdisk >> $WORK/boot/isolinux/isolinux.cfg
	echo initrd /boot/$j.img >> $WORK/boot/isolinux/isolinux.cfg
	j=$( expr $j + 1 )
done
#END DISK IMAGE ENTRY#

#BEGIN GRUB4DOS ENTRY#
if [ -f $WORK/boot/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/grub.exe">>$WORK/boot/isolinux/isolinux.cfg
elif [ -f $WORK/boot/riplinux/grub4dos/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/riplinux/grub4dos/grub.exe">>$WORK/boot/isolinux/isolinux.cfg
fi
#END GRUB4DOS ENTRY#

#BEGIN GAMES ENTRY#
if [ $GAMES = 1 ];then
echo "label games
menu label ^Games on disk images
com32 menu.c32
append games.cfg">>$WORK/boot/isolinux/isolinux.cfg
fi
#END GAMES ENTRY#

#BEGIN MEMTEST ENTRY#
if [ -f $WORK/boot/memtest ];then
echo "label memtest
menu label ^Memtest86+
kernel /boot/memtest">>$WORK/boot/isolinux/isolinux.cfg
fi
#END MEMTEST ENTRY#
##END ISOLINUX MENU CODE##

if [ $GAMES = 1 ];then
k="0"
cat > $WORK/boot/isolinux/games.cfg << "EOF"
default menu.c32
timeout 300

menu title "Choose a game to play:"
EOF
for i in games/*.im[agz]; do
	test -r "$i" || continue
	BASICNAME=$(echo $i|sed 's/\.im.//'|sed 's/games\///')
	echo label "$BASICNAME" >> $WORK/boot/isolinux/games.cfg
	echo kernel memdisk >> $WORK/boot/isolinux/games.cfg
	echo initrd /boot/games/$k.img >> $WORK/boot/isolinux/games.cfg
	k=$( expr $k + 1 )
done
echo "label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg">>$WORK/boot/isolinux/games.cfg
fi

if [ -d includes ];then
 echo "Copying includes..."
 cp -r includes/* $WORK/
fi

if $WAIT;then
	chmod -R a+w $WORK/boot/isolinux #So regular users can edit menus
	echo "    Dropping to root prompt. Type \"exit\" to build the ISO image."
	echo "    Don't do anything hasty."
	echo "PS1=\"    mcd waiting# \"">/tmp/mcdprompt
	bash --rcfile /tmp/mcdprompt || sh
	rm /tmp/mcdprompt || true
fi

if $MD5;then
 echo "Generating MD5 checksums..."
 if $VERBOSE;then
	find $WORK/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin \
	-exec md5sum '{}' \; | sed "s^$WORK^^g" | tee $WORK/md5sum.txt
 else
	find $WORK/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin\
	-exec md5sum '{}' \; | sed "s^$WORK^^g" > $WORK/md5sum.txt
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
if ! $VERBOSE;then
	EXTRAARGS="$EXTRAARGS -quiet"
fi
if [ ! -f $TAGS/win9x ];then
	EXTRAARGS="$EXTRAARGS -iso-level 4" #To ensure that Windows 9x installation CDs boot properly
fi
echo "Building CD image..."
$GENERATOR -o multicd.iso \
-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
-no-emul-boot -boot-load-size 4 -boot-info-table \
-r -J $EXTRAARGS \
-V "$CDLABEL" $WORK/
rm -r $WORK/
isohybrid multicd.iso || true
chmod 666 multicd.iso
rm -r $TAGS
#END SCRIPTwget -
