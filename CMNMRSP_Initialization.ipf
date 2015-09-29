#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37


//Checks if ConMatNMRSimPro window has been made. 
//If made brings to front, if not made, makes window

Function CheckMainPanel()
	DoWindow ConMatNMRSimPro
	if(v_flag==1)
		DoWindow/F ConMatNMRSimPro
	elseif(v_flag==0)
		Execute "ConMatNMRSimPro()"
	endif
End

//Initializes folders, variables, waves, and spectrum1 if it has not already been made

Function InitializeConMatNMRSimPro()
	newdatafolder/o root:SpectrumSimulation
	newdatafolder/o root:SpectrumSimulation:System
	newdatafolder/o root:Spectrumsimulation:Energywaves
	newdatafolder/o root:Spectrumsimulation:Eigenwaves
	newdatafolder/o root:spectrumsimulation:WandHdep
	newdatafolder/o root:spectrumsimulation:SavedSimulations
	
	setdatafolder root:SpectrumSimulation:system
			
	//General parameters
	variable/g gatomicmass, galtatomicmass, gII, ggyro, gw0, gH0, gfieldsweep, gfrequencysweep, gintensity=1, gspectrumnumber=1, gspectrumon , gspectrumdisplay, gqandangdep, gNQR
	variable/g gpowder, gsinglecrystal, gthetastep, gphistep, gspectrumpoints=1, gangularsteps=25, gfieldsteps=25, gfieldstep, gbaseline, gspectrumsumdisplay, gspectrumstart, gspectrumend
	variable/g gspectrumcount, goldbaseline, gpreviousmass
	variable/g gfieldstep, gphistep, gthetastep, gqstep
	string/g gnucleus
	//Zeeman parameters
	variable/g  gKiso, gKaniso, gepsilon, gdVM, gthetaM, gphiM, guseKxyz, gKx, gKy, gKz
	//Quadrupolar parameters
	variable/g gvQ, geta, gdvQ
	//AF parameters
	variable/g gvMAF, gq, gthetaAF, gphiAF, gqstep, gtotalqsteps=100, gvMAF2, gq2, gphase2
	//Transitions
	variable/g gt11_2on, gt9_2on, gt7_2on, gt5_2on, gt3_2on, gt1_2on, gtm1_2on, gtm3_2on, gtm5_2on, gtm7_2on, gtm9_2on
	variable/g gI11_2, gI9_2, gI7_2, gI5_2, gI3_2, gI1_2, gIm1_2, gIm3_2, gIm5_2, gIm7_2, gIm9_2

	variable/g gt0on, gt1on, gt2on, gt3on, gt4on, gt5on, gt6on, gt7on, gtm6on, gtm5on, gtm4on, gtm3on, gtm2on, gtm1on
	variable/g gI0 , gI1 , gI2 , gI3 , gI4 , gI5 , gI6 , gI7 , gIm6 , gIm5 , gIm4 , gIm3 , gIm2 , gIm1 

	make/o/n=(4)/t parameternamewave={"q","theta","phi","thetaphi"}
	make/o/n=11 transon, transintensity
	make/o/c/n=(2,2) Ix, Iy, Iz, Ix2, Iy2, Iz2, I2, Iplus, Iminus, Iplus2, Iminus2, HQ, HZ, HAF, Htotal, M_product
	make/o/n=1 energylevels, w_eigenvalues, thetawave, phiwave, fieldsteps, fsenergylevels, w0wave, interpwave
	make/o/n=1 energyvsq, energyvstheta, energyvsphi, energyvsthetaphi
	make/o/n=1 eigenvaluesvsq, eigenvaluesvstheta, eigenvaluesvsphi, eigenvaluesvsthetaphi
	make/o/n=1 spectrumsum
	
	MakeNucleusNameWave()
	MakeNuclearSpinWave()
	MakeNuclearGyroWave()
	Makevariablewave()

	make/t/o/n=(14,2) root:spectrumsimulation:system:TransName
	wave/t transname	=root:spectrumsimulation:system:TransName
	transname[0][0]={"gt11_2on","gt9_2on","gt7_2on","gt5_2on","gt3_2on","gt1_2on","gtm1_2on","gtm3_2on","gtm5_2on","gtm7_2on","gtm9_2on"}
	transname[0][1]={"gI11_2","gI9_2","gI7_2","gI5_2","gI3_2","gI1_2","gIm1_2","gIm3_2","gIm5_2","gIm7_2","gIm9_2"}

	make/t/o/n=(14,2) root:spectrumsimulation:system:IntTransName
	wave/t inttransname=root:spectrumsimulation:system:IntTransName
	inttransname[0][0]={"gt7on", "gt6on", "gt5on", "gt4on", "gt3on", "gt2on", "gt1on", "gt0on", "gtm1on", "gtm2on", "gtm3on", "gtm4on", "gtm5on", "gtm6on"}
	inttransname[0][1]={"gi7", "gi6", "gi5", "gi4", "gi3", "gi2", "gi1", "gi0", "gim1", "gim2", "gim3", "gim4", "gim5", "gim6"}

	Makedefaultstats()
	
	STRUCT spectrum spec; initspectrum(spec)	

	print spec.spectrumcount
	
	if(spec.spectrumcount==0)
		make/o/n=(1000) root:spectrumsimulation:Spectrum1
		wave defaultstatswave; duplicate/o defaultstatswave, root:SpectrumSimulation:StatsSpectrum1		
		spec.spectrumcount=1
		Initspectrum(spec)
		LoadSpectrumData(spec)
		storespectrumdata(spec)
		setscale/i x spec.gyro*spec.H0*.9, spec.gyro*spec.H0*1.1, spec.nspec
		spec.nspec=exp(-(x-spec.gyro*spec.H0)^2/sqrt(2)/(spec.dvM/1000)^2)
		print (spec.gyro*spec.H0)
	endif

	setdatafolder root:
		
End

Function StoreSpectrumData(s)
	STRUCT spectrum &s
		
	variable i
	
	do
		string varstring=s.statsnamewave[i]
		NVAR var=root:spectrumsimulation:system:$varstring
	
		s.nstats[i]=var			
		i+=1
	while(i<36)
	
	if(mod(s.II, 1)!=0)
		wave/t transname=s.transname
	else
		wave/t transname=s.inttransname
	endif
	
	do
		string onstring=transname[i-36][0]
		NVAR onvar=root:spectrumsimulation:system:$onstring
		string intstring=transname[i-36][1]
		NVAR intvar=root:spectrumsimulation:system:$intstring
		
		if(numtype(onvar)!=2)
			s.nstats[i]=onvar
		else
			s.nstats[i]=0
		endif
		s.nstats[i+14]=intvar
		
		i+=1
	while(i<50)
		
End



Function LoadSpectrumData(s)
	STRUCT spectrum &s

	variable i=0
	do
		string varstring=s.statsnamewave[i]
		
		NVAR var=root:spectrumsimulation:system:$varstring
		var=s.nstats[i]		
		
		i+=1
	while(i<36)
		
	if(mod(s.II, 1)!=0)
		wave/t transname=s.transname
	else
		wave/t transname=s.inttransname
	endif
		
	do
		string onstring=transname[i-36][0]
		NVAR onvar=root:spectrumsimulation:system:$onstring
		string intstring=transname[i-36][1]
		NVAR intvar=root:spectrumsimulation:system:$intstring
		
		if(strlen(onstring)!=0)
			onvar=s.nstats[i]
		endif
		
		if(strlen(intstring)!=0)
			intvar=s.nstats[i+14]
		endif
		i+=1
	while(i<50)
		
	s.II = s.Nuclearspin[s.atomicmass][s.altatomicmass]
	s.gyro = s.Nucleargyro[s.atomicmass][s.altatomicmass]
	s.nucleus=s.NucleusName[s.atomicmass][s.altatomicmass]	
end


Function MakeNuclearSpinWave()

	make/o/n=(244,2) NuclearSpin
	
	NuclearSpin[1][0]=0.5;NuclearSpin[2][0]=1;NuclearSpin[3][0]=0.5;NuclearSpin[3][1]=0.5;NuclearSpin[6][0]=1;NuclearSpin[7][0]=1.5;NuclearSpin[9][0]=1.5;NuclearSpin[10][0]=3;NuclearSpin[11][0]=1.5;
NuclearSpin[13][0]=0.5;NuclearSpin[14][0]=1;NuclearSpin[15][0]=0.5;NuclearSpin[17][0]=2.5;NuclearSpin[19][0]=0.5;NuclearSpin[21][0]=1.5;NuclearSpin[23][0]=1.5;NuclearSpin[25][0]=2.5;
  NuclearSpin[27][0]=2.5;NuclearSpin[29][0]=0.5;NuclearSpin[31][0]=0.5;NuclearSpin[33][0]=1.5;NuclearSpin[35][0]=1.5;NuclearSpin[37][0]=1.5;NuclearSpin[39][0]=1.5;NuclearSpin[41][0]=1.5;
NuclearSpin[43][0]=3.5;NuclearSpin[45][0]=3.5;NuclearSpin[47][0]=2.5;NuclearSpin[49][0]=3.5;NuclearSpin[50][0]=6;NuclearSpin[51][0]=3.5;NuclearSpin[53][0]=1.5;NuclearSpin[55][0]=2.5;
  NuclearSpin[57][0]=0.5;NuclearSpin[59][0]=3.5;NuclearSpin[61][0]=1.5;NuclearSpin[63][0]=1.5;NuclearSpin[65][0]=1.5;NuclearSpin[67][0]=2.5;NuclearSpin[69][0]=1.5;NuclearSpin[71][0]=1.5;
NuclearSpin[73][0]=4.5;NuclearSpin[75][0]=1.5;NuclearSpin[77][0]=0.5;NuclearSpin[79][0]=1.5;NuclearSpin[81][0]=15;NuclearSpin[83][0]=4.5;NuclearSpin[85][0]=2.5;NuclearSpin[87][0]=1.5;
  NuclearSpin[87][1]=4.5;NuclearSpin[89][0]=4.5;NuclearSpin[91][0]=0.5;NuclearSpin[93][0]=2.5;NuclearSpin[95][0]=4.5;NuclearSpin[97][0]=2.5;NuclearSpin[99][0]=4.5;NuclearSpin[99][1]=2.5;
NuclearSpin[101][0]=2.5;NuclearSpin[103][0]=0.5;NuclearSpin[105][0]=2.5;NuclearSpin[107][0]=0.5;NuclearSpin[109][0]=0.5;NuclearSpin[111][0]=0.5;NuclearSpin[113][0]=0.5;NuclearSpin[113][1]=4.5;
  NuclearSpin[115][0]=4.5;NuclearSpin[117][0]=0.5;NuclearSpin[119][0]=0.5;NuclearSpin[121][0]=2.5;NuclearSpin[123][0]=3.5;NuclearSpin[123][1]=0.5;NuclearSpin[125][0]=0.5;NuclearSpin[127][0]=2.5;
NuclearSpin[129][0]=0.5;NuclearSpin[131][0]=1.5;NuclearSpin[133][0]=3.5;NuclearSpin[135][0]=1.5;NuclearSpin[137][0]=1.5;NuclearSpin[139][0]=3.5;NuclearSpin[141][0]=2.5;NuclearSpin[143][0]=3.5;
  NuclearSpin[145][0]=3.5;NuclearSpin[147][0]=3.5;NuclearSpin[149][0]=3.5;NuclearSpin[151][0]=2.5;NuclearSpin[153][0]=2.5;NuclearSpin[153][1]=1.5;NuclearSpin[155][0]=1.5;NuclearSpin[157][0]=1.5;
NuclearSpin[161][0]=2.5;NuclearSpin[163][0]=2.5;NuclearSpin[165][0]=3.5;NuclearSpin[167][0]=3.5;NuclearSpin[169][0]=0.5;NuclearSpin[171][0]=0.5;NuclearSpin[173][0]=2.5;NuclearSpin[175][0]=3.5;
  NuclearSpin[176][0]=7;NuclearSpin[177][0]=3.5;NuclearSpin[179][0]=4.5;NuclearSpin[181][0]=3.5;NuclearSpin[183][0]=0.5;NuclearSpin[185][0]=0.5;NuclearSpin[187][0]=2.5;NuclearSpin[187][1]=0.5;
NuclearSpin[189][0]=1.5;NuclearSpin[191][0]=1.5;NuclearSpin[193][0]=1.5;NuclearSpin[195][0]=0.5;NuclearSpin[197][0]=1.5;NuclearSpin[199][0]=0.5;NuclearSpin[201][0]=1.5;NuclearSpin[203][0]=0.5;
  NuclearSpin[205][0]=0.5;NuclearSpin[207][0]=0.5;NuclearSpin[209][0]=4.5;NuclearSpin[235][0]=3.5;NuclearSpin[239][0]=0.5;
End

Function MakeNuclearGyroWave()

	make/o/n=(242,2) NuclearGyro
	
	Nucleargyro[1][0]=42.577;Nucleargyro[2][0]=6.5359;Nucleargyro[3][0]=45.414;Nucleargyro[3][1]=32.434;Nucleargyro[6][0]=6.2655;Nucleargyro[7][0]=16.547;Nucleargyro[9][0]=5.9833;
Nucleargyro[10][0]=4.5744;Nucleargyro[11][0]=13.652;Nucleargyro[13][0]=10.705;Nucleargyro[14][0]=3.0752;Nucleargyro[15][0]=4.3143;Nucleargyro[17][0]=5.7719;Nucleargyro[19][0]=40.059;
  Nucleargyro[21][0]=3.3613;Nucleargyro[23][0]=11.262;Nucleargyro[25][0]=2.6055;Nucleargyro[27][0]=11.094;Nucleargyro[29][0]=8.4577;Nucleargyro[31][0]=17.236;Nucleargyro[33][0]=3.2655;
Nucleargyro[35][0]=4.1717;Nucleargyro[37][0]=3.4725;Nucleargyro[39][0]=1.9867;Nucleargyro[41][0]=1.0905;Nucleargyro[43][0]=2.8646;Nucleargyro[45][0]=10.343;Nucleargyro[47][0]=2.4009;
  Nucleargyro[49][0]=2.4003;Nucleargyro[50][0]=4.243;Nucleargyro[51][0]=11.193;Nucleargyro[53][0]=2.4066;Nucleargyro[55][0]=10.5;Nucleargyro[57][0]=1.3757;Nucleargyro[59][0]=10.03;
Nucleargyro[61][0]=3.8047;Nucleargyro[63][0]=11.285;Nucleargyro[65][0]=12.089;Nucleargyro[67][0]=2.6639;Nucleargyro[69][0]=10.219;Nucleargyro[71][0]=12.965;Nucleargyro[73][0]=1.4852;
  Nucleargyro[75][0]=7.2919;Nucleargyro[77][0]=8.13;Nucleargyro[79][0]=10.667;Nucleargyro[81][0]=11.499;Nucleargyro[83][0]=1.6384;Nucleargyro[85][0]=4.1099;Nucleargyro[87][0]=13.932;
Nucleargyro[87][1]=10.343;Nucleargyro[89][0]=2.0864;Nucleargyro[91][0]=3.9581;Nucleargyro[93][0]=10.405;Nucleargyro[95][0]=2.7747;Nucleargyro[97][0]=2.8329;Nucleargyro[99][0]=9.5831;
  Nucleargyro[99][1]=1.9607;Nucleargyro[101][0]=2.1976;Nucleargyro[103][0]=4.3454;Nucleargyro[105][0]=1.9484;Nucleargyro[107][0]=1.723;Nucleargyro[109][0]=1.9808;Nucleargyro[111][0]=9.028;
Nucleargyro[113][0]=9.446;Nucleargyro[113][1]=9.3092;Nucleargyro[115][0]=9.3295;Nucleargyro[117][0]=15.168;Nucleargyro[119][0]=15.867;Nucleargyro[121][0]=10.189;Nucleargyro[123][0]=5.5176;
  Nucleargyro[123][1]=11.16;Nucleargyro[125][0]=13.454;Nucleargyro[127][0]=8.557;Nucleargyro[129][0]=11.776;Nucleargyro[131][0]=3.4911;Nucleargyro[133][0]=5.5844;Nucleargyro[135][0]=4.2295;
Nucleargyro[137][0]=4.7316;Nucleargyro[139][0]=6.0146;Nucleargyro[141][0]=12.471;Nucleargyro[143][0]=2.33;Nucleargyro[145][0]=1.4244;Nucleargyro[147][0]=1.76;Nucleargyro[149][0]=1.45;
  Nucleargyro[151][0]=10.49;Nucleargyro[153][0]=4.632;Nucleargyro[153][1]=10.1;Nucleargyro[155][0]=1.28;Nucleargyro[157][0]=1.71;Nucleargyro[161][0]=1.4027;Nucleargyro[163][0]=1.9515;
Nucleargyro[165][0]=8.91;Nucleargyro[167][0]=1.2305;Nucleargyro[169][0]=3.51;Nucleargyro[171][0]=7.44;Nucleargyro[173][0]=2.05;Nucleargyro[175][0]=4.857;Nucleargyro[176][0]=3.43;
  Nucleargyro[177][0]=1.3286;Nucleargyro[179][0]=0.7962;Nucleargyro[181][0]=5.096;Nucleargyro[183][0]=1.7716;Nucleargyro[185][0]=9.5854;Nucleargyro[187][0]=9.6839;Nucleargyro[187][1]=0.97174;
Nucleargyro[189][0]=3.3063;Nucleargyro[191][0]=0.73191;Nucleargyro[193][0]=0.79684;Nucleargyro[195][0]=9.094;Nucleargyro[197][0]=0.72919;Nucleargyro[199][0]=7.5901;Nucleargyro[201][0]=2.802;
  Nucleargyro[203][0]=24.327;Nucleargyro[205][0]=24.567;Nucleargyro[207][0]=8.874;Nucleargyro[209][0]=6.8418;Nucleargyro[235][0]=0.7623;Nucleargyro[239][0]=2.39;
End

Function MakeNucleusNameWave()

	make/t/o/n=(242,2) NucleusName
	
	NucleusName[1][0]="1H";NucleusName[2][0]="2H";NucleusName[3][0]="3H";NucleusName[3][1]="3He";NucleusName[6][0]="6Li";NucleusName[7][0]="7Li";NucleusName[9][0]="9Be";NucleusName[10][0]="10B";
NucleusName[11][0]="11B";NucleusName[13][0]="13C";NucleusName[14][0]="14N";NucleusName[15][0]="15N";NucleusName[17][0]="17O";NucleusName[19][0]="19F";NucleusName[21][0]="21Ne";NucleusName[23][0]="23Na";
  NucleusName[25][0]="25Mg";NucleusName[27][0]="27Al";NucleusName[29][0]="29Si";NucleusName[31][0]="31P";NucleusName[33][0]="33S";NucleusName[35][0]="35Cl";NucleusName[37][0]="37Cl";NucleusName[39][0]="29K";
NucleusName[41][0]="41K";NucleusName[43][0]="43Ca";NucleusName[45][0]="45Sc";NucleusName[47][0]="47Ti";NucleusName[49][0]="49Ti";NucleusName[50][0]="50V";NucleusName[51][0]="51V";NucleusName[53][0]="53Cr";
  NucleusName[55][0]="55Mn";NucleusName[57][0]="57Fe";NucleusName[59][0]="59Co";NucleusName[61][0]="61Ni";NucleusName[63][0]="63Cu";NucleusName[65][0]="65Cu";NucleusName[67][0]="67Zn";NucleusName[69][0]="69Ga";
NucleusName[71][0]="71Ga";NucleusName[73][0]="73Ge";NucleusName[75][0]="75As";NucleusName[77][0]="77Se";NucleusName[79][0]="79Br";NucleusName[81][0]="81Br";NucleusName[83][0]="83Kr";NucleusName[85][0]="85Rb";
  NucleusName[87][0]="87Rb";NucleusName[87][1]="87Sr";NucleusName[89][0]="89Y";NucleusName[91][0]="91Zr";NucleusName[93][0]="93Nb";NucleusName[95][0]="95Mo";NucleusName[97][0]="97Mo";NucleusName[99][0]="99Tc";
NucleusName[99][1]="99Ru";NucleusName[101][0]="101Ru";NucleusName[103][0]="103Rh";NucleusName[105][0]="105Pd";NucleusName[107][0]="107Ga";NucleusName[109][0]="109Ag";NucleusName[111][0]="111Cd";
  NucleusName[113][0]="113Cd";NucleusName[113][1]="113In";NucleusName[115][0]="115In";NucleusName[117][0]="117Sn";NucleusName[119][0]="119Sn";NucleusName[121][0]="121Sb";NucleusName[123][0]="123Sb";
NucleusName[123][1]="123Te";NucleusName[125][0]="125Te";NucleusName[127][0]="127I";NucleusName[129][0]="129Xe";NucleusName[131][0]="131Xe";NucleusName[133][0]="133Ce";NucleusName[135][0]="135Ba";
  NucleusName[137][0]="137Ba";NucleusName[139][0]="139La";NucleusName[141][0]="141Pr";NucleusName[143][0]="143Nd";NucleusName[145][0]="145Nd";NucleusName[147][0]="147Sm";NucleusName[149][0]="149Sm";
NucleusName[151][0]="151Eu";NucleusName[153][0]="153Eu";NucleusName[153][1]="153Tb";NucleusName[155][0]="155Gd";NucleusName[157][0]="157Gd";NucleusName[161][0]="161Dy";NucleusName[163][0]="163Dy";
  NucleusName[165][0]="165Ho";NucleusName[167][0]="167Er";NucleusName[169][0]="169Tm";NucleusName[171][0]="171Yb";NucleusName[173][0]="173Yb";NucleusName[175][0]="175Lu";NucleusName[176][0]="176Lu";
NucleusName[177][0]="177Hf";NucleusName[179][0]="179Hf";NucleusName[181][0]="181Ta";NucleusName[183][0]="183W";NucleusName[185][0]="185Re";NucleusName[187][0]="187Re";NucleusName[187][1]="187Os";
  NucleusName[189][0]="189Os";NucleusName[191][0]="191Ir";NucleusName[193][0]="193Ir";NucleusName[195][0]="195Pt";NucleusName[197][0]="197Au";NucleusName[199][0]="199Hg";NucleusName[201][0]="201Hg";
NucleusName[203][0]="203Tl";NucleusName[205][0]="205Tl";NucleusName[207][0]="207Pb";NucleusName[209][0]="209Bi";NucleusName[235][0]="235U";NucleusName[239][0]="239Pu";
End

Function Makevariablewave()

	make/t/o/n=(36) root:spectrumsimulation:system:statsnamewave
 	wave/t statsnamewaveref= root:spectrumsimulation:system:statsnamewave
  statsnamewaveref[0]="gspectrumon";statsnamewaveref[1]="gspectrumdisplay";statsnamewaveref[2]="gatomicmass";statsnamewaveref[3]="galtatomicmass";statsnamewaveref[4]="gII";statsnamewaveref[5]="ggyro";
statsnamewaveref[6]="gfrequencysweep";statsnamewaveref[7]="gfieldsweep";statsnamewaveref[8]="gNQR";statsnamewaveref[9]="gw0";statsnamewaveref[10]="gH0";statsnamewaveref[11]="gsinglecrystal";
  statsnamewaveref[12]="gpowder";statsnamewaveref[13]="guseKxyz";statsnamewaveref[14]="gKiso";statsnamewaveref[15]="gKaniso";statsnamewaveref[16]="gepsilon";statsnamewaveref[17]="gKx";statsnamewaveref[18]="gKy";
statsnamewaveref[19]="gKz";statsnamewaveref[20]="gdvM";statsnamewaveref[21]="gthetaM";statsnamewaveref[22]="gphiM";statsnamewaveref[23]="gvQ";statsnamewaveref[24]="geta";statsnamewaveref[25]="gdvQ";
  statsnamewaveref[26]="gvMAF";statsnamewaveref[27]="gq";statsnamewaveref[28]="gvMAF2";statsnamewaveref[29]="gq2";statsnamewaveref[30]="gthetaAF";statsnamewaveref[31]="gphiAF";statsnamewaveref[32]="gintensity";
statsnamewaveref[33]="gbaseline";statsnamewaveref[34]="gspectrumstart";statsnamewaveref[35]="gspectrumend"
	
	
end

Function Makedefaultstats()

	make/o/n=64 defaultstatswave
	
	defaultstatswave[0,1]=1
	defaultstatswave[2]=63
	defaultstatswave[6]=1
	defaultstatswave[10]=5
	defaultstatswave[11]=1
	defaultstatswave[20]=50
	defaultstatswave[32]=1
	defaultstatswave[41]=1
	defaultstatswave[50,54]=NAN
	defaultstatswave[56,63]=NAN
	
End
	

Function PrintStatwave()

	wave/t Statsnamewaveref= root:spectrumsimulation:system:statsnamewave
	string printout
	variable i
	printout="statsnamewaveref["+num2istr(i)+"]="+statsnamewaveref[i]+";"
	do
		i+=1
		printout=printout+"statsnamewaveref["+num2istr(i)+"]="+statsnamewaveref[i]+";"
	while(i<dimsize(statsnamewaveref,0)-1)
		
	print printout
	
end


Function listTransname()
	wave/t nameref=root:SpectrumSimulation:System:transonname
	string namedisplay="transonname={"
	
	variable i=0
	
	do
		namedisplay+=nameref[i]+","
		i+=1
	while(i<dimsize(nameref,0))
	namedisplay=removeending(namedisplay)
	namedisplay+="}"
	print namedisplay
	i=0
	
	wave/t nameref=root:SpectrumSimulation:System:transintensityname
	namedisplay="transintensityname={"
		
	do
		namedisplay+=nameref[i]+","
		i+=1
	while(i<dimsize(nameref,0))
	namedisplay=removeending(namedisplay)
	namedisplay+="}"
	print namedisplay

	
end

Function listvarname()
	wave/t nameref=root:SpectrumSimulation:System:statsnamewave
	
	variable i=0
	string namesdisplay
	
	namesdisplay= "statsnamewaveref={"
	do
		i+=1
		namesdisplay+=nameref[i]+","
	while(i<dimsize(nameref,0)-1)
	namesdisplay=removeending(namesdisplay,",")
	namesdisplay+="}"

	print namesdisplay
end




Function Lastpoint(wname)
	wave wname
	
	return dimsize(wname,0)-1
End

Function Firstxpoint(wname)
	wave wname
	
	return pnt2x(wname, 0)
end


Function Lastxpoint(wname)
	wave wname
	
	return pnt2x(wname, dimsize(wname, 0)-1)
End


Function/s ListofWavesinFolder()

	string list=""
	variable numwaves,index=0
	
	numwaves = Countobjects("root:",1)
	do
		list=list + GetIndexedObjName("root:", 1, index)+";"
		index +=1
	while(index < numwaves)
	
	return(Sortlist(list))
	
End

Function/s ListofSimwavesinFolder()

	string list=""
	variable numwaves,index=0
	
	numwaves = Countobjects("root:spectrumsimulation:savedsimulations:",1)
	do
		if(strsearch(GetIndexedObjName("root:spectrumsimulation:savedsimulations:", 1, index),"Sim",0)==0)
			list=list + Replacestring("Sim", GetIndexedObjName("root:spectrumsimulation:savedsimulations:", 1, index), "")+";"
		endif
		index +=1
	while(index < numwaves)

	return(Sortlist(list))
End

Function/s ListofAllSpecwavesinFolder()

	string list=""
	variable numwaves,index=0
	
	numwaves = Countobjects("root:spectrumsimulation:savedsimulations:",1)
	do
		if(strsearch(GetIndexedObjName("root:spectrumsimulation:savedsimulations:", 1, index),"AllSpec",0)==0)
			list=list + Replacestring("AllSpec", GetIndexedObjName("root:spectrumsimulation:savedsimulations:", 1, index), "")+";"
		endif
		index +=1
	while(index < numwaves)

	return(Sortlist(list))
End


Function Samestring(string1, string2)
	string string1, string2
	
	if(cmpstr(string1, string2)==0)
		return 1
	else
		return 0
	endif
End

	
Window ConMatNMRSimPro() : Panel

	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(0,0,1100,720)
	ShowInfo/W=ConMatNMRSimPro
	SetDrawLayer UserBack
	
	ConMatNMRSimPro_Master()
	
End
	

Function ConMatNMRSimPro_Master()
	
	SetDataFolder root:SpectrumSimulation:
	
	Display/W=(233,99,1053,679)/HOST=#  root:spectrumsimulation:Spectrum1
	ModifyGraph lSize=2
	Label bottom "Frequencey (MHz)"
	RenameWindow #,G0
	SetActiveSubwindow ##

	//General Parameters
	TitleBox titlegnucleus,pos={60,5},size={77,40},fSize=30,frame=0
	TitleBox titlegnucleus,variable= root:SpectrumSimulation:System:gnucleus

	SetVariable setvargatomicmass,pos={50,45},size={105,15},proc=SetVariableNucleus,title="Atomic Mass"
	SetVariable setvargatomicmass,limits={1,inf,1},value= root:SpectrumSimulation:System:gatomicmass

	SetVariable setvargspectrumnumber,pos={10,65},size={85,15},proc=SetVariableSpectrumNumber,title="Spectrum"
	SetVariable setvargspectrumnumber,limits={1,inf,1},value= root:SpectrumSimulation:System:gspectrumnumber
	
	DrawText 97,79,"/"
	SetDrawEnv fstyle= 5
	ValDisplay valdispgspectrumcount,pos={100,65},size={50,13}
	ValDisplay valdispgspectrumcount,limits={0,0,0},barmisc={0,1000},mode= 2	
	ValDisplay valdispgspectrumcount,value= #"root:spectrumsimulation:system:gspectrumcount"	
	
	CheckBox checkgspectrumon,pos={140,65},size={62,14},proc=SpectrumOnandDisplay,title="Calcualte?"
	CheckBox checkgspectrumon,variable= root:SpectrumSimulation:System:gspectrumon

	SetVariable setvarggryo,pos={30,85},size={170,15},proc=SetVariableStats,title="\F'Symbol'g \F'Arial' (MHz/T)"
	SetVariable setvarggryo,value= root:SpectrumSimulation:System:ggyro

	SetVariable setvargII,pos={65,105},size={100,15},proc=SetVariableStats,title="Nuclear Spin"
	SetVariable setvargII,value= root:SpectrumSimulation:System:gII
	Button buttonTransitionPanel,pos={170,102},size={15,20},proc=TransitionPanelbutton,title="I"
	
	SetVariable setvargIntisity,pos={70,125},size={100,15},proc=SetVariableStats,title="Intensity"
	SetVariable setvargIntisity,limits={0.001,inf,0.01},value= root:SpectrumSimulation:System:gintensity

	SetVariable setvargbaseline,pos={70,145},size={110,15},proc=SetVariableStats,title="Baseline"
	SetVariable setvargbaseline,limits={0,inf,0.01},value= root:SpectrumSimulation:System:gbaseline

	SetVariable setvargspectrumpoints,pos={168,7},size={160,15},title="Spectrum Points 100*10^"
	SetVariable setvargspectrumpoints,value= root:SpectrumSimulation:System:gspectrumpoints	

	//Magnetic Paramters
	DrawText 63,180,"Magnetic Parameters"
	SetDrawEnv fstyle= 1
	
	SetVariable setvargKiso,pos={10,190},size={100,15},proc=SetVariableKvalues,title="K\Biso\M (%)"
	SetVariable setvargKiso,value= root:SpectrumSimulation:System:gKiso
	SetVariable setvargKaniso,pos={10,210},size={100,15},proc=SetVariableKvalues,title="K\Baniso\M (%)"
	SetVariable setvargKaniso,value= root:SpectrumSimulation:System:gKaniso
	SetVariable setvargepsilon,pos={10,230},size={100,15},proc=SetVariableKvalues,title="\F'Symbol'e"
	SetVariable setvargepsilon,value= root:SpectrumSimulation:System:gepsilon
	
	SetVariable setvargKz,pos={115,190},size={100,15},proc=SetVariableKvalues,title="K\Bz\M (%)"
	SetVariable setvargKz,value= root:SpectrumSimulation:System:gKz
	SetVariable setvargKy,pos={115,210},size={100,15},proc=SetVariableKvalues,title="K\By\M (%)"
	SetVariable setvargKy,value= root:SpectrumSimulation:System:gKy
	SetVariable setvargKx,pos={115,230},size={100,15},proc=SetVariableKvalues,title="K\Bx\M (%)"
	SetVariable setvargKx,value= root:SpectrumSimulation:System:gKx
	
	SetVariable setvargdvM,pos={50,250},size={100,15},proc=SetVariableStats,title="dv\BM\M (kHz)"
	SetVariable setvargdvM,value= root:SpectrumSimulation:System:gdVM

	DrawText 45,285,"Orietation relative to V\Bzz"
	SetDrawEnv fstyle= 5
		
	SetVariable setvargthetaM,pos={50,290},size={100,15},proc=SetVariableStats,title="\F'Symbol'q \F'Arial'(deg)"
	SetVariable setvargthetaM,value= root:SpectrumSimulation:System:gthetaM
	SetVariable setvargPhiM,pos={50,310},size={100,15},proc=SetVariableStats,title="\F'Symbol'f \F'Arial'(deg)"
	SetVariable setvargPhiM,value= root:SpectrumSimulation:System:gphiM
	
	//QuadupolarParameters
	DrawText 50,345,"Quadrupolar Parameters"
	SetDrawEnv fstyle= 5
	
	SetVariable setvargvQ,pos={50,350},size={100,15},proc=SetVariableStats,title="v\BQ\M (MHz)"
	SetVariable setvargvQ,value= root:SpectrumSimulation:System:gvQ
	SetVariable setvargeta,pos={50,370},size={100,15},proc=SetVariableStats,title="\F'Symbol'h"
	SetVariable setvargeta,value= root:SpectrumSimulation:System:geta	
	SetVariable setvargdvQ,pos={50,390},size={100,15},proc=SetVariableStats,title="dv\BQ\M (kHz)"
	SetVariable setvargdvQ,value= root:SpectrumSimulation:System:gdvQ

	//AF parameters
	DrawText 20,425,"Antiferromagnetic Parameters"
	SetDrawEnv fstyle= 1
	
	SetVariable setvargvMAF,pos={50,430},size={100,15},proc=SetVariableStats,title="v\BMAF\M (MHz)"
	SetVariable setvargvMAF,value= root:SpectrumSimulation:System:gvMAF
	SetVariable setvargq,pos={50,450},size={100,15},proc=SetVariableStats,title="q (\F'Symbol'p\F'Arial'/2)"
	SetVariable setvargq,value= root:SpectrumSimulation:System:gq
	
	DrawText 45,490,"Orietation relative to V\Bzz"
	
	SetVariable setvargthetaAF,pos={50,495},size={100,15},proc=SetVariableStats,title="\F'Symbol'q\F'Arial' (deg)"
	SetVariable setvargthetaAF,value= root:SpectrumSimulation:System:gthetaAF
	SetVariable setvargPhiAF,pos={50,515},size={100,15},proc=SetVariableStats,title="\F'Symbol'f\F'Arial' (deg)"
	SetVariable setvargPhiAF,value= root:SpectrumSimulation:System:gphiAF
	
	SetVariable setvargtotalqsteps,pos={35,545},size={160,15},title="q steps for AF spectrum"
	SetVariable setvargtotalqsteps,value= root:SpectrumSimulation:System:gtotalqsteps

	//Calculate and display

	Button buttonCalculateSpectra,pos={54,613},size={120,20},proc=CalculateSpectra,title="Calculate Spectra"	
	
	CheckBox checkgspectrumdisplay,pos={90,645},size={54,14},proc=SpectrumOnandDisplay,title="Display?"
	CheckBox checkgspectrumdisplay,variable= root:SpectrumSimulation:System:gspectrumdisplay
	CheckBox checkgspectrumsumdisplay,pos={90,665},size={120,14},proc=SpectrumOnandDisplay,title="Display Spectrum Sum?"
	CheckBox checkgspectrumsumdisplay,variable= root:SpectrumSimulation:System:gspectrumsumdisplay
	
	Button buttonDeleteSpectrum,pos={563,691},size={180,20},proc=DeleteCurrentSpectrum,title="Delete Current Spectrum"
	Button buttonAutoScale,pos={972,687},size={80,20},proc=Autoscale,title="Auto Scale"

	//Experiment Parameters
	CheckBox checkgNQR,pos={180,45},size={36,14},proc=NQRFieldorFrequencySweep,title="NQR"
	CheckBox checkgNQR,variable= root:SpectrumSimulation:System:gNQR
	CheckBox checkgfrequencysweep,pos={225,45},size={94,14},proc=NQRFieldorFrequencySweep,title="Frequency Sweep"
	CheckBox checkgfrequencysweep,variable= root:SpectrumSimulation:System:gfrequencysweep
	CheckBox checkgfieldsweep,pos={225,65},size={69,14},proc=NQRFieldorFrequencySweep,title="Field Sweep"
	CheckBox checkgfieldsweep,variable= root:SpectrumSimulation:System:gfieldsweep

	SetVariable setvargfield,pos={345,45},size={95,15},proc=SetFieldorFrequency,title="Field (T)"
	SetVariable setvargfield,value= root:SpectrumSimulation:System:gH0
	SetVariable setvargfrequency,pos={309,65},size={130,15},proc=SetFieldorFrequency,title="Frequency (MHz)"
	SetVariable setvargfrequency,value= root:SpectrumSimulation:System:gw0
		
	CheckBox checkgsinglecrystal,pos={475,45},size={77,14},proc=SingleCrystalorPowder,title="Single Crystal"
	CheckBox checkgsinglecrystal,variable= root:SpectrumSimulation:System:gsinglecrystal
	CheckBox checkgpowder,pos={475,65},size={50,14},proc=SingleCrystalorPowder,title="Powder"
	CheckBox checkgpowder,variable= root:SpectrumSimulation:System:gpowder
		
	SetVariable setvargangularsteps,pos={475,82},size={160,15},title="Angular steps for powder"
	SetVariable setvargangularsteps,value= root:SpectrumSimulation:System:gangularsteps
	
	SetVariable setvargfieldsteps,pos={300,82},size={160,15},title="Field Steps for Field Sweep"
	SetVariable setvargfieldsteps,value= root:SpectrumSimulation:System:gfieldsteps	
	
	//Res/Eigen vs parameters

	CheckBox checkcalculateresonancevsparam,pos={861,79},size={234,14},title="Calculate Resonance and Eigen values vs params?"
	CheckBox checkcalculateresonancevsparam,variable= root:SpectrumSimulation:System:gqandangdep
	
	PopupMenu popupEandEigen,pos={878,51},size={176,20},proc=DisplayEorEigenPopup
	PopupMenu popupEandEigen,mode=1,popvalue="Resonance vs Parameters",value= #"\"Resonance vs Parameters;Eigen values vs Parameters\""

	//Save Load Spectra	
	
	PopupMenu popupLoadsingleSpectrumandData,pos={524,4},size={342,20},title="Load Single Spectrum and Data"
	PopupMenu popupLoadsingleSpectrumandData,mode=7,popvalue="",value= #"Listofwavesinfolder()"
	PopupMenu popupSaveData,pos={343,5},size={164,20},proc=SaveDataPopup,title="Save"
	PopupMenu popupSaveData,mode=2,popvalue="All Waves and Data",value= #"\"Single Wave and Data;All Waves and Data\""

	PopupMenu popupLoadgroupSpectrumandDat,pos={814,4},size={346,20},proc=LoadDataPopup,title="Load Group of Spectra and Data"
	PopupMenu popupLoadgroupSpectrumandDat,mode=7,popvalue="",value= #"Listofwavesinfolder()"
End

Window ResonancevsParameterPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1253,142,2362,860)
	Display/W=(64,64,561,382)/HOST=# 
	SetDrawLayer UserFront
	RenameWindow #,G0
	SetActiveSubwindow ##
	Display/W=(573,64,1071,382)/HOST=# 
	SetDrawLayer UserFront
	DrawText -0.949799196787149,0.113207547169811,"\t\t\tmake/o/n=(gtotalqsteps, gII*2) $(\"Energyvsq\"+num2istr(gspectrumnumber))\r"
	RenameWindow #,G1
	SetActiveSubwindow ##
	Display/W=(61,391,559,710)/HOST=# 
	RenameWindow #,G2
	SetActiveSubwindow ##
	Display/W=(577,391,1072,709)/HOST=# 
	RenameWindow #,G3
	SetActiveSubwindow ##
EndMacro

Window EigenvaluesvsParameterPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(358,197,1467,915)
	Display/W=(64,64,561,382)/HOST=# 
	RenameWindow #,G0
	SetActiveSubwindow ##
	Display/W=(573,64,1071,382)/HOST=# 
	SetDrawLayer UserFront
	DrawText -0.949799196787149,0.113207547169811,"\t\t\tmake/o/n=(gtotalqsteps, gII*2) $(\"Energyvsq\"+num2istr(gspectrumnumber))\r"
	RenameWindow #,G1
	SetActiveSubwindow ##
	Display/W=(61,391,559,710)/HOST=# 
	RenameWindow #,G2
	SetActiveSubwindow ##
	Display/W=(577,391,1072,709)/HOST=# 
	RenameWindow #,G3
	SetActiveSubwindow ##
EndMacro

