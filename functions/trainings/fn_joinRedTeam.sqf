_teamHint = [call RCT7Bootcamp_fnc_getACESelfInfo, " and under Team Management, and join the red team"] joinString "";
_teamTaskId = "joinTeam";
[_teamTaskId, "Join the red team", _teamHint, "meet"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil {
	assignedTeam player isEqualTo "RED";
};

[_teamTaskId] call RCT7Bootcamp_fnc_taskSetState;

true;