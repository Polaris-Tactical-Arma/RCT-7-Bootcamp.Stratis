
_unit = _this;

_syncedUnits = synchronizedObjects _unit;
_count = count(_syncedUnits);

if (_count < 1) exitWith { systemChat "Please sync at least 2 units together!"; };


player addAction ["Start!", {
				params ["_target", "_caller", "_actionId", "_arguments"];
				player removeAction _actionId;
				_unit = (synchronizedObjects leader player) # 0;
				player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false];
				_unit setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true];
			},
			nil,1.5,true,true,"","player call RCT7Bootcamp_fnc_bounding"
];

// TASK Icon: run
// player group
{
		_waypoint = _x;
		_pos = waypointPosition _waypoint;
		"Sign_Sphere100cm_F" createVehicle _pos;

		_condition = "


			if !( player getVariable ['RCT7Bootcamp_BoundingIsMyTurn', false] ) exitWith {
				false;
			};

			_unit = (synchronizedObjects this) # 0;
			
			_dist = RCT7_BootcampWaypointPos distance _unit;
			_dist < 2;

		";

		_onSuccess = '
			_unit = (synchronizedObjects this) # 0;
			_unit setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true];

			RCT7_BootcampWaypointPos = [0,0,0];

			player addAction ["Set!", {
					params ["_target", "_caller", "_actionId", "_parameter"];
					player removeAction _actionId;
					player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false];
				},nil,1.5,true,true,"","player call RCT7Bootcamp_fnc_bounding"
			];
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
			hint str _check;
			
			_check;
		";

		_onSuccess = '
			player setVariable ["RCT7Bootcamp_BoundingIsMyTurn", true];
			this setVariable ["RCT7Bootcamp_BoundingIsMyTurn", false];

			_g = group this;
			_wp = currentWaypoint _g;
			RCT7_BootcampWaypointPos = waypointPosition [_g, _wp + 1];

			"Sign_Arrow_Large_Cyan_F" createVehicle RCT7_BootcampWaypointPos;

		';

		_waypoint setWaypointStatements [_condition, _onSuccess];

} forEach (waypoints (_syncedUnits # 0));