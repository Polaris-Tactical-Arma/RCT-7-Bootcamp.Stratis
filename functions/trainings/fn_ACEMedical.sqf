private _patient = param[0, objNull, [objNull]];
private _bodyPart = param[1, "rightleg", [""]];

if (_patient isEqualTo objNull) exitWith {};

_patientMedicalTaskId = "PatientMedical";
[_patientMedicalTaskId, "Finish the medical training", "Follow the instructions", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

hint "always make sure to prioritize combat over medical!";
sleep 5;
hint "Base Medical Kit was added to your inventory";

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

	_message = ["Applying message to ", name _patient, "in"] joinString "";
	[_message, 5] call RCT7Bootcamp_fnc_cooldownHint;
	[_patient, 0.8, _bodyPart, "bullet"] call ace_medical_fnc_addDamageToUnit;
};

private _isRunning = true;

while { _isRunning } do {
	private _startOver = false;
	[ _patient ] call ACE_medical_treatment_fnc_fullHealLocal;

	[_patient, _bodyPart] call _applyDamage;

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
	[[_patientTournequitRemove, _patientMedicalTaskId], "Remove a tournequit", "Remove the tournequit from your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil{
		sleep 1;
		[_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo isEqualTo false;
	};
	[_patientTournequitRemove] call RCT7Bootcamp_fnc_taskSetState;

	// morphine
	_patientMorphine = "PatientMorphine";
	[[_patientMorphine, _patientMedicalTaskId], "Use morphine", "Apply a morphine to one of your limbs", "heal"] call RCT7Bootcamp_fnc_taskCreate;
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