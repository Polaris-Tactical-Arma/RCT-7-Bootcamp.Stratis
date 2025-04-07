/*
	Author: Eduard Schwarzkopf
	
	Description:
	Start the bounding training
	
	Parameter(s):
	0: Object - Unit which should be the bounding partner of the player
	1: String - name of the bounding type
	
	Returns:
	true
*/

_unit = param[0, objNull, [objNull]];
RCT7BoundingType = param[1, "Alternate", [""]];
_taskDescription = param[2, "", [""]];

[player] joinSilent (group _unit);
sleep 1;

[RCT7BoundingType+"Bounding", RCT7BoundingType+" Bounding", _taskDescription, "run", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

_actionString = ["Start", RCT7BoundingType, "Bounding Training"] joinString " ";

player addAction [_actionString, {
	params ["_target", "_caller", "_actionId", "_arguments"];
	player removeAction _actionId;
	_unit = (synchronizedObjects leader player) # 0;
	_varMyTurn = "RCT7Bootcamp_BoundingIsMyTurn";
	player setVariable [_varMyTurn, false, true];
	_unit setVariable [_varMyTurn, true, true];
},
nil, 5, true, true, "", "(player distance leader player) < 5"
];

private _taskId = RCT7BoundingType+"Bounding";

[_unit, _taskId] call RCT7Bootcamp_fnc_boundingLogic;
[] spawn RCT7Bootcamp_fnc_boundingInFormationCheck;

waitUntil {
	_group = group player;
	(currentWaypoint _group) isEqualTo (count( waypoints _group));
};

[_taskId] call RCT7Bootcamp_fnc_taskSetState;

// reset
_otherLeader = (synchronizedObjects leader player) # 0;
_varMyTurn = "RCT7Bootcamp_BoundingIsMyTurn";
player setVariable [_varMyTurn, nil, true];
_otherLeader setVariable [_varMyTurn, nil, true];
[player] joinSilent grpNull;
RCT7BoundingType = nil;

true;