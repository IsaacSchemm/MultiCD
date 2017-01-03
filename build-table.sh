#!/bin/bash
set -e
export MCDDIR=.
echo "<table>"
echo "<tr>"
	echo "<th>Plugin</th>"
	echo "<th>Name</th>"
	echo "<th>URL</th>"
	echo "<th>ISO filename</th>"
	echo "<th>Date</th>"
echo "</tr>"
for filename in plugins/*.sh;do
	echo "<tr>"
	echo "<td>$filename</td>"
	ISONAME=$(echo $($filename links | sed -e 's/ .*//g') | sed -e 's/ /<br>/g')
	if echo $ISONAME | grep -q Usage;then
		ISONAME=""
	fi
	cat $filename | ./build-table.pl | sed -e "s/<!--isos-->/$ISONAME/g"
	echo "</tr>"
done
echo "</table>"
