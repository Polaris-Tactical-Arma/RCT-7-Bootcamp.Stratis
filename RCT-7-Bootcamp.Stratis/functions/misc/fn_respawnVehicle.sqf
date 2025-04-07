_unit = param[0, objNull, [objNull]];

_pos = getPosATL _unit;
_dir = direction _unit;
_type = typeOf _unit;
_isAir = _type isKindOf "Air";

private _special = "NONE";

if (_isAir) then {
	_special = "FLY";
};

RCT7LauncherTargetList deleteAt (RCT7LauncherTargetList find _unit);
deleteVehicleCrew _unit;
deleteVehicle _unit;
sleep 1;

private _veh = createVehicle [_type, [0, 0, 0], [], 0, _special];
_veh enableSimulation false;
RCT7LauncherTargetList pushBack _veh;

_veh setPosATL _pos;
_veh setDir _dir;
_veh setVectorUp surfaceNormal position _veh;
_veh enableSimulation true;

if (_veh isKindOf "Air") then {
	_crew = createVehicleCrew _veh;
	_crew setBehaviour "CARELESS";
	_veh flyInHeight (_pos # 2);
	_veh call RCT7Bootcamp_fnc_unlimitedFuel;
};