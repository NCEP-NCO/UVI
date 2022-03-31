C********************************************************************
      program uvlist
C********************************************************************
C$$$  PROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM: uvlist         generate city list bulletin
C   PRGMMR: Hai-Tien Lee     ORG: W/NMC53    DATE: 94-04-29
C
C ABSTRACT: Generate the UV forecast City list bulletin
C
C PROGRAM HISTORY LOG:
C     94-04-29  Hai-Tien Lee
C     94-05-24  HTLEE   Bulletin Header and number of digit modified
C     94-05-25  HTLEE   Apply MOS cloud modification to clear-sky UVI
C     05-08-26  CS Long Altered subroutine to be program, took out
C                       cards computing UVI, replaced mos parms with
C                       UV trans, Aero, and Snow Albedo values in
C                       validation output
C
C USAGE:    CALL uvlist
C   INPUT FILES:   (DELETE IF NO INPUT FILES IN SUBPROGRAM)
C     10       - clear sky erythemal values
C     11       - cloudy sky erythemal values
C     12       - UV transmissivity
C     13       - Solar Zenith Angles
C     14       - Aerosol ratio
C     15       - Total Ozone
C     31       - city list for the interested cities/stations
C
C   OUTPUT FILES:  (DELETE IF NO OUTPUT FILES IN SUBPROGRAM)
C     61       - City list bulletin
C     62       - verification data
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN77
C   MACHINE:  AIX
C
C*********************************************************************
C$$$
      parameter(nx=720,ny=361,nxy=nx*ny)
      parameter(mxcity=900)
C
      character*20 city
      character*2  state,country
      character*26 station
      character*3  callid, stnx
      character*40 buffer(mxcity),head
      character*50 title
      character*80 prefix(30)
C
      real uv(nx,ny), huv, uvc(nx,ny), huvc, uvt(nx,ny), huvt,
     > sza(nx,ny), hsza, aero(nx,ny), haero, ozone(nx,ny), hoz 
C
      integer tomorrow
      integer indx(mxcity)
      integer afos
C
C      common /uvdata/ozone,uv,a0,a1,a2,idate
C---------------------------------------------------------------------
      head='CITY               STATE  UVI'
C
C...read erythemal UV values
C
      open(10, status='OLD', form='FORMATTED')
      read(10,900) idate, icyc, ifhr   
      read(10,901) uvc
C
      open(11, status='OLD', form='FORMATTED')
      read(11,900) idate, icyc, ifhr   
      read(11,901) uv
C
      open(12, status='OLD', form='FORMATTED')
      read(12,900) idate, icyc, ifhr   
      read(12,901) uvt
C
      open(13, status='OLD', form='FORMATTED')
      read(13,900) idate, icyc, ifhr   
      read(13,901) sza
C
      open(14, status='OLD', form='FORMATTED')
      read(14,900) idate, icyc, ifhr   
      read(14,901) aero
C
      open(15, status='OLD', form='FORMATTED',iostat=IO)
      IF (IO.EQ.0) THEN
         read(15,900) idate, icyc, ifhr   
         read(15,901) ozone
      ELSE
         write(6,905)
         ozone = -1.0
      ENDIF
C
C...flip uv field
C
      CALL FLIP_FIELD(UVC)
      CALL FLIP_FIELD(UV)
      CALL FLIP_FIELD(UVT)
      CALL FLIP_FIELD(sza)
      CALL FLIP_FIELD(aero)
      CALL FLIP_FIELD(ozone)
C
C...W3FT01 parameters
      NCYCLK=1
      LIN=1
      i=1
C
      read(5,*) tomorrow
C
C...read bulletin headers
C
 20   continue
      read(5,902,end=22) prefix(i)
      i=i+1
      goto 20
 22   continue
      nprefix=i-1
C
C...write valid date to validation file
C
      open(62, status='replace', form='formatted')
      write(62,903) tomorrow
C      
C...read mos citylist
C
      ncity=0
      open(31, status='old', form='formatted')
   10 continue
      read(31,904,end=99) city,state,country,sti,stj,itopo,callid,afos
C
C...interpolate clear and cloudy UVI, SZA, Ozone grid to city location
C
      STI = 2.0*STI
      STJ = 2.0*STJ
C
      call W3FT01(STI,STJ,uvc,huvc,nx,ny,NCYCLK,LIN)
      call W3FT01(STI,STJ,uv,huv,nx,ny,NCYCLK,LIN)
      call W3FT01(STI,STJ,uvt,huvt,nx,ny,NCYCLK,LIN)
      call W3FT01(STI,STJ,sza,hsza,nx,ny,NCYCLK,LIN)
      call W3FT01(STI,STJ,aero,haero,nx,ny,NCYCLK,LIN)
      call W3FT01(STI,STJ,ozone,hoz,nx,ny,NCYCLK,LIN)
C
      if (huvc .lt. -10.0) huvc = -1.00
      if (huv .lt. -10.0) huv = -1.00
      if (huvt .lt. -10.0) huvt = -1.00
      if (hsza .lt. -10.0) hsza = -1.00
      if (haero .lt. -10.0) haero = -1.00
      if (hoz .lt. -10.0) hoz = -1.00
C
      if (huvc .gt. 0.0) huvc = huvc/25.0
      if (huv .gt. 0.0) huv = huv/25.0

      station=city//' '//state
c...Compose the bulletin
C...only write stations to AFOS Bulletin if afos=1
c...also round the UV Index
      if (afos .eq. 1) then
         ncity=ncity+1
         write(buffer(ncity),910) station,int(huv+0.5)
      endif
C
C...Write out data to validation file
C
      fill = -1.0
      write(62,912) callid,huvc,huv,huvt,hsza,haero,hoz
      goto 10
C
   99 continue
      open(61, status='replace', form='formatted')
      write(6,*) 'UVLIST : NCITY=',ncity
      do i=1,nprefix
         write(61,920) prefix(i)
      enddo
      write(61,921) head,head
      ncol2=ncity/2+mod(ncity,2)
c
C...sort bulletin by cities
c
      call indexx(ncity,buffer,indx)
c
      do i=1,ncity/2
         write(6,921) buffer(indx(i)),buffer(indx(ncol2+i))
         write(61,921) buffer(indx(i)),buffer(indx(ncol2+i))
      enddo
      if (mod(ncity,2) .eq. 1) then
         write(6,921) buffer(indx(ncol2))
         write(61,921) buffer(indx(ncol2))
      endif
C  
  900 format(I8,1x,I2,1x,I3)
  901 format(10f8.2)
  902 format(a80)
  903 format(i8.8)
  904 format(a20,1x,a2,1x,a2,1x,2(f6.2,1x),i4,1x,a3,1x,i1)
  905 format(1x,'*** Ozone Field Not Available ***')
  910 format(a26,1x,i2)
  912 format(1x,a3,1x,2(f5.2,1x),3(f5.1,1x),f5.1)
  920 format(a65)
  921 format(a32,4x,a29)
C  
      STOP
      END 
