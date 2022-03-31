#!/bin/ksh
#################################################################
#  SCRIPT TO CREATE UV BULLETIN
#################################################################
 
cd $DATA

set +x
echo "***************"
echo "* UV LIST"
echo "***************"
set -x

date=$1
cycl=$2
tomorrow=$3

fday=1


#
export pgm=uv_index_grid_3
. prep_step
#
# input data files
#
export FORT10="$DATA/eryc24_${date}_${cycl}_d${fday}.dat"
export FORT11="$DATA/ery24_${date}_${cycl}_d${fday}.dat"
export FORT12="$DATA/uvt24_${date}_${cycl}_d${fday}.dat"
export FORT13="$DATA/sza24_${date}_${cycl}_d${fday}.dat"
export FORT14="$DATA/aero24_${date}_${cycl}_d${fday}.dat"
export FORT15="$DATA/oz24_${date}_${cycl}_d${fday}.dat"
export FORT31="$FIXuv/uv_citylist.dat"
export FORT61="$DATA/uv.${cycle}.uvbull"
export FORT62="$DATA/uv.${cycle}.validation.dat"

hour=`TZ="US/Eastern" date +%I`
hour=`expr $hour \* 1`
min=`TZ="US/Eastern" date +%M`
cyc=`TZ="US/Eastern" date +%p`
timezone=`TZ="US/Eastern" date +%Z`
weekday=`TZ="US/Eastern" date +%a | tr 'a-z' 'A-Z'`
month=`TZ="US/Eastern" date +%b | tr 'a-z' 'A-Z'`
date=`TZ="US/Eastern" date +%d`
date=`expr $date \* 1`
year=`TZ="US/Eastern" date +%Y`

timestamp="$hour$min $cyc $timezone $weekday $month $date $year"

yyyy=`echo $tomorrow | cut -c1-4`
mm=`echo $tomorrow | cut -c5-6`
dd=`echo $tomorrow | cut -c7-8`
case $mm in
  01) mm=JAN ;;
  02) mm=FEB ;;
  03) mm=MAR ;;
  04) mm=APR ;;
  05) mm=MAY ;;
  06) mm=JUN ;;
  07) mm=JUL ;;
  08) mm=AUG ;;
  09) mm=SEP ;;
  10) mm=OCT ;;
  11) mm=NOV ;;
  12) mm=DEC ;;
esac
dd=`expr $dd \* 1`

validdate="VALID $mm $dd $yyyy AT SOLAR NOON /APPROXIMATELY NOON"
validdate2="LOCAL STANDARD TIME OR 100 PM LOCAL DAYLIGHT TIME/"

startmsg

$EXECuv/uv_uvlist << EOF >> $pgmout 2>errfile
$tomorrow

NOAA/EPA ULTRAVIOLET INDEX /UVI/ FORECAST
NWS CLIMATE PREDICTION CENTER COLLEGE PARK MD
$timestamp

$validdate
$validdate2

THE UV INDEX IS CATEGORIZED BY THE WORLD HEALTH ORGANIZATION
AS FOLLOWS:
           UVI             EXPOSURE LEVEL
           0 1 2              LOW
           3 4 5              MODERATE
           6 7                HIGH
           8 9 10             VERY HIGH
           11 AND GREATER     EXTREME

FOR HEALTH RELATED ISSUES GO TO WWW.EPA.GOV/SUNSAFETY
FOR TECHNICAL INFORMATION ABOUT THE UV INDEX....
GO TO THE NATIONAL WEATHER SERVICE UV INDEX WEB PAGE:
WWW.CPC.NCEP.NOAA.GOV/PRODUCTS/STRATOSPHERE/UV_INDEX

EOF
export err=$? ; err_chk

exit
