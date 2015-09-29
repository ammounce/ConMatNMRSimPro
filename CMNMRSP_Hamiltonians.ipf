#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function MakeIz(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Iz =0
	variable i=0
	do
		s.Iz[i][i] = -s.II+i
		i+=1
	while(i<2*s.II+1)

End 

Function MakeI2(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:I2 =0
	
	variable i=0
	
	do
		s.I2[i][i] = s.II*(s.II+1)
	
		i+=1
	
	while(i<2*s.II+1)
	
End

Function MakeIplus(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Iplus =0
	
	variable i=-s.II
	do
		s.Iplus[i+s.II][i+1+s.II] =sqrt(s.ii*(s.ii+1)-i*(i+1))
	
		i+=1
	
	while(i<s.II)
	
End

Function MakeIminus(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Iminus =0	
	
	variable i=-s.II+1
	do
		s.Iminus[i+s.II][i+s.II-1] =sqrt(s.II*(s.II+1)-i*(i-1))
	
		i+=1
	
	while(i<s.II+1)
	
End

Function MakeIx(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Ix =0
	
	MakeIplus(s)
	MakeIminus(s)
		
	s.Ix = .5*(s.Iplus+s.Iminus)
	
End

Function MakeIy(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Iy =0
	
	MakeIplus(s)
	MakeIminus(s)
		
	s.Iy = .5/sqrt(-1)*(s.Iplus - s.Iminus)

End

Function QuadrupolarHamiltonian(s)
	STRUCT Spectrum &s
		
	MakeIz(s)
	MakeI2(s)
	MakeIplus(s)
	MakeIminus(s)
		
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:spectrumsimulation:system:Iz2= 0
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:spectrumsimulation:system:Iminus2= 0
	make/o/c/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Iplus2= 0

	MatrixMultiply s.Iz, s.Iz
	s.Iz2 = s.product

	MatrixMultiply s.Iplus, s.Iplus
	s.Iplus2 = s.product

	MatrixMultiply s.Iminus, s.Iminus
	s.Iminus2= s.product

	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:spectrumsimulation:system:HQ=0
 
	s.HQ= s.vQ/6*(3*s.Iz2 - s.I2 + s.eta/2*(s.Iplus2+s.Iminus2))
End	


Function ZeemanHamiltonian(s)
	STRUCT Spectrum &s
	
	variable Kinv
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:spectrumsimulation:system:HZ=0
	if(s.fieldsweep==0 || (s.fieldsweep ==1 && s.II>1/2))
		s.Hz = s.gyro*s.fieldstep*(cos(pi*s.thetastep/180)*s.Iz*(1+s.Kz/100))
		s.Hz+=s.gyro*s.fieldstep*sin(pi*s.thetastep/180)*cos(pi*s.phistep/180)*s.Ix*(1+s.Kx/100)
		s.Hz+=s.gyro*s.fieldstep*sin(pi*s.thetastep/180)*sin(pi*s.phistep/180)*s.Iy*(1+s.Ky/100)
	elseif(s.fieldsweep==1)
		Kinv = cos(pi/180*s.thetastep)^2*(1+s.Kz/100)^2+sin(pi/180*s.thetastep)^2*cos(pi/180*s.phistep)^2*(1+s.Kx/100)^2+sin(pi/180*s.thetastep)^2*sin(pi/180*s.phistep)^2*(1+s.Ky/100)^2
		s.Hz=s.w0/s.gyro/sqrt(Kinv)*s.Iz
	endif
	
	
End


Function AFHamiltonian(s)
	STRUCT Spectrum &s
	
	make/o/c/n=(2*s.iI+1, 2*s.II+1)  root:spectrumsimulation:system:HAF=0
			
	s.HAF =s.vMAF*sin(pi/2*s.qstep*s.q)*cos(pi*s.thetaAF/180)*s.Iz
	s.HAF+=s.vMAF*sin(pi/2*s.qstep*s.q)*sin(pi*s.thetaAF/180)*cos(pi*s.phiAF/180)*s.Ix
	s.HAF+=s.vMAF*sin(pi/2*s.qstep*s.q)*sin(pi*s.thetaAF/180)*sin(pi*s.phiAF/180)*s.Iy
	
End

Function TotalHamiltonian(s)
	STRUCT Spectrum &s
	SetDataFolder root:spectrumsimulation:system
	make/o/c/n=(2*s.II+1, 2*s.II+1) root:spectrumsimulation:system:Htotal=0

	ZeemanHamiltonian(s)
	AFHamiltonian(s)
	s.Htotal=s.HZ+s.HAF+s.HQ
	
end
