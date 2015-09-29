#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

//Main calculation procedures and decision tree

//Main calculation button, calculates all spectra with spectrum on selected
//Reverts back to originally selected spectrum after calculation
Function CalculateSpectra(ctrlname):Buttoncontrol
	string ctrlname
	
	setdatafolder root:ConMatNMRSimPro:system:
	
	STRUCT Spectrum spec; ;initspectrum(spec)
	
	variable i=1
	
	variable startspecnumber=spec.spectrumnumber
	
	do
		spec.spectrumnumber=i
		Initspectrum(spec); LoadSpectrumData(spec)

		if(spec.spectrumon==1)
			print spec.specname
			CalcSingleSpectrum(spec)
		endif
	
		i+=1
	while(i<=spec.spectrumcount)

	spec.spectrumnumber=startspecnumber
	LoadSpectrumData(spec)
	CalculateSpectrumSum(spec)
	
	setdatafolder root:
end

//Calculates the energy levels of given spectrum
//If transition is turned off values is set to nan
Function CalculateEnergylevels(s)
	STRUCT Spectrum &s

	TotalHamiltonian(s)

	MatrixEigenV/SYM/EVEC s.Htotal 

	variable i = 0, j=0, k=0, m=0
		
	if(s.H0==0 && s.fieldsweep==0)
		if(s.vQ!=0 && s.VMAF==0)
			make/o/n=(s.II-1/2) root:ConMatNMRSimPro:system:energylevels=0
			
			do
				s.Energylevels[i/2] = s.W_eigenvalues[i+2]-s.W_eigenvalues[i]
				i+=2
			while(i<2*s.II-1)
		
		elseif(s.VQ!=0 && s.VMAF!=0)
		
			make/o/n=((2*s.II-1)) root:ConMatNMRSimPro:system:energylevels=0

			do
				s.energylevels[i] = s.W_eigenvalues[i+2]-s.W_eigenvalues[i]
				s.energylevels[i+1]=s.W_eigenvalues[i+3]-s.W_eigenvalues[i+1]
		
				i+=2
			while(i<2*s.II-1)
		endif
		
	elseif(s.H0!=0 || s.fieldsweep==1)
			make/o/n=(2*s.II) root:ConMatNMRSimPro:system:energylevels=0
			
			if(mod(s.ii,1)!=0)
				j=36+5-s.ii+1/2
			else
				j=36+7-s.II
			endif
			
			do
				if(s.nstats[j]==1)
					s.energylevels[i] =abs( s.W_eigenvalues[i+1]-s.W_eigenvalues[i])
				else
					s.Energylevels[i]=nan
				endif
				j+=1	
				i+=1		
			while(i<2*s.II)
		
	endif
		
End


//Calculates single spectrum
//Only calculates HQ, Ix, Iy once
//Sets the range of the calculated spectrum
//Goes through decision tree to decide how to calculate the spectrum
//Normalizes and sets intensity of spectrum
//Calls calculation of anglar dependence if selected
Function CalcSingleSpectrum(s)
	STRUCT Spectrum &s
	
	make/o/n=(100*10^s.spectrumpoints+1) root:ConMatNMRSimPro:$(s.specname) =0
	
	s.thetastep=0; s.phistep=0;s.qstep=0
	
	if(s.fieldsweep==0)
		s.fieldstep=s.H0
	else
		s.fieldstep=s.w0/s.gyro
	endif
	
	QuadrupolarHamiltonian(s)
	makeIx(s)
	makeIy(s)

	CalculateEnergyLevels(s)
	//diagonalizeEandI(s)
	wavestats/q s.Energylevels
	
//Set scaling and range for Spectrum#
	if(s.fieldsweep==0)
		if(s.H0==0)
			if(s.VQ!=0 && s.VMAF ==0 )
				setscale/I x v_min*.8, v_max+.2*v_min, s.nspec
			elseif(s.VQ!=0 && s.VMAF !=0 )
				setscale/I x (v_min)*.8-s.vMAF, (v_max+v_min*.2+s.vMAF), s.nspec
				setscale/I x 0, v_max*2, s.nspec

			endif
		elseif(s.H0!=0)
			if(s.vMAF ==0)
				setscale/I x (v_min)*.8-1, (v_max+.2*v_min)+1, s.nspec
			elseif(s.vMAF !=0)
				//setscale/I x (v_min)*.8-s.vMAF, v_max+.2*v_min+s.vMAF,s.nspec
				setscale/I x 0, 4*v_max,s.nspec
				
			endif
		endif
	elseif(s.fieldsweep ==1)
		if(s.II==.5 && s.VMAF==0)
			setscale/I x v_min*(.90-abs(s.Kaniso/100)), v_max+v_min*(.1+abs(s.Kaniso/100)), s.nspec
		elseif(s.iI>.5 && s.vMAF ==0)
			setscale/I x (s.w0/s.gyro-(s.ii-1/2)*s.vQ/s.gyro)*(.70-abs(s.Kiso/100)-abs(s.Kaniso/100)), (s.w0/s.gyro+(s.ii-1/2)*s.VQ/s.gyro)*(1.3+abs(s.Kiso/100)+abs(s.Kaniso/100)),s.nspec
	//	elseif(gVQ!=0 && gVMAF!=0)
	//		setscale/I x (gw0/ggyro-(gii-1/2)*gvQ/ggyro-gvMAF/ggyro)*.95, (gw0/ggyro+(gii-1/2)*gVQ/ggyro+gvMAF/ggyro)+(gw0/ggyro-(gii-1/2)*gVQ/ggyro-gvMAF/ggyro)*.05,wspec
		endif
	endif
		
	s.spectrumstart = firstxpoint(s.nspec)
	s.spectrumend=lastxpoint(s.nspec)
//Frequency sweep conditition
if(s.fieldsweep==0)
print "-Frequency sweep"
	if(s.H0==0)
		print "--NQR"
		if(s.vMAF==0)
			print "---No AF"
			NQR(s)
			
		elseif(s.vMAF!=0)
			print "---Plus AF"
			NQRAF(s)
		endif
		
	elseif(s.H0!=0 && s.vMAF ==0)
		print"--NMR"
		if(s.powder==0)
			print "---Single Crystal"
			
			NMRfreqswpSC(s)
			
		elseif(s.powder==1)
			print "---Powder"
			
			NMRfreqswppowder(s)			
		
		endif
	elseif(s.H0!=0 && s.vMAF!=0)
		print "--NMR + AF"
		if(s.powder==0)
			print "---Single Crystal"
			
			NMRAFfreqswpSC(s)
			
		elseif(s.powder==1)
			print "---Powder"
			
			NMRAFfreqswppowder(s)
	
		endif
	endif
	
//Field Sweep	
elseif(s.fieldsweep!=0)	
	print "-Field sweep"
	if(s.II == 1/2 &&s.vMAF==0)
		print"--Spin 1/2"
			print "---No AF order"
			if(s.powder ==0)
				print "----Single Crystal"
				
				NMRspin12fieldsweepSC(s)
				
			elseif(s.powder!=0)
				print "----Powder"
				
				NMRspin12fieldsweeppowder(s)			
					
			endif
	elseif(s.vMAF==0)	
		print "--No AF order"
		if(s.powder==0)
			print "---Single Crystal"
			
			NMRfieldsweepSC(s)
			
		elseif(s.powder==1)
			print "---Powder"
			
			NMRfieldsweeppowder(s)
						
		endif
	elseif(s.vMAF!=0)
		print "--Plus AF order"
		if(s.powder ==0)
			print "---Single Crystal"
					
		elseif(s.powder==1)
			print "---Powder"
			print "Coming Soon"
		endif
	endif
endif

wavestats/q s.nspec
s.nspec/=v_max/(s.intensity-s.baseline)
s.nspec+=s.baseline

if(s.fieldsweep==1)
	Label/w=$(s.specwindow) bottom "Field (T)"
elseif(s.fieldsweep==0)
	Label/w=$(s.specwindow) bottom "Frequency (MHz)"
endif

if(s.qandangdep==1)
	Calculateqandangledependence(s)
endif

storespectrumdata(s)


End


//Calculates simple NQR spectrum
Function NQR(s)
	STRUCT Spectrum &s

	s.qstep=0; s.fieldstep=0

	calculateenergylevels(s)
	
	variable i=0, trans

	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif
	
	do
		variable coherencefactor = s.nstats[trans]
		variable linewidth = s.dvQ*(i+1)/1000
		s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
		i+=1
		trans+=1
	while(i<dimsize(s.energylevels,0))
	
End


//Calculates NQR plus AF spectrum
//Half intensity for q=0
Function NQRAF(s)
	STRUCT Spectrum &s	

	variable i=0, j=0, trans
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif	
	
	s.qstep=0

	do
		calculateenergylevels(s)
		do
			variable coherencefactor =s.nstats[trans]
			variable linewidth =s.dvM/1000+ s.dvQ*(i+1+mod(i+1,2))/2/1000
			if(j==0)		
				s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += .5*coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
			else
				s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
			endif
			i+=1
			trans+=1
		while(i<dimsize(s.energylevels,0))	

		if(mod(s.ii,1)!=0)
			trans=50+5-s.ii+1/2
		else
			trans=50+7-s.II
		endif	
	


		i=0
		j+=1
		s.qstep=J*pi/(s.totalqsteps+5)
	while (j<s.totalqsteps)

End

//Simple NMR frequency sweep
Function NMRfreqswpSC(s)
	STRUCT Spectrum &s

	variable i=0, trans
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif
	
	s.thetastep=s.thetaM; s.phistep=s.phiM; s.fieldstep=s.H0;s.phistep=s.phiM
	
	calculateenergylevels(s)
	do
		variable coherencefactor = s.nstats[trans]
		variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000
		if(s.energylevels[i]>0)
			s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
		endif
		i+=1
		trans+=1
	while(i<dimsize(s.energylevels,0))

End

//NMR frequency sweep for powder spectrum
//Angular theta steps offset by 90/angularsteps^2 each phi step to increase efficiency
FUnction NMRfreqswppowder(s)
	STRUCT Spectrum &s	

	s.thetastep=0;s.phistep=0;s.fieldstep=s.H0;s.qstep=0
	
			
	variable i=0, j=0, k=0, trans
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif	
		
	do
		do
			calculateenergylevels(s)
			do
				variable coherencefactor=s.nstats[trans]
				variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000
				
				if(s.energylevels[i]>0)
					s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += sin(pi/180*s.thetastep)*coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
				endif											
				
				i+=1
				trans+=1
			while(i<dimsize(s.energylevels,0))
			i=0
			if(mod(s.ii,1)!=0)
				trans=50+5-s.ii+1/2
			else
				trans=50+7-s.II
			endif	
	
			j+=1
			s.thetastep = 90*j/s.angularsteps+90*k/s.angularsteps^2
			while(j<s.angularsteps)
		
		j=0
		k+=1
		s.thetastep = 90*j/s.angularsteps+90*k/s.angularsteps^2
		print k, "/", s.angularsteps
		s.phistep=90*k/s.angularsteps
	while(k<s.angularsteps)			
	

End

//Single crystal NMR frequency sweep 
Function NMRAFfreqswpSC(s)
	STRUCT Spectrum &s
					
	variable i=0, j=0, trans
	
	s.thetastep=s.thetaM; s.phistep=s.phiM; s.fieldstep=s.H0;s.qstep=0
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif	
	
	do
		calculateenergylevels(s)
		do
			variable coherencefactor =s.nstats[trans]
			variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000
			if(s.energylevels[i]>0)
					s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
			endif
			i+=1
			trans+=1
		while(i<dimsize(s.energylevels,0))
		i=0
		j+=1

		if(mod(s.ii,1)!=0)
			trans=50+5-s.ii+1/2
		else
			trans=50+7-s.II
		endif	

		s.qstep=4*j/s.q/(s.totalqsteps)
		print j, "/", s.totalqsteps
	while (j<s.totalqsteps)
			
end

//Powder NMR AF frequency sweep
//Angular theta steps offset by 90/angularsteps^2 each phi step to increase efficiency
//Half intensity for q=0
Function NMRAFfreqswppowder(s)
	STRUCT Spectrum &s
	
	s.thetastep=0;s.phistep = 0;s.qstep=0;s.fieldstep=s.H0
	
	variable i=0, j=0, k=0, m=0, trans
	
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif	
	
	do
		do
			do
				calculateenergylevels(s)
				do
					variable coherencefactor = s.nstats[trans]
					variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000
					if(s.energylevels[i]>0)
						s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += sin(pi/180*s.thetastep)*coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
					endif
					i+=1
					trans+=1
				while(i<dimsize(s.energylevels,0))
				i=0
				s.qstep+=1

				if(mod(s.ii,1)!=0)
					trans=50+5-s.ii+1/2
				else
					trans=50+7-s.II
				endif	

				j+=1
			while (j<s.totalqsteps)
			s.qstep=0
			j=0
			k+=1
			s.thetastep=k*90/s.angularsteps+m*90/s.angularsteps^2
		while(k<s.angularsteps)
		k=0
		m+=1
		s.thetastep=k*90/s.angularsteps+m*90/s.angularsteps^2
		s.phistep=m/s.angularsteps*90
		print m, "/" , s.angularsteps
	while(m<s.angularsteps)
						

end	
	
//Spin 1/2 field sweep, can simplify Hamiltonian
Function NMRspin12fieldsweepSC(s)
	STRUCT Spectrum &s

	s.fieldstep=s.H0;s.qstep=0;s.thetastep=s.thetaM;s.phistep=s.phiM

	calculateenergylevels(s)	
	variable i =0
	
	do
		variable coherencefactor =1
		variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000/s.gyro
	
		s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
		i+=1
	while(i<dimsize(s.energylevels,0))
			
end

//Spin 1/2 field sweep powder, can simplify Hamiltonian
Function NMRspin12fieldsweeppowder(s)
	STRUCT Spectrum &s
	
	s.fieldstep=s.H0; s.thetastep=0;s.phistep = 0;s.qstep=0	
		
	make/o/n=(s.angularsteps, s.angularsteps) root:ConMatNMRSimPro:system:thetawave=0
	make/o/n=(s.angularsteps) root:ConMatNMRSimPro:system:phiwave=0

	variable i=0, j=0, k=0
	do
		do
			calculateenergylevels(s)
			do
				variable coherencefactor =1
				variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000+s.dvM/1000/s.gyro
							
				s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += sin(pi/180*s.thetastep)*coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
												
				i+=1
								
			while(i<dimsize(s.energylevels,0))
			i=0
			s.thetawave[j][k]=s.thetastep
			j+=1
			s.thetastep= 90*j/s.angularsteps+90*k/s.angularsteps^2
		while(j<s.angularsteps)
		j=0
		s.phiwave[k]=s.phistep
		k+=1
		print k, "/", s.angularsteps
		s.phistep=90*k/s.angularsteps
	while(k<s.angularsteps)

end

//I>1/2 field sweep for single crystal
//Calculates resonance freq as a functino of field then interpolates to w0
Function NMRfieldsweepSC(s)
	STRUCT Spectrum &s
	
	s.qstep=0; s.thetastep=s.thetaM; s.phistep=s.phiM

	make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:fieldsteps=0, root:ConMatNMRSimPro:system:interpwave
	make/o/n=(s.totalfieldsteps, s.II*2) root:ConMatNMRSimPro:system:FSenergylevels=0
	make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:w0wave
			
	setscale/I x (s.w0/s.gyro-(s.ii-1/2)*s.vQ/s.gyro)*.95, (s.w0/s.gyro+(s.ii-1/2)*s.VQ/s.gyro)+(s.w0/s.gyro-(s.ii-1/2)*s.VQ/s.gyro)*.05, s.FSenergylevels, s.w0wave
	s.fieldsteps= pnt2x(s.fsenergylevels, 0) + x* dimdelta(s.fsenergylevels, 0)
	
	variable i=0, trans
	
	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif
				
	
	do
		s.fieldstep=s.fieldsteps[i]
		calculateenergylevels(s)			
		s.FSenergylevels[i][] =s. energylevels[y]
		i+=1	
	while(i<dimsize(s.fieldsteps,0))
	
	i=0
	do
		s.interpwave = s.FSenergylevels[x][i]
		s.energylevels[i] = interp(s.w0, s.interpwave, s.fieldsteps)
				
		variable coherencefactor =s.nstats[trans]
		variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000/s.gyro+s.dvM/1000/s.gyro

		if(s.energylevels[i]>0)
			s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] += coherencefactor*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
		endif			
		i+=1
		trans+=1
	while(i<dimsize(s.energylevels,0))
	

end

//I>1/2 field sweep for powder
//Calculates resonance freq as a functino of field then interpolates to w0
Function NMRfieldsweeppowder(s)
	STRUCT Spectrum &s


	make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:fieldsteps=0, root:ConMatNMRSimPro:system:interpwave
	make/o/n=(s.totalfieldsteps, s.II*2) root:ConMatNMRSimPro:system:FSenergylevels=0
	make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:w0wave
			
	setscale/I x (s.w0/s.gyro-(s.ii-1/2)*s.vQ/s.gyro)*.95, (s.w0/s.gyro+(s.ii-1/2)*s.VQ/s.gyro)+(s.w0/s.gyro-(s.ii-1/2)*s.VQ/s.gyro)*.05, s.FSenergylevels, s.w0wave
	s.fieldsteps= pnt2x(s.fsenergylevels, 0) + x* dimdelta(s.fsenergylevels, 0)
	
	s.thetastep=0;s.phistep = 0;s.qstep=0
	
	variable i=0, j=0, k=0, trans

	if(mod(s.ii,1)!=0)
		trans=50+5-s.ii+1/2
	else
		trans=50+7-s.II
	endif
				
	make/o/n=(s.angularsteps, s.angularsteps) root:ConMatNMRSimPro:system:thetawave=0
	make/o/n=(s.angularsteps)  root:ConMatNMRSimPro:system:phiwave=0
	
	do			
		do
			do
				s.fieldstep=s.fieldsteps[i]
				calculateenergylevels(s)
				
				s.FSenergylevels[i][] = s.energylevels[y]

				i+=1	
			while(i<dimsize(s.fieldsteps,0))
			i=0
	 			
			do
				s.interpwave = s.FSenergylevels[x][i]
				s.energylevels[i] = interp(s.w0, s.interpwave, s.fieldsteps)
				
				variable coherencefactor = s.nstats[trans]
				variable linewidth = abs(s.dvQ*(i-s.II+1/2))/1000/s.gyro+s.dvM/1000/s.gyro
				if(s.energylevels[i]>0)
					s.nspec[x2pnt(s.nspec,s.energylevels[i]-linewidth*5), x2pnt(s.nspec,s.energylevels[i]+linewidth*5)] +=sin(pi/180*s.thetastep)* coherencefactor/linewidth*exp(-(x-s.energylevels[i])^2/sqrt(2)/linewidth^2)
				endif			
				i+=1
				trans+=1
			while(i<dimsize(s.energylevels,0))
			i=0
			if(mod(s.ii,1)!=0)
				trans=50+5-s.ii+1/2
			else
				trans=50+7-s.II
			endif
			s.thetawave[j][k]=s.thetastep
			j+=1
			s.thetastep=90*j/(s.angularsteps)+90*k/(s.angularsteps)^2
		while(j<s.angularsteps)
		s.phiwave[k]=s.phistep
		j=0
		k+=1
		s.thetastep=90*k/(s.angularsteps)^2
		s.phistep=90*k/(s.angularsteps)
		print k, "/", s.angularsteps
	while(k<s.angularsteps)
		

End

//Calculates the angular dependence of the resonance frequency or eigenvalues
Function  Calculateqandangledependence(s)
	STRUCT Spectrum &s

	variable i=0, j=0
	make/o/n=(s.angularsteps, s.II*2) root:ConMatNMRSimPro:energywaves:$("Energyvstheta"+num2istr(s.spectrumnumber)),root:ConMatNMRSimPro:energywaves:$("Energyvsphi"+num2istr(s.spectrumnumber)),root:ConMatNMRSimPro:energywaves:$("Energyvsthetaphi"+num2istr(s.spectrumnumber))
	make/o/n=(s.angularsteps,s.II*2+1) root:ConMatNMRSimPro:eigenwaves:$("Eigenvaluesvstheta"+num2istr(s.spectrumnumber)), root:ConMatNMRSimPro:Eigenwaves:$("Eigenvaluesvsphi"+num2istr(s.spectrumnumber)), root:ConMatNMRSimPro:Eigenwaves:$("Eigenvaluesvsthetaphi"+num2istr(s.spectrumnumber))
	initspectrum(s)
	setscale/P x 0, 90/(s.angularsteps-1), s.nEvstheta, s.nEvsphi, s.nEvsthetaphi, s.nEVvstheta, s.nEVvsphi, s.nEVvsthetaphi

	if(s.H0!=0)
		make/o/n=(s.totalqsteps, s.II*2)  root:ConMatNMRSimPro:energywaves:$("Energyvsq"+num2istr(s.spectrumnumber))
	elseif(s.H0==0)
		make/o/n=(s.totalqsteps, s.II-1/2)  root:ConMatNMRSimPro:energywaves:$("Energyvsq"+num2istr(s.spectrumnumber))
	endif
	
	make/o/n=(s.totalqsteps, s.II*2+1)  root:ConMatNMRSimPro:eigenwaves:$("Eigenvaluesvsq"+num2istr(s.spectrumnumber))
	
	if(s.frequencysweep==1 && s.H0!=0)
			
		s.thetastep=0; s.phistep=0; s.qstep=0; s.fieldstep=s.H0
		
		do
			calculateenergylevels(s)
			s.nEvstheta[i][]=s.energylevels[y]
			s.nEVvstheta[i][]=s.w_eigenvalues[y]
			i+=1
			s.thetastep=i*90/(s.angularsteps-1)
		while(i<s.angularsteps)

		i=0
		s.thetastep=90
		s.phistep=0
		
		do
			calculateenergylevels(s)
			s.nEvsphi[i][]=s.energylevels[y]
			s.nEVvsphi[i][]=s.w_eigenvalues[y]
			i+=1
			s.phistep=i*90/(s.angularsteps-1)
		while(i<s.angularsteps)
		
		i=0; s.thetastep=0; s.phistep=0
		
		do
			calculateenergylevels(s)
			s.nEvsthetaphi[i][]=s.energylevels[y]
			s.nEVvsthetaphi[i][]=s.w_eigenvalues[y]
			i+=1
			s.phistep=i*90/(s.angularsteps-1)
			s.thetastep=s.phistep
		while(i<s.angularsteps)
		i=0; s.thetastep=0; s.phistep=0
		
	elseif(s.fieldsweep==1)
		make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:fieldsteps=0
		make/o/n=(s.totalfieldsteps, s.II*2) root:ConMatNMRSimPro:system:FSenergylevels=0

		setscale/I x (s.w0/s.gyro-(s.ii-1/2)*s.vQ/s.gyro)*.95, (s.w0/s.gyro+(s.ii-1/2)*s.VQ/s.gyro)+(s.w0/s.gyro-(s.ii-1/2)*s.VQ/s.gyro)*.05, s.FSenergylevels
		s.fieldsteps= pnt2x(s.fsenergylevels, 0) + x* dimdelta(s.fsenergylevels,0)

		s.thetastep=0; s.phistep=0
		do
			do
				s.fieldstep=s.fieldsteps[i]
				calculateenergylevels(s)			
				s.FSenergylevels[i][] = s.energylevels[y]
	
				i+=1	
			while(i<dimsize(s.fieldsteps,0))
			i=0
					 
			 make/o/n=(dimsize(s.fsenergylevels, 0)) root:ConMatNMRSimPro:system:interpwave
				
			do
				s.interpwave = s.FSenergylevels[x][i]
				s.nEvstheta[j][i]= interp(s.w0, s.interpwave, s.fieldsteps)
				i+=1
			while(i<dimsize(s.nEvstheta,1))
			i=0
			j+=1
			s.thetastep=j*90/(s.angularsteps-1)
		while(j<s.angularsteps)
		i=0; j=0
		
		s.thetastep=90; s.phistep=0
		do
			do
				s.fieldstep=s.fieldsteps[i]
				calculateenergylevels(s)			
				s.FSenergylevels[i][] = s.energylevels[y]
	
				i+=1	
			while(i<dimsize(s.fieldsteps,0))
			i=0
					 				
			do
				s.interpwave = s.FSenergylevels[x][i]
				s.nEvsphi[j][i]= interp(s.w0, s.interpwave, s.fieldsteps)
				i+=1
			while(i<dimsize(s.nEvsphi,1))
			i=0
			j+=1
			s.phistep=j*90/(s.angularsteps-1)
		while(j<s.angularsteps)
		i=0; j=0
		
		s.thetastep=0; s.phistep=0
		do
			do
				s.fieldstep=s.fieldsteps[i]
				calculateenergylevels(s)			
				s.FSenergylevels[i][] = s.energylevels[y]
	
				i+=1	
			while(i<dimsize(s.fieldsteps,0))
			i=0
					 				
			do
				s.interpwave = s.FSenergylevels[x][i]
				s.nEvsthetaphi[j][i]= interp(s.w0, s.interpwave, s.fieldsteps)
				i+=1
			while(i<dimsize(	s.nEvsthetaphi,1))
			i=0
			j+=1
			s.phistep=j*90/(s.angularsteps-1)
			s.thetastep=s.phistep
		while(j<s.angularsteps)
		i=0;j=0; s.phistep=0; s.thetastep=0
	endif

	if(s.vMAF!=0 && s.frequencysweep==1)
		setscale/P x 0, s.q, s.nEvsq, s.nEVvsq
		s.thetastep=s.thetaM; s.phistep=s.phiM; s.qstep=0; s.fieldstep=s.H0
		
		do
			calculateenergylevels(s)
			s.nEVvsq[i][]=s.w_eigenvalues[y]
			s.nEvsq[i][]=s.energylevels[y]
			i+=1
			s.qstep=4*i/s.q/(s.totalqsteps-1)
		while(i<s.totalqsteps)

		i=0
		s.qstep=0
	elseif(s.vMAF!=0 && s.fieldsweep==1)
		setscale/P x 0, s.q, s.nEvsq, s.nEVvsq
		
		s.thetastep=0; s.phistep=0; s.qstep=0
		
		make/o/n=(s.totalfieldsteps) root:ConMatNMRSimPro:system:fieldsteps=0
		make/o/n=(s.fieldsteps, s.II*2) root:ConMatNMRSimPro:system:FSenergylevels=0
		
		setscale/I x (s.w0/s.gyro-(s.ii-1/2)*s.vQ/s.gyro)*.95, (s.w0/s.gyro+(s.ii-1/2)*s.VQ/s.gyro)+(s.w0/s.gyro-(s.ii-1/2)*s.VQ/s.gyro)*.05, s.FSenergylevels
		s.fieldsteps= pnt2x(s.fsenergylevels, 0) + x* dimdelta(s.fsenergylevels,0)

		s.thetastep=s.thetaM; s.phistep=s.phiM
		do
			do
				s.fieldstep=s.fieldsteps[i]
				calculateenergylevels(s)			
				s.FSenergylevels[i][] = s.energylevels[y]
	
				i+=1	
			while(i<dimsize(s.fieldsteps,0))
			i=0
					 
			 make/o/n=(dimsize(s.fsenergylevels, 0)) root:ConMatNMRSimPro:system:interpwave
				
			do
				s.interpwave = s.FSenergylevels[x][i]
				s.nEvsq[j][i]= interp(s.w0, s.interpwave, s.fieldsteps)
				i+=1
			while(i<dimsize(s.nEvsq,1))
			i=0
			j+=1
			s.qstep=4*i/s.q/(s.totalqsteps-1)
		while(j<s.totalqsteps)
		i=0; j=0; s.qstep=0
	endif
	
	if(s.vMAF==0)
		s.nEvsq=nan; s.nEVvsq=NAN
	endif
	
	if(s.fieldsweep==1)
		s.nEVvstheta=nan; s.nEvvsphi=nan; s.nEvvsthetaphi=nan
	endif
	
end

//Yet to be complete resonance frequency and eigen values vs field
Function CalculateResVsworH(s)
	STRUCT spectrum &s
	
	variable i=0
	
	QuadrupolarHamiltonian(s)
	makeIx(s)
	makeIy(s)	
	
	if(s.fieldsweep==1)
		make/n=(300, s.ii*2)/o root:ConMatNMRSimPro:WandHdep:$("ResvsHtheta"+num2str(s.spectrumnumber))=0,  root:ConMatNMRSimPro:WandHdep:$("ResvsHphi"+num2str(s.spectrumnumber))=0,  root:ConMatNMRSimPro:WandHdep:$("ResvsHthetaphi"+num2str(s.spectrumnumber))=0;initspectrum(s)
		setscale/i x .1, 100, s.nresvshtheta, s.nresvshphi, s.nresvshthetaphi
		
		s.thetastep=0;s.phistep=0
		do	
			s.fieldstep=pnt2x(s.nresvsHtheta,i)
			CalculateEnergylevels(s)
		
			s.nresvsHtheta[i]=s.energylevels[y]
			i+=1
		while(i<dimsize(s.nresvshtheta,0))
		i=0
		
		s.thetastep=90
		do	
			s.fieldstep=pnt2x(s.nresvsHphi,i)
			CalculateEnergylevels(s)
		
			s.nresvsHphi[i]=s.energylevels[y]
			i+=1
		while(i<dimsize(s.nresvshphi,0))
		i=0
		s.thetastep=90;s.phistep=90
		do	
			s.fieldstep=pnt2x(s.nresvsHthetaphi,i)
			CalculateEnergylevels(s)
		
			s.nresvsHthetaphi[i]=s.energylevels[y]
			i+=1
		while(i<dimsize(s.nresvshthetaphi,0))

	endif
	


end

//Function test()
	STRUCT spectrum spec; initspectrum(spec)
	
	calculateresvsworh(spec)
	
	
end