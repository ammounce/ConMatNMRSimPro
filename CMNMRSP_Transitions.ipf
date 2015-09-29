#pragma rtGlobals=3		// Use modern global access method and strict wave access.
 
 
 
Function TransitionCheckbox(ctrlname, checked):CheckBoxControl
	string ctrlname
	variable checked
	
	STRUCT spectrum spec; initspectrum(spec)
		
	storetransitions(spec)	
end

Function TransitionIntensitySetVar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; initspectrum(spec)
	
	storetransitions(spec)	
End


Function InitTransitionIntensity(s)
	STRUCT spectrum &s
	
	setdatafolder root:SpectrumSimulation:system
	variable i, ii, transend
			
	if(mod(s.II, 1)!=0)
		wave/t transnamewave=s.transname
		Transend=	11
		II = 11/2
	else
		wave/t transnamewave=s.inttransname
		transend=14
		II = 7
	endif

	do
		string onstring=transnamewave[i][0]
		NVAR onvar=$onstring
		string intstring=transnamewave[i][1]
		NVAR intvar=$intstring
		
		if(II>s.II || II < -s.II+1)
			s.nstats[36+i]=0
			onvar=0
			s.nstats[50+i]=nan
			intvar=nan
			onvar=0
			intvar=NAN
		else
			s.nstats[36+i]=1
			onvar=1
			s.nstats[50+i]=(s.II+II)*(s.II-II+1)
			intvar=(s.II+II)*(s.II-II+1)			
		endif

		i+=1
		II-=1
	while(i<14)
	
	storespectrumdata(s)	
End


Function Storetransitions(s)
	STRUCT spectrum &s
	
	variable i, ii, minspin, endtrans
	
	if(mod(s.II, 1)!=0)
		wave/t transnamewave=s.transname
		endtrans=11
	else
		wave/t transnamewave=s.inttransname
		endtrans=14

	endif



	do
		string onstring=transnamewave[i][0]
		NVAR onvar=root:spectrumsimulation:system:$onstring
		string intstring=transnamewave[i][1]
		NVAR intvar=root:spectrumsimulation:system:$intstring
		
		s.nstats[i+36]=onvar
		s.nstats[i+50]=intvar
		i+=1
	while(i<endtrans)

	//storespectrumdata(s)	
end

Window TransitionsPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(0,0,200,310)
	
	SetDrawLayer UserBack
	TitleBox titleOn, frame=0, fsize=14, pos={7,28}, title="On?"
		
	CheckBox checkgt11_2,pos={10,55},size={79,14},proc=TransitionCheckbox,title="11/2 <-> 9/2"
	CheckBox checkgt11_2,variable= root:SpectrumSimulation:system:gt11_2on
	CheckBox checkgt9_2,pos={10,75},size={73,14},proc=TransitionCheckbox,title="9/2 <-> 7/2"
	CheckBox checkgt9_2,variable= root:SpectrumSimulation:system:gt9_2on
	CheckBox checkgt7_2,pos={10,95},size={73,14},proc=TransitionCheckbox,title="7/2 <-> 5/2"
	CheckBox checkgt7_2,variable= root:SpectrumSimulation:system:gt7_2on
	CheckBox checkgt5_2,pos={10,115},size={73,14},proc=TransitionCheckbox,title="5/2 <-> 3/2"
	CheckBox checkgt5_2,variable= root:SpectrumSimulation:system:gt5_2on
	CheckBox checkgt3_2,pos={10,135},size={73,14},proc=TransitionCheckbox,title="3/2 <-> 1/2"
	CheckBox checkgt3_2,variable= root:SpectrumSimulation:system:gt3_2on
	CheckBox checkgt1_2,pos={10,155},size={77,14},proc=TransitionCheckbox,title="1/2 <-> -1/2"
	CheckBox checkgt1_2,variable= root:SpectrumSimulation:system:gt1_2on
	CheckBox checkgtm1_2,pos={10,175},size={80,14},proc=TransitionCheckbox,title="-1/2 <-> -3/2"
	CheckBox checkgtm1_2,variable= root:SpectrumSimulation:system:gtm1_2on
	CheckBox checkgtm3_2,pos={10,195},size={80,14},proc=TransitionCheckbox,title="-3/2 <-> -5/2"
	CheckBox checkgtm3_2,variable= root:SpectrumSimulation:system:gtm3_2on
	CheckBox checkgtm5_2,pos={10,215},size={80,14},proc=TransitionCheckbox,title="-5/2 <-> -7/2"
	CheckBox checkgtm5_2,variable= root:SpectrumSimulation:system:gtm5_2on
	CheckBox checkgtm7_2,pos={10,235},size={80,14},proc=TransitionCheckbox,title="-7/2 <-> -9/2"
	CheckBox checkgtm7_2,variable= root:SpectrumSimulation:system:gtm7_2on
	CheckBox checkgtm9_2,pos={10,255},size={86,14},proc=TransitionCheckbox,title="-9/2 <-> -11/2"
	CheckBox checkgtm9_2,variable= root:SpectrumSimulation:system:gtm9_2on
	
	TitleBox titleIntensity, frame=0, fsize=14, pos={118,28}, title="Intensity"
	

	SetVariable setvargI11_2,pos={120,55},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI11_2,value= root:SpectrumSimulation:system:gI11_2
	SetVariable setvargI9_2,pos={120,75},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI9_2,value= root:SpectrumSimulation:system:gI9_2
	SetVariable setvargI7_2,pos={120,95},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI7_2,value= root:SpectrumSimulation:system:gI7_2
	SetVariable setvargI5_2,pos={120,115},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI5_2,value= root:SpectrumSimulation:system:gI5_2
	SetVariable setvargI3_2,pos={120,135},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI3_2,value= root:SpectrumSimulation:system:gI3_2
	SetVariable setvargI1_2,pos={120,155},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI1_2,value= root:SpectrumSimulation:system:gI1_2
	SetVariable setvargIm1_2,pos={120,175},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm1_2,value= root:SpectrumSimulation:system:gIm1_2
	SetVariable setvargIm3_2,pos={120,195},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm3_2,value= root:SpectrumSimulation:system:gIm3_2
	SetVariable setvargIm5_2,pos={120,215},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm5_2,value= root:SpectrumSimulation:system:gIm5_2
	SetVariable setvargIm7_2,pos={120,235},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm7_2,value= root:SpectrumSimulation:system:gIm7_2
	SetVariable setvargIm9_2,pos={120,255},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm9_2,value= root:SpectrumSimulation:system:gIm9_2
EndMacro

Window IntTransitionsPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(0,0,200,310)
	
	SetDrawLayer UserBack
	TitleBox titleOn, frame=0, title="On?"
		
	CheckBox checkgt7,pos={10,25},size={79,14},proc=TransitionCheckbox,title="7 <-> 6"
	CheckBox checkgt7,variable= root:SpectrumSimulation:system:gt7on
	CheckBox checkgt6,pos={10,45},size={73,14},proc=TransitionCheckbox,title="6 <-> 5"
	CheckBox checkgt6,variable= root:SpectrumSimulation:system:gt6on
	CheckBox checkgt5,pos={10,65},size={73,14},proc=TransitionCheckbox,title="5 <-> 4"
	CheckBox checkgt5,variable= root:SpectrumSimulation:system:gt5on
	CheckBox checkgt4,pos={10,85},size={73,14},proc=TransitionCheckbox,title="4 <-> 3"
	CheckBox checkgt4,variable= root:SpectrumSimulation:system:gt4on
	CheckBox checkgt3,pos={10,105},size={73,14},proc=TransitionCheckbox,title="3 <-> 2"
	CheckBox checkgt3,variable= root:SpectrumSimulation:system:gt3on
	CheckBox checkgt2,pos={10,125},size={77,14},proc=TransitionCheckbox,title="2 <-> 1"
	CheckBox checkgt2,variable= root:SpectrumSimulation:system:gt2on
	CheckBox checkgt1,pos={10,145},size={80,14},proc=TransitionCheckbox,title="1 <-> 0"
	CheckBox checkgt1,variable= root:SpectrumSimulation:system:gt1on
	CheckBox checkgt0,pos={10,165},size={80,14},proc=TransitionCheckbox,title="0 <-> -1"
	CheckBox checkgt0,variable= root:SpectrumSimulation:system:gt0on
	CheckBox checkgtm1,pos={10,185},size={80,14},proc=TransitionCheckbox,title="-1 <-> -2"
	CheckBox checkgtm1,variable= root:SpectrumSimulation:system:gtm1on
	CheckBox checkgtm2,pos={10,205},size={80,14},proc=TransitionCheckbox,title="-2 <-> -3"
	CheckBox checkgtm2,variable= root:SpectrumSimulation:system:gtm2on
	CheckBox checkgtm3,pos={10,225},size={86,14},proc=TransitionCheckbox,title="-3 <-> -4"
	CheckBox checkgtm3,variable= root:SpectrumSimulation:system:gtm3on
	CheckBox checkgtm4,pos={10,245},size={86,14},proc=TransitionCheckbox,title="-4 <-> -5"
	CheckBox checkgtm4,variable= root:SpectrumSimulation:system:gtm4on
	CheckBox checkgtm5,pos={10,265},size={86,14},proc=TransitionCheckbox,title="-5 <-> -6"
	CheckBox checkgtm5,variable= root:SpectrumSimulation:system:gtm5on
	CheckBox checkgtm6,pos={10,285},size={86,14},proc=TransitionCheckbox,title="-6 <-> -7"
	CheckBox checkgtm6,variable= root:SpectrumSimulation:system:gtm6on

	
	DrawText 118,20,"Intensity"
	
	
	SetVariable setvargI7,pos={120,25},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI7,value= root:SpectrumSimulation:system:gI7
	SetVariable setvargI6,pos={120,45},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI6,value= root:SpectrumSimulation:system:gI6
	SetVariable setvargI5,pos={120,65},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI5,value= root:SpectrumSimulation:system:gI5
	SetVariable setvargI4,pos={120,85},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI4,value= root:SpectrumSimulation:system:gI4
	SetVariable setvargI3,pos={120,105},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI3,value= root:SpectrumSimulation:system:gI3
	SetVariable setvargI2,pos={120,125},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI2,value= root:SpectrumSimulation:system:gI2
	SetVariable setvargI1,pos={120,145},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI1,value= root:SpectrumSimulation:system:gI1
	SetVariable setvargI0,pos={120,165},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI0,value= root:SpectrumSimulation:system:gI0
	SetVariable setvargIm1,pos={120,185},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm1,value= root:SpectrumSimulation:system:gIm1
	SetVariable setvargIm2,pos={120,205},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm2,value= root:SpectrumSimulation:system:gIm2
	SetVariable setvargIm3,pos={120,225},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm3,value= root:SpectrumSimulation:system:gIm3
	SetVariable setvargIm4,pos={120,245},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm4,value= root:SpectrumSimulation:system:gIm4
	SetVariable setvargIm5,pos={120,265},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm5,value= root:SpectrumSimulation:system:gIm5
	SetVariable setvargIm6,pos={120,285},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm6,value= root:SpectrumSimulation:system:gIm6


Function TransitionsPanelMaster()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(0,0,250,250)
	
	SetDrawLayer UserBack

	TitleBox titleOn, frame=0, title="On?"
		
	CheckBox checkgt11_2,pos={10,25},size={79,14},proc=TransitionCheckbox,title="11/2 <-> 9/2"
	CheckBox checkgt11_2,variable= root:SpectrumSimulation:system:gt11_2on
	CheckBox checkgt9_2,pos={10,45},size={73,14},proc=TransitionCheckbox,title="9/2 <-> 7/2"
	CheckBox checkgt9_2,variable= root:SpectrumSimulation:system:gt9_2on
	CheckBox checkgt7_2,pos={10,65},size={73,14},proc=TransitionCheckbox,title="7/2 <-> 5/2"
	CheckBox checkgt7_2,variable= root:SpectrumSimulation:system:gt7_2on
	CheckBox checkgt5_2,pos={10,85},size={73,14},proc=TransitionCheckbox,title="5/2 <-> 3/2"
	CheckBox checkgt5_2,variable= root:SpectrumSimulation:system:gt5_2on
	CheckBox checkgt3_2,pos={10,105},size={73,14},proc=TransitionCheckbox,title="3/2 <-> 1/2"
	CheckBox checkgt3_2,variable= root:SpectrumSimulation:system:gt3_2on
	CheckBox checkgt1_2,pos={10,125},size={77,14},proc=TransitionCheckbox,title="1/2 <-> -1/2"
	CheckBox checkgt1_2,variable= root:SpectrumSimulation:system:gt1_2on
	CheckBox checkgtm1_2,pos={10,145},size={80,14},proc=TransitionCheckbox,title="-1/2 <-> -3/2"
	CheckBox checkgtm1_2,variable= root:SpectrumSimulation:system:gtm1_2on
	CheckBox checkgtm3_2,pos={10,165},size={80,14},proc=TransitionCheckbox,title="-3/2 <-> -5/2"
	CheckBox checkgtm3_2,variable= root:SpectrumSimulation:system:gtm3_2on
	CheckBox checkgtm5_2,pos={10,185},size={80,14},proc=TransitionCheckbox,title="-5/2 <-> -7/2"
	CheckBox checkgtm5_2,variable= root:SpectrumSimulation:system:gtm5_2on
	CheckBox checkgtm7_2,pos={10,205},size={80,14},proc=TransitionCheckbox,title="-7/2 <-> -9/2"
	CheckBox checkgtm7_2,variable= root:SpectrumSimulation:system:gtm7_2on
	CheckBox checkgtm9_2,pos={10,225},size={86,14},proc=TransitionCheckbox,title="-9/2 <-> -11/2"
	CheckBox checkgtm9_2,variable= root:SpectrumSimulation:system:gtm9_2on
	
	DrawText 138,20,"Intensity"
	
	
	SetVariable setvargI11_2,pos={120,25},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI11_2,value= root:SpectrumSimulation:system:gI11_2
	SetVariable setvargI9_2,pos={120,45},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI9_2,value= root:SpectrumSimulation:system:gI9_2
	SetVariable setvargI7_2,pos={120,65},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI7_2,value= root:SpectrumSimulation:system:gI7_2
	SetVariable setvargI5_2,pos={120,85},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI5_2,value= root:SpectrumSimulation:system:gI5_2
	SetVariable setvargI3_2,pos={120,105},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI3_2,value= root:SpectrumSimulation:system:gI3_2
	SetVariable setvargI1_2,pos={120,125},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargI1_2,value= root:SpectrumSimulation:system:gI1_2
	SetVariable setvargIm1_2,pos={120,145},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargIm1_2,value= root:SpectrumSimulation:system:gIm1_2
	SetVariable setvargIm3_2,pos={120,165},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargIm3_2,value= root:SpectrumSimulation:system:gIm3_2
	SetVariable setvargIm5_2,pos={120,185},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargIm5_2,value= root:SpectrumSimulation:system:gIm5_2
	SetVariable setvargIm7_2,pos={120,205},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargIm7_2,value= root:SpectrumSimulation:system:gIm7_2
	SetVariable setvargIm9_2,pos={120,225},size={95,15},proc=TransitionIntensitySetVar,title="Intensity"
	SetVariable setvargIm9_2,value= root:SpectrumSimulation:system:gIm9_2
	
end




Function ChangeTransPanel(s)
	STRUCT spectrum &s
	
	STRUCT spectrum spec; initspectrum(spec)
	
	if(mod(s.II,1)==0)
		Killcontrol/W=$(spec.transpanelname) checkgt11_2;Killcontrol/W=$(spec.transpanelname) checkgt9_2;Killcontrol/W=$(spec.transpanelname)  checkgt7_2
		Killcontrol/W=$(spec.transpanelname) checkgt5_2;Killcontrol/W=$(spec.transpanelname) checkgt3_2;Killcontrol/W=$(spec.transpanelname)  checkgt1_2
		Killcontrol/W=$(spec.transpanelname) checkgtm1_2;Killcontrol/W=$(spec.transpanelname) checkgtm3_2;Killcontrol/W=$(spec.transpanelname)  checkgtm5_2
		Killcontrol/W=$(spec.transpanelname) checkgtm7_2;Killcontrol/W=$(spec.transpanelname) checkgtm9_2;

		TitleBox titleon,win=$(spec.transpanelname), pos={7,5}

		CheckBox checkgt7, win=$(spec.transpanelname), pos={10,25},size={79,14},proc=TransitionCheckbox,title="7 <-> 6"
		CheckBox checkgt7, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt7on
		CheckBox checkgt6, win=$(spec.transpanelname), pos={10,45},size={73,14},proc=TransitionCheckbox,title="6 <-> 5"
		CheckBox checkgt6, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt6on
		CheckBox checkgt5, win=$(spec.transpanelname), pos={10,65},size={73,14},proc=TransitionCheckbox,title="5 <-> 4"
		CheckBox checkgt5, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt5on
		CheckBox checkgt4, win=$(spec.transpanelname), pos={10,85},size={73,14},proc=TransitionCheckbox,title="4 <-> 3"
		CheckBox checkgt4, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt4on
		CheckBox checkgt3, win=$(spec.transpanelname), pos={10,105},size={73,14},proc=TransitionCheckbox,title="3 <-> 2"
		CheckBox checkgt3, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt3on
		CheckBox checkgt2, win=$(spec.transpanelname), pos={10,125},size={77,14},proc=TransitionCheckbox,title="2 <-> 1"
		CheckBox checkgt2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt2on
		CheckBox checkgt1, win=$(spec.transpanelname), pos={10,145},size={80,14},proc=TransitionCheckbox,title="1 <-> 0"
		CheckBox checkgt1, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt1on
		CheckBox checkgt0, win=$(spec.transpanelname), pos={10,165},size={80,14},proc=TransitionCheckbox,title="0 <-> -1"
		CheckBox checkgt0, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt0on
		CheckBox checkgtm1, win=$(spec.transpanelname), pos={10,185},size={80,14},proc=TransitionCheckbox,title="-1 <-> -2"
		CheckBox checkgtm1, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm1on
		CheckBox checkgtm2, win=$(spec.transpanelname), pos={10,205},size={80,14},proc=TransitionCheckbox,title="-2 <-> -3"
		CheckBox checkgtm2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm2on
		CheckBox checkgtm3, win=$(spec.transpanelname), pos={10,225},size={86,14},proc=TransitionCheckbox,title="-3 <-> -4"
		CheckBox checkgtm3, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm3on
		CheckBox checkgtm4, win=$(spec.transpanelname), pos={10,245},size={86,14},proc=TransitionCheckbox,title="-4 <-> -5"
		CheckBox checkgtm4, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm4on
		CheckBox checkgtm5, win=$(spec.transpanelname), pos={10,265},size={86,14},proc=TransitionCheckbox,title="-5 <-> -6"
		CheckBox checkgtm5, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm5on
		CheckBox checkgtm6, win=$(spec.transpanelname), pos={10,285},size={86,14},proc=TransitionCheckbox,title="-6 <-> -7"
		CheckBox checkgtm6, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm6on


		Killcontrol/W=$(spec.transpanelname) setvargI11_2;Killcontrol/W=$(spec.transpanelname) setvargI9_2;Killcontrol/W=$(spec.transpanelname)  setvargI7_2
		Killcontrol/W=$(spec.transpanelname) setvargI5_2;Killcontrol/W=$(spec.transpanelname) setvargI3_2;Killcontrol/W=$(spec.transpanelname)  setvargI1_2
		Killcontrol/W=$(spec.transpanelname) setvargIm1_2;Killcontrol/W=$(spec.transpanelname) setvargIm3_2;Killcontrol/W=$(spec.transpanelname)  setvargIm5_2
		Killcontrol/W=$(spec.transpanelname) setvargIm7_2;Killcontrol/W=$(spec.transpanelname) setvargIm9_2;


		TitleBox titleintensity,win=$(spec.transpanelname), pos={118,5}

		SetVariable setvargI7, win=$(spec.transpanelname), pos={120,25},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI7, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI7
		SetVariable setvargI6, win=$(spec.transpanelname), pos={120,45},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI6, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI6
		SetVariable setvargI5, win=$(spec.transpanelname), pos={120,65},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI5, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI5
		SetVariable setvargI4, win=$(spec.transpanelname), pos={120,85},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI4, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI4
		SetVariable setvargI3, win=$(spec.transpanelname), pos={120,105},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI3, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI3
		SetVariable setvargI2, win=$(spec.transpanelname), pos={120,125},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI2
		SetVariable setvargI1, win=$(spec.transpanelname), pos={120,145},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI1, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI1
		SetVariable setvargI0, win=$(spec.transpanelname), pos={120,165},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI0, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI0
		SetVariable setvargIm1, win=$(spec.transpanelname), pos={120,185},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm1, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm1
		SetVariable setvargIm2, win=$(spec.transpanelname), pos={120,205},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm2
		SetVariable setvargIm3, win=$(spec.transpanelname), pos={120,225},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm3, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm3
		SetVariable setvargIm4, win=$(spec.transpanelname), pos={120,245},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm4, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm4
		SetVariable setvargIm5, win=$(spec.transpanelname), pos={120,265},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm5, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm5
		SetVariable setvargIm6, win=$(spec.transpanelname), pos={120,285},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm6, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm6

	else
		Killcontrol/W=$(spec.transpanelname) checkgt7;Killcontrol/W=$(spec.transpanelname) checkgt6;Killcontrol/W=$(spec.transpanelname)  checkgt5
		Killcontrol/W=$(spec.transpanelname) checkgt4;Killcontrol/W=$(spec.transpanelname) checkgt3;Killcontrol/W=$(spec.transpanelname)  checkgt2
		Killcontrol/W=$(spec.transpanelname) checkgt1;Killcontrol/W=$(spec.transpanelname) checkgtm1;Killcontrol/W=$(spec.transpanelname)  checkgtm2
		Killcontrol/W=$(spec.transpanelname) checkgtm3;Killcontrol/W=$(spec.transpanelname) checkgtm4;Killcontrol/W=$(spec.transpanelname) checkgtm5;
		Killcontrol/W=$(spec.transpanelname) checkgtm6;		Killcontrol/W=$(spec.transpanelname) checkgt0;

		TitleBox titleOn, frame=0, fsize=14, win=$(spec.transpanelname),pos={7,28}, title="On?"
		
		CheckBox checkgt11_2, win=$(spec.transpanelname), pos={10,55},size={79,14},proc=TransitionCheckbox,title="11/2 <-> 9/2"
		CheckBox checkgt11_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt11_2on
		CheckBox checkgt9_2, win=$(spec.transpanelname), pos={10,75},size={73,14},proc=TransitionCheckbox,title="9/2 <-> 7/2"
		CheckBox checkgt9_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt9_2on
		CheckBox checkgt7_2, win=$(spec.transpanelname), pos={10,95},size={73,14},proc=TransitionCheckbox,title="7/2 <-> 5/2"
		CheckBox checkgt7_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt7_2on
		CheckBox checkgt5_2, win=$(spec.transpanelname), pos={10,115},size={73,14},proc=TransitionCheckbox,title="5/2 <-> 3/2"
		CheckBox checkgt5_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt5_2on
		CheckBox checkgt3_2, win=$(spec.transpanelname), pos={10,135},size={73,14},proc=TransitionCheckbox,title="3/2 <-> 1/2"
		CheckBox checkgt3_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt3_2on
		CheckBox checkgt1_2, win=$(spec.transpanelname), pos={10,155},size={77,14},proc=TransitionCheckbox,title="1/2 <-> -1/2"
		CheckBox checkgt1_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gt1_2on
		CheckBox checkgtm1_2, win=$(spec.transpanelname), pos={10,175},size={80,14},proc=TransitionCheckbox,title="-1/2 <-> -3/2"
		CheckBox checkgtm1_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm1_2on
		CheckBox checkgtm3_2, win=$(spec.transpanelname), pos={10,195},size={80,14},proc=TransitionCheckbox,title="-3/2 <-> -5/2"
		CheckBox checkgtm3_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm3_2on
		CheckBox checkgtm5_2, win=$(spec.transpanelname), pos={10,215},size={80,14},proc=TransitionCheckbox,title="-5/2 <-> -7/2"
		CheckBox checkgtm5_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm5_2on
		CheckBox checkgtm7_2, win=$(spec.transpanelname), pos={10,235},size={80,14},proc=TransitionCheckbox,title="-7/2 <-> -9/2"
		CheckBox checkgtm7_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm7_2on
		CheckBox checkgtm9_2, win=$(spec.transpanelname), pos={10,255},size={86,14},proc=TransitionCheckbox,title="-9/2 <-> -11/2"
		CheckBox checkgtm9_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gtm9_2on

		Killcontrol/W=$(spec.transpanelname) setvargI7;Killcontrol/W=$(spec.transpanelname) setvargI6;Killcontrol/W=$(spec.transpanelname)  setvargI5
		Killcontrol/W=$(spec.transpanelname) setvargI4;Killcontrol/W=$(spec.transpanelname) setvargI3;Killcontrol/W=$(spec.transpanelname)  setvargI2
		Killcontrol/W=$(spec.transpanelname) setvargI1;Killcontrol/W=$(spec.transpanelname) setvargIm1;Killcontrol/W=$(spec.transpanelname)  setvargIm2
		Killcontrol/W=$(spec.transpanelname) setvargIm3;Killcontrol/W=$(spec.transpanelname) setvargIm4;Killcontrol/W=$(spec.transpanelname) setvargIm5;
		Killcontrol/W=$(spec.transpanelname) setvargIm6;		Killcontrol/W=$(spec.transpanelname) setvargI0;


		TitleBox titleIntensity, frame=0, fsize=14, win=$(spec.transpanelname),pos={118,28}, title="Intensity"

		SetVariable setvargI11_2, win=$(spec.transpanelname), pos={120,55},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI11_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI11_2
		SetVariable setvargI9_2, win=$(spec.transpanelname), pos={120,75},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI9_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI9_2
		SetVariable setvargI7_2, win=$(spec.transpanelname), pos={120,95},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI7_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI7_2
		SetVariable setvargI5_2, win=$(spec.transpanelname), pos={120,115},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI5_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI5_2
		SetVariable setvargI3_2, win=$(spec.transpanelname), pos={120,135},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI3_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI3_2
		SetVariable setvargI1_2, win=$(spec.transpanelname), pos={120,155},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargI1_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gI1_2
		SetVariable setvargIm1_2, win=$(spec.transpanelname), pos={120,175},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm1_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm1_2
		SetVariable setvargIm3_2, win=$(spec.transpanelname), pos={120,195},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm3_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm3_2
		SetVariable setvargIm5_2, win=$(spec.transpanelname), pos={120,215},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm5_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm5_2
		SetVariable setvargIm7_2, win=$(spec.transpanelname), pos={120,235},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm7_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm7_2
		SetVariable setvargIm9_2, win=$(spec.transpanelname), pos={120,255},size={55,15},proc=TransitionIntensitySetVar,title=" "
		SetVariable setvargIm9_2, win=$(spec.transpanelname),variable= root:SpectrumSimulation:system:gIm9_2



	endif
	
	
end
