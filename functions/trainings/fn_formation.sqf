_group = param[0, grpNull, [grpNull]];

private _unit1 = nil;
private _unit2 = nil;
private _unit3 = nil;
private _unit4 = nil;

{
	_unit = _x;

	_pos = _unit getVariable "RCT7Bootcamp_Formation";
	systemChat str _pos;

	switch (_pos) do {
		case 1: {
			_unit1 = _unit;
		};
		case 2: {
			_unit2 = _unit;
		};
		case 3: {
			_unit3 = _unit;
		};
		case 4: {
			_unit4 = _unit;
		};
	};
} forEach units _group;

_formationList = [
	"COLUMN",
	"LINE",
	"STAG COLUMN",
	"WEDGE",
	"ECH LEFT",
	"ECH RIGHT"
];

{
	systemChat _x;
	[[_unit1, _unit2, _unit3, _unit4], _x] call RCT7Bootcamp_fnc_setFormation;

	sleep 5;
} forEach _formationList;