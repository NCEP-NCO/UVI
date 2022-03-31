C***************************************************************
      PROGRAM UV24HR
C***************************************************************
C
C   purpose: to combine 24 - 15 degree longitude swaths and create
C            a one day 'noontime' dataset.
C
C            00Z runs start at 180W
C         *  12Z runs start at 00E
C
C   Change : 09-03-05 : Add ip2 and itri to comgrib common block
C                       set ifcst from 24 to ifday*24
C                       set ip2 to (ifday+1)*24 
C                       set itri to 2
C                       changes add corect informatin to grib header
C                       about timespan of data file
C
C*******************************************************************
C
      integer nx, ny, nxy
      parameter (nx=720, ny=361, nxy=nx*ny)
      parameter (mxbit=32, lenpds=28, lengds=32)
      parameter (mxsize=30+lenpds+lengds+nxy*(mxbit+1)/8)
C
      real uv(nx,ny), uv24(nx,ny), uvgrb(nxy)
C
      integer yy, mm, dd, ihr, ifcst, idscale, idmodel, idpara,
     > idlevel, itot, yyyy, ip2, itri
C
      character*1 kbuf(mxsize)
      character*11 fname(24)
C
      common /comgrib/yy,mm,dd,ihr,ifcst,idscale,idmodel,idpara,
     > idlevel,itot, ip2, itri
C-------------------------------------------------------------------
C
      read(5,*) icycl
      read(5,*) ifday
C
      open(50, status='replace', form='formatted')
C
      do 100 ih = 1, 24
         iun = 10 + ih 
         open(iun, status='old', form='formatted')
         read(iun,900) idate
         read(iun,901) uv
C
C...determine longitude bands
C
         if (icycl.eq.00) then
            lstrt = 316 - (ih-1)*30
            lend  = 346 - (ih-1)*30
         else
            lstrt = 676 - (ih-1)*30
            lend  = 706 - (ih-1)*30
         endif
C
         do 20 il = lstrt, lend
            i = il
            if (i .le. 0) i = i + 720
            do 19 j = 1, 361
               uv24(i,j) = uv(i,j)
   19       continue
   20    continue
  100 continue
C
C...write 24hr file 
C
      write(50,902) idate, icycl, ifday
      write(50,901) uv24
C
C...create grib file
C
      yyyy = idate/10000
      yy   = mod(yyyy,100)
      mm   = (idate - yyyy*10000)/100
      dd   = idate - yyyy*10000 - mm*100
      ihr  = icycl
C...  ifcst = 24
      ifcst = ifday*24
      ip2   = (ifday+1)*24
      itri  = 2 
      idscale = 0
      idmodel = 2
      idpara  = 206
      idlevel = 1
C...model  2 = uv index
C...para 206 = uv index (W/M**2)
C...level  1 = surface
C
C...convert unit mW/m**2 to Grib Standard W/m**2
C
      do 50 j = 1, ny
         do 40 i = 1, nx
            k = (j-1)*nx + i
            uvgrb(k) = uv24(i,j)*1.0e-3
   40    continue
   50 continue
C
      call grib(uvgrb, kbuf)
C
      open(60, status='replace',form='unformatted',
     > access='direct', recl=itot)
C
      write(60,rec=1) (kbuf(i),i=1,itot)
C
  900 format(I8)
  901 format(10f8.2)
  902 format(I8.8, I3, I3)
C
      stop
      end
