C*********************************************************
      SUBROUTINE ERYTH(AOD, SSA, SZA, RAT)
C*********************************************************
C   This subroutine inputs the aerosol optical depth, the
C   single scattering albedo, and the solar zenith angle.   
C   Outputs the ratio of erythemal dose rate with aerosols
C   vs erythemal dose rate without aerosols.  This ratio is
C   total ozone independant.
C   R = UV{SZA,SSA,AOD}/UV{SZA,no aerosols}
C   R = a e**c*AOD
C
C   The solution is determined for a range of SZA, SSA and AOD
C   The equations provide the best fit to the ratios.
C
C   c = f(SZA,SSA)
C
C   c = b*(x3*mu**3 + x2*mu**2 + x1*mu + x0) where mu = cos(SZA)
C
C   b = y3*mu**3 + y2*mu**2 + y1*mu + y0
C
C   a = z3*mu**3 + z2*mu**2 + z1*mu + z0
C
C   x3= -0.3607   y3= 36.770*SSA - 36.836   z3= -0.0347*SSA + 0.0358
C   x2=  0.9084   y2=-90.641*SSA + 90.790   z2=  0.1148*SSA - 0.1172
C   x1= -0.6380   y1= 71.899*SSA - 71.982   z1= -0.1136*SSA + 0.1152
C   x0= -0.0287   y0=-29.940*SSA + 30.967   z0 = 0.0299*SSA + 0.9701
C
C...Range of AOD = [0.03.....0.60]
C...Range of SSA = [0.70.....1.00]
C...Range of SZA = [0.00.....90.0]
C
C********************************************************************
      REAL AOD, SSA, SZA, RAT, MU, X0, X1, X2, X3, B, C
     > Y0, Y1, Y2, Y3, A, Z0, Z1, Z2, Z3, PI, D2R
C
C----------------------------------------------------------
C
      PI = 3.1415927
      D2R = PI/360.0
C
C...Convert from degrees to radians
C...determine the cosine of the Solar Zenith Angle
C
      MU = COS(D2R*SZA)
C
      Y0 = -29.940*SSA + 30.967
      Y1 =  71.899*SSA - 71.982
      Y2 = -90.641*SSA + 90.790
      Y3 =  36.770*SSA - 36.836
C
      B = Y3*MU**3 + Y2*MU**2 + Y1*MU + Y0
C
      X0 = -0.0287
      X1 = -0.6380
      X2 =  0.9084
      X3 = -0.3607
C
      C = B*(X3*MU**3 + X2*MU**2 + X1*MU + X0)
C
      Z0 =  0.0299*SSA + 0.9701
      Z1 = -0.1136*SSA + 0.1152
      Z2 =  0.1148*SSA - 0.1172
      Z3 = -0.0347*SSA + 0.0358
C
      A = Z3*MU**3 + Z2*MU**2 + Z1*MU + Z0
C
C...Ratio of flux with aerosols vs w/o aerosols
C
      RAT = A*EXP(C*AOD)
C
      RETURN
      END
