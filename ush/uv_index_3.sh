#!/bin/ksh
#################################################################
#  SCRIPT TO DETERMINE UV ERYTHEMAL DOSE RATES
#################################################################

cd $DATA

set +x
echo "***************"
echo "* UV INDEX 3"
echo "***************"
set -x

date=$1
cycl=$2
zz=$3

echo 'UV INDEX',' date=',$date, ' cycle=',$cycl,' fcst hr =',$zz
#
#
export pgm=uv_index_grid_3
. prep_step
#

#Set Unit numbers
export FORT10="$FIXuv/erythemal_lut.dat"
export FORT11="$FIXuv/global_orography_0.5x0.5.dat"
export FORT12="$FIXuv/gads_grid_summer.dat"
export FORT13="$FIXuv/gads_grid_winter.dat"
export FORT20="$DATA/uv_ozone.txt"
export FORT21="$DATA/uv_albedo.txt"
export FORT22="$DATA/uv_clear.txt"
export FORT23="$DATA/uv_cloud.txt"
export FORT24="$DATA/uv_tsfc.txt"
export FORT51="$DATA/ery2_${date}_${cycl}_f${zz}.dat"
export FORT52="$DATA/ery5_${date}_${cycl}_f${zz}.dat"
export FORT53="$DATA/uvtrans_${date}_${cycl}_f${zz}.dat"
export FORT54="$DATA/sza_${date}_${cycl}_f${zz}.dat"
export FORT55="$DATA/aero_${date}_${cycl}_f${zz}.dat"
export FORT56="$DATA/albedo_${date}_${cycl}_f${zz}.dat"
export FORT57="$DATA/albsno_${date}_${cycl}_f${zz}.dat"
export FORT58="$DATA/ozone_${date}_${cycl}_f${zz}.dat"
export FORT62="$DATA/uv.${cycle}.grbf${zz}"

startmsg

$EXECuv/uv_index_grid_3 << EOF >> $pgmout 2>errfile
${date}
${cycl}
${zz}
EOF
export err=$? ; err_chk

cp $DATA/ery5_${date}_${cycl}_f${zz}.dat $DATA/uv.${cycle}.f${zz}.dat

exit
