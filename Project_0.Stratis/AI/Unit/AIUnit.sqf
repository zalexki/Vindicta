/*
AI class for the group

Author: Sparker 12.11.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "unitWorldStateProperties.hpp"
#include "..\..\GlobalAssert.hpp"

#define pr private

CLASS("AIUnit", "AI")

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		// Make sure that the needed MessageLoop exists
		ASSERT_GLOBAL_OBJECT(gMessageLoopGroupAI);
		
		// Initialize the world state
		
		// Initialize sensors
		pr _sensorSalute = NEW("SensorUnitSalute", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorSalute]);
		
		pr _sensorGrenade = NEW("SensorUnitGrenade", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorGrenade]);
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// | The group AI resides in its own thread
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		gMessageLoopGroupAI
	} ENDMETHOD;

ENDCLASS;