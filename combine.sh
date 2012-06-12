#!/bin/sh
#combine.sh version 6.9 - combine multicd.sh plugins into one script
#Under MIT/X11 license - see multicd.sh
set -e
if [ "$1" != "" ];then
	OUTPUT="$1"
else
	OUTPUT=multicd-single-file.sh
fi

if [ ! -f multicd.sh ] || [ ! -d plugins ] || [ -d functions.sh ];then
	echo "The files multicd.sh and functions.sh and the plugins folder must be present."
	exit 1
fi
rm working*.sh 2>/dev/null ||true
echo "#!/bin/bash
#This is the single-file version of multicd.sh, compiled on: $(date)
" > working0.sh
sed -n '/set -e/,/#START PREPARE/p' multicd.sh >> working0.sh
sed -n '/#!\/bin\/sh/,/#START LINKS/p' functions.sh >> working0.sh
sed -n '/#END LINKS/,/#END FUNCTIONS/p' functions.sh >> working3.sh
sed -n '/#END PREPARE/,/#START SCAN/p' multicd.sh >> working3.sh
sed -n '/#END SCAN/,/#START COPY/p' multicd.sh > working5.sh
sed -n '/#END COPY/,/#START WRITE/p' multicd.sh > working7.sh
sed -n '/#END WRITE/,/#END SCRIPT/p' multicd.sh > working9.sh
for i in $(echo plugins/*.sh);do
	if grep -q 'scan|copy|writecfg' $i;then
		if ! grep -q "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM," $i;then
			echo "Note: $i may not be under the MIT license. Check its license terms and add them to combined-multicd.sh."
		fi
		if grep -q "#START FUNCTIONS#" $i;then
			sed -n '/#START FUNCTIONS#/,/#END FUNCTIONS#/p' $i >> working1.sh
		fi
		if grep -q '\$1 = links' $i;then
			sed -n '/\$1 = links/,/\$1 = scan/p' $i|sed -e '1d' -e '$d' >> working2.sh #Links portion
		fi
		sed -n '/\$1 = scan/,/\$1 = copy/p' $i|sed -e '1d' -e '$d' >> working4.sh #Scan portion
		sed -n '/\$1 = copy/,/\$1 = writecfg/p' $i|sed -e '1d' -e '$d' >> working6.sh #Copy portion
		sed -n '/\$1 = writecfg/,/scan|copy|writecfg/p' $i|sed -e '1d' -e 'N;$!P;$!D;$d' >> working8.sh #isolinux.cfg portion
	else
		echo "Note: $i being skipped (it doesn't contain the string \"scan|copy|writecfg\")."
	fi
done
sed -i -e 's/$/ >> $TAGS\/linklist/g' working2.sh
cat working[0123456789].sh > $OUTPUT
rm working[0123456789].sh
sed -i -e 's^\. \$MCDDIR/functions\.sh^^g' $OUTPUT
chmod +x $OUTPUT
