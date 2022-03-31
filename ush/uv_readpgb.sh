#!/bin/ksh
#################################################################
#  SCRIPT TO RETRIEVE FIELDs FROM GFS
#  SAVE IN ASCII FOR FORECAST
#################################################################

cd $DATA
echo $DATA

set +x
echo "***************"
echo "* READPGB2"
echo "***************"
set -x

f3=$1
f6=$2

cat ${COMIN_GFS}/${cyc}/atmos/gfs.t${cycl}z.pgrb2.0p50.f${f3} ${COMIN_GFS}/${cyc}/atmos/gfs.t${cycl}z.pgrb2b.0p50.f${f3} > grib2f3
cat ${COMIN_GFS}/${cyc}/atmos/gfs.t${cycl}z.pgrb2.0p50.f${f6} ${COMIN_GFS}/${cyc}/atmos/gfs.t${cycl}z.pgrb2b.0p50.f${f6} > grib2f6


echo 'READ_PGB2_MASTER: grib2f3 fhr=', $f3
echo 'READ_PGB2_MASTER: grib2f6 fhr=', $f6
#
# Create input files for uv_index_3.sh step
#
$WGRIB2 grib2f3 -s | grep "TOZNE" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_ozone.txt
$WGRIB2 grib2f3 -s | grep "ALBDO" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_albedo.txt
$WGRIB2 grib2f3 -s | grep ":DUVB" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_cloud.txt
$WGRIB2 grib2f3 -s | grep "CDUVB" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_clear.txt
$WGRIB2 grib2f3 -s | grep "TMP:surface" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_tsfc.txt
#
# Create input files for uv_index_6.sh step
#
$WGRIB2 grib2f3 -s | grep "DSWRF:surface" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_swdn3.txt
$WGRIB2 grib2f3 -s | grep "USWRF:surface" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_swup3.txt
$WGRIB2 grib2f3 -s | grep ":DUVB" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_cloud3.txt
$WGRIB2 grib2f3 -s | grep "CDUVB" | $WGRIB2 -i grib2f3 -order we:ns -text $DATA/uv_clear3.txt

$WGRIB2 grib2f6 -s | grep "TOZNE" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_ozone6.txt
$WGRIB2 grib2f6 -s | grep "DSWRF:surface" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_swdn6.txt
$WGRIB2 grib2f6 -s | grep "USWRF:surface" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_swup6.txt
$WGRIB2 grib2f6 -s | grep ":DUVB" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_cloud6.txt
$WGRIB2 grib2f6 -s | grep "CDUVB" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_clear6.txt
$WGRIB2 grib2f6 -s | grep "TMP:surface" | $WGRIB2 -i grib2f6 -order we:ns -text $DATA/uv_tsfc6.txt

exit
