/*
	See Arma 3 Task Framework: 
https// community.bistudio.com/wiki/BIS_fnc_taskCreate
*/

if (isNil "RCT7BootcampTaskPrefix") then {
	RCT7BootcampTaskPrefix = "RCT7BootcampTask";
};

private _taskId = param [0, RCT7BootcampTaskPrefix, ["", []], 2];
_title = param [1, "New Task", [""]];
_description = param [2, "", [""]];
_icon = param [3, "interact", [""]];
_state = param [4, "ASSIGNED", [""]];
_showHint = param [5, true, [true]];
_showNotification = param [6, true, [true]];
_priority = param[7, 1, [0]];
_destination = param [8, objNull, [objNull, []], 3];
_visibleIn3D = param [9, false, [false]];

if (_showHint) then {
	_description spawn {
		hint "";
		sleep 2;
		hint parseText _this;
	}
};

[
	player,
	_taskId,
	[
		_description,
		_title
	],
	_destination,
	_state,
	_priority,
	_showNotification,
	_icon,
	_visibleIn3D
] call BIS_fnc_taskCreate;