#!/bin/ksh
#################################################################
#  SCRIPT TO CREATE 'NOONTIME' GLOBAL GRID
#################################################################
 
cd $DATA

set +x
echo "***************"
echo "* UV 24hr"
echo "***************"
set -x

date=$1
cycl=$2
fday=$3
parm1=$4
parm2=$5

z1=`expr $fday \* 24 + 1`
z2=`expr $fday \* 24 + 2`
z3=`expr $fday \* 24 + 3`
z4=`expr $fday \* 24 + 4`
z5=`expr $fday \* 24 + 5`
z6=`expr $fday \* 24 + 6`
z7=`expr $fday \* 24 + 7`
z8=`expr $fday \* 24 + 8`
z9=`expr $fday \* 24 + 9`
z10=`expr $fday \* 24 + 10`
z11=`expr $fday \* 24 + 11`
z12=`expr $fday \* 24 + 12`
z13=`expr $fday \* 24 + 13`
z14=`expr $fday \* 24 + 14`
z15=`expr $fday \* 24 + 15`
z16=`expr $fday \* 24 + 16`
z17=`expr $fday \* 24 + 17`
z18=`expr $fday \* 24 + 18`
z19=`expr $fday \* 24 + 19`
z20=`expr $fday \* 24 + 20`
z21=`expr $fday \* 24 + 21`
z22=`expr $fday \* 24 + 22`
z23=`expr $fday \* 24 + 23`
z24=`expr $fday \* 24 + 24`

if test $fday -eq 0
then
   z1=0${z1}
   z2=0${z2}
   z3=0${z3}
   z4=0${z4}
   z5=0${z5}
   z6=0${z6}
   z7=0${z7}
   z8=0${z8}
   z9=0${z9}
fi
#
#
export pgm=uv_uv24hr
. prep_step
#

#Set Unit numbers
export FORT11="$DATA/${parm1}_${date}_${cycl}_f${z1}.dat"
export FORT12="$DATA/${parm1}_${date}_${cycl}_f${z2}.dat"
export FORT13="$DATA/${parm1}_${date}_${cycl}_f${z3}.dat"
export FORT14="$DATA/${parm1}_${date}_${cycl}_f${z4}.dat"
export FORT15="$DATA/${parm1}_${date}_${cycl}_f${z5}.dat"
export FORT16="$DATA/${parm1}_${date}_${cycl}_f${z6}.dat"
export FORT17="$DATA/${parm1}_${date}_${cycl}_f${z7}.dat"
export FORT18="$DATA/${parm1}_${date}_${cycl}_f${z8}.dat"
export FORT19="$DATA/${parm1}_${date}_${cycl}_f${z9}.dat"
export FORT20="$DATA/${parm1}_${date}_${cycl}_f${z10}.dat"
export FORT21="$DATA/${parm1}_${date}_${cycl}_f${z11}.dat"
export FORT22="$DATA/${parm1}_${date}_${cycl}_f${z12}.dat"
export FORT23="$DATA/${parm1}_${date}_${cycl}_f${z13}.dat"
export FORT24="$DATA/${parm1}_${date}_${cycl}_f${z14}.dat"
export FORT25="$DATA/${parm1}_${date}_${cycl}_f${z15}.dat"
export FORT26="$DATA/${parm1}_${date}_${cycl}_f${z16}.dat"
export FORT27="$DATA/${parm1}_${date}_${cycl}_f${z17}.dat"
export FORT28="$DATA/${parm1}_${date}_${cycl}_f${z18}.dat"
export FORT29="$DATA/${parm1}_${date}_${cycl}_f${z19}.dat"
export FORT30="$DATA/${parm1}_${date}_${cycl}_f${z20}.dat"
export FORT31="$DATA/${parm1}_${date}_${cycl}_f${z21}.dat"
export FORT32="$DATA/${parm1}_${date}_${cycl}_f${z22}.dat"
export FORT33="$DATA/${parm1}_${date}_${cycl}_f${z23}.dat"
export FORT34="$DATA/${parm1}_${date}_${cycl}_f${z24}.dat"
export FORT50="$DATA/${parm2}24_${date}_${cycl}_d${fday}.dat"
export FORT60="$DATA/${parm2}24_${date}_${cycl}_d${fday}.grb"

startmsg

$EXECuv/uv_uv24hr << EOF >> $pgmout 2>errfile
${cycl}
${fday}
EOF
export err=$? ; err_chk
 
exit
