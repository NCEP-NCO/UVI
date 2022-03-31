C*****************************************************************
      SUBROUTINE sundis(idate,esrm2)
C*****************************************************************
C*-----------------------------------------------------------------------------*
C*=  PURPOSE:                                                                 =*
C*=  Calculate Earth-Sun distance variation for a given date.  Based on       =*
C*=  Fourier coefficients originally from:  Spencer, J.W., 1971, Fourier      =*
C*=  series representation of the position of the sun, Search, 2:172          =*
C*-----------------------------------------------------------------------------*
C*=  PARAMETERS:                                                              =*
C*=  IDATE  - INTEGER, specification of the date, from YYMMDD              (I)=*
C*=  ESRM2  - REAL, variation of the Earth-sun distance                    (O)=*
C*=           ESRM2 = (average e/s dist)^2 / (e/s dist on day IDATE)^2        =*
C*-----------------------------------------------------------------------------*
C
      IMPLICIT NONE
C
C* input:
      INTEGER idate
C
C* output:
      REAL esrm2
C
C* internal:
      INTEGER iyear, imonth, iday, mday, month, jday
      REAL dayn, thet0
      REAL sinth, costh, sin2th, cos2th
      INTEGER imn(12)
C
      REAL pi
      PARAMETER(pi=3.1415926535898)
C
C*-----------------------------------------------------------------------------*
      DATA imn/31,28,31,30,31,30,31,31,30,31,30,31/             
C*-----------------------------------------------------------------------------*
C
C* parse date to find day number (Julian day)
C
      iyear = int(idate/10000)
      imonth = int( (idate-10000*iyear)/100 )
      iday = idate - (10000*iyear + 100*imonth)
c
      if (imonth.gt.12) then
         write(*,*) 'Month in date exceeds 12'
         write(*,*) 'date = ', idate
         write(*,*) 'month = ', imonth
         stop
      endif
c
      IF ( MOD(iyear,4) .EQ. 0) THEN
         imn(2) = 29
      ELSE
         imn(2) = 28
      ENDIF
c
      if (iday.gt.imn(imonth)) then
         write(*,*) 'Day in date exceeds days in month'
         write(*,*) 'date = ', idate
         write(*,*) 'day = ', iday
         stop
      endif
c
      mday = 0
      DO 12, month = 1, imonth-1
         mday = mday + imn(month)	  	   
   12 CONTINUE
      jday = mday + iday
      dayn = FLOAT(jday - 1) + 0.5
C
C* define angular day number and compute esrm2:
C
      thet0 = 2.*pi*dayn/365.
C
C* calculate SIN(2*thet0), COS(2*thet0) from
C* addition theoremes for trig functions for better
C* performance;  the computation of sin2th, cos2th
C* is about 5-6 times faster than the evaluation
C* of the intrinsic functions SIN and COS
C*
      sinth = SIN(thet0)
      costh = COS(thet0)
      sin2th = 2.*sinth*costh
      cos2th = costh*costh - sinth*sinth
C
      esrm2  = 1.000110 + 
     $         0.034221*costh  +  0.001280*sinth + 
     $         0.000719*cos2th +  0.000077*sin2th
C
      RETURN
      END
