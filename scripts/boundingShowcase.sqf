
_unit = _this;

_syncedUnits = synchronizedObjects _unit;
_count = count(_syncedUnits);

if (_count < 1) exitWith { systemChat "Please sync at least 2 units together!"; };

_list = [_unit, _syncedUnits # 0];

{
	_unit = _x;

	{
		_waypoint = _x;
		_pos = waypointPosition _waypoint;
		"Sign_Sphere100cm_F" createVehicle _pos;

		_code = "
			_unit = (synchronizedObjects this) # 0;
			_unit call RCT7Bootcamp_fnc_bounding;
		";
		// TODO: They will need to use a button or cta to call "set" when in position

		_waypoint setWaypointStatements [_code, ''];

	} forEach (waypoints _unit);
	
} forEach _list;
