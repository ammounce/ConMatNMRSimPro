#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 0.2
#pragma IgorVersion = 6.37

#include ":CMNMRSP_Structure"
#include ":CMNMRSP_Initialization"
#include ":CMNMRSP_Controls"
#include ":CMNMRSP_Hamiltonians"
#include ":CMNMRSP_Transitions"
#include ":CMNMRSP_Calculate"

//This function will initialize the ConMatNMRSimPro software by making variables, waves, strings
// folder ect, then checking the status of the ConMatSimNMRPro main panel
// This macro can be called again in order to reinitialized the variables

Macro ConMatNMRSimPro_Initialize()
	InitializeConMatNMRSimPro()
	
	CheckMainPanel()
End
