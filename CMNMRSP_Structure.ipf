#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

//Structure definition and initialization procedures

//Main structure
Structure Spectrum
	
	//General variables
	NVAR atomicmass, altatomicmass, II, gyro, w0, H0, fieldsweep, frequencysweep, intensity, spectrumnumber, spectrumon , spectrumdisplay, qandangdep, NQR
	NVAR powder, singlecrystal, spectrumpoints, angularsteps, totalfieldsteps, baseline, spectrumsumdisplay, spectrumstart, spectrumend
	NVAR spectrumcount, oldbaseline, previousmass
	
	NVAR thetastep, phistep, qstep, fieldstep
	
	SVAR nucleus
	
	string specname
	//Magnetic NVARs
	NVAR  Kiso, Kaniso, epsilon, dVM, thetaM, phiM, useKxyz, Kx, Ky, Kz
	
	//Qaud NVARs
	NVAR vQ, eta, dvQ
	
	//AF NVARs
	NVAR vMAF, q, thetaAF, phiAF, totalqsteps
	
	//Transition NVARs
	NVAR  t11_2on,  t9_2on,  t7_2on,  t5_2on,  t3_2on,  t1_2on,  tm1_2on,  tm3_2on, tm5_2on,  tm7_2on,  tm9_2on
	NVAR  I11_2,  I9_2,  I7_2,  I5_2,  I3_2,  I1_2,  Im1_2,  Im3_2,  Im5_2,  Im7_2,  Im9_2
	
	//Hamiltonian tensors
	wave/c Iz, Ix, Iy, I2, Ix2, Iy2, Iz2 ,Iplus, Iminus, Iplus2, Iminus2, product, HQ, HZ, HAF, Htotal
	
	//Simultion storage waves
	wave nspec, nstats, spectrumsum, ntrans
	
	//Windowstrings
	string specwindow, transpanelname
	
	//systemwaves
	wave energylevels, transon, transintensity, w_eigenvalues, thetawave, phiwave, fieldsteps, FSenergylevels, w0wave, interpwave, intensities
	
	//Energy and EVwaves
	wave nEvsq, nEvstheta, nEvsphi, nEvsthetaphi, nEVvsq, nEVvstheta, nEVvsphi, nEVvsthetaphi
	wave Evsq, Evstheta, Evsphi, Evsthetaphi, EVvsq, EVvstheta, EVvsphi, EVvsthetaphi
	
	//Res vs H and w
	wave nResvsHtheta, nresvsHphi, nresvsHthetaphi
	wave nresvswtheta, nresvswphi, nresvswthetaphi
	
	//Full Diag
	wave energymatrix, eigenvectors, teigenvectors, EvsI, EvsH, IvsH
	wave/c Msquared
	wave/t transname, inttransname, parameternamewave, statsnamewave
	
	//Nucleus information waves
	wave nuclearspin, nucleargyro
	wave/t nucleusname
	
Endstructure

//Initilization function
Function InitSpectrum(s)
	STRUCT Spectrum &s

	SVAR s.nucleus=root:ConMatNMRSimPro:system:gnucleus
	//General Variables	
	NVAR s.atomicmass=root:ConMatNMRSimPro:system:gatomicmass
	NVAR s.altatomicmass=root:ConMatNMRSimPro:system:galtatomicmass
	NVAR s.previousmass=root:ConMatNMRSimPro:system:gpreviousmass
	NVAR s.II=root:ConMatNMRSimPro:system:gII
	NVAR s.gyro=root:ConMatNMRSimPro:system:ggyro
	NVAR s.w0=root:ConMatNMRSimPro:system:gw0
	NVAR s.H0=root:ConMatNMRSimPro:system:gH0
	NVAR  s.fieldsweep=root:ConMatNMRSimPro:system:gfieldsweep
	NVAR s.frequencysweep=root:ConMatNMRSimPro:system:gfrequencysweep
	NVAR  s.intensity=root:ConMatNMRSimPro:system:gintensity
	NVAR s.spectrumnumber=root:ConMatNMRSimPro:system:gspectrumnumber
	NVAR  s.spectrumon=root:ConMatNMRSimPro:system:gspectrumon 
	NVAR  s.spectrumdisplay=root:ConMatNMRSimPro:system:gspectrumdisplay
	NVAR  s.qandangdep=root:ConMatNMRSimPro:system:gqandangdep
	NVAR  s.NQR=root:ConMatNMRSimPro:system:gNQR
	NVAR s.powder=root:ConMatNMRSimPro:system:gpowder
	NVAR  s.singlecrystal=root:ConMatNMRSimPro:system:gsinglecrystal
	NVAR s.spectrumpoints=root:ConMatNMRSimPro:system:gspectrumpoints
	NVAR s.angularsteps=root:ConMatNMRSimPro:system:gangularsteps
	NVAR s.totalfieldsteps=root:ConMatNMRSimPro:system:gfieldsteps
	 NVAR s.baseline=root:ConMatNMRSimPro:system:gbaseline
	 NVAR s.spectrumsumdisplay=root:ConMatNMRSimPro:system:gspectrumsumdisplay
	 NVAR s.spectrumstart=root:ConMatNMRSimPro:system:gspectrumstart
	 NVAR  s.spectrumend=root:ConMatNMRSimPro:system:gspectrumend
	NVAR  s.spectrumcount=root:ConMatNMRSimPro:system:gspectrumcount
	NVAR s.oldbaseline=root:ConMatNMRSimPro:system:goldbaseline	
	
	NVAR s.thetastep=root:ConMatNMRSimPro:system:gthetastep
	NVAR s.phistep=root:ConMatNMRSimPro:system:gphistep
	NVAR s.qstep=root:ConMatNMRSimPro:system:gqstep
	NVAR s.fieldstep=root:ConMatNMRSimPro:system:gfieldstep
	
	//Magnetic variables	
	NVAR  s.Kiso=root:ConMatNMRSimPro:system:gKiso
	NVAR s.Kaniso=root:ConMatNMRSimPro:system:gKaniso
	NVAR s.epsilon=root:ConMatNMRSimPro:system:gepsilon
	NVAR s.dvM=root:ConMatNMRSimPro:system:gdVM
	NVAR s.thetaM=root:ConMatNMRSimPro:system:gthetaM
	NVAR s.phiM=root:ConMatNMRSimPro:system:gphiM
	NVAR s.useKxyz=root:ConMatNMRSimPro:system:guseKxyz
	NVAR s.Kx=root:ConMatNMRSimPro:system:gKx
	NVAR s.Ky=root:ConMatNMRSimPro:system:gKy
	NVAR s.Kz=root:ConMatNMRSimPro:system:gKz

	//Quadrupolar variables
	NVAR s.vQ=root:ConMatNMRSimPro:system:gvQ
	NVAR  s.eta=root:ConMatNMRSimPro:system:geta
	NVAR s.dvQ=root:ConMatNMRSimPro:system:gdvQ
		
	//AF variables	
	NVAR s.vMAF=root:ConMatNMRSimPro:system:gvMAF
	NVAR s.q=root:ConMatNMRSimPro:system:gq
	NVAR  s.thetaAF=root:ConMatNMRSimPro:system:gthetaAF
	NVAR s.phiAF=root:ConMatNMRSimPro:system:gphiAF
	NVAR s.totalqsteps=root:ConMatNMRSimPro:system:gtotalqsteps

	//Transitions
	NVAR s.t11_2on=root:ConMatNMRSimPro:system:g11_2on
	NVAR s.t9_2on=root:ConMatNMRSimPro:system:g9_2on
	NVAR  s.t7_2on=root:ConMatNMRSimPro:system:g7_2on
	NVAR s.t5_2on=root:ConMatNMRSimPro:system:g5_2on
	NVAR  s.t3_2on=root:ConMatNMRSimPro:system:g3_2on
	NVAR  s.t1_2on=root:ConMatNMRSimPro:system:g1_2on
	NVAR  s.tm1_2on=root:ConMatNMRSimPro:system:gm1_2on
	NVAR  s.tm3_2on=root:ConMatNMRSimPro:system:gm3_2on
	NVAR s.tm5_2on=root:ConMatNMRSimPro:system:gm5_2on
	NVAR s.tm7_2on=root:ConMatNMRSimPro:system:gm7_2on
	NVAR s.tm9_2on=root:ConMatNMRSimPro:system:gm9_2on
	NVAR s.I11_2=root:ConMatNMRSimPro:system:gI11_2
	NVAR s.I9_2=root:ConMatNMRSimPro:system:gI9_2
	NVAR s.I7_2=root:ConMatNMRSimPro:system:gI7_2
	NVAR s.I5_2=root:ConMatNMRSimPro:system:gI5_2 
	NVAR s.I3_2=root:ConMatNMRSimPro:system:gI3_2
	NVAR s.I1_2=root:ConMatNMRSimPro:system:gI1_2
	NVAR  s.Im1_2=root:ConMatNMRSimPro:system:gIm1_2
	NVAR s.Im3_2=root:ConMatNMRSimPro:system:gIm3_2
	NVAR s.Im5_2=root:ConMatNMRSimPro:system:gIm5_2
	NVAR s.Im7_2=root:ConMatNMRSimPro:system:gIm7_2
	NVAR s.Im9_2=root:ConMatNMRSimPro:system:gIm9_2
	
	//Windows and panels
	s.specwindow="SpectrumSimulationPanel#G0"
	s.specname="Spectrum"+num2istr(s.spectrumnumber)
	s.transpanelname="transitionspanel"
	
	//Hamiltonian tensors
	wave/c s.Iz=root:ConMatNMRSimPro:system:Iz
	wave/c s.Iz2=root:ConMatNMRSimPro:system:Iz2
	wave/c s.Ix=root:ConMatNMRSimPro:system:Ix
	wave/c s.Iy=root:ConMatNMRSimPro:system:Iy
	wave/c s.I2=root:ConMatNMRSimPro:system:I2
	wave/c s.Iplus=root:ConMatNMRSimPro:system:Iplus
	wave/c s.Iminus=root:ConMatNMRSimPro:system:Iminus
	wave/c s.Iplus2=root:ConMatNMRSimPro:system:Iplus2
	wave/c s.Iminus2=root:ConMatNMRSimPro:system:Iminus2
	wave/c s.HQ=root:ConMatNMRSimPro:system:HQ
	wave/c s.HZ=root:ConMatNMRSimPro:system:HZ
	wave/c s.HAF=root:ConMatNMRSimPro:system:HAF
	wave/c s.Htotal=root:ConMatNMRSimPro:system:Htotal
	wave/c s.product=root:ConMatNMRSimPro:system:m_product
	
	//Simulation waves
	wave s.nspec=root:ConMatNMRSimPro:$("Spectrum"+num2istr(s.spectrumnumber))
	wave s.nstats=root:ConMatNMRSimPro:$("StatsSpectrum"+num2istr(s.spectrumnumber))
	
	wave s.energylevels=root:ConMatNMRSimPro:system:energylevels
	wave s.intensities=root:ConMatNMRSimPro:system:intensities
	wave s.w_eigenvalues=root:ConMatNMRSimPro:system:w_eigenvalues
	wave s.transon=root:ConMatNMRSimPro:system:transon
	wave s.transintensity=root:ConMatNMRSimPro:system:transintensity
	wave s.thetawave=root:ConMatNMRSimPro:system:thetawave
	wave s.phiwave=root:ConMatNMRSimPro:system:phiwave
	wave s.fieldsteps=root:ConMatNMRSimPro:system:fieldsteps
	wave s.FSenergylevels=root:ConMatNMRSimPro:system:FSenergylevels
	wave s.w0wave=root:ConMatNMRSimPro:system:w0wave
	wave s.interpwave=root:ConMatNMRSimPro:system:interpwave
	
	wave s.nEvsq=root:ConMatNMRSimPro:energywaves:$("Energyvsq"+num2istr(s.spectrumnumber))
	wave s.nEvstheta=root:ConMatNMRSimPro:energywaves:$("Energyvstheta"+num2istr(s.spectrumnumber))
	wave s.nEvsphi=root:ConMatNMRSimPro:energywaves:$("Energyvsphi"+num2istr(s.spectrumnumber))
	wave s.nEvsthetaphi=root:ConMatNMRSimPro:energywaves:$("Energyvsthetaphi"+num2istr(s.spectrumnumber))
	wave s.nEVvsq=root:ConMatNMRSimPro:eigenwaves:$("Eigenvaluesvsq"+num2istr(s.spectrumnumber))
	wave s.nEVvstheta=root:ConMatNMRSimPro:Eigenwaves:$("Eigenvaluesvstheta"+num2istr(s.spectrumnumber))
	wave s.nEVvsphi=root:ConMatNMRSimPro:eigenwaves:$("Eigenvaluesvsphi"+num2istr(s.spectrumnumber))
	wave s.nEVvsthetaphi=root:ConMatNMRSimPro:eigenwaves:$("Eigenvaluesvsthetaphi"+num2istr(s.spectrumnumber))

	wave s.Evsq=root:ConMatNMRSimPro:system:$("Energyvsq")
	wave s.Evstheta=root:ConMatNMRSimPro:system:$("Energyvstheta")
	wave s.Evsphi=root:ConMatNMRSimPro:system:$("Energyvsphi")
	wave s.Evsthetaphi=root:ConMatNMRSimPro:system:$("Energyvsthetaphi")
	wave s.EVvsq=root:ConMatNMRSimPro:system:$("Eigenvaluesvsq")
	wave s.EVvstheta=root:ConMatNMRSimPro:system:$("Eigenvaluesvstheta")
	wave s.EVvsphi=root:ConMatNMRSimPro:system:$("Eigenvaluesvsphi")
	wave s.EVvsthetaphi=root:ConMatNMRSimPro:system:$("Eigenvaluesvsthetaphi")

	wave s.nresvsHtheta=root:ConMatNMRSimPro:WandHdep:$("ResvsHtheta"+num2str(s.spectrumnumber))
	wave s.nresvsHphi=root:ConMatNMRSimPro:WandHdep:$("ResvsHphi"+num2str(s.spectrumnumber))
	wave s.nresvsHthetaphi=root:ConMatNMRSimPro:WandHdep:$("ResvsHthetaphi"+num2str(s.spectrumnumber))

	wave/t parameternamewave=root:ConMatNMRSimPro:system:parameternamewave
	wave/t s.parameternamewave=root:ConMatNMRSimPro:system:parameternamewave
	wave/t s.transname=root:ConMatNMRSimPro:system:transname
	wave/t s.inttransname=root:ConMatNMRSimPro:system:inttransname
	
	wave s.energymatrix=root:ConMatNMRSimPro:system:energymatrix
	wave s.eigenvectors=root:ConMatNMRSimPro:system:M_eigenvectors
	wave s.teigenvectors=root:ConMatNMRSimPro:system:teigenvectors
	wave/c s.msquared=root:ConMatNMRSimPro:system:msquared
	wave s.EvsI=root:ConMatNMRSimPro:system:EvsI
	wave s.EvsH=root:ConMatNMRSimPro:system:EvsH
	wave s.IvsH=root:ConMatNMRSimPro:system:IvsH
	
	wave s.spectrumsum=root:ConMatNMRSimPro:system:spectrumsum
	
	wave/t s.statsnamewave=root:ConMatNMRSimPro:system:statsnamewave
	wave s.nuclearspin=root:ConMatNMRSimPro:system:nuclearspin
	wave s.nucleargyro=root:ConMatNMRSimPro:system:nucleargyro
	wave/t  s.nucleusname=root:ConMatNMRSimPro:system:nucleusname

End