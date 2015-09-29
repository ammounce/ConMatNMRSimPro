#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

 //Functions which control the transition
 
 //Controls for the transition checkboxes which stores the state of the transition
Function TransitionCheckbox(ctrlname, checked):CheckBoxControl
	string ctrlname
	variable checked
	
	STRUCT spectrum spec; initspectrum(spec)
		
	storetransitions(spec)	
end

//Controls for transition intensity which stores the intensity of each transition
Function TransitionIntensitySetVar(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable
	
	STRUCT spectrum spec; initspectrum(spec)
	
	storetransitions(spec)	
End

//Initializes the transition intensity based on the spin, depending on integer or half integer values
Function InitTransitionIntensity(s)
	STRUCT spectrum &s
	
	setdatafolder root:ConMatNMRSimPro:system
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

//Stores the transition intensity and on/off state
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
		NVAR onvar=root:ConMatNMRSimPro:system:$onstring
		string intstring=transnamewave[i][1]
		NVAR intvar=root:ConMatNMRSimPro:system:$intstring
		
		s.nstats[i+36]=onvar
		s.nstats[i+50]=intvar
		i+=1
	while(i<endtrans)

	//storespectrumdata(s)	
end

//Initializes the transitino panel for half integer spin
Window TransitionsPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(0,0,200,310)
	SetDrawLayer UserBack
	
	TransitionsPanel_Master()
	
End

//Makes controls for on/off state and transition intensity
Function TransitionsPanel_Master()
	
	STRUCT Spectrum spec; initspectrum(spec)
	
	variable intstate, halfintstate
	
	if(mod(spec.II,1)==0)
		intstate=0
		halfintstate=1
	else
		intstate=1
		halfintstate=0
	endif
	
	TitleBox titleon,win=$(spec.transpanelname), pos={7,5+intstate*23}
	TitleBox titleintensity,win=$(spec.transpanelname), pos={118,5+intstate*23}
		
	CheckBox checkgt11_2,pos={10,55},size={79,14},proc=TransitionCheckbox,title="11/2 <-> 9/2"
	CheckBox checkgt11_2,variable= root:ConMatNMRSimPro:system:gt11_2on, disable=halfintstate
	CheckBox checkgt9_2,pos={10,75},size={73,14},proc=TransitionCheckbox,title="9/2 <-> 7/2"
	CheckBox checkgt9_2,variable= root:ConMatNMRSimPro:system:gt9_2on, disable=halfintstate
	CheckBox checkgt7_2,pos={10,95},size={73,14},proc=TransitionCheckbox,title="7/2 <-> 5/2"
	CheckBox checkgt7_2,variable= root:ConMatNMRSimPro:system:gt7_2on, disable=halfintstate
	CheckBox checkgt5_2,pos={10,115},size={73,14},proc=TransitionCheckbox,title="5/2 <-> 3/2"
	CheckBox checkgt5_2,variable= root:ConMatNMRSimPro:system:gt5_2on, disable=halfintstate
	CheckBox checkgt3_2,pos={10,135},size={73,14},proc=TransitionCheckbox,title="3/2 <-> 1/2"
	CheckBox checkgt3_2,variable= root:ConMatNMRSimPro:system:gt3_2on, disable=halfintstate
	CheckBox checkgt1_2,pos={10,155},size={77,14},proc=TransitionCheckbox,title="1/2 <-> -1/2"
	CheckBox checkgt1_2,variable= root:ConMatNMRSimPro:system:gt1_2on, disable=halfintstate
	CheckBox checkgtm1_2,pos={10,175},size={80,14},proc=TransitionCheckbox,title="-1/2 <-> -3/2"
	CheckBox checkgtm1_2,variable= root:ConMatNMRSimPro:system:gtm1_2on, disable=halfintstate
	CheckBox checkgtm3_2,pos={10,195},size={80,14},proc=TransitionCheckbox,title="-3/2 <-> -5/2"
	CheckBox checkgtm3_2,variable= root:ConMatNMRSimPro:system:gtm3_2on, disable=halfintstate
	CheckBox checkgtm5_2,pos={10,215},size={80,14},proc=TransitionCheckbox,title="-5/2 <-> -7/2"
	CheckBox checkgtm5_2,variable= root:ConMatNMRSimPro:system:gtm5_2on, disable=halfintstate
	CheckBox checkgtm7_2,pos={10,235},size={80,14},proc=TransitionCheckbox,title="-7/2 <-> -9/2"
	CheckBox checkgtm7_2,variable= root:ConMatNMRSimPro:system:gtm7_2on, disable=halfintstate
	CheckBox checkgtm9_2,pos={10,255},size={86,14},proc=TransitionCheckbox,title="-9/2 <-> -11/2"
	CheckBox checkgtm9_2,variable= root:ConMatNMRSimPro:system:gtm9_2on, disable=halfintstate
		
	SetVariable setvargI11_2,pos={120,55},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI11_2,value= root:ConMatNMRSimPro:system:gI11_2, disable=halfintstate
	SetVariable setvargI9_2,pos={120,75},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI9_2,value= root:ConMatNMRSimPro:system:gI9_2, disable=halfintstate
	SetVariable setvargI7_2,pos={120,95},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI7_2,value= root:ConMatNMRSimPro:system:gI7_2, disable=halfintstate
	SetVariable setvargI5_2,pos={120,115},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI5_2,value= root:ConMatNMRSimPro:system:gI5_2, disable=halfintstate
	SetVariable setvargI3_2,pos={120,135},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI3_2,value= root:ConMatNMRSimPro:system:gI3_2, disable=halfintstate
	SetVariable setvargI1_2,pos={120,155},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI1_2,value= root:ConMatNMRSimPro:system:gI1_2, disable=halfintstate
	SetVariable setvargIm1_2,pos={120,175},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm1_2,value= root:ConMatNMRSimPro:system:gIm1_2, disable=halfintstate
	SetVariable setvargIm3_2,pos={120,195},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm3_2,value= root:ConMatNMRSimPro:system:gIm3_2, disable=halfintstate
	SetVariable setvargIm5_2,pos={120,215},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm5_2,value= root:ConMatNMRSimPro:system:gIm5_2, disable=halfintstate
	SetVariable setvargIm7_2,pos={120,235},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm7_2,value= root:ConMatNMRSimPro:system:gIm7_2, disable=halfintstate
	SetVariable setvargIm9_2,pos={120,255},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm9_2,value= root:ConMatNMRSimPro:system:gIm9_2, disable=halfintstate
	
	CheckBox checkgt7,pos={10,25},size={79,14},proc=TransitionCheckbox,title="7 <-> 6"
	CheckBox checkgt7,variable= root:ConMatNMRSimPro:system:gt7on, disable=intstate
	CheckBox checkgt6,pos={10,45},size={73,14},proc=TransitionCheckbox,title="6 <-> 5"
	CheckBox checkgt6,variable= root:ConMatNMRSimPro:system:gt6on, disable=intstate
	CheckBox checkgt5,pos={10,65},size={73,14},proc=TransitionCheckbox,title="5 <-> 4"
	CheckBox checkgt5,variable= root:ConMatNMRSimPro:system:gt5on, disable=intstate
	CheckBox checkgt4,pos={10,85},size={73,14},proc=TransitionCheckbox,title="4 <-> 3"
	CheckBox checkgt4,variable= root:ConMatNMRSimPro:system:gt4on, disable=intstate
	CheckBox checkgt3,pos={10,105},size={73,14},proc=TransitionCheckbox,title="3 <-> 2"
	CheckBox checkgt3,variable= root:ConMatNMRSimPro:system:gt3on, disable=intstate
	CheckBox checkgt2,pos={10,125},size={77,14},proc=TransitionCheckbox,title="2 <-> 1"
	CheckBox checkgt2,variable= root:ConMatNMRSimPro:system:gt2on, disable=intstate
	CheckBox checkgt1,pos={10,145},size={80,14},proc=TransitionCheckbox,title="1 <-> 0"
	CheckBox checkgt1,variable= root:ConMatNMRSimPro:system:gt1on, disable=intstate
	CheckBox checkgt0,pos={10,165},size={80,14},proc=TransitionCheckbox,title="0 <-> -1"
	CheckBox checkgt0,variable= root:ConMatNMRSimPro:system:gt0on, disable=intstate
	CheckBox checkgtm1,pos={10,185},size={80,14},proc=TransitionCheckbox,title="-1 <-> -2"
	CheckBox checkgtm1,variable= root:ConMatNMRSimPro:system:gtm1on, disable=intstate
	CheckBox checkgtm2,pos={10,205},size={80,14},proc=TransitionCheckbox,title="-2 <-> -3"
	CheckBox checkgtm2,variable= root:ConMatNMRSimPro:system:gtm2on, disable=intstate
	CheckBox checkgtm3,pos={10,225},size={86,14},proc=TransitionCheckbox,title="-3 <-> -4"
	CheckBox checkgtm3,variable= root:ConMatNMRSimPro:system:gtm3on, disable=intstate
	CheckBox checkgtm4,pos={10,245},size={86,14},proc=TransitionCheckbox,title="-4 <-> -5"
	CheckBox checkgtm4,variable= root:ConMatNMRSimPro:system:gtm4on, disable=intstate
	CheckBox checkgtm5,pos={10,265},size={86,14},proc=TransitionCheckbox,title="-5 <-> -6"
	CheckBox checkgtm5,variable= root:ConMatNMRSimPro:system:gtm5on, disable=intstate
	CheckBox checkgtm6,pos={10,285},size={86,14},proc=TransitionCheckbox,title="-6 <-> -7"
	CheckBox checkgtm6,variable= root:ConMatNMRSimPro:system:gtm6on	, disable=intstate
	
	SetVariable setvargI7,pos={120,25},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI7,value= root:ConMatNMRSimPro:system:gI7, disable=intstate
	SetVariable setvargI6,pos={120,45},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI6,value= root:ConMatNMRSimPro:system:gI6, disable=intstate
	SetVariable setvargI5,pos={120,65},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI5,value= root:ConMatNMRSimPro:system:gI5, disable=intstate
	SetVariable setvargI4,pos={120,85},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI4,value= root:ConMatNMRSimPro:system:gI4, disable=intstate
	SetVariable setvargI3,pos={120,105},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI3,value= root:ConMatNMRSimPro:system:gI3, disable=intstate
	SetVariable setvargI2,pos={120,125},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI2,value= root:ConMatNMRSimPro:system:gI2, disable=intstate
	SetVariable setvargI1,pos={120,145},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI1,value= root:ConMatNMRSimPro:system:gI1, disable=intstate
	SetVariable setvargI0,pos={120,165},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargI0,value= root:ConMatNMRSimPro:system:gI0, disable=intstate
	SetVariable setvargIm1,pos={120,185},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm1,value= root:ConMatNMRSimPro:system:gIm1, disable=intstate
	SetVariable setvargIm2,pos={120,205},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm2,value= root:ConMatNMRSimPro:system:gIm2, disable=intstate
	SetVariable setvargIm3,pos={120,225},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm3,value= root:ConMatNMRSimPro:system:gIm3, disable=intstate
	SetVariable setvargIm4,pos={120,245},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm4,value= root:ConMatNMRSimPro:system:gIm4, disable=intstate
	SetVariable setvargIm5,pos={120,265},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm5,value= root:ConMatNMRSimPro:system:gIm5, disable=intstate
	SetVariable setvargIm6,pos={120,285},size={55,15},proc=TransitionIntensitySetVar,title=" "
	SetVariable setvargIm6,value= root:ConMatNMRSimPro:system:gIm6, disable=intstate
	
EndMacro

//Changes transition panel between integer and half integer 
Function ChangeTransPanel(s)
	STRUCT spectrum &s
	
	variable intstate, halfintstate
	
	if(mod(s.II,1)==0)
		intstate=0
		halfintstate=1
	else
		intstate=1
		halfintstate=0
	endif
	
	TitleBox titleon,win=$(s.transpanelname), pos={7,5+intstate*23}
	TitleBox titleintensity,win=$(s.transpanelname), pos={118,5+intstate*23}
	
	CheckBox checkgt7, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt6, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt5, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt4, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt3, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt2, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt1, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgt0, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm1, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm2, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm3, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm4, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm5, disable=intstate,win=$(s.transpanelname)
	CheckBox checkgtm6, disable=intstate,win=$(s.transpanelname)

	SetVariable setvargI7, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI6, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI5, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI4, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI3, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI2, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI1, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargI0, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm1, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm2, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm3, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm4, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm5, disable=intstate,win=$(s.transpanelname)
	SetVariable setvargIm6, disable=intstate,win=$(s.transpanelname)

	
	CheckBox checkgt11_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgt9_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgt7_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgt5_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgt3_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgt1_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgtm1_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgtm3_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgtm5_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgtm7_2, disable=halfintstate,win=$(s.transpanelname)
	CheckBox checkgtm9_2, disable=halfintstate,win=$(s.transpanelname)

	SetVariable setvargI11_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargI9_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargI7_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargI5_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargI3_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargI1_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargIm1_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargIm3_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargIm5_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargIm7_2, disable=halfintstate,win=$(s.transpanelname)
	SetVariable setvargIm9_2, disable=halfintstate,win=$(s.transpanelname)

end
