#!/bin/sh
mcdcp() {
	cp -l "$@" 2> /dev/null || cp "$@"
}

mcdmount () {
	# "${MNT}" is defined in multicd.sh and is normally in /tmp
	# $1 is the argument passed to mcdmount - used for both ISO name and mount folder name
	if [ $EXTRACTOR = mount ] && grep -q "${MNT}"/$1 /etc/mtab ; then
		umount "${MNT}"/$1
	fi
	if [ -d "${MNT}"/$1 ];then
		rm -r "${MNT}"/$1
	fi
	mkdir "${MNT}"/$1
	if [ $EXTRACTOR = file-roller ];then
		file-roller -e "${MNT}"/$1 $1.iso
		chmod -R +w "${MNT}"/$1 #To avoid confirmation prompts on BSD cp
	elif [ $EXTRACTOR = ark ];then
		ark -b -o "${MNT}"/$1 $1.iso
		chmod -R +w "${MNT}"/$1 #To avoid confirmation prompts on BSD cp
	elif [ $EXTRACTOR = 7z ];then
		7z x -o"${MNT}"/$1 $1.iso
		chmod -R +w "${MNT}"/$1 #To avoid confirmation prompts on BSD cp
	elif [ $EXTRACTOR = win7z ];then
		OUTPATH=$(cygpath -wa "${MNT}"/$1)
		"${WIN7ZSEARCHPATH}/7z.exe" x -o"$OUTPATH" "$(cygpath -wa $1.iso)"
	elif [ $EXTRACTOR = mount ];then
		mount -o loop,ro $1.iso "${MNT}"/$1/
	elif [ $EXTRACTOR = fuseiso ];then
		fuseiso $1.iso "${MNT}"/$1 -orw,umask=0000
	else
		echo "mcdmount function: \$EXTRACTOR not defined! (this is a bug in multicd.sh)"
		exit 1
	fi
}
umcdmount () {
	if [ $EXTRACTOR = mount ];then
		umount "${MNT}"/$1;rmdir "${MNT}"/$1
	elif [ $EXTRACTOR = fuseiso ];then
		fusermount -u "${MNT}"/$1; rmdir "${MNT}"/$1
	else
		rm -r "${MNT}"/$1
	fi
}

isoaliases () {
	true > "${TAGS}"/linklist #Clears the file that keeps track of the links.

	#The data from START LINKS to END LINKS is not copied when combine.sh makes a single file.
	#In that case, this is instead handled by adding " >> "${TAGS}"/linklist" to each line in the "links" section of a plugin.
	#START LINKS#
	for i in "${MCDDIR}"/plugins/*;do
		if ! ("$i" links|grep -q Usage);then
			"$i" links >> "${TAGS}"/linklist
		fi
	done
	#END LINKS#

	cat "${TAGS}"/linklist|while read i;do

		DEFAULTNAME=$(echo "$i"|awk '{print $NF}')
		LINKNAME=$(echo "$i"|awk '{LESS=NF-1; print $LESS}') #What should be linked to
		MATCHING_ISOS=$(echo $i|awk '{LESS=NF-1; for (i=1; i<LESS; i++) print $i }') #Prints all except the last 2 fields. $i is NOT surrounded by quotes, so wildcards are expanded.

		FOUND=false
		if [ -f "$MATCHING_ISOS" ];then
			FOUND=true
		else
			#probably has an asterisk
			if [ "$(echo $MATCHING_ISOS)" != "$MATCHING_ISOS" ];then
				#asterisks expanded
				FOUND=true
			fi
		fi

		if $FOUND;then
			COUNTER=0
			for j in $MATCHING_ISOS;do
				#This is done for each matching ISO.

				LINKTO=$LINKNAME #The intended link name.
				while [ -f "$LINKTO" ];do
					#Adds the counter number and an underscore to the beginning of the link name.
					#This is used when more than one matching ISO is present - e.g. TinyCore-5.0.iso and TinyCore-5.3.iso
					COUNTER=$(($COUNTER+1))
					LINKTO=${COUNTER}_${LINKNAME}
				done

				if [ -e "$j" ] && ln -s $j $LINKTO;then
					#The ISO that the link should point to exists, and the link was created sucessfully.

					JBASENAME=$(echo $j|sed -e 's/\.iso//g')
					ISOBASENAME=$(echo $LINKTO|sed -e 's/\.iso//g')
					if [ -f "$JBASENAME.name" ];then
						if [ -f "$ISOBASENAME.name" ];then
							true #echo "Custom name $ISOBASENAME.name exists - not overwriting"
						else
							#echo "Custom name $JBASENAME.name found - linking to $ISOBASENAME.name"
							ln -sv "$JBASENAME.name" "$ISOBASENAME.name"
						fi
					fi

					touch "${TAGS}"/madelinks #This function will pause for 1 second if this file exists, so the notifications are readable

					CUTOUT1=$(echo "$i"|awk 'BEGIN {FS = "*"} ; {print $1}') #The parts of the ISO name before the asterisk
					CUTOUT2=$(echo "$i"|awk '{print $1}'|awk 'BEGIN {FS = "*"} ; {print $2}') #The parts after the asterisk
					VERSION=$(echo "$j"|awk '{sub(/'"$CUTOUT1"'/,"");sub(/'"$CUTOUT2"'/,"");print}') #Cuts out whatever the asterisk represents (which will be the version number)

					if [ "$VERSION" != "*" ] && [ "$VERSION" != "$j" ];then
						echo $VERSION > $ISOBASENAME.version #Some plugins (like SystemRescueCD) don't use this, because the version number is on a file in the ISO. Others don't use it because I forgot it exists.
						echo "Made a link named $LINKTO pointing to $j (version $VERSION)"
					else	
						echo "Made a link named $LINKTO pointing to $j"
						VERSION="*"
					fi
					if [ "$DEFAULTNAME" != "none" ];then
						#The last field of the row will be the default name when multicd.sh asks the user to enter a name (activated with "i" option.)
						#This could also be used by the menu-writing portion of the plugin script if "${TAGS}"/whatever.name (created by the "i" option) is not present.
						#Underscores are replaced with spaces. Asterisks are replaced with the $VERSION found above.
						if [ ! -f $ISOBASENAME.defaultname ];then
							echo $DEFAULTNAME|sed -e 's/_/ /g' -e "s/\*/$VERSION/g">$ISOBASENAME.defaultname
						fi
					fi
				fi
			done
		fi
	done

	if [ "$(echo *.name)" != '*.name' ];then
		echo "Linking all .name files to .defaultname files, overriding when necessary"
		for i in *.name;do
			ln -s -fv "$i" "$(echo $i|sed -e 's/\.name/\.defaultname/g')"
		done
	fi

	if [ -f "${TAGS}"/madelinks ];then
		#If the file exists, remove it, then pause for 1 second so the notifications can be seen.
		rm "${TAGS}"/madelinks
		sleep 1
	fi
}

puppycommon () {
	if [ ! -z "$1.puppy" ] && [ -f $1.puppy.iso ];then
		mcdmount $1.puppy
		#The installer will only work if Puppy is in the root dir of the disc
		if [ -f "${TAGS}"/puppies/$1.inroot ];then
			cp "${MNT}"/$1.puppy/*.sfs "${WORK}"/
			cp "${MNT}"/$1.puppy/vmlinuz "${WORK}"/vmlinuz
			cp "${MNT}"/$1.puppy/initrd.gz "${WORK}"/initrd.gz
		else
			mkdir "${WORK}"/$1
			cp "${MNT}"/$1.puppy/*.sfs "${WORK}"/$1/
			cp "${MNT}"/$1.puppy/vmlinuz "${WORK}"/$1/vmlinuz
			cp "${MNT}"/$1.puppy/initrd.gz "${WORK}"/$1/initrd.gz
		fi
		umcdmount $1.puppy
	else
		echo "$0: \"$1.puppy\" is empty or not an ISO, so it will not be copied. This is a bug."
		exit 1
	fi
}
ubuntucommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		mcdcp -R "${MNT}"/$1/casper "${WORK}"/boot/$1 #Live system
		if [ -d "${MNT}"/$1/preseed ];then
			cp -R "${MNT}"/$1/preseed "${WORK}"/boot/$1
		fi
		# Fix the isolinux.cfg
		if [ -f "${MNT}"/$1/isolinux/text.cfg ];then
			UBUCFG=text.cfg
		elif [ -f "${MNT}"/$1/isolinux/txt.cfg ];then
			UBUCFG=txt.cfg
		else
			UBUCFG=isolinux.cfg #For custom-made live CDs like Weaknet and Zorin
		fi
		cp "${MNT}"/$1/isolinux/splash.* \
		"${MNT}"/$1/isolinux/bg_redo.png \
		"${WORK}"/boot/$1/ 2> /dev/null || true #Splash screen - only if the filename is splash.something or bg_redo.png
		cp "${MNT}"/$1/isolinux/$UBUCFG "${WORK}"/boot/$1/$1.cfg
		echo "label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> "${WORK}"/boot/$1/$1.cfg
		sed -i "s@menu background @menu background /boot/$1/@g" "${WORK}"/boot/$1/$1.cfg #If it uses a splash screen, update the .cfg to show the new location
		sed -i "s@MENU BACKGROUND @MENU BACKGROUND /boot/$1/@g" "${WORK}"/boot/$1/$1.cfg #uppercase
		sed -i "s@default live@default menu.c32@g" "${WORK}"/boot/$1/$1.cfg #Show menu instead of boot: prompt
		sed -i "s@file=/cdrom/preseed/@file=/cdrom/boot/$1/preseed/@g" "${WORK}"/boot/$1/$1.cfg #Preseed folder moved - not sure if ubiquity uses this
		sed -i "s^initrd=/casper/^live-media-path=/boot/$1 ignore_uuid initrd=/boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Initrd moved, ignore_uuid added
		sed -i "s^kernel /casper/^kernel /boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Kernel moved
		sed -i "s^KERNEL /casper/^KERNEL /boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #For uppercase KERNEL
		if [ -f "${TAGS}"/lang ];then
			echo added lang
			sed -i "s^initrd=/boot/$1/^debian-installer/language=$(cat "${TAGS}"/lang) initrd=/boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Add language codes to cmdline
		fi
		if [ -f "${TAGS}"/country ];then
			echo added country
			sed -i "s^initrd=/boot/$1/^console-setup/layoutcode?=$(cat "${TAGS}"/country) initrd=/boot/$1/^g" "${WORK}"/boot/$1/$1.cfg #Add language codes to cmdline
		fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}

#Returns the version saved by the isoaliases function. For use in writing the menu.
getVersion() {
	BASENAME=$(echo $1|sed -e 's/\.iso//g')
	if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
		VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
	else
		VERSION=""
	fi

	echo ${VERSION}
}
#END FUNCTIONS
