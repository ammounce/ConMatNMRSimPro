#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2

#include ":CMNMRSP_Structure"
#include ":CMNMRSP_Initialization"
#include ":CMNMRSP_Controls"
#include ":CMNMRSP_Hamiltonians"
#include ":CMNMRSP_Transitions"
#include ":CMNMRSP_Calculate"


Macro NMRSimuPro_Initialize()
	InitializeNMRSimuPro()
	
	CheckMainPanel()
End
