_taskId = param [0, RCT7BootcampTaskPrefix, [""]];
_state = param [1, "SUCCEEDED", [""]];
_showInHud = param [2, true, [true]];

[_taskId, _state, _showInHud] call BIS_fnc_taskSetState;