C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM: flip_field     flip the latlon field from pole to pole
C   PRGMMR: Hai-Tien Lee     ORG: W/NMC53    DATE: 94-04-29
C
C ABSTRACT: Flip a latlon grid field (make the starting element at
C           either north pole or south pole
C
C PROGRAM HISTORY LOG:
C   94-04-29  Hai-Tien Lee
C   05-09-12  Craig Long     increased resolution of grid
C
C USAGE:    CALL flip_field(x)
C   INPUT ARGUMENT LIST:
C     x        - given latlon gridded field
C   OUTPUT ARGUMENT LIST:
C     x        - fliped latlon gridded field
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN77
C   MACHINE:  AIX
C
C$$$
C********************************************************************
      subroutine flip_field(x)
C********************************************************************
      integer nx, ny
      parameter (nx=720, ny=361)
C
      real x(nx,ny),y(ny)
C
      do 100 i=1,nx
         do 80 j=1,ny
            y(j)=x(i,(ny+1)-j)
   80    continue
         do 90 j=1,ny
            x(i,j)=y(j)
   90    continue
  100 continue
C
      return
      end
