#!/bin/sh
mcdmount () {
	# $MNT is defined in multicd.sh and is normally in /tmp
	# $1 is the argument passed to mcdmount - used for both ISO name and mount folder name
	if [ $EXTRACTOR = mount ] && grep -q $MNT/$1 /etc/mtab ; then
		umount $MNT/$1
	fi
	if [ -d $MNT/$1 ];then
		rm -r $MNT/$1
	fi
	mkdir $MNT/$1
	if [ $EXTRACTOR = file-roller ];then
		file-roller -e $MNT/$1 $1.iso
		chmod -R +w $MNT/$1 #To avoid confirmation prompts on BSD cp
	elif [ $EXTRACTOR = ark ];then
		ark -b -o $MNT/$1 $1.iso
		chmod -R +w $MNT/$1 #To avoid confirmation prompts on BSD cp
	elif [ $EXTRACTOR = mount ];then
		mount -o loop $1.iso $MNT/$1/
	else
		echo "mcdmount function: \$EXTRACTOR not defined! (this is a bug in multicd.sh)"
		exit 1
	fi
}
umcdmount () {
	if [ $EXTRACTOR = mount ];then
		umount $MNT/$1;rmdir $MNT/$1
	else
		rm -r $MNT/$1
	fi
}

isoaliases () {
	true > $TAGS/linklist #Clears the file that keeps track of the links.

	#The data from START LINKS to END LINKS is not copied when combine.sh makes a single file.
	#In that case, this is instead handled by adding " >> $TAGS/linklist" to each line in the "links" section of a plugin.
	#START LINKS#
	for i in $MCDDIR/plugins/*;do
		if ! ($i links|grep -q Usage);then
			$i links >> $TAGS/linklist
		fi
	done
	#END LINKS#

	cat $TAGS/linklist|while read i;do

		DEFAULTNAME=$(echo "$i"|awk '{print $NF}')
		LINKNAME=$(echo "$i"|awk '{LESS=NF-1; print $LESS}') #What should be linked to
		MATCHING_ISOS=$(echo $i|awk '{LESS=NF-1; for (i=1; i<LESS; i++) print $i }') #Prints all except the last 2 fields. $i is NOT surrounded by quotes, so wildcards are expanded.

		if !( echo $MATCHING_ISOS | grep -q '\*' ) && [ ! -e $LINKNAME ];then
			#MATCHING_ISOS exists (i.e. the asterisk got expanded) and LINKNAME doesn't exist yet
			COUNTER=0
			for j in $MATCHING_ISOS;do
				#This is done for each matching ISO.

				if [ $COUNTER = 0 ];then
					LINKTO=$LINKNAME #The intended link name.
				else
					#Adds the counter number and an underscore to the beginning of the link name.
					#This is done for all link names with more than one matching ISO, but only plugins that support multiples (i.e. ubuntu.sh) will pick up the extra ISO names.
					#This might cause a little (harmless) clutter in the working directory.
					LINKTO=${COUNTER}_${LINKNAME}
				fi

				if [ -e "$j" ] && ln -s $j $LINKTO;then
					#The ISO that the link should point to exists, and the link was created sucessfully.

					ISOBASENAME=$(echo $LINKTO|sed -e 's/\.iso//g')

					touch $TAGS/madelinks #This function will pause for 1 second if this file exists, so the notifications are readable

					CUTOUT1=$(echo "$i"|awk 'BEGIN {FS = "*"} ; {print $1}') #The parts of the ISO name before the asterisk
					CUTOUT2=$(echo "$i"|awk '{print $1}'|awk 'BEGIN {FS = "*"} ; {print $2}') #The parts after the asterisk
					VERSION=$(echo "$j"|awk '{sub(/'"$CUTOUT1"'/,"");sub(/'"$CUTOUT2"'/,"");print}') #Cuts out whatever the asterisk represents (which will be the version number)

					if [ "$VERSION" != "*" ] && [ "$VERSION" != "$j" ];then
						echo $VERSION > $ISOBASENAME.version #Some plugins (like SystemRescueCD) don't use this, because the version number is on a file in the ISO.
						echo "Made a link named $LINKTO pointing to $j (version $VERSION)"
					else	
						echo "Made a link named $LINKTO pointing to $j"
						VERSION="*"
					fi
					if [ "$DEFAULTNAME" != "none" ];then
						#The last field of the row will be the default name when multicd.sh asks the user to enter a name (activated with "i" option.)
						#This could also be used by the menu-writing portion of the plugin script if $TAGS/whatever.name (created by the "i" option) is not present.
						#Underscores are replaced with spaces. Asterisks are replaced with the $VERSION found above.
						echo $DEFAULTNAME|sed -e 's/_/ /g' -e "s/\*/$VERSION/g">$ISOBASENAME.defaultname
					fi

				COUNTER=$(($COUNTER+1))
				fi
			done
		fi
	done
	if [ -f $TAGS/madelinks ];then
		#If the file exists, remove it, then pause for 1 second so the notifications can be seen.
		rm $TAGS/madelinks
		sleep 1
	fi
}

tinycorecommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		mkdir $WORK/boot/tinycore
		cp $MNT/$1/boot/bzImage $WORK/boot/tinycore/bzImage #Linux kernel
		cp $MNT/$1/boot/*.gz $WORK/boot/tinycore/ #Copy any initrd there may be - this works for microcore too
		if [ -d $MNT/$1/tce ];then
			cp -r $MNT/$1/tce $WORK/
		fi
		sleep 1
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}
puppycommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		#The installer will only work if Puppy is in the root dir of the disc
		if [ -f $TAGS/puppies/$1.inroot ];then
			cp $MNT/$1/*.sfs $WORK/
			cp $MNT/$1/vmlinuz $WORK/vmlinuz
			cp $MNT/$1/initrd.gz $WORK/initrd.gz
		else
			mkdir $WORK/$1
			cp $MNT/$1/*.sfs $WORK/$1/
			cp $MNT/$1/vmlinuz $WORK/$1/vmlinuz
			cp $MNT/$1/initrd.gz $WORK/$1/initrd.gz
		fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO, so it will not be copied. This is a bug."
		exit 1
	fi
}
ubuntucommon () {
	if [ ! -z "$1" ] && [ -f $1.iso ];then
		mcdmount $1
		cp -R $MNT/$1/casper $WORK/boot/$1 #Live system
		if [ -d $MNT/$1/preseed ];then
			cp -R $MNT/$1/preseed $WORK/boot/$1
		fi
		# Fix the isolinux.cfg
		if [ -f $MNT/$1/isolinux/text.cfg ];then
			UBUCFG=text.cfg
		elif [ -f $MNT/$1/isolinux/txt.cfg ];then
			UBUCFG=txt.cfg
		else
			UBUCFG=isolinux.cfg #For custom-made live CDs like Weaknet and Zorin
		fi
		cp $MNT/$1/isolinux/$UBUCFG $WORK/boot/$1/$1.cfg
		cp $MNT/$1/isolinux/*.png $WORK/boot/$1 2> /dev/null #copy splash images
		echo "label back
		menu label Back to main menu
		com32 menu.c32
		append /boot/isolinux/isolinux.cfg
		" >> $WORK/boot/$1/$1.cfg
		sed -i "s@default live@default menu.c32@g" $WORK/boot/$1/$1.cfg #Show menu instead of boot: prompt
		sed -i "s@file=/cdrom/preseed/@file=/cdrom/boot/$1/preseed/@g" $WORK/boot/$1/$1.cfg #Preseed folder moved - not sure if ubiquity uses this
		sed -i "s^initrd=/casper/^live-media-path=/boot/$1 ignore_uuid initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Initrd moved, ignore_uuid added
		sed -i "s^kernel /casper/^kernel /boot/$1/^g" $WORK/boot/$1/$1.cfg #Kernel moved
		if [ -f $TAGS/lang ] && [ "$(cat $TAGS/lang)" != "en" ];then
			sed -i "s^initrd=/boot/$1/^debian-installer/language=$(cat $TAGS/lang) console-setup/layoutcode?=$(cat $TAGS/lang) initrd=/boot/$1/^g" $WORK/boot/$1/$1.cfg #Add language codes to cmdline
		fi
		umcdmount $1
	else
		echo "$0: \"$1\" is empty or not an ISO"
		exit 1
	fi
}

#Returns the version saved by the isoaliases function. For use in writing the menu.
getVersion() {
	BASENAME=$(echo $i|sed -e 's/\.iso//g')
	if [ -f $BASENAME.version ] && [ "$(cat $BASENAME.version)" != "" ];then
		VERSION=" $(cat $BASENAME.version)" #Version based on isoaliases()
	else
		VERSION=""
	fi

	echo ${VERSION}
}
#END FUNCTIONS
