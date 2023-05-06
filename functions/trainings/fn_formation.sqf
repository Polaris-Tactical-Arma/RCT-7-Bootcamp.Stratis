_group = param[0, grpNull, [grpNull]];

private _unit1 = nil;
private _unit2 = nil;
private _unit3 = nil;
private _unit4 = nil;

_createArrow = {
	private _unit = param[0, objNull, [objNull]];
	private _arrowType = param[1, "Sign_Arrow_Large_F", ["Add your description here"]];

	_arrow = _arrowType createVehicle (getPos _unit);
	_arrow attachTo [_unit, [0, 0, 2.5]];
};

{
	private _unit = _x;

	_pos = _unit getVariable "RCT7Bootcamp_Formation";

	switch (_pos) do {
		case 1: {
			_unit1 = _unit;
			[_unit] call _createArrow;
		};
		case 2: {
			_unit2 = _unit;
			[_unit] call _createArrow;
		};
		case 3: {
			_unit3 = _unit;
			[_unit, "Sign_Arrow_Large_Blue_F"] call _createArrow;
		};
		case 4: {
			_unit4 = _unit;
			[_unit, "Sign_Arrow_Large_Blue_F"] call _createArrow;
		};
	};
} forEach units _group;

private _unitList = [_unit1, _unit2, _unit3, _unit4];

private _formationList = [
	["COLUMN", "Column", "Add your description here"],
	["LINE", "Line", "Add your description here"],
	["STAG COLUMN", "Staggered Column", "Add your description here"],
	["WEDGE", "Wedge", "Add your description here"],
	["ECH LEFT", "Echelon Left", "Add your description here"],
	["ECH RIGHT", "Echelon Right", "Add your description here"]
];

sleep 2;

{
	[_unitList, _x # 0] call RCT7Bootcamp_fnc_setFormation;
	private _formationDisplayname = _x # 1;
	private _formationDescription = _x # 2;
	private _hintText = ["This formation is called: ", _formationDisplayname, "\n\n", _formationDescription] joinString "";
	hint _hintText;
	sleep 10;
} forEach _formationList;

private _quizz = {
	_formationAddActionList = param [0, [], [[]]];

	{
		_displayname = _x # 1;

		player addAction [["<t color='#ffe0b5'>", _displayname, "</t>"] joinString "", {
			params ["_target", "_caller", "_actionId", "_arguments"];

			private _formation = _arguments # 0;
			private _formationDisplayname = _arguments # 1;

			private _formationFormatted = _formation regexReplace [" ", "_"];

			private _dbSection = ["Formation", RCT7Bootcamp_CurrentFormation] joinString "-";

			private _result = false;
			if (_formation isEqualTo RCT7Bootcamp_CurrentFormation) then {
				_result = true;
			};

			_result spawn {
				if (_this) then {
					player call RCT7Bootcamp_fnc_targetHitValid;
					hint "Correct";
				} else {
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					hint "Incorrect";
				};

				sleep 3;
				hintSilent "";
			};

			systemChat _dbSection;
			[[player, _dbSection, "correct", _result, [["answer", _formationDisplayname]]]] remoteExec ["RCT7_addToDBQueue", 2];
			RCT7Bootcamp_FormationHasAnswered = true;
		}, [_x # 0, _displayname]];
	} forEach _formationAddActionList;
};

_FormationTaskId = "Formation";
[_FormationTaskId, "Formation", "Make the quizz", "interact", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

RCT7Bootcamp_FormationHasAnswered = false;
_formationAddActionList = + _formationList;

while { count _formationList > 0 } do {
	_formationData = selectRandom _formationList;
	_formation = _formationData # 0;
	RCT7Bootcamp_CurrentFormation = _formation;

	[[_unit1, _unit2, _unit3, _unit4], _formation] call RCT7Bootcamp_fnc_setFormation;
	[_formationAddActionList] call _quizz;

	waitUntil {
		RCT7Bootcamp_FormationHasAnswered;
	};

	RCT7Bootcamp_FormationHasAnswered = false;
	_formationList deleteAt (_formationList find _formationData);
	systemChat str _formationList;
	removeAllActions player;
};

[_FormationTaskId] call RCT7Bootcamp_fnc_taskSetState;