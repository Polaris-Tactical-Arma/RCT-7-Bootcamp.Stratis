_unit = _this;

[player] joinSilent (group _unit);

player addAction ["Start Successive Bounding Training", {
	params ["_target", "_caller", "_actionId", "_arguments"];
	player removeAction _actionId;
	_unit = (synchronizedObjects leader player) # 0;
	_varMyTurn = "RCT7Bootcamp_BoundingIsMyTurn";
	player setVariable [_varMyTurn, false];
	_unit setVariable [_varMyTurn, true];
	["SuccessiveBounding", "Successive Bounding", "Follow your Partner and stay close to him", "run", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;
},
nil, 5, true, true, "", "(player distance leader player) < 5"
];

private _taskId = "SuccessiveBounding";

[_unit, _taskId] call RCT7Bootcamp_fnc_boundingLogic;

waitUntil {
	_group = group player;
	(currentWaypoint _group) isEqualTo (count( waypoints _group))
};

[_taskId] call RCT7Bootcamp_fnc_taskSetState;

// reset
_otherLeader = (synchronizedObjects leader player) # 0;
_varMyTurn = "RCT7Bootcamp_BoundingIsMyTurn";
player setVariable [_varMyTurn, nil];
_otherLeader setVariable [_varMyTurn, nil];
[player] joinSilent grpNull;

true;