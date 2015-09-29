#pragma rtGlobals=3		// Use modern global access method and strict wave access.

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
	
	wave/c Iz, Ix, Iy, I2, Ix2, Iy2, Iz2 ,Iplus, Iminus, Iplus2, Iminus2, product, HQ, HZ, HAF, Htotal
	
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
	
	wave nuclearspin, nucleargyro
	wave/t nucleusname
	
Endstructure

Function InitSpectrum(s)
	STRUCT Spectrum &s

	SVAR s.nucleus=root:spectrumsimulation:system:gnucleus
	//General Variables	
	NVAR s.atomicmass=root:spectrumsimulation:system:gatomicmass
	NVAR s.altatomicmass=root:spectrumsimulation:system:galtatomicmass
	NVAR s.previousmass=root:spectrumsimulation:system:gpreviousmass
	NVAR s.II=root:spectrumsimulation:system:gII
	NVAR s.gyro=root:spectrumsimulation:system:ggyro
	NVAR s.w0=root:spectrumsimulation:system:gw0
	NVAR s.H0=root:spectrumsimulation:system:gH0
	NVAR  s.fieldsweep=root:spectrumsimulation:system:gfieldsweep
	NVAR s.frequencysweep=root:spectrumsimulation:system:gfrequencysweep
	NVAR  s.intensity=root:spectrumsimulation:system:gintensity
	NVAR s.spectrumnumber=root:spectrumsimulation:system:gspectrumnumber
	NVAR  s.spectrumon=root:spectrumsimulation:system:gspectrumon 
	NVAR  s.spectrumdisplay=root:spectrumsimulation:system:gspectrumdisplay
	NVAR  s.qandangdep=root:spectrumsimulation:system:gqandangdep
	NVAR  s.NQR=root:spectrumsimulation:system:gNQR
	NVAR s.powder=root:spectrumsimulation:system:gpowder
	NVAR  s.singlecrystal=root:spectrumsimulation:system:gsinglecrystal
	NVAR s.spectrumpoints=root:spectrumsimulation:system:gspectrumpoints
	NVAR s.angularsteps=root:spectrumsimulation:system:gangularsteps
	NVAR s.totalfieldsteps=root:spectrumsimulation:system:gfieldsteps
	 NVAR s.baseline=root:spectrumsimulation:system:gbaseline
	 NVAR s.spectrumsumdisplay=root:spectrumsimulation:system:gspectrumsumdisplay
	 NVAR s.spectrumstart=root:spectrumsimulation:system:gspectrumstart
	 NVAR  s.spectrumend=root:spectrumsimulation:system:gspectrumend
	NVAR  s.spectrumcount=root:spectrumsimulation:system:gspectrumcount
	NVAR s.oldbaseline=root:spectrumsimulation:system:goldbaseline	
	
	NVAR s.thetastep=root:spectrumsimulation:system:gthetastep
	NVAR s.phistep=root:spectrumsimulation:system:gphistep
	NVAR s.qstep=root:spectrumsimulation:system:gqstep
	NVAR s.fieldstep=root:spectrumsimulation:system:gfieldstep
	
	//Magnetic variables	
	NVAR  s.Kiso=root:spectrumsimulation:system:gKiso
	NVAR s.Kaniso=root:spectrumsimulation:system:gKaniso
	NVAR s.epsilon=root:spectrumsimulation:system:gepsilon
	NVAR s.dvM=root:spectrumsimulation:system:gdVM
	NVAR s.thetaM=root:spectrumsimulation:system:gthetaM
	NVAR s.phiM=root:spectrumsimulation:system:gphiM
	NVAR s.useKxyz=root:spectrumsimulation:system:guseKxyz
	NVAR s.Kx=root:spectrumsimulation:system:gKx
	NVAR s.Ky=root:spectrumsimulation:system:gKy
	NVAR s.Kz=root:spectrumsimulation:system:gKz

	//Quadrupolar variables
	NVAR s.vQ=root:spectrumsimulation:system:gvQ
	NVAR  s.eta=root:spectrumsimulation:system:geta
	NVAR s.dvQ=root:spectrumsimulation:system:gdvQ
		
	//AF variables	
	NVAR s.vMAF=root:spectrumsimulation:system:gvMAF
	NVAR s.q=root:spectrumsimulation:system:gq
	NVAR  s.thetaAF=root:spectrumsimulation:system:gthetaAF
	NVAR s.phiAF=root:spectrumsimulation:system:gphiAF
	NVAR s.totalqsteps=root:spectrumsimulation:system:gtotalqsteps

	//Transitions
	NVAR s.t11_2on=root:spectrumsimulation:system:g11_2on
	NVAR s.t9_2on=root:spectrumsimulation:system:g9_2on
	NVAR  s.t7_2on=root:spectrumsimulation:system:g7_2on
	NVAR s.t5_2on=root:spectrumsimulation:system:g5_2on
	NVAR  s.t3_2on=root:spectrumsimulation:system:g3_2on
	NVAR  s.t1_2on=root:spectrumsimulation:system:g1_2on
	NVAR  s.tm1_2on=root:spectrumsimulation:system:gm1_2on
	NVAR  s.tm3_2on=root:spectrumsimulation:system:gm3_2on
	NVAR s.tm5_2on=root:spectrumsimulation:system:gm5_2on
	NVAR s.tm7_2on=root:spectrumsimulation:system:gm7_2on
	NVAR s.tm9_2on=root:spectrumsimulation:system:gm9_2on
	NVAR s.I11_2=root:spectrumsimulation:system:gI11_2
	NVAR s.I9_2=root:spectrumsimulation:system:gI9_2
	NVAR s.I7_2=root:spectrumsimulation:system:gI7_2
	NVAR s.I5_2=root:spectrumsimulation:system:gI5_2 
	NVAR s.I3_2=root:spectrumsimulation:system:gI3_2
	NVAR s.I1_2=root:spectrumsimulation:system:gI1_2
	NVAR  s.Im1_2=root:spectrumsimulation:system:gIm1_2
	NVAR s.Im3_2=root:spectrumsimulation:system:gIm3_2
	NVAR s.Im5_2=root:spectrumsimulation:system:gIm5_2
	NVAR s.Im7_2=root:spectrumsimulation:system:gIm7_2
	NVAR s.Im9_2=root:spectrumsimulation:system:gIm9_2
	
	s.specwindow="SpectrumSimulationPanel#G0"
	s.specname="Spectrum"+num2istr(s.spectrumnumber)
	s.transpanelname="transitionspanel"
	
	wave/c s.Iz=root:spectrumsimulation:system:Iz
	wave/c s.Iz2=root:spectrumsimulation:system:Iz2
	wave/c s.Ix=root:spectrumsimulation:system:Ix
	wave/c s.Iy=root:spectrumsimulation:system:Iy
	wave/c s.I2=root:spectrumsimulation:system:I2
	wave/c s.Iplus=root:spectrumsimulation:system:Iplus
	wave/c s.Iminus=root:spectrumsimulation:system:Iminus
	wave/c s.Iplus2=root:spectrumsimulation:system:Iplus2
	wave/c s.Iminus2=root:spectrumsimulation:system:Iminus2
	wave/c s.HQ=root:spectrumsimulation:system:HQ
	wave/c s.HZ=root:spectrumsimulation:system:HZ
	wave/c s.HAF=root:spectrumsimulation:system:HAF
	wave/c s.Htotal=root:spectrumsimulation:system:Htotal
	wave/c s.product=root:spectrumsimulation:system:m_product
	
	wave s.nspec=root:spectrumsimulation:$("Spectrum"+num2istr(s.spectrumnumber))
	wave s.nstats=root:spectrumsimulation:$("StatsSpectrum"+num2istr(s.spectrumnumber))
	
	wave s.energylevels=root:spectrumsimulation:system:energylevels
	wave s.intensities=root:spectrumsimulation:system:intensities
	wave s.w_eigenvalues=root:spectrumsimulation:system:w_eigenvalues
	wave s.transon=root:spectrumsimulation:system:transon
	wave s.transintensity=root:spectrumsimulation:system:transintensity
	wave s.thetawave=root:spectrumsimulation:system:thetawave
	wave s.phiwave=root:spectrumsimulation:system:phiwave
	wave s.fieldsteps=root:spectrumsimulation:system:fieldsteps
	wave s.FSenergylevels=root:spectrumsimulation:system:FSenergylevels
	wave s.w0wave=root:spectrumsimulation:system:w0wave
	wave s.interpwave=root:spectrumsimulation:system:interpwave
	
	wave s.nEvsq=root:spectrumsimulation:energywaves:$("Energyvsq"+num2istr(s.spectrumnumber))
	wave s.nEvstheta=root:spectrumsimulation:energywaves:$("Energyvstheta"+num2istr(s.spectrumnumber))
	wave s.nEvsphi=root:spectrumsimulation:energywaves:$("Energyvsphi"+num2istr(s.spectrumnumber))
	wave s.nEvsthetaphi=root:spectrumsimulation:energywaves:$("Energyvsthetaphi"+num2istr(s.spectrumnumber))
	wave s.nEVvsq=root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsq"+num2istr(s.spectrumnumber))
	wave s.nEVvstheta=root:SpectrumSimulation:Eigenwaves:$("Eigenvaluesvstheta"+num2istr(s.spectrumnumber))
	wave s.nEVvsphi=root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsphi"+num2istr(s.spectrumnumber))
	wave s.nEVvsthetaphi=root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsthetaphi"+num2istr(s.spectrumnumber))

	wave s.Evsq=root:spectrumsimulation:system:$("Energyvsq")
	wave s.Evstheta=root:spectrumsimulation:system:$("Energyvstheta")
	wave s.Evsphi=root:spectrumsimulation:system:$("Energyvsphi")
	wave s.Evsthetaphi=root:spectrumsimulation:system:$("Energyvsthetaphi")
	wave s.EVvsq=root:spectrumsimulation:system:$("Eigenvaluesvsq")
	wave s.EVvstheta=root:spectrumsimulation:system:$("Eigenvaluesvstheta")
	wave s.EVvsphi=root:spectrumsimulation:system:$("Eigenvaluesvsphi")
	wave s.EVvsthetaphi=root:spectrumsimulation:system:$("Eigenvaluesvsthetaphi")

	wave s.nresvsHtheta=root:spectrumsimulation:WandHdep:$("ResvsHtheta"+num2str(s.spectrumnumber))
	wave s.nresvsHphi=root:spectrumsimulation:WandHdep:$("ResvsHphi"+num2str(s.spectrumnumber))
	wave s.nresvsHthetaphi=root:spectrumsimulation:WandHdep:$("ResvsHthetaphi"+num2str(s.spectrumnumber))

	wave/t parameternamewave=root:SpectrumSimulation:system:parameternamewave
	wave/t s.parameternamewave=root:spectrumsimulation:system:parameternamewave
	wave/t s.transname=root:spectrumsimulation:system:transname
	wave/t s.inttransname=root:spectrumsimulation:system:inttransname
	
	wave s.energymatrix=root:spectrumsimulation:system:energymatrix
	wave s.eigenvectors=root:spectrumsimulation:system:M_eigenvectors
	wave s.teigenvectors=root:spectrumsimulation:system:teigenvectors
	wave/c s.msquared=root:spectrumsimulation:system:msquared
	wave s.EvsI=root:spectrumsimulation:system:EvsI
	wave s.EvsH=root:spectrumsimulation:system:EvsH
	wave s.IvsH=root:spectrumsimulation:system:IvsH
	
	wave s.spectrumsum=root:spectrumsimulation:system:spectrumsum
	
	wave/t s.statsnamewave=root:spectrumsimulation:system:statsnamewave
	wave s.nuclearspin=root:spectrumsimulation:system:nuclearspin
	wave s.nucleargyro=root:spectrumsimulation:system:nucleargyro
	wave/t  s.nucleusname=root:spectrumsimulation:system:nucleusname

End