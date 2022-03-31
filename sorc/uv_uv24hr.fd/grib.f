C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM: GRIB           GRIB A GIVEN DATA ARRAY
C   PRGMMR: HAI-TIEN LEE     ORG: W/NMC53    DATE: 94-04-29
C
C ABSTRACT: GRIB A GIVEN DATA ARRAY
C
C PROGRAM HISTORY LOG:
C   94-04-29  HAI-TIEN LEE
C
C USAGE:    CALL GRIBER(FLD,KBUF)
C   INPUT ARGUMENT LIST:
C     FLD      - GIVEN DATA ARRAY
C
C   OUTPUT ARGUMENT LIST:
C     KBUF     - GRIB message
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN77
C   MACHINE:  CRAY
C
C$$$
C***********************************************************************
      SUBROUTINE grib(FLD, KBUF)
C***********************************************************************
      PARAMETER (NX=720,NY=361,NXY=NX*NY)
      PARAMETER (MXBIT=32,LENPDS=28,LENGDS=32)
      PARAMETER (MXSIZE=30+LENPDS+LENGDS+NXY*(MXBIT+1)/8)
C
      REAL FLD(NXY)
C
      INTEGER HEADER(5)
      INTEGER KPDS(LENPDS),KGDS(LENGDS),KPTR(10),KRET
      INTEGER ID(25),IBDSFL(12),IGDS(91)
      INTEGER JERR, NPTS
      integer iyy, imm, idd, ihr, ifcst, idscale,idmodel,idpara
     > idlevel, ITOT, IP2, ITRI
C
      LOGICAL*1 KBMS(NXY)
C
      CHARACTER*1 PDS(LENPDS),KBUF(MXSIZE)
C
      COMMON /COMGRIB/IYY,IMM,IDD,IHR,IFCST
     &     ,IDSCALE,IDMODEL,IDPARA,IDLEVEL
     &     ,ITOT,IP2,ITRI
C-------------------------------------------------------------
C
C...flip the field. Make the first point at North Pole
C      CALL FLIP_FIELD(FLD)

      IMN = 00
      ITYPE = 0
      IFLD = 0
      IBITL = MXBIT
      IGRID = 4
      IPFLAG = 0
      IGFLAG = 0
C     IGDS = 0
      ICOMP = 0
      IBFLAG = 0
      IBMAP = 0
      IBLEN = 0

      IBDSFL(1)=0
      IBDSFL(2)=0
      IBDSFL(3)=ITYPE
      IBDSFL(4)=0
      IBDSFL(5)=0
      IBDSFL(6)=0
      IBDSFL(7)=0
      IBDSFL(8)=0
      IBDSFL(9)=0
      IBDSFL(10)=0
      IBDSFL(11)=0
      IBDSFL(12)=0

      ID( 1)=LENPDS
      ID( 2)=  2
      ID( 3)=  7
      ID( 4)=IDMODEL
      ID( 5)=IGRID
      ID( 6)=  1
      ID( 7)=  0
      ID( 8)=IDPARA
      ID( 9)=IDLEVEL
      ID(10)=  0
      ID(11)=  0
      ID(12)=IYY
      ID(13)=IMM
      ID(14)=IDD
      ID(15)=IHR
      ID(16)=IMN
      ID(17)= 1
      ID(18)=IFCST
      ID(19)=IP2
      ID(20)=ITRI
      ID(21)= 0
      ID(22)= 0
      ID(23)=21
      ID(24)= 0
      ID(25)=IDSCALE

C...Calculate Bit length for packing data
      GMAX=0
      GMIN=500
      DS=10.**ID(25)
      DO I=1,NXY
         GMAX=MAX(FLD(I),GMAX)
         GMIN=MIN(FLD(I),GMIN)
      ENDDO
      write(6,910) gmax,gmin
  910 format(1x,'GRIB RANGE =', 2f8.2)
      NBIT=LOG((GMAX-GMIN)*DS+0.9)/LOG(2.)+1.
      IBITL=MIN(IBITL,NBIT)
C...FIX IBITL=12 FOR PACKING THE UV (Ranges from -1. to 20. W/m**2)
      IBITL=12
      write(6,*) 'IBITL=',IBITL,' NBIT=',NBIT
C...Grib it
      CALL W3FI72(ITYPE,FLD,IFLD,IBITL,IPFLAG,ID,PDS,
     &     IGFLAG,IGRID,IGDS,ICOMP,
     &     IBFLAG,IBMAP,IBLEN,
     &     IBDSFL,
     &     NPTS,KBUF,ITOT,JERR)
      write(6,*) 'ITOT=',itot,' NPTS=',npts,' JERR=',jerr
C
      RETURN
      END
