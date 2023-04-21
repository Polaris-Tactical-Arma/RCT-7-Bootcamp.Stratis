_group = param[0, grpNull, [grpNull]];

private _unit1 = nil;
private _unit2 = nil;
private _unit3 = nil;
private _unit4 = nil;

{
	_unit = _x;

	_pos = _unit getVariable "RCT7Bootcamp_Formation";

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

private _unitList = [_unit1, _unit2, _unit3, _unit4];

private _formationList = [
	["COLUMN", "Column"],
	["LINE", "Line"],
	["STAG COLUMN", "Staggered Column"],
	["WEDGE", "Wedge"],
	["ECH LEFT", "Echolon Left"],
	["ECH RIGHT", "Echolon Right"]
];

{
	[_unitList, _x # 0] call RCT7Bootcamp_fnc_setFormation;
	hint (["This formation is called", _x # 1] joinString ":\n");
	sleep 10;
} forEach _formationList;

private _quizz = {
	_formationAddActionList = param [0, [], [[]]];

	{
		_displayname = _x # 1;

		player addAction [["<t color='#ffe0b5'>", _displayname, "</t>"] joinString "", {
			params ["_target", "_caller", "_actionId", "_arguments"];
			player removeAction _actionId;

			_formation = _arguments;
			_formationFormatted = _formation regexReplace [" ", "_"];

			_dbSection = ["Formation", _formationFormatted] joinString "-";
			systemChat (["Formation", _formationFormatted] joinString ": ");

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

			[player, _dbSection, "correct", _result, [["answer", _formation]]] remoteExec ["RCT7_writeToDb", 2];
			RCT7Bootcamp_FormationHasAnswered = true;
		}, _x # 0];
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