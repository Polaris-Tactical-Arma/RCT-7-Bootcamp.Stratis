_taskId = param [0, RCT7BootcampTaskPrefix, ["", []], 2];
_description = param [1, "", [""]];

_taskDescriptionList = _taskId call BIS_fnc_taskDescription;
if (count(_taskDescriptionList) isEqualTo 0) exitWith {};

[
	_taskId,
	[
		_description,
		_taskDescriptionList # 1,
		_taskDescriptionList # 2
	]
] call BIS_fnc_taskSetDescription;