C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM: indexx         Sort Bulletin by cities
C   PRGMMR: Hai-Tien Lee     ORG: W/NMC53    DATE: 94-06-09
C
C ABSTRACT: Sort Bulletin by cities
C
C PROGRAM HISTORY LOG:
C     94-06-09  Hai-Tien Lee
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN77
C   MACHINE:  CRAY
C
C$$$
C****************************************************************
      subroutine indexx(n,buffer,indx)
C****************************************************************
      parameter(mxcity=900)
      character*1 buffer(40,mxcity)
      double precision arrin(mxcity)
      dimension indx(mxcity)
c...convert first three characters in city name and state abbreviation into
c...real numbers for sorting purpose
c...change the element index if buffer has been changed the wording style
c...nchar=no. of char in city name used for sorting
      do i=1,n
         arrin(i)=0.
         nchar=10
         do nc=1,nchar
            kpower=(nchar-nc)*2
            k=ichar(buffer(nc,i))
            arrin(i)=arrin(i)+k*10.**kpower
         enddo
         arrin(i)=arrin(i)+
     &        ichar(buffer(22,i))*1.e-2+ichar(buffer(23,i))*1.e-4
      enddo
c...following source code is mostly taken from numerical recipe "indexx"
      do 11 j=1,n
         indx(j)=j
 11   continue
      nn = n/2 + 1
      ir=n
 10   continue
      if (nn.gt.1) then
         nn = nn-1
         indxt=indx(nn)
         q=arrin(indxt)
      else
         indxt=indx(ir)
         q=arrin(indxt)
         indx(ir)=indx(1)
         ir=ir-1
         if(ir.eq.1)then
            indx(1)=indxt            
            return
         endif
      endif
      i=nn
      j=2*nn
 20   if(j.le.ir)then
         if(j.lt.ir)then
            if(arrin(indx(j)).lt.arrin(indx(j+1)))j=j+1
         endif
         if(q.lt.arrin(indx(j)))then
            indx(i)=indx(j)
            i=j
            j=j+j
         else
            j=ir+1
         endif
         go to 20
      endif
      indx(i)=indxt
      go to 10
C 
      end
