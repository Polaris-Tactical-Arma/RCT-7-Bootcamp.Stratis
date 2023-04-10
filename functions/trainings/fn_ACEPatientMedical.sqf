private _patient = param[0, objNull, [objNull]];
private _bodyPart = param[1, "rightleg", [""]];

if (_patient isEqualTo objNull) exitWith {};

_patientMedicalTaskId = "PatientMedical";
[_patientMedicalTaskId, "Finish the medical training", "Follow the instructions", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

hint "always make sure to prioritize combat over medical!";
sleep 5;
hint "Base Medical Kit was added to your inventory";

_applyDamage = {
	params["_unit", "_bodyPart"];

	_message = ["Applying message to", name _this, "in"] joinString "";
	[_message, 5] call RCT7Bootcamp_fnc_cooldownHint;
	[_this, 0.8, _bodyPart, "bullet"] call ace_medical_fnc_addDamageToUnit;
};

[_patient, _bodyPart] call _applyDamage;

_patientTournequit = "PatientTournequit";
[[_patientTournequit, _patientMedicalTaskId], "Use a tournequit", "Apply a tournequit to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	sleep 1;
	[_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo;
};
[_patientTournequit] call RCT7Bootcamp_fnc_taskSetState;

_patientBandage = "PatientBandage";
[[_patientBandage, _patientMedicalTaskId], "Use a bandage", "Apply a bandage to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	sleep 1;
	_wounds = player getVariable ["ace_medical_openWounds", []];
	private _result = false;

	{
		_x params ["_xClassID", "_xBodyPartN", "_xAmountOf", "_xBleeding", "_xDamage"];
		if (_xAmountOf isEqualTo 0) exitWith {
			_result = true;
		};
	} forEach _wounds;

	_result;
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
	player getVariable ["ace_medical_painSuppress", 0] > 0;
};

[_patientMorphine, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
[_patientMedicalTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;

hint "Full heal applied";
[ _patient ] call ACE_medical_treatment_fnc_fullHealLocal;
sleep 3;
hint "";