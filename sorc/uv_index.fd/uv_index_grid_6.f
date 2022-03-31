C**********************************************************************
C  program UV Index
C**********************************************************************
C  program will read fixed fields
C  get date , cycle and fcst hour
C  determine Solar Zenith Angles
C  Read ozone field
C  From LUT (ozone, sza) determine Erythemal Dose Rates
C  Adjust field for Elevation
C  Determine which GADS aerosol fields to use
C  Read the GADS data sets (AOD and SSA)
C  Call Erythemal_UV inputs:AOD,SSA,SZA output:Ratio
C  Determine second 3 hr means using 1st 3 hr and 6 hr means
C  Read SW Downwelling and SW Upwelling fields
C  Determine 2nd 3 hr SWD and SWU fields
C  Determine 2nd 3 hr Albedo (SWU/SWD)
C  Mask Albedo for just snow/ice by including only alb>30% and Tsfc < 275 K
C  Adjust field for Albedo (Snow)
C  Read UVBCLR and UVBCLD fields
C  Determine 2nd 3 hr UVBCLR AND UVBCLD
C  Determine 2nd 3 hr UV Transmissivity
C  Adjust field for UV Trans (Clouds)
C
C   OUTPUT FILES:
C     fort.052 - UV Index clrsky field (GRIB)
C
C   SUBPROGRAMS CALLED: (LIST ALL CALLED FROM ANYWHERE IN CODES)
C     UNIQUE:    - ROUTINES THAT ACCOMPANY SOURCE FOR COMPILE
C       grib     - grib UV Index field
C     LIBRARY:
C       W3LIB    - link to /nwprod/w3lib
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN
C   MACHINE:  Cray
C
C$$$
C   Changes: Feb 25, 2009 - Changed IFCST = 24
C                            to     IFCST = FCSTHR
C
C-----------------------------------------------------------
C 
      PARAMETER (IGRD=720, JGRD=361, NXY=IGRD*JGRD)
      PARAMETER (MXBIT=32,LENPDS=28,LENGDS=32)
      PARAMETER (MXSIZE=30+LENPDS+LENGDS+NXY*(MXBIT+1)/8)
C
      INTEGER YYYYMMDD, EDATE, YYYY, MM, DD, DOY, DPY, UTC, CYCL,
     > FCSTHR, YY
C
      REAL OZONE(igrd,jgrd), SZA(igrd,jgrd), GLAT,
     > EDRLUT(18,27), ELEV(igrd,jgrd), UV(NXY), 
     > UVBCLD(igrd,jgrd),  UVBCLR(igrd,jgrd), ALBEDO(igrd,jgrd),
     > UVBCLD3(igrd,jgrd), UVBCLR3(igrd,jgrd),SWD3(igrd,jgrd),
     > UVBCLD6(igrd,jgrd), UVBCLR6(igrd,jgrd),SWD6(igrd,jgrd),
     > ELADJ(igrd,jgrd), EL(igrd,jgrd), SWU3(igrd,jgrd),SWU6(igrd,jgrd),
     > TSFC(igrd,jgrd), ALBSNO(igrd,jgrd)
C23456789012345678901234567893123456789412345678951234567896123456789712
      REAL ERY1(igrd,jgrd), ERY2(igrd,jgrd), ERY3(igrd,jgrd),
     >     ERY4(igrd,jgrd), ERY5(igrd,jgrd), ERYOUT(720,361)
      REAL OPT(igrd,jgrd), OPTS(igrd,jgrd), OPTW(igrd,jgrd)
      REAL SSA(igrd,jgrd), SSAS(igrd,jgrd), SSAW(igrd,jgrd)
      REAL MON(12), MONL(12)
      REAL UVTRANS(igrd,jgrd), AERO(igrd,jgrd)
C
      REAL PI, D2R, R2D, FZ, FC, SOLDEC
C
      INTEGER IHR, IFCST, IDSCALE, IDMODEL, IDPARA, IDLEVEL, ITOT
C
      CHARACTER*1 KBUF(MXSIZE)
C
      COMMON /COMGRIB/YY,MM,DD,IHR,IFCST,IDSCALE,IDMODEL,IDPARA,
     &     IDLEVEL,ITOT
C
      DATA MON/0,31,59,90,120,151,181,212,243,273,304,334/
      DATA MONL/0,31,60,91,121,152,182,213,244,275,305,335/

C
C-----------------------------------------------------------------------
C
      PI = 3.1415927
      D2R = PI/180.0
      R2D = 180.0/PI
C
C...Read Input
C
      READ(5,*) YYYYMMDD 
      READ(5,*) CYCL
      READ(5,*) FCSTHR
C
      WRITE(6,910) YYYYMMDD, CYCL, FCSTHR
C
      YYYY = INT(YYYYMMDD/10000)
      YY   = MOD(YYYY,100)
      MM   = INT((YYYYMMDD-YYYY*10000)/100)
      DD   = YYYYMMDD-YYYY*10000-MM*100
C
C...Read Fixed Fields
C
C...Read Erythemal(oz,sza) LUT 
      OPEN(10, STATUS='OLD',FORM='FORMATTED',RECL=144)
      READ(10,*) EDRLUT
      CLOSE(10)
C      write(6,911) ((edrlut(i,j),i=1,18),j=1,27)
      WRITE(6,FMT='("Erythemal LUT read")')
C
C...Read Elevation
C
      OPEN(11, STATUS='OLD',FORM='FORMATTED')
      READ(11,907) ELEV
      CLOSE(11)
C 
      WRITE(6,FMT='("Elevation data read")')
C
C...Read GADS Optical Thickness and SSA for both Summer and Winter
C
      OPEN(12, STATUS='OLD', FORM='FORMATTED')
      OPEN(13, STATUS='OLD', FORM='FORMATTED')
      READ(12,903) OPTS
      READ(12,903) SSAS
      READ(13,903) OPTW 
      READ(13,903) SSAW
      CLOSE(12)
      CLOSE(13)
      WRITE(6,FMT='("GADS Data Read")')
C
C...Read Input Fields (1,1) is 90North, 0East
C
      OPEN(21, STATUS='OLD', FORM='FORMATTED')
      READ(21,*) nx1,ny1 
      READ(21,*) SWD3
      CLOSE(21)
      WRITE(6,FMT='("ShortWave Down_3 Data Read",i4,i4)') nx1,ny1
C
      OPEN(22, STATUS='OLD', FORM='FORMATTED')
      READ(22,*) nx1,ny1 
      READ(22,*) SWU3
      CLOSE(22)
      WRITE(6,FMT='("ShortWave UP_3 Data Read",i4,i4)') nx1,ny1
C
      OPEN(23, STATUS='OLD', FORM='FORMATTED')
      READ(23,*) nx2, ny2 
      READ(23,*) UVBCLR3
      CLOSE(23)
      WRITE(6,FMT='("UVBCLR_3 Data Read",i4,i4)') nx2,ny2
C
      OPEN(24, STATUS='OLD', FORM='FORMATTED')
      READ(24,*) nx3, ny3
      READ(24,*) UVBCLD3
      CLOSE(24)
      WRITE(6,FMT='("UVBCLD_3 Data Read",i4,i4)') nx3,ny3
C
      OPEN(30, STATUS='OLD', FORM='FORMATTED')
      READ(30,*) nx0, ny0
      READ(30,*) OZONE
      CLOSE(30)
      WRITE(6,FMT='("Ozone Data Read",i4,i4)') nx0, ny0
C
      OPEN(31, STATUS='OLD', FORM='FORMATTED')
      READ(31,*) nx1,ny1 
      READ(31,*) SWD6
      CLOSE(31)
      WRITE(6,FMT='("ShortWave Down_6 Data Read",i4,i4)') nx1,ny1
C
      OPEN(32, STATUS='OLD', FORM='FORMATTED')
      READ(32,*) nx1,ny1 
      READ(32,*) SWU6
      CLOSE(32)
      WRITE(6,FMT='("ShortWave Up_6 Data Read",i4,i4)') nx1,ny1
C
      OPEN(33, STATUS='OLD', FORM='FORMATTED')
      READ(33,*) nx2, ny2 
      READ(33,*) UVBCLR6
      CLOSE(33)
      WRITE(6,FMT='("UVBCLR_6 Data Read",i4,i4)') nx2,ny2
C
      OPEN(34, STATUS='OLD', FORM='FORMATTED')
      READ(34,*) nx3, ny3
      READ(34,*) UVBCLD6
      CLOSE(34)
      WRITE(6,FMT='("UVBCLD_6 Data Read",i4,i4)') nx3,ny3
C
      OPEN(35, STATUS='OLD', FORM='FORMATTED')
      READ(35,*) nx3, ny3
      READ(35,*) TSFC 
      CLOSE(35)
      WRITE(6,FMT='("Tmp Sfc Data Read",i4,i4)') nx3,ny3
C
C...Create 3 hour file from 6 hour files
C
      DO 50 J = 1, 361
         DO 49 I = 1, 720
            SD3 = SWD3(I,J)
            SU3 = SWU3(I,J)
            SD6 = SWD6(I,J)
            SU6 = SWU6(I,J)
            IF (SWD3(I,J) .GT. 0.0) THEN
               SWD = 2.0*SD6 - SD3
            ELSE
               SWD = SD6
            ENDIF
C
            IF (SWU3(I,J) .GT. 0.0) THEN
               SWU = 2.0*SU6 - SU3
            ELSE
               SWU = SU6
            ENDIF
C
            IF (SWD .GT. 0.0) THEN
               ALBEDO(I,J) = 100.0*SWU/SWD
            ELSE
               ALBEDO(I,J) = -1.0
            ENDIF
C
C...check for cold bright surfaces
C
            IF (TSFC(I,J) .LE. 274.0) THEN
               ALBSNO(I,J) = ALBEDO(I,J)
            ELSE
               ALBSNO(I,J) = 0.0
            ENDIF
C
            CLD3 = UVBCLD3(I,J)
            CLD6 = UVBCLD6(I,J)
            IF (CLD3 .GE. 0.0) THEN
               UVBCLD(I,J) = 2.0*CLD6 - CLD3
            ELSE
               UVBCLD(I,J) = CLD6
            ENDIF
C
            CLR3 = UVBCLR3(I,J)
            CLR6 = UVBCLR6(I,J)
            IF (CLR3 .GE. 0.0) THEN
               UVBCLR(I,J) = 2.0*CLR6 - CLR3
            ELSE
               UVBCLR(I,J) = CLR6
            ENDIF
   49    CONTINUE
   50 CONTINUE

C...Determine DOY and Days Per Year
C
      IF (MOD(YYYY,4).EQ.0) THEN
         DOY = MONL(MM) + DD
         DPY = 366
      ELSE
         DOY = MON(MM) + DD 
         DPY = 365
      ENDIF
      WRITE(6,919) YYYY, MM, DD, DOY
C
C...from the cycle time and forecast hour 
C...determine the day and UTC time of the product
C
      FC = FLOAT(CYCL)
      FZ = FLOAT(FCSTHR)
      UTC = MOD((CYCL+FCSTHR),24)
C
      DOY = DOY + (CYCL+FCSTHR)/24
      WRITE(6,920) DOY, CYCL, FCSTHR, UTC
C
C...determine Solar Declination
C
      SOLDEC = 23.45*SIN(2.0*PI*(DOY-80.0)/DPY)
c.      WRITE(6,921) SOLDEC
      SOLDEC = D2R*SOLDEC
C
C...determine Solar Zenith Angle
C
      GLON = 0.5
      GLAT = 0.5
C
      DO 10 IL = 1, jgrd
         RLT = 90.0 - (IL-1)*GLAT
         RLAT = D2R*RLT   
         DO 9 IJ = 1, igrd
            RLON = (IJ-1)*GLON
            HRR  = (UTC-12.0)*15.0 + RLON
            HOUR = D2R*HRR 
            COSZ = SIN(SOLDEC)*SIN(RLAT)+COS(SOLDEC)*COS(RLAT)*COS(HOUR)
            Z = R2D*ACOS(COSZ)
c...only work with SZA smaller than 85 degrees
            IF (Z.GE.0.0 .AND. Z.LE.85.0) THEN
               SZA(IJ,IL) = Z
            ELSE
               SZA(IJ,IL) = -1.0
            ENDIF
    9    CONTINUE
c.      WRITE(6,923)il,rlt, MAXVAL(SZA(1:igrd,il)), 
c.     > MINVAL(SZA(1:igrd,il), MASK = SZA(1:igrd,il) .GT. 0)
   10 CONTINUE
C
C...DETERMIN EARTH-SUN DISTANCE RATIO
C
      CALL SUNDIS(YYYYMMDD, ESRAT)
      WRITE(6,908) ESRAT
C
C...DETERMINE SEA LEVEL, NO AEROSOL, NO SNOW, NO CLOUDS EDR
C
      DO 20 LTT = 1, jgrd
         DO 19 LNN = 1, igrd 
            IF (SZA(LNN,LTT).GT.0.0 .AND. SZA(LNN,LTT).LT.85.0) THEN
               OZ = 1+(OZONE(LNN,LTT)-80.0)/20.0
               SZ = 1+SZA(LNN,LTT)/5.0
               CALL W3FT01(SZ, OZ, EDRLUT, EOUT, 18, 27, 0, 1)
               ERY1(LNN,LTT) = EOUT*ESRAT
C
C              if (lnn.eq.576) write(6,940)glat(ltt),ozone(lnn,ltt),
C     > oz, sza(lnn,ltt), sz, eout  
C
c.        if(lnn.eq.576) write(6,945) glat(ltt),sza(lnn,ltt),
c.     > ozone(lnn,ltt),albedo(lnn,ltt),uvbclr(lnn,ltt),uvbcld(lnn,ltt)
            ENDIF
   19    CONTINUE
c.      WRITE(6,924)ltt,glat(ltt), MAXVAL(ERY1(1:igrd,ltt)), 
c.     > MINVAL(ERY1(1:igrd,ltt))
   20 CONTINUE
C 
C...ADJUST Arrays FOR ELEVATION
C...Array operations
C
      EL = ELEV/1000.0
      ELADJ = -0.0009 + 5.4457*EL - 0.0414*EL**2
      ERY2 = ERY1*(1.0+ELADJ/100.0)
c.      DO 61 LTT = 1, JGRD
c.      WRITE(6,926)ltt,glat(ltt), MAXVAL(ERY2(1:igrd,ltt)), 
c.     > MINVAL(ERY2(1:igrd,ltt))
c.   61 CONTINUE
C
C...Adjust for AOD and SSA
C
      M = INT(MM)
      IF (M.EQ.3 .OR. M.EQ.4 .OR. M.EQ.9 .OR. M.EQ.10) THEN
         OPT = (OPTS+OPTW)/2.0
         SSA = (SSAS+SSAW)/2.0
      ELSE IF (M.GE.11 .OR. M.LE.2) THEN
         OPT = OPTW
         SSA = SSAW
      ELSE IF (M.GE.5 .OR. M.LE.8) THEN
         OPT = OPTS
         SSA = SSAS
      ENDIF
C
C...Compute Erythemal Ratio With vs W/O Aerosols
C
      DO 60 LTT = 1, jgrd
         LTX = JGRD - LTT + 1
         DO 59 LNN = 1, igrd
            IF (SZA(LNN,LTT).GT.0.0 .AND. SZA(LNN,LTT).LT.85.0) THEN
               CALL ERYTH(OPT(LNN,LTX),SSA(LNN,LTX),SZA(LNN,LTT),RAT)
            ELSE
               RAT = 0.0
            ENDIF
C
            AERO(LNN,LTT) = RAT*100.0
            ERY3(LNN,LTT) = ERY2(LNN,LTT)*RAT
   59    CONTINUE
c.      WRITE(6,925)ltt,glat(ltt), MAXVAL(ERY3(1:igrd,ltt)), 
c.     > MINVAL(ERY3(1:igrd,ltt))
   60 CONTINUE
C
C...ADJUST FOR ALBEDO (SNOW)
C
      ERY4 = ERY3
C
      A0 = -1.32278
      A1 =  0.43339
      A2 =  0.00053
      A3 =  0.00002
C
C...Adjust for snow if albedo is greater than 30%
C
      DO 80 LTT = 1, JGRD
         N = 0
         NN = 0
         DO 79 LNN = 1, IGRD
            ALB = ALBSNO(LNN,LTT)
            IF (SZA(LNN,LTT).GT.0 .AND. SZA(LNN,LTT).LT.85) THEN
               IF (ALB.GE.30) THEN
                  ALBADJ = A3*ALB**3 + A2*ALB**2 + A1*ALB + A0
                  ERY4(LNN,LTT) = ERY3(LNN,LTT)*(1.0 + ALBADJ/100.0)
                  N = N + 1
               ENDIF
               NN = NN + 1
            ENDIF
   79    CONTINUE
c.      WRITE(6,927)ltt,glat(ltt), MAXVAL(ERY4(1:igrd,ltt)), 
c.     > MINVAL(ERY4(1:igrd,ltt)), N, NN
   80 CONTINUE
C
C...Determine UV Trans
C
      ERY5 = ERY4
c
      DO 90 LTT = 1, JGRD
         DO 89 LNN = 1, IGRD
C23456789012345678901234567893123456789412345678951234567896123456789712
            IF(UVBCLD(LNN,LTT).GT.0.0.AND.UVBCLR(LNN,LTT).GT.0.0)THEN
               UVT = UVBCLD(LNN,LTT)/UVBCLR(LNN,LTT)
               IF (UVT .GT. 1.0) UVT = 1.0
               ERY5(LNN,LTT) = ERY4(LNN,LTT)*UVT
            ELSE
               UVT = -0.01
            ENDIF
            UVTRANS(LNN,LTT) = UVT*100.0
   89    CONTINUE
c.      WRITE(6,928)j,glat(j), MAXVAL(ERY5(1:igrd,j)), 
c.     > MINVAL(ERY5(1:igrd,j))
   90 CONTINUE
C
C...changed from ery1 to ery2 August 25, 2005
C
      OPEN(51, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(51,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(51,902) ERY2
      CLOSE(51)
C
      OPEN(52, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(52,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(52,902) ERY5
      CLOSE(52)
C
      OPEN(53, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(53,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(53,902) UVTRANS
      CLOSE(53)
C
      OPEN(54, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(54,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(54,902) SZA 
      CLOSE(54)
C
      OPEN(55, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(55,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(55,902) AERO
      CLOSE(55)
C
      OPEN(56, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(56,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(56,902) ALBEDO
      CLOSE(56)
C
      OPEN(57, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(57,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(57,902) ALBSNO
      CLOSE(57)
C
      OPEN(58, STATUS='REPLACE', FORM='FORMATTED')
      WRITE(58,909) YYYYMMDD, CYCL, FCSTHR
      WRITE(58,902) OZONE
      CLOSE(58)
C
C      OPEN(58, STATUS='REPLACE', FORM='FORMATTED')
C      WRITE(58,909) YYYYMMDD, CYCL, FCSTHR
C      WRITE(58,902) ELADJ
C      CLOSE(58)
c
C...GRIB PARAMETERS
C     IYY, IMM, IDD ARE PROVIDED BELOW
      IHR=12
      IFCST=FCSTHR
      IDSCALE=0
      IDMODEL=2
      IDPARA=206
      IDLEVEL=1
C...MODEL ID= 2, UV INDEX
C...PARAMETER ID=206, UV INDEX (W/M**2)
C...TYPE OF LEVEL=  1, SURFACE
C...SCALING FACTOR
C
C...Grib UV field as a product (Convert unit to Grib standard: W/m**2)
C
      do j = 1, jgrd
         do i = 1, igrd 
            k = (j-1)*igrd + i
            uv(k) = ery5(i,j)*1.e-3
         enddo
      enddo
C
      CALL GRIB(uv, kbuf)
C
      open(62,status='replace',form='unformatted',access='direct',
     > recl=itot)
C
      write(62,rec=1) (kbuf(i),i=1,itot)
C
C...FORMAT CARDS
C
  900 FORMAT(1x,I8)
  901 FORMAT(18F8.2)
  902 FORMAT(10F8.2)
  903 FORMAT(10F8.4)
  904 FORMAT(8F9.4)
  905 FORMAT(I4,2I2)
  906 FORMAT(48I1)
  907 FORMAT(10F8.1)
  908 FORMAT(1X,'Earth-Sun Distance Ratio =', f9.6)
  909 FORMAT(I8,1X,I2,1X,I3)
  910 FORMAT(' YYYYMMDD =', I8,/,' CYCL =', I3,/,' FCST HR =', I3)
  911 FORMAT(18f5.0)
  919 FORMAT(1X,'YYYY =', I5,', MM =', I3,', DD =', I3,', DOY =', I4)
  920 FORMAT(1X,'DOY =', I4, ' CYCL=', I4,' FCST HR=', I4,' UTC=', I4)
  921 FORMAT(1X,'SOLDEC (DEG)=', F8.2)
  922 FORMAT(1X,'GLON =', F8.5)
  923 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX SZA =', F8.3,
     > ' MIN SZA =', F8.3)
  924 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX ERY1 =', F8.3,
     > ' MIN ERY1 =', F8.3)
  925 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX ERY2 =', F8.3,
     > ' MIN ERY2 =', F8.3)
  926 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX ERY3 =', F8.3,
     > ' MIN ERY3 =', F8.3)
  927 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX ERY4 =', F8.3,
     > ' MIN ERY4 =', F8.3, ' N=',I4,' NN =', I4)
  928 FORMAT(1X,'IL=', i4,' RLAT=',F8.2,' MAX ERY5 =', F8.3,
     > ' MIN ERY5 =', F8.3)
  940 FORMAT(1X,'LAT=',F6.2,' OZONE=',F8.2,' OZ =', F6.2,' SZA =', 
     > F8.2,' SZ =', F6.2, ' EOUT=',F8.2)
  945 FORMAT(1x,'LAT=', F7.2,' SZA=', F6.2,' OZONE=', F7.2,
     > ' ALBEDO=', F6.2,' UV CLR=', F5.2,' UV CLD=', F5.2)
C
      END
