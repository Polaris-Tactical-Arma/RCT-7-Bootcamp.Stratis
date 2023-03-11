_trenchTask = "trenches";
[_trenchTask, "Dig a big trench", "Follow the instructions", "interact", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

_loadoutEvent = ["loadout", {
	_hasEntrenchingTool = [player, "ACE_EntrenchingTool"] call BIS_fnc_hasItem;

	if !(_hasEntrenchingTool) exitWith {};

	if (["trenchesStartDigging"] call BIS_fnc_taskExists) exitWith {};

	_desc = [call RCT7Bootcamp_fnc_getACESelfInfo, " and under Equipment, start digging a big trench"] joinString "";
	["trenchesGetTool"] call RCT7Bootcamp_fnc_taskSetState;
	[["trenchesStartDigging", "trenches"], "Start digging", _desc] call RCT7Bootcamp_fnc_taskCreate;
}] call CBA_fnc_addPlayerEventHandler;

[["trenchesGetTool", _trenchTask], "Grab an Entreching Tool", "Grab one [Entrenching Tool] out of the box."] call RCT7Bootcamp_fnc_taskCreate;

_trenchPlacedEvent = ["ace_trenches_placed", {
	[] spawn {
		sleep 0.1;

		_trench = (position player nearObjects ["ACE_envelope_big", 5]) # 0;

		["trenchesStartDigging", "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
		[["trenchesWait", "trenches"], "Wait till it is finished", "", "wait"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil {
			_trench getVariable ["ace_trenches_progress", 0] isEqualTo 1
		};
		["trenchesWait"] call RCT7Bootcamp_fnc_taskSetState;

		[["trenchesCamouflage", "trenches"], "Camouflage the trench"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil {
			sleep 1;
			_trench getVariable["ace_trenches_camouflaged", false];
		};
		["trenchesCamouflage"] call RCT7Bootcamp_fnc_taskSetState;

		[
			["trenchesPlaceGun", "trenches"],
			"Place your gun on the trench",
			["place your gun on the trench with:<br/>", call compile (actionKeysNames "deployWeaponAuto")] joinString ""
		] call RCT7Bootcamp_fnc_taskCreate;

		waitUntil {
			sleep 1;
			isWeaponDeployed [player, false]
		};
		["trenchesPlaceGun", "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
		["trenches"] call RCT7Bootcamp_fnc_taskSetState;
	};
}] call CBA_fnc_addEventHandler;

waitUntil {
	sleep 1;
	_trenchTask call BIS_fnc_taskCompleted;
};

["loadout", _loadoutEvent] call CBA_fnc_removePlayerEventHandler;
["ace_trenches_placed", _trenchPlacedEvent] call CBA_fnc_removeEventHandler;

true;