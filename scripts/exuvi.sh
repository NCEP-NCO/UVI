#! /bin/ksh

#
##############################################################
#     START ULTRAVIOLET INDEX PROCESSING
##############################################################

msg="BEGIN UV FORECAST"
postmsg "$msg"

set -x
echo " ----------------------------------------------------------"
echo "           WCOSS2 $envir PROCESSING     "
echo "               `date`     "
echo "           ULTRAVIOLET INDEX FORECAST "
echo "  "
echo "       - the cycle time of UVI FCST is $cycle"
echo "  "
echo " ----------------------------------------------------------"
echo "         Processing info for this execution     "
echo "Processing environments are ...................... $envir"
echo "Temporary processing file directory is ........... $DATA"
echo "Executable ultraviolet data directory is ......... $EXECuv"
echo "Unix Control Language ultraviolet directory is.... $UCLuv"
echo "FIX-field Ultraviolet data directory is .......... $FIXuv"
echo "  "
echo "Network id is .................................... $NET"
echo "Run id for $com files is ......................... $RUN"
echo "  "
echo "unique machine processing id is .................. $pid"
echo "standard temporary output file is ................ $pgmout"
echo "YES SENDCOM means save /com files ................ $SENDCOM"
echo " ----------------------------------------------------------"
#
set -x
cd $DATA

##########################################################################
# Define the working directory and log file
#
export XLFRTEOPTS="unit_vars=yes"
#

#Get Fixed files
# EDR LUT
# Elevation field
# GADS NDJF
# GADS MJJA
# Gaussian Latitudes

export cycl=12

#export TEMPuv=$DATA

for f6 in 6 12 18 24 30 36 42 48 54 60 66 72 78 84 90 96 102 108 114 120
do
  if test $f6 -lt 10
  then
    f6=00${f6}
  elif test $f6 -lt 100
  then
    f6=0${f6}
  fi
  
  f3=`expr $f6 - 3 `
  if test $f3 -lt 10
  then
    f3=00${f3}
  elif test $f3 -lt 100
  then
    f3=0${f3}
  fi

  $USHuv/uv_readpgb.sh ${f3} ${f6} 
# /nw${envir}/ush/uv_readpgb.sh ${f3} ${f6} 
  export err=$? ; err_chk

  ######################################################################
  # GFSOZONE
  #Get Input Data Sets
  #: Total Ozone
  # Albedo
  # UV Flux w/o clouds
  # UV Flux w/clouds
  ######################################################################

  for ii in -2 -1 0
  do
    zz=`expr $f3 + $ii`
    if test $zz -lt 10
    then
      zz=0${zz}
    fi
    $USHuv/uv_index_3.sh ${today} ${cycl} ${zz}
  done #ii

  for ii in -2 -1 0
  do
    zz=`expr $f6 + $ii`
    if test $zz -lt 10
    then
      zz=0${zz}
    fi
    $USHuv/uv_index_6.sh ${today} ${cycl} ${zz}
  done #ii

done #f6

#+++++
##create UV NOON grids (15 degree sections)
for fday in 0 1 2 3 4
do
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} ery2 eryc
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} ery5 ery
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} uvtrans uvt
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} sza sza 
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} aero aero
  $USHuv/uv_uv24hr.sh ${today} ${cycl} ${fday} ozone oz
done #fday

#
##create UV bulletin
$USHuv/uv_uvlist.sh ${today} ${cycl} ${tomorrow}
export err=$? ; err_chk

########################################################################
##create g211 and g207 grids
########################################################################
echo ' &NLCOPYGB IBS(206)=13, /' > tmpibs
$COPYGB -N tmpibs -g211 -x ery24_${today}_${cycl}_d1.grb uv_g211.${cycle}.grb
$COPYGB -N tmpibs -g207 -x ery24_${today}_${cycl}_d1.grb uv_g207.${cycle}.grb

cp ery24_${today}_${cycl}_d0.dat uv.noontime.${cycle}.d0.dat
cp ery24_${today}_${cycl}_d1.dat uv.noontime.${cycle}.d1.dat
cp ery24_${today}_${cycl}_d2.dat uv.noontime.${cycle}.d2.dat
cp ery24_${today}_${cycl}_d3.dat uv.noontime.${cycle}.d3.dat
cp ery24_${today}_${cycl}_d4.dat uv.noontime.${cycle}.d4.dat

if [ $SENDCOM = "YES" ] ; then

  mkdir -p $COMOUT

  cp uv.${cycle}.grbf* $COMOUT

  cp ery24_${today}_${cycl}_d0.dat $COMOUT/uv.noontime.${cycle}.d0.dat
  cp ery24_${today}_${cycl}_d1.dat $COMOUT/uv.noontime.${cycle}.d1.dat
  cp ery24_${today}_${cycl}_d1.grb $COMOUT/uv.noontime.${cycle}.d1.grb
  cp ery24_${today}_${cycl}_d2.dat $COMOUT/uv.noontime.${cycle}.d2.dat
  cp ery24_${today}_${cycl}_d3.dat $COMOUT/uv.noontime.${cycle}.d3.dat
  cp ery24_${today}_${cycl}_d4.dat $COMOUT/uv.noontime.${cycle}.d4.dat
  cp uv.${cycle}.uvbull $COMOUT
  cp uv.${cycle}.validation.dat $COMOUT

  cp uv_g211.${cycle}.grb $COMOUT
  cp uv_g207.${cycle}.grb $COMOUT
  
  if [ $SENDDBN = YES ]; then
      $DBNROOT/bin/dbn_alert MODEL UVI_DAT $job $COMOUT/uv.noontime.${cycle}.d1.dat
      $DBNROOT/bin/dbn_alert MODEL UVI_DAT $job $COMOUT/uv.noontime.${cycle}.d2.dat
      $DBNROOT/bin/dbn_alert MODEL UVI_DAT $job $COMOUT/uv.noontime.${cycle}.d3.dat
      $DBNROOT/bin/dbn_alert MODEL UVI_DAT $job $COMOUT/uv.noontime.${cycle}.d4.dat
      $DBNROOT/bin/dbn_alert MODEL UVI_DAT $job $COMOUT/uv.${cycle}.validation.dat
  fi 

#
#   Convert the uv grb files every hour up to 120 to GRIB2 format
#
  fh=0

  while [ $fh -le 120 ]
  do
    if [ $fh -lt 10 ]; then fh=0$fh; fi
    if [ -f $COMOUT/uv.${cycle}.grbf${fh} ]
    then
#      /nwprod/util/exec/cnvgrib -g12 -p40 $COMOUT/uv.${cycle}.grbf${fh} $COMOUT/uv.${cycle}.grbf${fh}.grib2
      $CNVGRIB -g12 -p40 $COMOUT/uv.${cycle}.grbf${fh} $COMOUT/uv.${cycle}.grbf${fh}.grib2
    fi
    fh=`expr $fh + 1 `
  done

#
#   Convert the 24 hour uv grb files to grid 227 and GRIB2 format
#   and put them all in one file
#
  for dd in 1 2 3 4
  do
     uv_file=ery24_${today}_${cycl}_d${dd}.grb
     $COPYGB -N tmpibs -g227 -x ${uv_file} uv_noon_g227.grb1
     $CNVGRIB -g12 -p40 uv_noon_g227.grb1 uv_noon_g227.grb2
     $WGRIB2 uv_noon_g227.grb2 -set_byte 4 47 2 -grib uv_noon_g227_max.grb2
     $WGRIB2 uv_noon_g227_max.grb2 -append -grib $COMOUT/uv.noontime.t12z.d1to4.g227.grb2
  done #dd

#
# Insert Super WMO headers for Daily Max UVI products at NDGD
#

export XLFRTEOPTS="unit_vars=yes"
echo 0 > filesize

export FORT11=$COMOUT/uv.noontime.t12z.d1to4.g227.grb2
export FORT12="filesize"
export FORT31=
export FORT51=grib2.t12z.uv.noontime.d1to4.tmp
# JY $utilexec/aqm_smoke < $PARMutil/grib2_maxuv_noontime_d1to4.227
#??
#$utilexec/tocgrib2super < $PARMutil/grib2_maxuv_noontime_d1to4.227
$TOCGRIB2SUPER < $PARMutil/grib2_maxuv_noontime_d1to4.227

echo `ls -l grib2.t12z.uv.noontime.d1to4.tmp | awk '{print $5} '` > filesize

export FORT11=grib2.t12z.uv.noontime.d1to4.tmp
export FORT12="filesize"
export FORT31=
export FORT51=$COMOUT/grib2.t12z.uv.noontime.d1to4.227
#??
#$utilexec/tocgrib2super < $PARMutil/grib2_maxuv_noontime_d1to4.227
$TOCGRIB2SUPER < $PARMutil/grib2_maxuv_noontime_d1to4.227

##############################
# Post Files to PCOM
##############################

if test "$SENDCOM" = 'YES'
then
   cp $COMOUT/grib2.t12z.uv.noontime.d1to4.227  $PCOM/grib2.t12z.uv.noontime.d1to4.227

   ##############################
   # Distribute Data
   ##############################

   if [ "$SENDDBN" = 'YES' ] ; then
      $DBNROOT/bin/dbn_alert NTC_LOW $NET $job $PCOM/grib2.t12z.uv.noontime.d1to4.227
   else
      msg="File $PCOM/grib2.t12z.uv.noontime.d1to4.227 not posted to db_net."
      postmsg "$msg"
   fi
fi

#
#   Convert the uv grb files every hour up to 120 to GRIB2 format
#

  for fh in 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 \
     21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
  do
     uv_in_grb1=uv.${cycle}.grbf${fh}
     $COPYGB -N tmpibs -g227 -x $uv_in_grb1 uv_out_g227.grb1
     $CNVGRIB -g12 -p40 uv_out_g227.grb1 uv_out_g227.grb2
     $WGRIB2 uv_out_g227.grb2 -append -grib $COMOUT/uv.${cycle}.g227.grb2
     rm uv_out_g227.grb*
  done #fh

#
# Insert Super WMO headers for 1-hour UVI products at NDGD
#

 export XLFRTEOPTS="unit_vars=yes"
 echo 0 > filesize

 export FORT11=$COMOUT/uv.t12z.g227.grb2 
 export FORT12="filesize"
 export FORT31=
 export FORT51=grib2.t12z.uv_1hr.227.tmp
 #??
#$utilexec/tocgrib2super < $PARMutil/grib2_uv_1hr.227
 $TOCGRIB2SUPER < $PARMutil/grib2_uv_1hr.227

 echo `ls -l grib2.t12z.uv_1hr.227.tmp |  awk '{print $5} '` > filesize

 export FORT11=grib2.t12z.uv_1hr.227.tmp
 export FORT12="filesize"
 export FORT31=
 export FORT51=$COMOUT/grib2.t12z.uv_1hr.227
 #??
#$utilexec/tocgrib2super < $PARMutil/grib2_uv_1hr.227
 $TOCGRIB2SUPER < $PARMutil/grib2_uv_1hr.227

 ##############################
 # Post Files to PCOM
 ##############################

 if test "$SENDCOM" = 'YES'
 then
    cp $COMOUT/grib2.t12z.uv_1hr.227  $PCOM/grib2.t12z.uv_1hr.227

    ##############################
    # Distribute Data
    ##############################

    if [ "$SENDDBN" = 'YES' ] ; then
     $DBNROOT/bin/dbn_alert NTC_LOW $NET $job $PCOM/grib2.t12z.uv_1hr.227
    else
       msg="File $PCOM/grib2.t12z.uv_1hr.227 not posted to db_net."
       postmsg "$msg"
    fi
 fi


#
#   Extract DSWRF data from GFS, Convert to g227, and append into one big file
#
  for fh in 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114
  do
    infile=${COMIN_GFS}/${cyc}/atmos/gfs.t12z.pgrb2.0p50.f${fh}
    $WGRIB2 -match ":DSWRF:" $infile  -append -grib temp1.grb2
  done

  $WGRIB2 temp1.grb2 -ncep_norm temp2.grb2

  $WGRIB2 temp2.grb2 -match "^(1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37):" -grib temp3.grb2

  $CNVGRIB -g21 temp3.grb2 temp4.grb1
  $COPYGB -N tmpibs -g227 -x temp4.grb1 temp5.grb1
  $CNVGRIB -g12 -p40 temp5.grb1 temp5.grb2
  cp temp5.grb2 $COMOUT/dswrf.t12z.g227.grb2

  rm temp*.grb*

#
# Insert Super WMO headers for DSWRF products at NDGD
#

 export XLFRTEOPTS="unit_vars=yes"
 echo 0 > filesize

 export FORT11=$COMOUT/dswrf.t12z.g227.grb2
 export FORT12="filesize"
 export FORT31=
 export FORT51=grib2.t12z.dswrf.227.tmp
 #??
#$utilexec/tocgrib2super < $PARMutil/grib2_dswrf_3hr.227
 $TOCGRIB2SUPER < $PARMutil/grib2_dswrf_3hr.227

 echo `ls -l grib2.t12z.dswrf.227.tmp |  awk '{print $5} '` > filesize

 export FORT11=grib2.t12z.dswrf.227.tmp
 export FORT12="filesize"
 export FORT31=
 export FORT51=$COMOUT/grib2.t12z.dswrf.227
 #??
#$utilexec/tocgrib2super < $PARMutil/grib2_dswrf_3hr.227
 $TOCGRIB2SUPER < $PARMutil/grib2_dswrf_3hr.227

 ##############################
 # Post Files to PCOM
 ##############################

 if test "$SENDCOM" = 'YES'
 then
    cp $COMOUT/grib2.t12z.dswrf.227  $PCOM/grib2.t12z.dswrf.227

    ##############################
    # Distribute Data
    ##############################

    if [ "$SENDDBN" = 'YES' ] ; then
      $DBNROOT/bin/dbn_alert NTC_LOW $NET $job $PCOM/grib2.t12z.dswrf.227
    else
       msg="File $PCOM/grib2.t12z.dswrf.227 not posted to db_net."
       postmsg "$msg"
    fi
 fi

#
#   Convert the uv 207 and 211 files to GRIB2 format
#
  $CNVGRIB -g12 -p40 $COMOUT/uv_g207.${cycle}.grb $COMOUT/uv_g207.${cycle}.grb.grib2
  $CNVGRIB -g12 -p40 $COMOUT/uv_g211.${cycle}.grb $COMOUT/uv_g211.${cycle}.grb.grib2

#
#  sent the uv text file to the LDM for sending to the weather wire
#
  if test "$SENDDBN" = 'YES'
  then
    #??
#    $utilscript/snd2forgntbl.sh uvbull uv.${cycle}.uvbull $COMOUT
     snd2forgntbl.sh uvbull uv.${cycle}.uvbull $COMOUT

    # Run the bulletin through form_ntc
    # put a SENDDBN test because dbn_alert is called from a script within formbul.pl
    name=aeus41
    outfile=$name.uvbul.$job
    #??
#   $utilscript/form_ntc.pl -d aeus41 -f $DATA/uv.${cycle}.uvbull -j $job -m $model -s $SENDDBN -o $outfile -p $PCOM
    form_ntc.pl -d aeus41 -f $DATA/uv.${cycle}.uvbull -j $job -m $model -s $SENDDBN -o $outfile -p $PCOM

   $DBNROOT/bin/dbn_alert MODEL UV_INDEX_grid211 $job $COMOUT/uv_g211.${cycle}.grb
   $DBNROOT/bin/dbn_alert MODEL UV_INDEX_grid207 $job $COMOUT/uv_g207.${cycle}.grb
    
#
#   Alert the uv 207 and 211 GRIB2 files
#
   if test "$SENDDBN_GB2" = 'YES'
   then
     $DBNROOT/bin/dbn_alert MODEL UV_INDEX_grid207_GB2 $job $COMOUT/uv_g207.${cycle}.grb.grib2
     $DBNROOT/bin/dbn_alert MODEL UV_INDEX_grid211_GB2 $job $COMOUT/uv_g211.${cycle}.grb.grib2
   fi # SENDDBN_GB2   
#
#   Alert the uv grb files every hour up to 120
#
   fh=0
   typeset -Z2 fh

   while [ $fh -le 120 ]
   do
     if [ -f $COMOUT/uv.${cycle}.grbf${fh} ]
     then
       $DBNROOT/bin/dbn_alert MODEL UVI_HOURLY $job $COMOUT/uv.${cycle}.grbf${fh}
     fi
     if test "$SENDDBN_GB2" = 'YES'
     then
       $DBNROOT/bin/dbn_alert MODEL UVI_HOURLY_GB2 $job $COMOUT/uv.${cycle}.grbf${fh}.grib2
     fi
     if [ $fh -eq 99 ]
     then
       typeset -Z3 fh 
     fi
     fh=`expr $fh + 1 `
   done #while
 fi # SENDDBN
fi  # SENDCOM

#  GOOD RUN
set +x
echo " *** ULTRAVIOLET FCST PROCESSING COMPLETED NORMALLY ***"
echo " *** ULTRAVIOLET FCST PROCESSING COMPLETED NORMALLY ***"
echo " *** ULTRAVIOLET FCST PROCESSING COMPLETED NORMALLY ***"
set -x
msg='HAS COMPLETED NORMALLY.'
echo $msg
postmsg "$msg"

#
# ------------------- END SCRIPT EXUVI--------------------------
#
