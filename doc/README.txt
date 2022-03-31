README.txt for uvi.v1.0.3 package

2021.09.14 Hai-Tien Lee
This software package is a parallel porting for WCOSS2, based on WCOSS1 operational
(v1.0.3) package.

To Set up (compile fortran programs):
   setup.sh 
   
To submit test run:
   qsub ecf_test/juvi.ecf
   qsub ecf_test/juvi_gempak.ecf
   Note: juvi_gempak.ecf is to be submitted after juvi.ecf is completed.
   Operationally, juvi_gempak will be invoked by ecflow.

To submit parallel run:
   modify envir=prod to envir=para in ecf/juvi.ecf and juvi_gempak.ecf
   
