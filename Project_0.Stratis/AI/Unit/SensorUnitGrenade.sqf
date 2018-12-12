#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
This sensor gets stimulated when someone salutes to this unit
*/

#define pr private

CLASS("SensorUnitGrenade", "SensorStimulatable")

	// ----------------------------------------------------------------------
	// |                          D O   C O M P L E X  C H E C K
	// | Performs complex sensor-specific check to determine if the sensor is sensitive to the stimulus
	// ----------------------------------------------------------------------
	
	METHOD("doComplexCheck") {
		// We always fear grenades!
		true
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           C R E A T E   W O R L D   F A C T
	// | Creates a world fact specific to this sensor
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("createWorldFact") {
		params [["_thisObject", "", [""]]];
		pr _AI = GETV(_thisObject, "AI");
		
		// Don't create a new fact if there is one already
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_SPOTTED_GRENADE] call wf_fnc_setType;
		//pr _wfFound = CALLM(_AI, "findWorldFact", [_wf]);
		//if (isNil "_wfFound") then {
			diag_log format ["[SensorUnitGrenade:createWorldFact] Sensor: %1, created world fact", _thisObject];
			
			// Create a world fact
			[_wf, STIMULUS_GET_SOURCE(_stimulus)] call wf_fnc_setSource;
			[_wf, 6] call wf_fnc_setLifetime;
			[_wf, 1] call wf_fnc_setRelevance;
			CALLM(_AI, "addWorldFact", [_wf]);
			
			// Call the process method of this AI ASAP so that he reacts faster
			// Now we are in the thread of this AI so we can call the method directly
			CALLM(_AI, "process", []);
		//};
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_GRENADE]
	} ENDMETHOD;

ENDCLASS;