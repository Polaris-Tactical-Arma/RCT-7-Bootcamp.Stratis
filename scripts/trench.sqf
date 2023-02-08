_getTrench = {
    (position player nearObjects ["ACE_envelope_big", 5]) # 0;
};

hint "Grab one [Entrenching Tool] out of the box.";
waitUntil { sleep 1; [player, "ACE_EntrenchingTool"] call BIS_fnc_hasItem; };

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

hint (["place your gun on the trench with:\n", call compile (actionKeysNames "deployWeaponAuto")] joinString "");
waitUntil {sleep 1; isWeaponDeployed [player, false] };

hint "Training complete";

sleep 5;
deleteVehicle _trench;

