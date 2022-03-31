#!/bin/ksh
#################################################################
#  SCRIPT TO DETERMIN UV ERYTHEMAL DOSE RATES
#################################################################

cd $DATA

set +x
echo "***************"
echo "* UV INDEX 6  *"
echo "***************"
set -x

date=$1
cycl=$2
zz=$3

echo 'UV INDEX',' date=',$date, ' cycle=',$cycl,' fcst hr =',$zz
#
#
export pgm=uv_index_grid_6
. prep_step
#

#Set Unit numbers
export FORT10="$FIXuv/erythemal_lut.dat"
export FORT11="$FIXuv/global_orography_0.5x0.5.dat"
export FORT12="$FIXuv/gads_grid_summer.dat"
export FORT13="$FIXuv/gads_grid_winter.dat"
export FORT21="$DATA/uv_swdn3.txt"
export FORT22="$DATA/uv_swup3.txt"
export FORT23="$DATA/uv_clear3.txt"
export FORT24="$DATA/uv_cloud3.txt"
export FORT30="$DATA/uv_ozone6.txt"
export FORT31="$DATA/uv_swdn6.txt"
export FORT32="$DATA/uv_swup6.txt"
export FORT33="$DATA/uv_clear6.txt"
export FORT34="$DATA/uv_cloud6.txt"
export FORT35="$DATA/uv_tsfc6.txt"
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

$EXECuv/uv_index_grid_6 << EOF >> $pgmout 2>errfile
${date}
${cycl}
${zz}
EOF
export err=$? ; err_chk

cp $DATA/ery5_${date}_${cycl}_f${zz}.dat $DATA/uv.${cycle}.f${zz}.dat

exit
