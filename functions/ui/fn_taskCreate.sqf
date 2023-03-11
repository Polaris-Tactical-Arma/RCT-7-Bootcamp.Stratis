/*
	See Arma 3 Task Framework: 
https// community.bistudio.com/wiki/BIS_fnc_taskCreate
*/

private _taskId = param [0, RCT7BootcampTaskPrefix, ["", []], 2];
_title = param [1, "New Task", [""]];
_description = param [2, "", [""]];
_icon = param [3, "interact", [""]];
_state = param [4, "ASSIGNED", [""]];
_showNotification = param [5, true, [true]];
_priority = param[6, 1, [0]];
_destination = param [7, objNull, [objNull, []], 3];
_visibleIn3D = param [8, false, [false]];

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