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
	["COLUMN", "Column", "The most time efficient formation at our disposal - formed by a single file with the first buddy group at the front and the second at the rear."],
	["LINE", "Line", "This is a simple formation that is formed by a single row of all fireteam members.<br/><br/>Strong side left or right will dictate which side of the formation the AR buddy team should fall in."],
	["STAG COLUMN", "This formation is typically used for walking along roads with a buddy team file on either side (dictated by strong side).<br/><br/>This formation allows a fireteam to respond to contact on either side without crossing lines of fire and reduces casualties from IEDs & mines with its increased spacing."],
	["DIAMOND", "Diamond", "The diamond has all around security - its shape allows each fireteam member to cover a quarter interval of the clock face.<br/><br/>The assistant autorifleman takes the rear position with the AR filling in on the left or right depending on the strong side."],
	["ECH LEFT", "Echelon Left", "The intent of the echelon formation is to provide maximum protection for the respective flank.<br/><br/>It is a diagonal line which faces potential enemy threats so that the fireteam’s power can be focused in their direction.<br/><br/>The AR will fall in last, taking the furthest poition to the left to increase the formation's strength."],
	["ECH RIGHT", "Echelon Right", "The intent of the echelon formation is to provide maximum protection for the respective flank.<br/><br/>It is a diagonal line which faces potential enemy threats so that the fireteam’s power can be focused in their direction.<br/><br/>The AR will fall in last, taking the furthest poition to the right to increase the formation's strength."]
];

sleep 2;

_introText = "A fireteam's success is often determined by its application of the right formation at the right time - failure to do so can at best lower the fireteam’s effectiveness and at the very worst cause the death of one or more of its members.\n\n

In each formation each member is vital in carrying out its function effectively.\n\n

The formations that follow are those typically used in RCT-7.";

hint _introText;

sleep 15;

{
	[_unitList, _x # 0] call RCT7Bootcamp_fnc_setFormation;
	private _formationDisplayname = _x # 1;
	private _formationDescription = _x # 2;
	private _hintText = ["This formation is called: ", _formationDisplayname, "\n\n", parseText _formationDescription] joinString "";
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

_FormationTaskId = "Formations";
[_FormationTaskId, "Formations", "Complete the quiz", "interact", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

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