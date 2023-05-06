private _patient = param[0, objNull, [objNull]];
private _bodyPart = param[1, "rightleg", [""]];

_getBodyPartN = {
	private _bodyPart = param[0, "", [""]];
	private _bodyPartN = -1;

	switch (_bodyPart) do {
		case "head": {
			_bodyPartN = 0
		};
		case "body": {
			_bodyPartN = 1
		};
		case "leftarm": {
			_bodyPartN = 2
		};
		case "rightarm": {
			_bodyPartN = 3
		};
		case "leftleg": {
			_bodyPartN = 4
		};
		case "rightleg": {
			_bodyPartN = 5
		};
	};
};

RCT_MedicalInProcess = true;

if (_patient isEqualTo objNull) exitWith {
	systemChat "No patient provided"
};

removeAllItems player;
_medicalItems = ["ACE_tourniquet", "ACE_fieldDressing", "ACE_morphine"];
player setVariable ["ace_medical_medicclass", 1, true]; // set as medic

{
	player addItem _x;
	player addItem _x;
	player addItem _x;
} forEach _medicalItems;

private _isAI = _patient isNotEqualTo player;

hint "Medical Items added to inventory\n\nAlways make sure to prioritize combat over medical!";
sleep 5;

_patientMedicalTaskId = "PatientMedical";
[_patientMedicalTaskId, "ACE Medical", "Follow the instructions provided.", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

private _isBandaged = {
	_wounds = _patient getVariable ["ace_medical_openWounds", []];
	private _result = false;

	{
		_x params ["_xClassID", "_xBodyPartN", "_xAmountOf", "_xBleeding", "_xDamage"];
		if (_xAmountOf isEqualTo 0) exitWith {
			_result = true;
		};
	} forEach _wounds;

	_result;
};

private _applyDamage = {
	params["_unit", "_bodyPart"];

	_message = ["Applying damage to ", name _patient, "in"] joinString "";
	[_message, 5] call RCT7Bootcamp_fnc_cooldownHint;
	[_patient, 0.8, _bodyPart, "bullet"] remoteExec ["ace_medical_fnc_addDamageToUnit", 0];

	_patient spawn {
		while { RCT_MedicalInProcess } do {
			sleep 10;
			_this setVariable ["ace_medical_bloodVolume", 5.8, true];
		};
	};

	if (_isAI) then {
		[_patient, true, 10e10] call ace_medical_fnc_setUnconscious;
	};
};

private _responseChecked = {
	_unit = param[0, objNull, [objNull]];
	_medicalLog = _unit getVariable ["ace_medical_log_quick_view", []];

	private _searchString = "STR_ace_medical_treatment_Check_Response";
	private _found = false;

	{
		if ([_searchString, _x select 0] call BIS_fnc_inString) exitWith {
			_found = true;
		};
	} forEach _medicalLog;

	_found;
};

private _isRunning = true;

while { _isRunning } do {
	private _startOver = false;
	[ _patient ] call ACE_medical_treatment_fnc_fullHealLocal;

	[_patient, _bodyPart] call _applyDamage;

	if (_isAI) then {
		_patientResponse = "PatientResponse";
		_medicalKeybind = ["ACE3 Common", "ACE_Medical_GUI_openMedicalMenuKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
		_reponseDescription = ["Open the medical menu by pressing [", _medicalKeybind, "], click on the diagram's head, then click the 'Examine Patient' button and select 'Check response'."] joinString "";
		[[_patientResponse, _patientMedicalTaskId], "Check response", _reponseDescription, "heal"] call RCT7Bootcamp_fnc_taskCreate;

		waitUntil {
			sleep 1;
			_patient call _responseChecked;
		};
		[_patientResponse] call RCT7Bootcamp_fnc_taskSetState;
	};

	_patientTournequit = "PatientTournequit";
	[[_patientTournequit, _patientMedicalTaskId], "Use a tourniquet", "In the medical menu, click on the patient's bleeding leg (yellow), click the 'Bandage/Fractures' button and select 'Apply Tourniquet'.", "heal"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil{
		sleep 1;

		if (call _isBandaged) then {
			[_patientTournequit, "FAILED"] call RCT7Bootcamp_fnc_taskSetState;
			_startOver = true;
			_startOver;
		} else {
			[_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo;
		};
	};

	if (_startOver) then {
		continue;
	};

	[_patientTournequit] call RCT7Bootcamp_fnc_taskSetState;

	_patientBandage = "PatientBandage";
	[[_patientBandage, _patientMedicalTaskId], "Use a bandage", "From the 'Bandage/Fractures' screen, with the leg still selected, click 'Bandage'", "heal"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil{
		sleep 1;

		if ([_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo isEqualTo false) then {
			[_patientBandage, "FAILED"] call RCT7Bootcamp_fnc_taskSetState;
			_startOver = true;
			_startOver
		} else {
			call _isBandaged;
		};
	};

	if (_startOver) then {
		continue;
	};

	[_patientBandage] call RCT7Bootcamp_fnc_taskSetState;

	_patientTournequitRemove = "PatientTournequitRemove";
	[[_patientTournequitRemove, _patientMedicalTaskId], "Remove a tourniquet", "Now that the bleeding has stopped, click 'Remove Tourniquet' on the 'Bandage/Fractures' screen.", "heal"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil{
		sleep 1;
		([_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo) isEqualTo false;
	};
	[_patientTournequitRemove] call RCT7Bootcamp_fnc_taskSetState;

	// Epi-pen

	if (_isAI) then {
		_patientEpi = "PatientEpi";
		player addItem "ACE_epinephrine";
		[[_patientEpi, _patientMedicalTaskId], "Use epinephrine", "To awaken the patient click the 'Medication' button, select any limb and then click 'Inject Epinephrine'.", "heal"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil{
			sleep 1;
			!(_patient getVariable ["ACE_isUnconscious", false]);
		};
		[_patientEpi, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
	};

	// morphine
	_patientMorphine = "PatientMorphine";
	[[_patientMorphine, _patientMedicalTaskId], "Use morphine", "To remove the effects of pain click the 'Medication' button, select any limb and then click 'Inject Morphine'.", "heal"] call RCT7Bootcamp_fnc_taskCreate;
	waitUntil{
		sleep 1;
		_patient getVariable ["ace_medical_painSuppress", 0] > 0;
	};

	[_patientMorphine, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
	[_patientMedicalTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;

	hint "Full heal applied";
	[ _patient ] call ACE_medical_treatment_fnc_fullHealLocal;
	sleep 3;
	hint "";
	_isRunning = false;
};

private _db_key = "self";

if (_isAI) then {
	_db_key = "patient";
};

RCT_MedicalInProcess = false;

true;