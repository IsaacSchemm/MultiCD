#!/usr/bin/perl
$name="";
$url="";
$iso="";
$date="";
while (<>) {
	if ($name eq "" && /^#(.*) plugin/) {
		$name=$1;
	}
	if ($url eq "" && /^#(http.*)/) {
		$url=$1;
	}
	if ($iso eq "" && /if \[ -f ([^\.]*\.iso) \];then/) {
		$iso=$1;
	}
	if ($date eq "" && /^#version.*(\d\d\d\d\d\d\d\d)/) {
		$date=$1;
	}
}
if (not $iso eq "") {
	$iso="$iso<br>"
}
$href = ($url eq "") ? "" : " href='$url'";
print "<td><a$href>$name</a></td><td>$iso<!--isos--></td><td>$date</td>\n";
