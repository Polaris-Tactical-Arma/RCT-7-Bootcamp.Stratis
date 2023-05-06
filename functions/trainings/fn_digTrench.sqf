_trenchTask = "trenches";
[_trenchTask, "Dig a big trench", "Follow the instructions provided.", "interact", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

_loadoutEvent = ["loadout", {
	_hasEntrenchingTool = [player, "ACE_EntrenchingTool"] call BIS_fnc_hasItem;

	if !(_hasEntrenchingTool) exitWith {};

	if (["trenchesStartDigging"] call BIS_fnc_taskExists) exitWith {};

	_desc = [call RCT7Bootcamp_fnc_getACESelfInfo, " hover over equipment, select dig a big trench.<br/>You must be looking at a natural surface e.g. dirt or grass."] joinString "";
	["trenchesGetTool"] call RCT7Bootcamp_fnc_taskSetState;
	[["trenchesStartDigging", "trenches"], "Dig a big trench", _desc] call RCT7Bootcamp_fnc_taskCreate;
}] call CBA_fnc_addPlayerEventHandler;

[["trenchesGetTool", _trenchTask], "Grab an Entrenching Tool", "Grab one [Entrenching Tool] out of the box."] call RCT7Bootcamp_fnc_taskCreate;

_trenchPlacedEvent = ["ace_trenches_placed", {
	[] spawn {
		sleep 0.1;

		_trench = (position player nearObjects ["ACE_envelope_big", 5]) # 0;

		["trenchesStartDigging", "SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
		[["trenchesWait", "trenches"], "Wait for the trench to be dug", "", "wait"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil {
			_trench getVariable ["ace_trenches_progress", 0] isEqualTo 1
		};
		["trenchesWait"] call RCT7Bootcamp_fnc_taskSetState;

		_interActionKey = ["ACE3 Common", "ACE_Interact_Menu_InteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
		_camouflageDescription = ["Camoflauge the trench [", _interactKey, "], look at the trench and select Interactions -> Camoflauge Trench."] joinString "";
		[["trenchesCamouflage", "trenches"], "Camoflauge the trench ", _camouflageDescription] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil {
			sleep 1;
			_trench getVariable["ace_trenches_camouflaged", false];
		};
		["trenchesCamouflage"] call RCT7Bootcamp_fnc_taskSetState;

		_deployWeaponKeybind = "deployWeaponAuto" call RCT7Bootcamp_fnc_getArmaKeybind;
		[
			["trenchesPlaceGun", "trenches"],
			"Mount your rifle on the trench",
			["Mount your rifle on the trench by pressing ", _deployWeaponKeybind] joinString ""
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