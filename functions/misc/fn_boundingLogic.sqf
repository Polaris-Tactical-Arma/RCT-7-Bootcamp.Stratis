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
	_pos = waypointPosition _waypoint;
	"Sign_Sphere100cm_F" createVehicle _pos;

	_condition = "
	if !(player getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) exitWith {
		false;
	};

	_unit = (synchronizedObjects this) # 0;

	_dist = RCT7_BootcampWaypointPos distance _unit;
	_atWaypoint = _dist < 2;

	_atWaypoint;

	";

	_onSuccess = '
	_unit = (synchronizedObjects this) # 0;
	_unit setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true];

	RCT7_BootcampWaypointPos = [0, 0, 0];

	_group = group player;
	_wpi = currentWaypoint _group;
	if (_wpi < (count( waypoints _group) - 1)) then {
		systemChat str _wpi;
		_taskId = ["BoundingSet", str(_wpi)] joinString "";
		[[_taskId, RCT7BoundingParentTaskId], "Move to next waypoint", "Move to the next waypoint and call out when you are set (use scroll wheel)"] call RCT7Bootcamp_fnc_taskCreate;

		player addAction ["Set!", {
			params ["_target", "_caller", "_actionId", "_parameter"];
			player removeAction _actionId;
			player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false];
			_wpi = (currentWaypoint group player) - 1;
			_taskId = ["BoundingSet", str(_wpi)] joinString "";
			[_taskId] call RCT7Bootcamp_fnc_taskSetState;
		}, nil, 5, true, true, "", "(player distance leader player) < 5 && speed (leader player) isEqualTo 0"
	];
};
';

_waypoint setWaypointStatements [_condition, _onSuccess];
} forEach (waypoints _unit);

// other group
{
	_waypoint = _x;
	_pos = waypointPosition _waypoint;
	"Sign_Sphere100cm_F" createVehicle _pos;

	_condition = "
	if !(this getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) exitWith {
		false;
	};

	_check = (player getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false]) isEqualTo false;

	_check;
	";

	_onSuccess = '
	player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true];
	this setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false];

	_g = group this;
	_wp = currentWaypoint _g;
	RCT7_BootcampWaypointPos = waypointPosition [_g, _wp + 1];
	';

	_waypoint setWaypointStatements [_condition, _onSuccess];
} forEach (waypoints (_syncedUnits # 0));