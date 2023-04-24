_unit = param[0, objNull, [objNull]];
RCT7BoundingParentTaskId = param[1, "Bounding", [""]];

_syncedUnits = synchronizedObjects _unit;
_count = count(_syncedUnits);

if (_count < 1) exitWith {
	systemChat "Please sync at least 2 units together!";
};

// player group
{
	_waypoint = _x;

	_condition = "
	_player = allPlayers # 0;
	if !(_player getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) exitWith {
		false;
	};

	_unit = (synchronizedObjects this) # 0;

	_dist = RCT7_BootcampWaypointPos distance _unit;
	_atWaypoint = _dist < 2;

	_atWaypoint;

	";

	_onSuccess = '
	private _player = allPlayers # 0;

	_unit = (synchronizedObjects this) # 0;
	_unit setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true, true];

	RCT7_BootcampWaypointPos = [0, 0, 0];

	_group = group _player;
	_wpi = currentWaypoint _group;
	if (_wpi < (count( waypoints _group) - 1)) then {
		_taskId = ["BoundingSet", str(_wpi)] joinString "";
		[[_taskId, RCT7BoundingParentTaskId], "Move to next waypoint", "Move to the next waypoint and call out when you are set (use scroll wheel)"] call RCT7Bootcamp_fnc_taskCreate;

		_player addAction ["Set!", {
			params ["_target", "_caller", "_actionId", "_parameter"];
			_caller removeAction _actionId;
			_caller setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false, true];
			_wpi = (currentWaypoint group _caller) - 1;
			_taskId = ["BoundingSet", str(_wpi)] joinString "";
			[_taskId] call RCT7Bootcamp_fnc_taskSetState;
		}, nil, 5, true, true, "", "[(leader _this)] call RCT7Bootcamp_fnc_isAtCurrentWaypoint && ((leader _this) distance _this) < 5"
	];
};
';

_waypoint setWaypointStatements [_condition, _onSuccess];
} forEach (waypoints _unit);

// other group
{
	_waypoint = _x;

	_condition = "
	if !(this getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) exitWith {
		false;
	};

	_player = allPlayers # 0;
	_check = (_player getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) isEqualTo false;

	_check;
	";

	_onSuccess = '
	_player = allPlayers # 0;
	_player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true, true];
	this setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false, true];

	_g = group this;
	_wp = currentWaypoint _g;
	RCT7_BootcampWaypointPos = waypointPosition [_g, _wp + 1];
	';

	_waypoint setWaypointStatements [_condition, _onSuccess];
} forEach (waypoints (_syncedUnits # 0));