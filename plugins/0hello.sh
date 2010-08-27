#!/bin/bash
set -e
#This script will have multicd.sh print something to the screen if you put a
#file named "moo" in with your ISO images. uudecode must be installed.

if [ $1 = scan ] && [ -f moo ] && which uudecode > /dev/null;then
	match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
	payload_start=$((match + 1))
	tail -n +$payload_start $0 | uudecode | gzip -cd
fi
exit 0
PAYLOAD:
begin 644 -
M'XL("$1N=4P``W!I;F4N='AT`)V7.Y+D(`Q`\SF%`S*<HW(51:*$`"G783C[
M"O`'&]P]LPJF/1@_A'Z(G^6+^&`$D9#%V6]SB_Q\>)<I$=Z%**S_"82$+T+T
MB3D'1GJJ=I<DK\P9</M,:_)FT!&8#QQ12JHI`.AS?;QK&7X'K*B4,/A\DV"4
M#`R=G^@W0)-4EZT\K19.I@4Y],>0?=JILHQR`UJ--^J,$W<D^F[2RF))I#%'
MWUS`U9!P>FP#@O+<XYLU!B6*%$/"$WD"B<NJYKD@YVR&02<."U&*L>D.;<!,
M4%><.,X''@>CL#39W9/.23^'=BR$S[T5$<BS4;<#Y?1Z`KL#A8`@)/2G_6*7
ML`DFO&5#W(&TN3-)29WW(R35AZS@?;8QYO(U'&IOQ'0IR[!O&M3"?"#)G4Z)
MRWH$:J9"'(`D1JZRX)JCBQ7K_[:D$H7+R^MBH;U:`O1`=OTR9T#&?*A(=QM?
M<>ADMY;%F8;^#G0Y[E9\A,8%E'A`%,AG5L$>A6L%GEN&G/<]PSTV.F`X_4ET
M96G:#:%[EDO!K$"!TRM3H(EQF8AA/QD%J_6'/@.CR9.BN6:+XZAQI6:DST#/
M&49E,.<XY!Y77H;/-EPI9W[L>D5;:NNCHOB]3IH&O'_3U4.UBW\<%<;4+^^%
M--->=MWGL%D<%VWZUWB4;.;M7*,JW4X%`?4+W>W4`7-JZV(]([U!UQTI'D$K
M#*+IQBP71]/V!BS!>GQN'T?43+PPE[/@U8:+A^^42STR(1@4@"!CQ3YL]@<B
M!!4&*=R^/O3`2(R_Y<7""UIQ2']BU^UT0*L'N=!W5A6L0&WRI&H:9T",D03Y
M,\@;$WUQ>@7JP5M_NX.QRQ0L1D8MKW-2,`S.YVW;,MD&C*GN^$7#M;Q#_1,'
M0S)*+*1#++8M&T)IFFX3X"*FK%G>Z[J]_7%["/JFH:3&ZQ.V`U8536C"9YJH
M.CTL.]+8RTLANN;KV.?*+0X/6IEKM,%N61NPN$&S)S`B1^U_M*>RBZ,ZW<&]
M$[@!-\8ZR>#1#VCC8J+FH??*B]!U\268?8Q#31X:SFRM3%KB20N?AB9J"EQY
MVF%/[P1?&\XB+PW[_)*1QE-H:(GA+T`<&\H'<'V[4;Q=@X;&_:DAS#5\O5=]
M!6JG,$..M[Y?`Y<LZ8&2E@DYTN/V0_3=*;MLV89@\^1&IZU$U,.8C;/;^%:!
*_P!R%:)E,0\`````
`
end
