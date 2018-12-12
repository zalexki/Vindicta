#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Salute action class
Author: Sparker 24.11.2018
*/

/*
[] spawn {
private _guy = cursorObject;
_guy action ["salute", _guy];
sleep 3;
_guy switchmove "AmovPercMstpSlowWrflDnon_SaluteOut";
};
*/

#define pr private

CLASS("ActionUnitAvoidGrenade", "Action")

	VARIABLE("target");
	VARIABLE("activationTime");
	VARIABLE("objectHandle");
	
	// ------------ N E W ------------
	// _target - whom to salute to
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];
		SETV(_thisObject, "target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "objectHandle", _oh);
	} ENDMETHOD;
	
	METHOD("delete") {
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		// Run the fuck away!
		pr _target = GETV(_thisObject, "target");
		pr _oh = GETV(_thisObject, "objectHandle");
		(group _oh) setBehaviour "AWARE";
		_oh disableAI "TARGET";
		_oh disableAI "AUTOTARGET";
		_oh setUnitPos "UP";
		pr _dir = _target getDir _oh;
		pr _escapePos = _target getPos [20, _dir];
		//createVehicle ["Sign_Arrow_Large_Green_F", _escapePos, [], 0, "CAN_COLLIDE"];
		_oh doMove _escapePos;
		
		SETV(_thisObject, "activationTime", time);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		// Action is active
		
		// Check if the grenade does not exist any more or time has expired
		
		pr _atime = GETV(_thisObject, "activationTime");
		pr _target = GETV(_thisObject, "target");
		pr _oh = GETV(_thisObject, "objectHandle");
		
		// Lay down if some time has passed
		/*if ((time - _atime > 1)) exitWith {
			_oh setUnitPos "DOWN";
		ACTION_STATE_ACTIVE};*/
		
		// Terminate if a lot of time has passed or the grenade has detonated
		if ((time - _atime > 10) || (isNull _target)) exitWith { CALLM(_thisObject, "terminate", []); ACTION_STATE_COMPLETED };
	
		// Othrewise the action is still running
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		diag_log "Terminating grenade avoidance!";
		
		
		pr _oh = GETV(_thisObject, "objectHandle");
		_oh doFollow (leader group _oh);
		_oh enableAI "TARGET";
		_oh enableAI "AUTOTARGET";
		_oh setUnitPos "AUTO";
		//(group _oh) setCombatMode "GREEN";
		(group _oh) setBehaviour "SAFE";
		
		//SETV(_thisObject, "state", ACTION_STATE_INACTIVE);
	} ENDMETHOD; 

ENDCLASS;