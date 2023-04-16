if (isNil "RCT7BootcampTaskPrefix") then {
	RCT7BootcampTaskPrefix = "RCT7BootcampTask";
};

_taskId = param [0, RCT7BootcampTaskPrefix, [""]];
_state = param [1, "SUCCEEDED", [""]];
_showInHud = param [2, true, [true]];
_deleteOnComplete = param[3, false, [false]];

[_taskId, _state, _showInHud] call BIS_fnc_taskSetState;

if !(_deleteOnComplete) exitWith {};

[_taskId, true] call BIS_fnc_deleteTask;