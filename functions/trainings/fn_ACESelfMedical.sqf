// hint them: Combat over medical

sleep 10;
_selfMedicalTaskId = "SelfMedical";
[_selfMedicalTaskId, "Finish the medical training", "Follow the instructions", "heal", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

hint "always make sure to prioritize combat over medical!";
sleep 5;
hint "Base Medical Kit was added to your inventory";

["You will get hurt in", 5] call RCT7Bootcamp_fnc_cooldownHint;

// Medical on self
[player, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit;

sleep 1;

// Bandage 
_selfTournequit = "SelfTournequit";
[[_selfTournequit, _selfMedicalTaskId], "Use a tournequit", "Apply a tournequit to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil{
	true
};
[_selfTournequit] call RCT7Bootcamp_fnc_taskSetState;

// Bandage 
_selfBandage = "SelfBandage";
[[_selfBandage, _selfMedicalTaskId], "Use a bandage", "Apply a bandage to your leg", "heal"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	true
};
[_selfBandage] call RCT7Bootcamp_fnc_taskSetState;

// morphine
_selfMorphine = "SelfMorphine";
[[_selfMorphine, _selfMedicalTaskId], "Use morphine", "Apply a morphine to one of your limbs", "heal"] call RCT7Bootcamp_fnc_taskCreate;
waitUntil{
	true
};
[_selfMorphine, "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
[_selfMedicalTaskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;