#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

//Procedures which calculate the different Hamiltonians starting with the spin Hamiltonians

//Iz matrix
Function MakeIz(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Iz =0
	variable i=0
	do
		s.Iz[i][i] = -s.II+i
		i+=1
	while(i<2*s.II+1)

End 

//I^2 matrix
Function MakeI2(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:I2 =0
	
	variable i=0
	
	do
		s.I2[i][i] = s.II*(s.II+1)
	
		i+=1
	
	while(i<2*s.II+1)
	
End

//I+ matrix
Function MakeIplus(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Iplus =0
	
	variable i=-s.II
	do
		s.Iplus[i+s.II][i+1+s.II] =sqrt(s.ii*(s.ii+1)-i*(i+1))
	
		i+=1
	
	while(i<s.II)
	
End

//I- matrix
Function MakeIminus(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Iminus =0	
	
	variable i=-s.II+1
	do
		s.Iminus[i+s.II][i+s.II-1] =sqrt(s.II*(s.II+1)-i*(i-1))
	
		i+=1
	
	while(i<s.II+1)
	
End

//Ix matrix, made from sum of I+ and I-
Function MakeIx(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Ix =0
	
	MakeIplus(s)
	MakeIminus(s)
		
	s.Ix = .5*(s.Iplus+s.Iminus)
	
End

//Iy matrix made from I+ and I-
Function MakeIy(s)
	STRUCT Spectrum &s
		
	make/c/o/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Iy =0
	
	MakeIplus(s)
	MakeIminus(s)
		
	s.Iy = .5/sqrt(-1)*(s.Iplus - s.Iminus)

End

//Quad Hamiltonian, calculates Iz^2, I+^2, I-^2, only depends on vQ and eta
Function QuadrupolarHamiltonian(s)
	STRUCT Spectrum &s
		
	MakeIz(s)
	MakeI2(s)
	MakeIplus(s)
	MakeIminus(s)
		
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:ConMatNMRSimPro:system:Iz2= 0
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:ConMatNMRSimPro:system:Iminus2= 0
	make/o/c/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Iplus2= 0

	MatrixMultiply s.Iz, s.Iz
	s.Iz2 = s.product

	MatrixMultiply s.Iplus, s.Iplus
	s.Iplus2 = s.product

	MatrixMultiply s.Iminus, s.Iminus
	s.Iminus2= s.product

	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:ConMatNMRSimPro:system:HQ=0
 
	s.HQ= s.vQ/6*(3*s.Iz2 - s.I2 + s.eta/2*(s.Iplus2+s.Iminus2))
End	

//Zeeman Hamiltonian, calculated form gamma, thetaM, phiM, Kx, Ky, Kz, and H0
Function ZeemanHamiltonian(s)
	STRUCT Spectrum &s
	
	variable Kinv
	make/o/c/n=(2*s.II+1, 2*s.II+1)  root:ConMatNMRSimPro:system:HZ=0
	if(s.fieldsweep==0 || (s.fieldsweep ==1 && s.II>1/2))
		s.Hz = s.gyro*s.fieldstep*(cos(pi*s.thetastep/180)*s.Iz*(1+s.Kz/100))
		s.Hz+=s.gyro*s.fieldstep*sin(pi*s.thetastep/180)*cos(pi*s.phistep/180)*s.Ix*(1+s.Kx/100)
		s.Hz+=s.gyro*s.fieldstep*sin(pi*s.thetastep/180)*sin(pi*s.phistep/180)*s.Iy*(1+s.Ky/100)
	elseif(s.fieldsweep==1)
		Kinv = cos(pi/180*s.thetastep)^2*(1+s.Kz/100)^2+sin(pi/180*s.thetastep)^2*cos(pi/180*s.phistep)^2*(1+s.Kx/100)^2+sin(pi/180*s.thetastep)^2*sin(pi/180*s.phistep)^2*(1+s.Ky/100)^2
		s.Hz=s.w0/s.gyro/sqrt(Kinv)*s.Iz
	endif
	
	
End

//AF Hamiltonian with ability to have different angle than Zeeman Hamiltonian
//Calculated by vMAF, q, and angles relative to Vzz
Function AFHamiltonian(s)
	STRUCT Spectrum &s
	
	make/o/c/n=(2*s.iI+1, 2*s.II+1)  root:ConMatNMRSimPro:system:HAF=0
			
	s.HAF =s.vMAF*sin(pi/2*s.qstep*s.q)*cos(pi*s.thetaAF/180)*s.Iz
	s.HAF+=s.vMAF*sin(pi/2*s.qstep*s.q)*sin(pi*s.thetaAF/180)*cos(pi*s.phiAF/180)*s.Ix
	s.HAF+=s.vMAF*sin(pi/2*s.qstep*s.q)*sin(pi*s.thetaAF/180)*sin(pi*s.phiAF/180)*s.Iy
	
End

//Calculates sum of Hamiltonians. Quadrupolar Hamiltonian is independent of H, w, angle, q, ect. therefore is calculated 
//before this functoin
Function TotalHamiltonian(s)
	STRUCT Spectrum &s
	SetDataFolder root:ConMatNMRSimPro:system
	make/o/c/n=(2*s.II+1, 2*s.II+1) root:ConMatNMRSimPro:system:Htotal=0

	ZeemanHamiltonian(s)
	AFHamiltonian(s)
	s.Htotal=s.HZ+s.HAF+s.HQ
	
end
