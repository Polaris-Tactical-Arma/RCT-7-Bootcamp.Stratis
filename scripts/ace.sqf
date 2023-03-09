
_selfInteractKeybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
_interactKeybind = ["ACE3 Common", "ACE_Interact_Menu_InteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;



_grp = createGroup west;
_unit = _grp createUnit [ "C_man_p_beggar_F", position player, [], 0, "FORM"];


// "CUP_B_nM1025_Unarmed_USMC_WDL"

// check if is handcuffed
waitUntil { _unit getVariable ["ace_captives_isHandcuffed", false]; };

// check if is escorted?
waitUntil { _unit in (attachedObjects player); };

// check distance
waitUntil { _unit distance _vehicle < 5; };

// release
waitUntil { !(_unit in (attachedObjects player)); };



// Hint them: Combat over medical

// Medical on self
[player, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit;

// Bandage 
// TASK Icon: heal

// morphine
// TASK Icon: heal

// Medical on other unit
[_unit, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit;

// Bandage 
// TASK Icon: help

// Check response
// TASK Icon: search

// Give unit blood 
// TASK Icon: heal

// Give them epi; Give them epi only if yellow
// TASK Icon: help

// load in vehicle
waitUntil { objectParent tester isEqualTo _vehicle; };