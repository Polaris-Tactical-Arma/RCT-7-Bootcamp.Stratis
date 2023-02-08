
_selfInteractKeybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
_interactKeybind = ["ACE3 Common", "ACE_Interact_Menu_InteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;


waitUntil { assignedTeam player isEqualTo "RED"; };

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





// Medical

[_unit, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit;


// load in vehicle
waitUntil { objectParent tester isEqualTo _vehicle; };











// trenches

_getTrench = {
    (position player nearObjects ["ACE_envelope_big", 5]) # 0;
};

// TODO: grab entranching tool

hint "Go on a dirt underground!";
waitUntil{ sleep 1; [player] call ace_common_fnc_canDig };

hint "Start digging a big trench!";
waitUntil {  sleep 1; count(position player nearObjects ["ACE_envelope_big", 5]) > 0 };

_trench = (position player nearObjects ["ACE_envelope_big", 5]) # 0;

hint "confirm and wait!";
waitUntil {
    sleep 1;
    _trenchProgress = (call _getTrench) getVariable ["ace_trenches_progress", 0];
    _trenchProgress isEqualTo 1;
 };

_trench = call _getTrench;
hint "Camouflage the trench!";
waitUntil { sleep 1; _trench getVariable["ace_trenches_camouflaged", false]; };

// TODO: place gun on the trench

hint "Training complete";
