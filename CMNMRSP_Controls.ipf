#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

//Autoscales main spectrum display
Function Autoscale(ctrlname):ButtonControl
	string ctrlname
	
	STRUCT spectrum spec; initspectrum(spec)
	
	SetAxis/A/W=$(spec.specwindow) 
End

//Turns display of single spectrum on or off
//Turns spectrum sum mode on or off
Function SpectrumOnandDisplay(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not
	
	STRUCT spectrum spec; InitSpectrum(spec)
	
	variable initialspectrumnumber, i=0
	
	initialspectrumnumber=spec.spectrumnumber
		
	SetactiveSubwindow $(spec.specwindow)

	if(samestring(ctrlname, "checkgspectrumdisplay")==1 && spec.spectrumsumdisplay==0)
		Removefromgraph/Z $("SpectrumSum")
		checkdisplayed/W=$(spec.specwindow) spec.nspec
		if(checked==1 && v_flag==0)
			appendtograph spec.nspec
			ModifyGraph lsize($spec.specname)=2
			if(spec.spectrumnumber==2)
				ModifyGraph rgb($spec.specname)=(1,12815,52428)
			elseif(spec.spectrumnumber==3)
				ModifyGraph rgb($spec.specname)=(2,39321,1)
			elseif(spec.spectrumnumber==4)
				ModifyGraph rgb($spec.specname)=(0,0,0)
			elseif(spec.spectrumnumber==5)
				ModifyGraph rgb($spec.specname)=(39321,39321,39321)
			endif
			
		elseif(checked==0 && v_flag==1)
			removefromgraph/Z $spec.specname
		endif
	elseif(samestring(ctrlname, "checkgspectrumdisplay")==1 && spec.spectrumsumdisplay==1)
		storespectrumdata(spec)
		CalculateSpectrumSum(spec)
	elseif(samestring(ctrlname, "checkgspectrumsumdisplay")==1)
		checkdisplayed/W=$(spec.specwindow) spec.spectrumsum

		if(checked==1 && v_flag==0)
			appendtograph spec.spectrumsum
			Modifygraph lsize($("SpectrumSum"))=2
			CalculateSpectrumSum(spec)
			do
				i+=1
				removefromgraph/Z $("Spectrum"+num2istr(i))
			while(i<spec.spectrumcount)
			i=0
		elseif(checked==0 && v_flag==1)
			removefromgraph $("SpectrumSum")
			spec.spectrumnumber=0
			do
				spec.spectrumnumber+=1
				initspectrum(spec)
				loadspectrumdata(spec)
				if(spec.spectrumdisplay==1)
					appendtograph spec.nspec
					ModifyGraph lsize($("Spectrum"+num2istr(spec.spectrumnumber)))=2
						if(spec.spectrumnumber==2)
							ModifyGraph rgb($("Spectrum"+num2istr(spec.spectrumnumber)))=(1,12815,52428)
						elseif(spec.spectrumnumber==3)
							ModifyGraph rgb($("Spectrum"+num2istr(spec.spectrumnumber)))=(2,39321,1)
						elseif(spec.spectrumnumber==4)
							ModifyGraph rgb($("Spectrum"+num2istr(spec.spectrumnumber)))=(0,0,0)
						elseif(spec.spectrumnumber==5)
							ModifyGraph rgb($("Spectrum"+num2istr(spec.spectrumnumber)))=(39321,39321,39321)
						endif
				endif
			while(spec.spectrumnumber<spec.spectrumcount)
			spec.spectrumnumber=initialspectrumnumber
			initspectrum(spec)
			loadspectrumdata(spec)
		endif
	
	endif
	storespectrumdata(spec)

	
ENd	

//Calculates spectrum sum depending on which spectra are turned on, normalizes sum to intensity
//and applies baselining
Function CalculateSpectrumSum(s)
	STRUCT spectrum &s		
	variable initialspectrumnumber=s.spectrumnumber
	
	make/o/n=(100*10^s.spectrumpoints+1) root:spectrumsimulation:system:$("SpectrumSum")=0
	
	variable maxx=0, minx=1000000000, i=0
	
	s.spectrumnumber=0
	
	do
		s.spectrumnumber+=1
		initspectrum(s)
		loadspectrumdata(s)
		if(s.spectrumdisplay==1)
			maxx=max(lastxpoint(s.nspec), maxx)
			minx=min(pnt2x(s.nspec, 0),minx)
		endif
	while(s.spectrumnumber<s.spectrumcount)
	
	Setscale/I x minx, maxx, s.SpectrumSum
	
	s.spectrumnumber=0
	do
		s.spectrumnumber+=1
		initspectrum(s)
		loadspectrumdata(s)
		wavestats/q s.nspec
		if(s.spectrumdisplay==1)
			s.SpectrumSum[x2pnt(s.spectrumsum, firstxpoint(s.nspec))+1,x2pnt(s.spectrumsum, lastxpoint(s.nspec))-1]+=s.nspec(x)-v_min
		endif
	while(s.spectrumnumber<s.spectrumcount) 
	
	s.SpectrumSUm+=s.baseline
	
	s.spectrumnumber=initialspectrumnumber
	initspectrum(s)
	loadspectrumdata(s)	
End

//Controls check boxes for experiment types NQR, Frequency sweep, or fieldsweep
//appropriately changes other boxes appropriately
Function NQRFieldorFrequencySweep(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not

	STRUCT spectrum spec; InitSpectrum(spec)

	if(strsearch(ctrlname, "checkgfrequencysweep",0)==0)
		if(checked==0)
			spec.fieldsweep=1
			spec.NQR=0
		elseif(checked==1 && spec.H0==0)
			spec.fieldsweep=0
			spec.NQR=1
		elseif(checked==1 && spec.H0!=0)
			spec.fieldsweep=0
			spec.NQR=0
		endif
	elseif(strsearch(ctrlname, "checkgfieldsweep",0)==0)
		if(checked==0 && spec.H0!=0)
			spec.frequencysweep=1
			spec.NQR=0
		elseif(checked==0 && spec.H0==0)
			spec.frequencysweep=1
			spec.NQR=1
		elseif(checked==1)
			spec.frequencysweep=0
			spec.NQR=0
		endif
	elseif(samestring(ctrlname, "checkgNQR")==1)
		if(checked==0)
			spec.fieldsweep=1
			spec.frequencysweep=0
		elseif(checked==1)
			spec.frequencysweep=1
			spec.fieldsweep=0
			spec.H0=0
		endif
	endif

	storespectrumdata(spec)
	changestatforallspectra(spec)
End

//Controls Single crystal or powder checkboxes, both being mutually exclusive
Function SingleCrystalorPowder(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selected, 0 if not

STRUCT spectrum spec; InitSpectrum(spec)
	
	if(strsearch(ctrlname, "checkgsinglecrystal",0)==0)
		if(checked==0)
			spec.powder=1
		elseif(checked==1)
			spec.powder=0
		endif
	elseif(strsearch(ctrlname, "checkgpowder",0)==0)
		if(checked==0)
			spec.singlecrystal=1
		elseif(checked==1)
			spec.singlecrystal=0
		endif
	endif
	storespectrumdata(spec)	
	changestatforallspectra(spec)
End

//If field or frequency is changed, sets appropriate expeirment type indicator
Function SetFieldorFrequency(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
STRUCT spectrum spec; InitSpectrum(spec)
	
	if(strsearch(ctrlname, "setvargfield",0)==0 && spec.H0==0)
		spec.frequencysweep=1
		spec.fieldsweep=0
		spec.NQR=1
	elseif(samestring(ctrlname, "setvarspec.field")==1 && spec.H0!=0)
		spec.frequencysweep=1
		spec.fieldsweep=0
		spec.NQR=0
	elseif(strsearch(ctrlname, "setvarspec.frequency",0)==0)
		spec.fieldsweep=1
		spec.frequencysweep=0
		spec.NQR=0
	endif

	storespectrumdata(spec)	
	changestatforallspectra(spec)
	
End

//General set variable control for spectrum parameters
//Changes experiment indicator depending on freq. or field change
//Changes baseline of all spectra and spectrum sum
//Changes intensity of current spectrum and spectrum su
Function SetVariableStats(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; initspectrum(spec)
		
	variable initialspecnumb=spec.spectrumnumber	
		
	storespectrumdata(spec)
		
	if(strsearch(ctrlname, "setvargfrequency",0)==0)
		spec.H0=0
		spec.fieldsweep=0
		spec.frequencysweep=1
	elseif(strsearch(ctrlname, "setvarspec.field",0)==0)
		spec.w0=0
		spec.fieldsweep=1
		spec.frequencysweep=0
	elseif(samestring(varname, "gbaseline")==1)
		changestatforallspectra(spec)	
		spec.spectrumnumber=0
		do
			spec.spectrumnumber+=1
			initspectrum(spec)
			loadspectrumdata(spec)
			wavestats/q spec.nspec
			spec.nspec-=v_min
			wavestats/q spec.nspec		
			spec.nspec/=v_max/(spec.intensity-spec.baseline)
			print v_max, v_min, spec.oldbaseline, v_max/(spec.intensity-spec.baseline)
			spec.nspec+=spec.baseline
		while(spec.spectrumnumber<spec.spectrumcount)
	
		spec.spectrumnumber=initialspecnumb
		initspectrum(spec)
		loadspectrumdata(spec)
		spec.oldbaseline=spec.baseline
		CalculateSpectrumSum(spec)
	elseif(samestring(varname, "gintensity")==1)
		wavestats/q spec.nspec
		spec.nspec-=v_min
		wavestats/q spec.nspec
		spec.nspec/=v_max/(spec.intensity-spec.baseline)
		spec.nspec+=spec.baseline
		CalculateSpectrumSum(spec)
	endif
	
	
End

//Sets the nucleus when atomic number is entered
//Popup window if atomic number is degenerate
//If arrows are used, atomatically chooses the next valid atomic number
Function SetVariableNucleus(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; initspectrum(spec)
				
	variable promptvar
	
	if(spec.nucleargyro[spec.atomicmass][0]==0)	
		do
			if(spec.previousmass-spec.atomicmass<0)
				spec.atomicmass+=1
			elseif(spec.previousmass-spec.atomicmass>0)
				spec.atomicmass-=1
			endif
			
		while(spec.nucleargyro[spec.atomicmass][0]==0)
	endif

	if(spec.atomicmass==3)
		Prompt promptvar, "Nucleus" , popup, "3H;3He"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
	
	elseif(spec.atomicmass==87)
	
		Prompt promptvar, "Nucleus" , popup, "87Rb;87Sr"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
			
	elseif(spec.atomicmass==99)
	
		Prompt promptvar, "Nucleus" , popup, "99Tc;99Ru"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]			
	
	elseif(spec.atomicmass==113)
	
		Prompt promptvar, "Nucleus" , popup, "113Cd;113In"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
	
	elseif(spec.atomicmass==123)
	
		Prompt promptvar, "Nucleus" , popup, "123Sb;123Te"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
	
	elseif(spec.atomicmass==153)
	
		Prompt promptvar, "Nucleus" , popup, "153Eu;153Tb"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
	
	elseif(spec.atomicmass==187)
	
		Prompt promptvar, "Nucleus" , popup, "187Rb;187Os"
		DoPrompt "Select Nucleus", promptvar
		if(v_flag)
			return 0
		endif
		spec.gyro = spec.nucleargyro[spec.atomicmass][promptvar-1]
		spec.II = spec.nuclearspin[spec.atomicmass][promptvar-1]
		spec.nucleus=spec.nucleusname[spec.atomicmass][promptvar-1]		
	else
		spec.gyro = spec.nucleargyro[spec.atomicmass][0]
		spec.II = spec.nuclearspin[spec.atomicmass][0]
		spec.nucleus=spec.nucleusname[spec.atomicmass][0]
	endif

	spec.previousmass=spec.atomicmass
	Inittransitionintensity(spec)
	storespectrumdata(spec)
	
 	 ChangeTransPanel(spec)
	
End

//Changes spectrum to control
//If spectrum number is greater than total number of spectra, gives option to make new spectrum
//New spectrum has the same stats as the previous one
Function SetVariableSpectrumNumber(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; InitSpectrum(spec)
	
	variable addspectrumprompt
		
	if(spec.spectrumnumber>spec.spectrumcount)
		Prompt  addspectrumprompt, "Create additional spectrum?", popup, "Yes; No"
		DoPrompt "Add Spectrum", addspectrumprompt
		if(v_flag==1 || addspectrumprompt==2)
			spec.spectrumnumber-=1
			return 0
		elseif(addspectrumprompt==1)			
			duplicate/o root:spectrumsimulation:$("Spectrum"+num2istr(spec.spectrumnumber-1)), root:spectrumsimulation:$("Spectrum"+num2istr(spec.spectrumnumber))
			duplicate/o root:spectrumsimulation:$("StatsSpectrum"+num2istr(spec.spectrumnumber-1)), root:spectrumsimulation:$("StatsSpectrum"+num2istr(spec.spectrumnumber))

			spec.spectrumon=1
			spec.spectrumdisplay=0
			
			spec.spectrumcount+=1
			Initspectrum(spec)
			StoreSpectrumData(spec)
		endif
	endif
	LoadSpectrumData(spec)
	Changetranspanel(spec)	
End

//If a K value is set, changes the K values in the other basis
Function SetVariableKvalues(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; Initspectrum(spec)
		
	if(strsearch(ctrlname, "setvargKiso",0)==0 || strsearch(ctrlname, "setvargKaniso",0)==0 || strsearch(ctrlname, "setvargepsilon",0)==0)
		spec.Kz=spec.Kiso+spec.Kaniso
		spec.Ky=spec.Kiso-spec.Kaniso*(1-spec.epsilon)/2
		spec.Kx=spec.Kiso-spec.Kaniso*(1+spec.epsilon)/2
	elseif(strsearch(ctrlname, "setvargKx",0)==0 ||strsearch(ctrlname, "setvargKy",0)==0 ||strsearch(ctrlname, "setvargKz",0)==0)
		spec.Kiso=(spec.Kx+spec.Ky+spec.Kz)/3
		spec.Kaniso= (spec.Kiso+spec.Kz-(spec.Kx+spec.Ky))/2
		if(spec.Kaniso==0)
			spec.epsilon=0
		else
			spec.epsilon=(spec.Ky-spec.Kx)/spec.Kaniso
		endif
	endif
	
	StoreSpectrumData(spec)
End	
	
//Deletes the current spectrum and all associated waves
//Currently can only delete the last spectrum? Need to move the spectrum number down if the spectrum
//is in the middle of the spread
Function DeleteCurrentSpectrum(ctrlname):ButtonControl
	string ctrlname
	
	STRUCT spectrum spec; initspectrum(spec)

	variable deleteprompt
	Prompt deleteprompt, "Are you sure you want to delete Spectrum " +num2istr(spec.spectrumnumber), popup, "Yes;No"
	DoPrompt "Spectrum Delete", deleteprompt
	
	if(v_flag==1 || deleteprompt==2)
		return 0
	elseif(v_flag==0 || deleteprompt==1)
	
		checkdisplayed/W=$(spec.specwindow) spec.nspec
		if(v_flag==1)
			removefromgraph/W=$(spec.specwindow) $("Spectrum"+num2istr(spec.spectrumnumber))
		endif		
		
		Killwaves/Z root:spectrumsimulation:$("Spectrum"+num2istr(spec.spectrumnumber)),spectrumref,root:spectrumsimulation:$("StatsSpectrum"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Energyvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Energyvstheta"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Energyvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Energyvsthetaphi"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Eigenvaluesvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Eigenvaluesvstheta"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Eigenvaluesvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Eigenvaluesvsthetaphi"+num2istr(spec.spectrumnumber))

		spec.spectrumcount-=1
		spec.spectrumnumber-=1
	endif
	
	if(spec.spectrumcount==0)
		Execute "SpectrumSimulation()"
	endif
	
	initspectrum(spec)
	loadspectrumdata(spec)	
	
End

//Saves single spectrum and stats
Function SaveCurrentSpectrum(ctrlname):ButtonControl
	string ctrlname
	
	setdatafolder root:SpectrumSimulation
	
	variable/g gspectrumnumber
	
	String savewaveas
	Prompt savewaveas, "Save Wave as:"
	DoPrompt "Save Wave", savewaveas
	
	if(v_flag==1)
		return 0
	elseif(v_flag==0)
		wave newwaveref=root:$(savewaveas)
		if(exists("root:"+savewaveas)==1)
			variable deletepreviouswave
			Prompt deletepreviouswave, "Delete Previous " + savewaveas, popup, "Yes;No"
			DoPrompt "Delete Wave?", deletepreviouswave
			if(v_flag==1 || deletepreviouswave==2)
				return 0
			endif
		endif
		duplicate/o $("Spectrum"+num2istr(gspectrumnumber)), root:$(savewaveas)				
		duplicate/o $("StatsSpectrum"+num2istr(gspectrumnumber)), root:$("Stats"+savewaveas)
	endif
	
End

//Changes specific stats for all spectra
Function changestatforallspectra(s)
	STRUCT spectrum &s

	variable i=0

	do
		i+=1
		wave statwave=root:spectrumsimulation:$("StatsSpectrum" + num2istr(i))
		statwave[6]=s.frequencysweep
		statwave[7]=s.fieldsweep
		statwave[9]=s.w0
		statwave[10]=s.H0
		statwave[11]=s.singlecrystal
		statwave[12]=s.powder
		statwave[33]=s.baseline
	while(i<s.spectrumcount)

end

//Loads waves and data preaviously saved
Function LoadWaveandData(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	setdatafolder root:SpectrumSimulation
	
	variable/g gspectrumnumber
	
	wave loadwaveref=root:$popstr
	wave loadstatswaveref=root:$("Stats"+popstr)
	wave spectrumref=$("Spectrum"+num2istr(gspectrumnumber))
	wave statwaveref=$("StatsSpectrum"+num2istr(gspectrumnumber))

	duplicate/o loadwaveref, spectrumref
	duplicate/o loadstatswaveref, statwaveref

	//RetreiveSpectrumData()
End

Function ResnaonceorEvsparamterpanel(ctrlname):ButtonControl
	string ctrlname
	
	setdatafolder root:SpectrumSimulation
	
	
	string parameter
	variable/g gspectrumnumber, gfieldsweep
	variable i=0
	
	if(samestring(ctrlname, "buttonResonancevsParameter")==1)
		DoWindow ResonancevsParameterPanel
			if(v_flag==1)
				Dowindow/f ResonancevsParameterPanel
			elseif(v_flag==0)
				Execute "ResonancevsParameterPanel()"
			endif
			
	endif
End

Function UpdateEigenandResWaves(s)
	STRUCT spectrum &s
	
	string parameter, value, panel
	variable i=0, j=0, k=0

	wave/t parameterref=root:SpectrumSimulation:Systemwaves:parameternamewave
//	do	
	//	do
			if(j==0 && k==0)
				DoWindow ResonancevsParameterPanel
				if(v_flag==0)
					Execute "ResonancevsParameterPanel()"
				endif
				value="Energyvs"
				panel="ResonancevsParameterPanel#G"
			elseif(j==0 && k==1)
				DoWindow EigenvaluesvsParameterPanel
				if(v_flag==0)
					Execute "EigenvaluesvsParameterPanel()"
				endif
				value="Eigenvaluesvs"
				panel="EigenvaluesvsParameterPanel#G"
			endif
			parameter=s.parameternamewave[j]
			
			if(k==0)
				duplicate/o root:spectrumsimulation:energywaves:$(Value+parameter+num2istr(s.spectrumnumber)), root:SpectrumSimulation:System:$(Value+parameter)
			elseif(k==1)
				duplicate/o root:spectrumsimulation:eigenwaves:$(Value+parameter+num2istr(s.spectrumnumber)), root:SpectrumSimulation:System:$(Value+parameter)
			endif
			
			wave Valuevsparamref=root:SpectrumSimulation:system:$( Value+parameter)

			string windowstring=panel+num2istr(j)

			SetActiveSubWindow $windowstring
						
			do
				removefromgraph/Z $(Value+parameter)
				checkdisplayed/W=$windowstring root:SpectrumSimulation:Systemwaves:$(Value+parameter)
				i+=1
			while(v_flag==1)
			
		end
		
			i=0
			do
				appendtograph Valuevsparamref[][i]
				i+=1
			while(i<dimsize(Valuevsparamref,1))
			i=0
			if(j==0)
				Label bottom "q (pi/2)"
			elseif(j==1)
				Label bottom "theta (degrees)"
			elseif(j==2)
				Label bottom "phi (degrees)"
			elseif(j==3)
				Label bottom "theta=phi (degrees)"
			endif
			
			if(k==0)
				if(s.fieldsweep==1)
					Label left "Field (T)";DelayUpdate
				elseif(s.fieldsweep==0)		
					Label left "Frequency (MHz)"; DelayUpdate
				endif
			elseif(k==1)
				Label left "Eigen Value (MHz)"; DelayUpdate
			endif
			j+=1	
	//	while(j<4)
		j=0
		k+=1
	//while(k<2)
	
End




Function SaveDataPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	STRUCT Spectrum spec; initspectrum(spec)

	String savewaveas, savewavesas
	variable initialspectrumnumber, minx, maxx
	
	if(samestring(popstr, "Single Wave and Data")==1)
		
		Prompt savewaveas, "Save Wave as:"
		DoPrompt "Save Wave", savewaveas
	
		if(v_flag==1)
			return 0
		elseif(v_flag==0)
			wave newwaveref=root:spectrumsimulation:savedsimulations:$("Sim"+savewaveas)
			if(exists("root:"+savewaveas)==1)
				variable deletepreviouswave
				Prompt deletepreviouswave, "Delete Previous " + savewaveas, popup, "Yes;No"
				DoPrompt "Delete Wave?", deletepreviouswave
				if(v_flag==1 || deletepreviouswave==2)
					return 0
				endif
			endif
			duplicate/o spec.nspec root:spectrumsimulation:savedsimulations:$("Sim"+savewaveas)				
			duplicate/o spec.nstats, root:spectrumsimulation:savedsimulations:$("Stats"+savewaveas)
		endif		
	elseif(samestring(popstr, "All Waves and Data")==1)
		initialspectrumnumber=spec.spectrumnumber
		spec.spectrumnumber=1
		
		Prompt savewavesas, "Save Waves as:"
		DoPrompt "Save Waves", savewavesas
		if(v_flag==1)
			return 0
		elseif(v_flag==0)		
			wave specsumref=root:spectrumsimulation:savedsimulations:$("AllSpec"+savewavesas)
			wave allstatsref=root:spectrumsimulation:savedsimulations:$("AllStats"+savewavesas)
			if(exists("root:spectrumsimulation:savedsimulations:AllSpec"+savewavesas)==1  || exists("root:spectrumsimulation:savedsimulations:AllStats"+savewavesas)==1)
				variable deletepreviouswaves
				Prompt deletepreviouswaves, "Delete Previous " + savewavesas, popup, "Yes;No"
				DoPrompt "Delete Wave?", deletepreviouswaves
				if(v_flag==1 || deletepreviouswaves==2)
					return 0
				endif
			endif

			duplicate/o spec.nstats, root:spectrumsimulation:savedsimulations:$("AllStats"+savewavesas)
			duplicate/o spec.nspec, root:spectrumsimulation:savedsimulations:$("AllSpec"+savewavesas)
			wave newstatswaveref=root:spectrumsimulation:savedsimulations:$("AllStats"+savewavesas)
			wave newspectrawaveref=root:spectrumsimulation:savedsimulations:$("AllSpec"+savewavesas)
			wave oldspectrumref=root:SpectrumSimulation:$("Spectrum"+num2istr(spec.spectrumnumber))

			insertpoints/M=1 1, spec.spectrumcount-1,  newstatswaveref, newspectrawaveref

			do
				spec.spectrumnumber+=1;initspectrum(spec)
					
				newstatswaveref[][spec.spectrumnumber-1]=spec.nstats[p][0]
				newspectrawaveref[][spec.spectrumnumber-1]=spec.nspec[p][0]
			while(spec.spectrumnumber<spec.spectrumcount)
			
			duplicate/o spec.spectrumsum, root:spectrumsimulation:savedsimulations:$("SpecSum"+savewavesas)			
							
			spec.spectrumnumber=initialspectrumnumber;initspectrum(spec)
		
		endif
	endif

End

Function LoadDataPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	STRUCT spectrum spec; initspectrum(spec)

	variable i=0

	if(samestring(ctrlname, "popupLoadsingleSpectrumandData")==1)
		wave savedwaveref=root:spectrumsimulation:savedsimulations:$("Sim"+popstr)
		duplicate/o savedwaveref, root:spectrumsimulation:$("Spectrum"+num2istr(spec.spectrumnumber))
		wave savedstatsref=root::spectrumsimulation:savedsimulations:$("Stats"+popstr)
		duplicate/o savedstatsref, root:spectrumsimulation:$("StatsSpectrum"+num2istr(spec.spectrumnumber))
		LoadSpectrumData(spec)
	elseif(samestring(ctrlname, "popupLoadgroupSpectrumandDat")==1)
		wave allspecref=root:spectrumsimulation:savedsimulations:$("AllSpec"+popstr)
		wave allstatsref=root:spectrumsimulation:savedsimulations:$("AllStats"+popstr)
		wave SpecSumref=root:spectrumsimulation:savedsimulations:$("SpecSum"+popstr)
		print popstr
		if(spec.spectrumcount>dimsize(allspecref,1))
			do
				removefromgraph/Z/W=$(spec.specwindow) $("Spectrum"+num2istr(spec.spectrumcount))
				killwaves/Z root:spectrumsimulation:$("Spectrum"+num2str(spec.spectrumcount)), root:spectrumsimulation:$("StatsSpectrum"+num2str(spec.spectrumcount))
				Killwaves/Z root:spectrumsimulation:energywaves:$("Energyvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:energywaves:$("Energyvstheta"+num2istr(spec.spectrumnumber))
				Killwaves/Z root:spectrumsimulation:energywaves:$("Energyvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:energywaves:$("Energyvsthetaphi"+num2istr(spec.spectrumnumber))
				Killwaves/Z root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:eigenwaves:$("Eigenvaluesvstheta"+num2istr(spec.spectrumnumber))
				Killwaves/Z root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:eigenwaves:$("Eigenvaluesvsthetaphi"+num2istr(spec.spectrumnumber))
				spec.spectrumcount-=1
			while(spec.spectrumcount<dimsize(allspecref,1))
		endif
	
		do
			i+=1
			duplicate/r=[][i-1]/o allstatsref, root:spectrumsimulation:$("StatsSpectrum"+num2istr(i))
			duplicate/r=[][i-1]/o allspecref, root:spectrumsimulation:$("Spectrum"+num2istr(i));
			spec.spectrumnumber=i; initspectrum(spec)
			loadspectrumdata(spec)
			setscale/i x spec.spectrumstart, spec.spectrumend,  root:spectrumsimulation:$("Spectrum"+num2istr(i))
		while(i<spec.spectrumcount)
		
		duplicate/o specsumref, root:spectrumsimulation:system:SpectrumSum
		
		spec.spectrumcount=dimsize(allspecref, 1)
		spec.spectrumnumber=1; initspectrum(spec)
		loadspectrumdata(spec)
	
	endif
end

		checkdisplayed/W=$(spec.specwindow) spec.nspec
		if(v_flag==1)
			removefromgraph/W=$(spec.specwindow) $("Spectrum"+num2istr(spec.spectrumnumber))
		endif		
		
		Killwaves/Z root:spectrumsimulation:$("Spectrum"+num2istr(spec.spectrumnumber)),spectrumref,root:spectrumsimulation:$("StatsSpectrum"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Energyvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Energyvstheta"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Energyvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Energyvsthetaphi"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Eigenvaluesvsq"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Eigenvaluesvstheta"+num2istr(spec.spectrumnumber))
		Killwaves/Z root:spectrumsimulation:$("Eigenvaluesvsphi"+num2istr(spec.spectrumnumber)), root:spectrumsimulation:$("Eigenvaluesvsthetaphi"+num2istr(spec.spectrumnumber))



//Replacestring("buttoniso", ctrlname, "")
	if(samestring(ctrlname, "popupLoadgroupSpectrumandDat")==1)
		if(strsearch(popstr, "AllSpec",0)==-1)
			return 0
		endif
		gspectrumnumber=0
		do
			gspectrumnumber+=1
			setactivesubwindow SpectrumSimulationPanel#G0
			removefromgraph/Z $("Spectrum"+num2istr(gspectrumnumber))
			if(gspectrumnumber!=1)
				killwaves $("Spectrum"+num2istr(gspectrumnumber)), $("StatsSpectrum"+num2istr(gspectrumnumber))
			endif		
		while(gspectrumnumber<gspectrumcount)
		gspectrumnumber=0
		gspectrumcount=1
		
		string savedwavename=removeending(popstr, "AllSpec")
		wave savedspecswaveref= root:$popstr
		wave savedstatswaveref=root:$("Stats"+savedwavename)
		wave savedspecsumwaveref=root:$("SpecSum"+savedwavename)
		
		gspectrumcount=dimsize(savedstatswaveref,1)
		do		
			gspectrumnumber+=1
			make/o/n=(33) $("StatsSpectrum"+num2istr(	gspectrumnumber))
			wave statsref=$("StatsSpectrum"+num2istr(	gspectrumnumber))
			statsref=savedstatswaveref[p][gspectrumnumber-1]
		
			make/o/n=(dimsize(savedspecswaveref,0)) $("Spectrum"+num2istr(gspectrumnumber))
			wave specref= $("Spectrum"+num2istr(gspectrumnumber))
			specref=savedspecswaveref[p][gspectrumnumber-1]
			setscale/i x statsref[31], statsref[32], specref
			
			SpectrumonandDisplay( "checkgspectrumdisplay", statsref[1])
		while(gspectrumnumber<gspectrumcount)
		
		duplicate/o savedspecsumwaveref, SpectrumSum
		
		gspectrumnumber=1
		
		//SetvariableSpectrumNumber("",1,"","")
		
	endif
	
End



Function DisplayEorEigenPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	STRUCT spectrum spec; initspectrum(spec)
	
	UpdateEigenandResWaves(spec);DelayUpdate
	
End
		if(samestring(popstr, "Resonance vs Parameters")==1)
			DoWindow ResonancevsParameterPanel
			if(v_flag==0)
				Execute "ResonancevsParameterPanel()"
			else
				DoWindow/f ResonancevsParameterPanel
			endif
		elseif(samestring(popstr, "Eigen values vs Parameters")==1)
			DoWindow EigenvaluesvsParameterPanel
			if(v_flag==1)
				Dowindow/f EigenvaluesvsParameterPanel
			elseif(v_flag==0)
				Execute "EigenvaluesvsParameterPanel()"
			endif
		endif
		
End

//Checks if transitions panel is open
//If open, brings to front
//If not open, opens
Function TransitionPanelbutton(ctrlname):Buttoncontrol
	string ctrlname
	
	STRUCT spectrum spec;initspectrum(spec)
	
	Dowindow TransitionsPanel
	if(v_flag==0)
		Execute "TransitionsPanel()"
	elseif(v_flag==1)
		Dowindow/f TransitionsPanel
		changetranspanel(spec)
	endif
	
end
