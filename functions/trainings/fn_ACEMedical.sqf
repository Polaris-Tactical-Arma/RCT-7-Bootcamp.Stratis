private _patient = param[0, objNull, [objNull]];
private _bodyPart = param[1, "rightleg", [""]];

if (_patient isEqualTo objNull) exitWith {
	systemChat "No Patient provided"
};

removeAllItems player;
_medicalItems = ["ACE_tourniquet", "ACE_fieldDressing", "ACE_epinephrine", "ACE_morphine"];
player setVariable ["ace_medical_medicclass", 1, true]; // set as medic

{
	player addItem _x;
} forEach _medicalItems;

private _isAI = _patient isNotEqualTo player;

hint "Medical Items added to inventory\n\nalways make sure to prioritize combat over medical!";
sleep 5;

_patientMedicalTaskId = "PatientMedical";
[_patientMedicalTaskId, "Finish the medical training", "Follow the instructions", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

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
		_reponseDescription = "Open the medical menu, click on the head and check the response.";
		[[_patientResponse, _patientMedicalTaskId], "Check Response", _reponseDescription, "heal"] call RCT7Bootcamp_fnc_taskCreate;

		waitUntil {
			sleep 1;
			_patient call _responseChecked;
		};
		[_patientResponse] call RCT7Bootcamp_fnc_taskSetState;
	};

	_patientTournequit = "PatientTournequit";
	[[_patientTournequit, _patientMedicalTaskId], "Use a tournequit", "Apply a tournequit", "heal"] call RCT7Bootcamp_fnc_taskCreate;

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
	[[_patientBandage, _patientMedicalTaskId], "Use a bandage", "Apply a bandage", "heal"] call RCT7Bootcamp_fnc_taskCreate;

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
	[[_patientTournequitRemove, _patientMedicalTaskId], "Remove a tournequit", "Remove the tournequit", "heal"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil{
		sleep 1;
		([_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo) isEqualTo false;
	};
	[_patientTournequitRemove] call RCT7Bootcamp_fnc_taskSetState;

	// Epi-pen

	if (_isAI) then {
		_patientEpi = "PatientEpi";
		[[_patientEpi, _patientMedicalTaskId], "Use Epinephrine", "Apply a Epinephrine to one of the limbs", "heal"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil{
			sleep 1;
			!(_patient getVariable ["ACE_isUnconscious", false]);
		};
		[_patientEpi, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
	};

	// morphine
	_patientMorphine = "PatientMorphine";
	[[_patientMorphine, _patientMedicalTaskId], "Use morphine", "Apply a morphine to one limbs", "heal"] call RCT7Bootcamp_fnc_taskCreate;
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

true;