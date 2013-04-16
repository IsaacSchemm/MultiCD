#!/bin/bash
set -e

#MCDDIR: directory where functions.sh, plugins.md5 and plugins folder are expected to be. Not used in a combined .sh file.
export MCDDIR="."
. "${MCDDIR}"/functions.sh

MCDVERSION="20130127"
#multicd.sh Jan. 27, 2013
#Copyright (c) 2013 Isaac Schemm
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

#Needs to be changed when a new version of syslinux comes out.
RECENT_SYSLINUX="4.06"

mcdclean() {
	for i in *;do
		if [ -n "$(readlink "$i"|grep -v '/')" ];then
			rm -v "$i"
		fi
	done
	rm -fv *.defaultname 2> /dev/null
	rm -fv *.version 2> /dev/null
}

#Clean operation runs here
if [ "$1" = "clean" ];then
	mcdclean
	exit 0 #quit program
else
	mcdclean
fi

#GUI helper - calls a terminal emulator which calls another multicd
if [ "$1" = "gui" ];then
	if which zenity &> /dev/null;then
		DIR=$(zenity --file-selection --directory --filename=$HOME/ --title="MultiCD - Choose directory")
		cd "$DIR"
		RUN="$0 -w"
	else
		RUN="$0 give-error"
	fi
	if which x-terminal-emulator &> /dev/null;then
		exec x-terminal-emulator -e $RUN
	else
		exec xterm -e $RUN
	fi
fi

if [ "$1" = "give-error" ];then
	echo "Zenity is not installed. Please navigate to your ISO directory in the terminal, and run multicd from there."
	echo "Press ENTER to continue..."
	read
	exit 1
fi

#if getopt -T > /dev/null;then
#	echo "You have a non-GNU getopt. Don't use an output path with spaces in it."
	ARGS=$(getopt cdmviVo:tw $*)
#else
#	ARGS=$(getopt cdmviVo:tw "$@")
#fi
export MD5=false
export MEMTEST=true
export VERBOSE=true
export INTERACTIVE=false
export DEBUG=false
export OUTPUT='multicd.iso'
export TESTISO=false
export WAIT=false
eval set -- $ARGS
for i do
	case "$i" in
		-c) shift;export MD5=true;;
		-d) shift;export DEBUG=true;;
		-i) shift;export INTERACTIVE=true;;
		-m) shift;export MEMTEST=false;;
		-o) shift;export OUTPUT="$1";shift;;
		-t) shift;export TESTISO=true;shift;;
		-v) shift;export VERBOSE=true;;
		-V) shift;echo $MCDVERSION;exit 0;; #quit program
		-w) shift;export WAIT=true;shift;;
	esac
done

if ! touch "${OUTPUT}" 2> /dev/null;then
	echo "Error: cannot write to "${OUTPUT}""
	exit 1
else
	rm "${OUTPUT}"
fi

#--------Directory Variables--------#
#WORK: the directory that the eventual CD/DVD contents will be stored temporarily.
export WORK="$(pwd)/multicd-working"
#MNT: the directory inside which new folders will be made to mount the ISO images.
export MNT="$(pwd)/temporary-mountpoints"
mkdir -p "${MNT}"
#TAGS: used to store small text files (temporary)
export TAGS="${MNT}/tags"

if [ $(whoami) = root ] && uname|grep -q Linux;then
	export EXTRACTOR=mount #When possible, loop-mount is preferred because it is faster (files are copied once, not twice, before the ISO is generated) and because it runs without an X server. However, it is only available to root, which opens up security risks.
elif which fuseiso &> /dev/null; then
	export EXTRACTOR=fuseiso
elif which 7z &> /dev/null;then
	export EXTRACTOR=7z #7z is a command line application
elif which ark &> /dev/null;then
	export EXTRACTOR=ark #Ark is a KDE application
elif which file-roller &> /dev/null;then
	export EXTRACTOR=file-roller #file-roller is a GNOME application
else
	if !(uname|grep -q Linux);then
		echo "Unless fuseiso, file-roller or ark is installed to extract ISOs, only Linux kernels are supported (due to the use of \"-o loop\")."
		exit 1
	elif [ $(whoami) != "root" ];then
		echo "Unless file-roller, ark or 7z is installed to extract ISOs, this script must be run as root, so it can mount ISO images on the filesystem during the building process."
		exit 1
	fi
fi
if ( [ $EXTRACTOR = file-roller ] || [ $EXTRACTOR = ark ] ) && [ ! -n "$DISPLAY" ];then
	echo "This script cannot use file-roller or ark to extract ISOs, because no X server  is available. Please launch an X server or run this script as root."
	exit 1
fi

if [ -d "${TAGS}" ];then rm -r "${TAGS}";fi
mkdir -p "${TAGS}"
mkdir "${TAGS}"/puppies
mkdir "${TAGS}"/debians
chmod -R 777 "${TAGS}"

#START PREPARE#

#Plugin check currently disabled because it seems like more of a distraction than it's worth.
#One parenthesis is for md5sums that don't match; the other is for plugins that are not listed in plugins.md5
#UNKNOWNS="$(md5sum -c "${MCDDIR}"/plugins.md5|grep FAILED|awk -F: '{print $1}') $(for i in "${MCDDIR}"/plugins/*.sh;do grep -q $(basename $i) "${MCDDIR}"/plugins.md5||echo $i;done)"
#if [ "$UNKNOWNS" != " " ];then
#	echo
#	echo "Plugins that are not from the official release: $UNKNOWNS"
#	if [ $(whoami) = root ];then
#		echo "Make sure you trust every script in the plugins folder - all these scripts will get root access!"
#	fi
#	echo "Press Ctrl+C to cancel"
#	echo
#	sleep 2
#fi

#END PREPARE#

isoaliases #This function is in functions.sh

echo "multicd.sh $MCDVERSION"
echo "Extracting ISO images with $EXTRACTOR; will build "${OUTPUT}"; UID $(id -u)."
echo

#START SCAN
for i in "${MCDDIR}"/plugins/*.sh;do
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

if [ $EXTRACTOR == file-roller ];then
	FRVER=$(file-roller --version 2>/dev/null|awk '{print $2}'|head -c 3)
	if [ $(echo "${FRVER}<3.5"|bc) == 0 ];then
		echo
		echo "WARNING: versions of file-roller newer than 3.4.xx may not successfully extract ISOs! Installing fuseiso is recommended." 1>&2
	fi
fi

echo
echo "Continuing in 2 seconds - press Ctrl+C to cancel"
sleep 2

if $INTERACTIVE;then
	if ! which dialog &> /dev/null;then
		echo "You must install dialog to use the interactive options."
		exit 1
	fi

	dialog --inputbox "What would you like the title of the CD's main menu to be?" 8 70 "MultiCD - Created $(LANG=C date +"%b %d, %Y")" 2> /tmp/cdtitle
	CDTITLE=$(cat /tmp/cdtitle)
	rm /tmp/cdtitle

	dialog --inputbox "What would you like the CD label to be?" 9 40 "MultiCD" 2> /tmp/cdlabel
	export CDLABEL=$(cat /tmp/cdlabel)
	rm /tmp/cdlabel

	dialog --menu "What menu BACKGROUND color would you like?" 0 0 0 40 black 41 red 42 green 43 brown 44 blue 45 magenta 46 cyan 47 white 2> /tmp/color
	MENUCOLOR=$(cat /tmp/color)
	echo $(echo -e "\r\033[0;$(cat /tmp/color)m")Color chosen.$(echo -e '\033[0;39m')
	rm /tmp/color

	dialog --menu "What menu TEXT color would you like?" 0 0 0 37 white 30 black 31 red 32 green 33 brown 34 blue 35 magenta 36 cyan 2> /tmp/color
	TEXTCOLOR=$(cat /tmp/color)
	echo $(echo -e "\r\033[0;$(cat /tmp/color)m")Color chosen.$(echo -e '\033[0;39m')
	rm /tmp/color

	dialog --inputbox "Enter the language code for the language you would like to use.\n\
Leaving this empty will leave the choice up to the plugin (usually English.)\n\
Examples: fr_FR = Francais (France); es_ES = Espanol (Espana)" 12 50 "${LANGFULL}" 2> "${TAGS}"/lang-full

	dialog --inputbox "Enter the code for your keyboard layout.\n
Leaving this blank will typically default to QWERTY (US).\n\
Examples: fr (AZERTY France), fr_CH (QWERTZ Switzerland)" 12 50 "${COUNTRY}" 2> "${TAGS}"/country

	if [ -f slax.iso ];then
		dialog --checklist "Slax modules to include:" 13 45 6 \
		002 Xorg on \
		003 KDE on \
		004 "KDE applications" on \
		005 "KDE Office" on \
		006 Development on \
		007 Firefox on \
		2> "${TAGS}"/slaxlist0
		echo >> "${TAGS}"/slaxlist0
		cat "${TAGS}"/slaxlist0|sed -e 's/"//g' -e 's/ /\n/g'>"${TAGS}"/slaxlist
		rm "${TAGS}"/slaxlist0
		if wc -c "${TAGS}"/slaxlist|grep -q 24;then #24 bytes means they are all checked
			rm "${TAGS}"/slaxlist #If they are all checked, delete the file
		fi
	fi
	if [ -f porteus.iso ];then
		dialog --checklist "Porteus modules to include:" 13 45 6 \
		002 Xorg on \
		003 LXDE on \
		004 KDE on \
		005 "KDE apps" on \
		006 KOffice on \
		007 Development on \
		008 Firefox on \
		2> "${TAGS}"/porteuslist0
		echo >> "${TAGS}"/porteuslist0
		cat "${TAGS}"/porteuslist0|sed -e 's/"//g' -e 's/ /\n/g'>"${TAGS}"/porteuslist
		rm "${TAGS}"/porteuslist0
		if wc -c "${TAGS}"/porteuslist|grep -q 28;then #28 bytes means they are all checked
			rm "${TAGS}"/porteuslist #If they are all checked, delete the file
		fi
	fi
	if [ -f win98se.iso ] || [ -f winme.iso ];then
		if dialog --yesno "Would you like to copy the \"tools\" and \"add-ons\" folders from the Windows 9x/Me CD?" 0 0;then
			touch "${TAGS}"/9xextras
		fi
	fi
	if [ $(find "${TAGS}"/puppies -maxdepth 1 -type f|wc -l) -gt 1 ] && which dialog &> /dev/null;then
		echo "dialog --radiolist \"Which Puppy variant would you like to be installable to HD from the disc?\" 13 45 6 \\">puppychooser
		for i in "${TAGS}"/puppies/*;do
			echo $(basename $i) \"\" off \\ >> puppychooser
		done
		echo "2> puppyresult" >> puppychooser
		sh puppychooser
		touch "${TAGS}"/puppies/$(cat puppyresult).inroot
		rm puppychooser puppyresult
	elif [ $(find "${TAGS}"/puppies -maxdepth 1 -type f|wc -l) -eq 1 ];then
		NAME=$(ls "${TAGS}"/puppies)
		true>$(find "${TAGS}"/puppies -maxdepth 1 -type f).inroot
	fi
	if [ $(find "${TAGS}"/debians -maxdepth 1 -type f|wc -l) -gt 1 ] && which dialog &> /dev/null;then
		echo "dialog --radiolist \"Which Debian-Live variant would you like to be installable to HD from the disc?\" 13 45 6 \\">debianschooser
		for i in "${TAGS}"/debians/*;do
			echo $(basename $i) \"\" off \\ >> debianschooser
		done
		echo "2> debiansresult" >> debianschooser
		sh debianschooser
		touch "${TAGS}"/debians/$(cat debiansresult).inroot
		rm debianschooser debiansresult
	elif [ $(find "${TAGS}"/debians -maxdepth 1 -type f|wc -l) -eq 1 ];then
		NAME=$(ls "${TAGS}"/debians)
		TAG_TO_TOUCH=$(find "${TAGS}"/debians -maxdepth 1 -type f).inroot
		true>"$TAG_TO_TOUCH"
	fi
	if which dialog &> /dev/null;then
		find "${TAGS}" -maxdepth 1 -name \*.needsname|while read i;do
			BASENAME=$(basename "$i"|sed -e 's/\.needsname//g')
			if [ -f $BASENAME.defaultname ];then
				DEFUALTTEXT=$(cat $BASENAME.defaultname)
			else
				DEFAULTTEXT=""
			fi
			NAME_FILE=$(echo $i|sed -e 's/needsname/name/g')
			dialog --inputbox "What would you like $BASENAME to be called on the CD boot menu?\n(Leave blank for the default.)" 10 70 \
			2> "$NAME_FILE"
			if [ "$(cat "${TAGS}"/$BASENAME.name)" = "" ] && [ -f $BASENAME.defaultname ];then
				cp $BASENAME.defaultname "${TAGS}"/$BASENAME.name
			fi
		done
	else
		for i in $(find "${TAGS}" -maxdepth 1 -name \*.needsname);do
			BASENAME=$(basename $i|sed -e 's/\.needsname//g')
			if [ -f $BASENAME.defaultname ];then
				cp $BASENAME.defaultname "${TAGS}"/$BASENAME.name
			fi
		done
	fi
else
	#Do these things if interactive options are not enabled with "-i"
	CDTITLE="MultiCD - Created $(LANG=C date +"%b %d, %Y")"
	export CDLABEL=MultiCD
	MENUCOLOR=44
	TEXTCOLOR=37
	if [ "$LANGFULL" ] && [ "$LANGFULL" != "C" ];then
		echo "$LANGFULL" > "${TAGS}"/lang-full
	fi
	if [ $COUNTRY ];then
		echo "$COUNTRY" > "${TAGS}"/country
	fi
	touch "${TAGS}"/9xextras
	for i in puppies debians;do
		if [ $(find "${TAGS}"/$i -maxdepth 1 -type f|wc -l) -ge 1 ] && which dialog &> /dev/null;then #Greater or equal to 1 puppy installed
			FILE=$(find "${TAGS}"/$i -maxdepth 1 -type f|head -n 1)
			touch "$FILE.inroot" #This way, the first one alphabetically will be in the root dir
		fi
	done
	for i in $(find "${TAGS}" -maxdepth 1 -name \*.needsname);do
		BASENAME=$(basename $i|sed -e 's/\.needsname//g')
		if [ -f $BASENAME.defaultname ];then
			cp $BASENAME.defaultname "${TAGS}"/$BASENAME.name
		fi
	done
fi

for i in lang-full country;do
	if [ -f "${TAGS}"/$i ] && ( [ -z $(cat "${TAGS}"/$i) ] || [ $(cat "${TAGS}"/$i) = "C" ] ); then
		rm "${TAGS}"/$i #The user didn't enter anything - removing this tag file will let the plugin decide which language to use.
	fi
done
if [ -f "${TAGS}"/lang-full ];then
	#Get two-letter code (e.g. the first part) for plugins that only use that part of the lang code
	cut -c1-2 < "${TAGS}"/lang-full > "${TAGS}"/lang
fi

if [ -d "${WORK}" ];then
 rm -r "${WORK}"/*
else
 mkdir "${WORK}"
fi

#Make sure it exists, you need to put stuff there later
mkdir -p "${WORK}"/boot/isolinux

#START COPY
echo "Copying files for each plugin...";
for i in "${MCDDIR}"/plugins/*.sh;do
	[ ! -x "$i" ]&&chmod +x "$i"
	"$i" copy
done
#END COPY

#The below chunk copies floppy images.
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	cp "$i" "${WORK}"/boot/$j.img
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
	mkdir -p "${WORK}"/boot/games
	for i in games/*.im[agz]; do
		test -r "$i" || continue
		echo -n Copying $(echo $i|sed 's/\.im.//'|sed 's/games\///')"... "
		cp "$i" "${WORK}"/boot/games/$k.img
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
 cp grub.exe "${WORK}"/boot/grub.exe
fi

if [ -f syslinux-4.03.tar.gz ] && [ ! -f syslinux.tar.gz ];then
	ln -s syslinux-4.03.tar.gz syslinux.tar.gz #Link newest version
fi

if [ ! -f syslinux.tar.gz ];then
	echo "Downloading SYSLINUX..."
	if $VERBOSE ;then #These will only be run if there is no syslinux.tar.gz
		#Both of these need to be changed when a new version of syslinux comes out.
		if ! wget -t 1 -O syslinux.tar.gz https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$RECENT_SYSLINUX.tar.gz;then
			echo "Error: could not download SYSLINUX. Please update the URL in $0."
			rm syslinux.tar.gz
			false #quits script
		fi
	else
		if ! wget -t 1 -qO syslinux.tar.gz https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$RECENT_SYSLINUX.tar.gz;then
			echo "Error: could not download SYSLINUX. Please update the URL in $0."
			rm syslinux.tar.gz
			false #quits script
		fi
	fi
fi
echo "Unpacking and copying SYSLINUX files..."
tar -C /tmp -xzf syslinux.tar.gz
cp /tmp/syslinux-*/core/isolinux.bin "${WORK}"/boot/isolinux/
cp /tmp/syslinux-*/memdisk/memdisk "${WORK}"/boot/isolinux/
cp /tmp/syslinux-*/com32/menu/menu.c32 "${WORK}"/boot/isolinux/
cp /tmp/syslinux-*/com32/menu/vesamenu.c32 "${WORK}"/boot/isolinux/
cp /tmp/syslinux-*/com32/chain/chain.c32 "${WORK}"/boot/isolinux/
cp /tmp/syslinux-*/utils/isohybrid "${TAGS}"/isohybrid
chmod -R +w "$WORK/boot/isolinux"
chmod +x "${TAGS}"/isohybrid
rm -r /tmp/syslinux-*/

if $MEMTEST;then
	if [ -f memtest ] && [ "$(wc -c memtest)" != "0" ];then
		cp memtest "${WORK}"/boot/memtest
	else
		echo "Downloading memtest86+ 4.20 from memtest.org..."
		if $VERBOSE;then
			wget -O- http://memtest.org/download/4.20/memtest86+-4.20.bin.gz|gzip -cd>memtest
		else
			wget -qO- http://memtest.org/download/4.20/memtest86+-4.20.bin.gz|gzip -cd>memtest
		fi
		if [ -f memtest ] && [ "$(wc -c memtest)" != "0 memtest" ];then
			cp memtest "${WORK}"/boot/memtest
			echo 'v4.20' > memtestver
		else
			echo "Download of memtest failed."
		fi
	fi
fi

echo "Writing isolinux.cfg..."

##BEGIN ISOLINUX MENU CODE##
#The ISOLINUX menu can be rearranged by renaming your plugin scripts - they are processed in alphabetical order.

#BEGIN HEADER#
#Don't move this part. You can change the timeout and menu title, however.
echo "DEFAULT menu.c32
TIMEOUT 0
PROMPT 0" > "${WORK}"/boot/isolinux/isolinux.cfg
#Changed to use $TAGS/country instead of the old $ccTLD
if [ -f "${TAGS}/country" ];then #PDV
	cp -r maps "${WORK}"/boot/isolinux
	echo "KBDMAP maps/$(cat "${TAGS}"/country).ktl" >> "${WORK}"/boot/isolinux/isolinux.cfg
fi
echo "menu title $CDTITLE" >> "${WORK}"/boot/isolinux/isolinux.cfg
#END HEADER#

#BEGIN COLOR CODE#
	if [ $MENUCOLOR = 40 ];then
		BORDERCOLOR=37 #white border
	else
		BORDERCOLOR=30 #black border
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
	menu color msg07 37;40"|sed \
	-e "s/30/$BORDERCOLOR/g" -e "s/44/$MENUCOLOR/g"|sed \
	-e "s/unsel 37/unsel $TEXTCOLOR/g" >>"${WORK}"/boot/isolinux/isolinux.cfg
#END COLOR CODE#

#BEGIN HD BOOT OPTION#
#If this bugs you, get rid of it.
echo "label local
menu label Boot from ^hard drive
kernel chain.c32
append hd0" >> "${WORK}"/boot/isolinux/isolinux.cfg
#END HD BOOT OPTION#
#START WRITE
for i in "${MCDDIR}"/plugins/*.sh;do
	[ ! -x $i ]&&chmod +x $i
	$i writecfg
done
#END WRITE

#BEGIN DISK IMAGE ENTRY#
j="0"
for i in *.im[agz]; do
	test -r "$i" || continue
	BASICNAME=$(echo $i|sed 's/\.im.//')
	echo label "$BASICNAME" >> "${WORK}"/boot/isolinux/isolinux.cfg
	echo kernel memdisk >> "${WORK}"/boot/isolinux/isolinux.cfg
	echo initrd /boot/$j.img >> "${WORK}"/boot/isolinux/isolinux.cfg
	j=$( expr $j + 1 )
done
#END DISK IMAGE ENTRY#

#BEGIN GRUB4DOS ENTRY#
if [ -f "${WORK}"/boot/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/grub.exe">>"${WORK}"/boot/isolinux/isolinux.cfg
elif [ -f "${WORK}"/boot/riplinux/grub4dos/grub.exe ];then
echo "label grub4dos
menu label ^GRUB4DOS
kernel /boot/riplinux/grub4dos/grub.exe">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
#END GRUB4DOS ENTRY#

#BEGIN GAMES ENTRY#
if [ $GAMES = 1 ];then
echo "label games
menu label ^Games on disk images
com32 menu.c32
append games.cfg">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
#END GAMES ENTRY#

#BEGIN MEMTEST ENTRY#
if [ -f "${WORK}"/boot/memtest ];then
echo "label memtest
menu label ^Memtest86+ $(cat memtestver)
kernel /boot/memtest">>"${WORK}"/boot/isolinux/isolinux.cfg
fi
#END MEMTEST ENTRY#
##END ISOLINUX MENU CODE##

if [ $GAMES = 1 ];then
k="0"
cat > "${WORK}"/boot/isolinux/games.cfg << "EOF"
default menu.c32
timeout 300

menu title "Choose a game to play:"
EOF
for i in games/*.im[agz]; do
	test -r "$i" || continue
	BASICNAME=$(echo $i|sed 's/\.im.//'|sed 's/games\///')
	echo label "$BASICNAME" >> "${WORK}"/boot/isolinux/games.cfg
	echo kernel memdisk >> "${WORK}"/boot/isolinux/games.cfg
	echo initrd /boot/games/$k.img >> "${WORK}"/boot/isolinux/games.cfg
	k=$( expr $k + 1 )
done
echo "label back
menu label Back to main menu
com32 menu.c32
append isolinux.cfg">>"${WORK}"/boot/isolinux/games.cfg
fi

if [ -d includes ] && [ "$(echo empty/.* empty/*)" != 'empty/. empty/.. empty/*' ] ;then
 echo "Copying includes..."
 cp -r includes/* "${WORK}"/
fi

if $DEBUG;then
	chmod -R a+w "${WORK}"/boot/isolinux #So regular users can edit menus
	echo "    Dropping to $(whoami) prompt. Type \"exit\" to build the ISO image."
	echo "    Don't do anything hasty."
	echo "PS1=\"    mcd debug# \"">/tmp/mcdprompt
	bash --rcfile /tmp/mcdprompt
	rm /tmp/mcdprompt || true
fi

if $MD5;then
	echo "Generating MD5 checksums..."
	if which md5sum &> /dev/null;then
		MD5SUM=md5sum
	else
		MD5SUM=md5
	fi
	if $VERBOSE;then
		find "${WORK}"/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin \
		-exec $MD5SUM '{}' \; | sed "s^"${WORK}"^^g" | tee "${WORK}"/md5sum.txt
	else
		find "${WORK}"/ -type f -not -name md5sum.txt -not -name boot.cat -not -name isolinux.bin\
		-exec $MD5SUM '{}' \; | sed "s^"${WORK}"^^g" > "${WORK}"/md5sum.txt
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
if [ ! -f "${TAGS}"/win9x ];then
	EXTRAARGS="$EXTRAARGS -iso-level 4" #To ensure that Windows 9x installation CDs boot properly
fi
echo "Building CD image..."
$GENERATOR -o ""${OUTPUT}"" \
-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
-no-emul-boot -boot-load-size 4 -boot-info-table \
-r -J $EXTRAARGS \
-V "$CDLABEL" "${WORK}"/
rm -rf "${WORK}"/

echo "Running isohybrid..."
#if which isohybrid > /dev/null;then
#	isohybrid ""${OUTPUT}"" 2> /dev/null || echo "The installed isohybrid gave an error status of $?. The ISO might not work on a flash drive."
#else
	"${TAGS}"/isohybrid ""${OUTPUT}"" 2> /dev/null || echo "isohybrid gave an error status of $?. The ISO might not work on a flash drive."
	rm "${TAGS}"/isohybrid
#fi
if [ $(whoami) == "root" ];then
	chmod 666 ""${OUTPUT}""
fi
rm -r "${TAGS}" "${MNT}"

if $TESTISO;then
	RAM_FREE=$(free -m|awk 'NR == 3 {print $4}') #Current free RAM in MB, without buffers/cache
	#Determine how much RAM to use. There is no science to this; I just arbitrarily chose these cutoff points.
	if [ $RAM_FREE -ge 2048 ];then
		RAM_TO_USE=1024
	elif [ $RAM_FREE -ge 1024 ];then
		RAM_TO_USE=512
	elif [ $RAM_FREE -ge 512 ];then
		RAM_TO_USE=256
	else
		RAM_TO_USE=128
	fi
	if which kvm &> /dev/null;then
		kvm -m $RAM_TO_USE -cdrom ""${OUTPUT}""&
	elif which qemu &> /dev/null;then
		qemu -m $RAM_TO_USE -cdrom ""${OUTPUT}""&
	else
		echo "Cannot test "${OUTPUT}" in a VM. Please install qemu or qemu-kvm."
	fi
fi

echo "Cleaning current directory..."
mcdclean

if $WAIT;then
	echo "Done. Press ENTER to exit."
	read
fi
#END SCRIPT
