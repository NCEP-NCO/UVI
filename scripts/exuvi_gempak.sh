#!/bin/ksh -x

#------------------------------------------------------------------------------
#
#   exuvi_gempak.sh.ecf
#
# This script will plot the uv index for the most recent 
# available data or user specified date. 
#
#------------------------------------------------------------------------------


# Identify script to the output file
  typeset -u mon

# Set time information. This stuff should be parsed automatically
# and should not require any mods. Look down below for changing 
# this script to fit additional applications.

# See if an "archive" time has been entered, get the parts

  export YY=`echo $PDY | cut -c1-4`
  export cc=`echo $PDY | cut -c1-2`
  export yy=`echo $PDY | cut -c3-4`
  export mm=`echo $PDY | cut -c5-6`
  export dd=`echo $PDY | cut -c7-8`


# Find tomorrow's date and reset date/time parameters

  today=${YY}${mm}${dd}
  tomorrow=`${utilscript}/finddate.sh ${today} s+1`
  echo "\n today = ${today}  tomorrow = ${tomorrow}\n"

  TY=`echo $tomorrow | cut -c1-4`
  tm=`echo $tomorrow | cut -c5-6`
  td=`echo $tomorrow | cut -c7-8`
  echo "\n Tomorrow's date/time: year = $TY   month = $tm   day = $td \n"


  case $tm in
    01)mon="Jan";;
    02)mon="Feb";;
    03)mon="Mar";;
    04)mon="Apr";;
    05)mon="May";;
    06)mon="Jun";;
    07)mon="Jul";;
    08)mon="Aug";;
    09)mon="Sep";;
    10)mon="Oct";;
    11)mon="Nov";;
    12)mon="Dec";;
  esac

  cp ${FIXgempak}/uv_ncepgrib2.tbl ncepgrib2.tbl
  cp ${FIXgempak}/uv_coltbl.xw coltbl.xwp
  cp ${FIXgempak}/uv_index.tbl uv_index.tbl
  cp ${NTSgempak}/uv_base_us.nts base_us.nts
  cp ${NTSgempak}/uv_gemglb.nts gemglb.nts

#########################################
# Copy in UV GRIB Input File
#########################################
  #cp ${COMIN}/uv.${PDY}${cyc}.pgrb.fuv GRIB_FILE
  cp ${COMIN}/uv.noontime.${cycle}.d1.grb GRIB_FILE
  export GRIB_FILE=GRIB_FILE
  export GEM_FILE=uv.${PDY}${cyc}.gem

#########################################
# Create the top label for this chart
#########################################
  echo "NCEP UV INDEX FORECAST" > title_top.lab
  echo "                    " >> title_top.lab
  echo "Valid for Solar Noon on:   ${mon} ${td}, ${TY}" >> title_top.lab


# Run the GRIB to GEMPAK converter

  $GEMEXE/nagrib_nc << EOF
    GBFILE   =  ${GRIB_FILE}
    INDXFL   =
    GDOUTF   =  ${GEM_FILE}
    PROJ     =
    GRDAREA  =
    KXKY     =
    MAXGRD   =  1
    CPYFIL   =  GDS
    GAREA    =  dset
    OUTPUT   =  F
    GBTBLS   =
    GBDIAG   =  ALL
    r

    exit
EOF

# ---------------------------------------------------

#   Do minimal error checking - verify the gempak file is there.

  if [ ! -e ${GEM_FILE} ]
  then
    msg="GEMPAK file ${GEM_FILE} does not exist. Aborting..."
    postmsg "$msg"
    export err=1
    err_chk
  fi

# Loop through the charts making one at a time 
  for n in ${REGION_INDEX}
  do

     msg="Making CHART ${n}"
     postmsg "$msg"

     export uvi_gif_file=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f2 `
     export uvi_index_gif=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f1`

     export region_name=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f3`
     export graph_loc=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f4`
     export txtloc_top=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f5`
     export txtloc_bot=`grep UVINDEX${n} uv_index.tbl | cut -d"|" -f6`

     echo "region_name = $region_name"
     echo "graph_loc = $graph_loc"
     echo "txtloc_top = $txtloc_top"
     echo "txtloc_bot = $txtloc_bot"
     
     cp ${NTSgempak}/uv_0${n}.nts uvindex${n}.nts

     # Create bottom label for chart
     echo "UV Index" > title_bot.lab
     echo "                    " >> title_bot.lab
     echo $region_name >> title_bot.lab

     # Write the chart name to a label file
     echo $uvi_gif_file > graph_name.lab

     export tmpgif=uvindex${n}.gif

     # Set the background color to white
#gpcolor << EOF1
#  DEVICE = gif|${tmpgif}|900;650|xw
#  COLORS = 101=white
#  CLEAR  = no
#  r

#  ex
#EOF1

     # Run the gempak program(s)
gdplot2 << EOF

restore base_us

!Restore the uvindex parameters.
restore uvindex${n}

GDFILE  = ${GEM_FILE}
GDATTIM = fall
CLEAR   = yes
DEVICE  = gif|${tmpgif}|900;650|M
GLEVEL  = 0 
GVCORD  = none
PANEL   =
SCALE   = 0 
GDPFUN  = MUL(uvin24,40)  
TYPE    = F
CONTUR  =
LINE    = 32/1/1
FINT    = 1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16
FLINE   = 30;29;24;25;26;27;23;21;5;19;17;16;14;11;10;8;31
TEXT    = 1.0/13/sw
MAP     = 32
PROJ    = CED/0.0;0.0;0.0/;9.3;;6.8
LUTFIL  = coltbl.xw
r

exit
EOF


gpbox<< GPBOX_FLAG
region=plot
line=32/1/1/1
r

GPBOX_FLAG


gptext << EOF2
  CLEAR  = no
  PANEL  = 0
  COLORS = 32
  TEXT   = 0.7/12////L
  DEVICE = gif|${tmpgif}|900;650
  TXTFIL = graph_name.lab
  TXTLOC = ${graph_loc}
  COLUMN = 1
  r

  CLEAR  = no
  TEXT   = 1.5/3////C/sw
  TXTFIL = title_top.lab
  TXTLOC = ${txtloc_top}
  r

  CLEAR  = no
  TEXT   = 1.5/3////C/sw
  TXTFIL = title_bot.lab
  TXTLOC = ${txtloc_bot}
  r
 
  exit
EOF2

     gpend

     if test "$SENDCOM" = "YES"
     then
        cp uvindex${n}.gif ${COMOUT}/${uvi_gif_file}
        chgrp rstprod ${COMOUT}/${uvi_gif_file}
        chmod 750 ${COMOUT}/${uvi_gif_file}
     fi

     if test "$SENDDBN" = "YES"
     then
        $DBNROOT/bin/dbn_alert MODEL UVI_GIF $job ${COMOUT}/${uvi_gif_file}
     fi

     msg="Completed making CHART ${n} for $region_name"
     postmsg "$msg"

  done

