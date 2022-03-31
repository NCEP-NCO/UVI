README_WCOSS2_porting.txt

==========================================================================================
2021.09.15 Hai-Tien Lee

Parallel porting of uvi.v1.0.3 sofware package from WCOSS1 to WCOSS2

It is modified from canned package at [WCOSS2 Cactus] /lfs/h1/ops/canned/packages/uvi.v1.0.3
Note: [WCOSS1] Operational package is at /gpfs/dell1/nco/ops/nwprod/uvi.v1.0.3
      and it is in use since May 4, 2020.

==========================================================================================
Change History:
2021.09.14
Create v1.0.3 for WCOSS2 porting

New files:
README.txt - new file containing package basic instructions
README_WCOSS2_porting.txt - records for porting actions and issues
versions/run.ver - required new file for module version definitions
versions/build.ver - required new file for module version definitions
setup.sh - set up script that compiles the codes
ecf_test - directory containing test scripts

Modifications:
ecf/juvi.ecf
   submission instruction changes from BSUB to PBS
   removed all %include, %manul and %end instructions
   replaced envir definion fro %ENVIR% to hardcoded "prod"
   modified module loading statements
   added HOMEuvi definition
ecf/juvi_gempak.ecf
   similar to changes in juvi.ecf

jobs/JUVI - compath.py format change

Removed:
sorc/build_uv.module - contents now are embedded in the new script setup.sh

Bug fixes: (Note: GEMPAK part is written by NCO)  
   -------------------------------------------------------------------------------------   
   jobs/JUVI_GEMPAK line 49 path defined is not present: 
      export NTSgempak=$USHgempak/restore .
   Fix:
      export NTSgempak=$HOMEgempak/restore
   -------------------------------------------------------------------------------------   
   jobs/JUVI_GEMPAK line 82 if test syntax error: 
      if [ $KEEPDATA -eq 'NO' ]; then
      error: use -eq on non-numerical variables
   Fix:
      if [ $KEEPDATA != 'YES' ]; then
   -------------------------------------------------------------------------------------   
   scripts/exuvi_gempak.sh.ecf line 130:
      gempak/restore/uv_01.nts (and 02, 03, ..., 09) input data files are not present
   Fixes: 
      temporary placeholder of uv_01.nts and all are created, copied from uv_base_us.nts
   -------------------------------------------------------------------------------------   

==========================================================================================
2021.09.14
Testing on Cactus:

Input: 20210824 canned data on /lfs/h1/ops/canned/com

Jobs:
qsub /u/Hai-Tien.Lee/nwprod/uvi.v1.0.3/ecf/juvi.ecf
qsub /u/Hai-Tien.Lee/nwprod/uvi.v1.0.3/ecf/juvi_gempak.ecf
note: gempak job manually after juvi job is completed (operationally, ecflow invoked it)

Note: disabled features during testing:
export SENDDBN=NO
export SENDECF=NO

Products verifications:
   uvi forecast fields (uv.t12z.grbf01.grib2, total 120 files)
   uvi noontime composite fields (uv.noontime.t12z.d1.dat, total 5 files)
   Bulletin (uv.t12z.uvbull)
   Cities verification extraction (uv.t12z.validation.dat)


   