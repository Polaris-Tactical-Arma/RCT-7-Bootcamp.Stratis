private _patient = player;
private _bodyPart = "rightleg";
// hint them: Combat over medical

_selfMedicalTaskId = "SelfMedical";
[_selfMedicalTaskId, "Finish the medical training", "Follow the instructions", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

hint "always make sure to prioritize combat over medical!";
sleep 5;
hint "Base Medical Kit was added to your inventory";

["You will get hurt in", 5] call RCT7Bootcamp_fnc_cooldownHint;

// Medical on self
[_patient, 0.8, _bodyPart, "bullet"] call ace_medical_fnc_addDamageToUnit;

_selfTournequit = "SelfTournequit";
[[_selfTournequit, _selfMedicalTaskId], "Use a tournequit", "Apply a tournequit to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	sleep 1;
	[_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo;
};
[_selfTournequit] call RCT7Bootcamp_fnc_taskSetState;

_selfBandage = "SelfBandage";
[[_selfBandage, _selfMedicalTaskId], "Use a bandage", "Apply a bandage to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;
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
[_selfBandage] call RCT7Bootcamp_fnc_taskSetState;

_selfTournequitRemove = "SelfTournequitRemove";
[[_selfTournequitRemove, _selfMedicalTaskId], "Remove a tournequit", "Remove the tournequit from your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	sleep 1;
	[_patient, _bodyPart] call ace_medical_treatment_fnc_hasTourniquetAppliedTo isEqualTo false;
};
[_selfTournequitRemove] call RCT7Bootcamp_fnc_taskSetState;

// morphine
_selfMorphine = "SelfMorphine";
[[_selfMorphine, _selfMedicalTaskId], "Use morphine", "Apply a morphine to one of your limbs", "heal"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	sleep 1;
	player getVariable ["ace_medical_painSuppress", 0] > 0;
};

[_selfMorphine, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
[_selfMedicalTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;

hint "Full heal applied";
[ _patient ] call ACE_medical_treatment_fnc_fullHealLocal;
sleep 3;
hint "";