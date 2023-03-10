firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_module = Gun3DReport;
_syncedObjects = synchronizedObjects _module;

private _triggerObj = nil;
private _targetController = nil;
private _targetClusterList = [];


{
	private _syncedObj = _x;

	if (_syncedObj isKindOf "Logic" && ["TargetCluster", str _syncedObj] call BIS_fnc_inString) then {
		// It is a Target Cluster
		_targetClusterList pushBack _syncedObj;
		continue;
	};
	
	if (_syncedObj isKindOf "Logic" && ["TargetController", str _syncedObj] call BIS_fnc_inString) then {
		_targetController = _syncedObj;
		continue;
	};
	
} forEach _syncedObjects;


_index = 0;
_magSize = getNumber (configfile >> "CfgMagazines" >> (getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0) >> "count");
_count = count(_targetClusterList);


_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
private _baseHint = [call RCT7Bootcamp_fnc_getACESelfInfo, " and under"] joinString "";

_teamHint = [_baseHint, " Team Management, and join the red team"] joinString "";
_teamTaskId = "joinTeam";
[_teamTaskId, "Join the red team", _teamHint, "meet"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil { assignedTeam player isEqualTo "RED"; };

[_teamTaskId] call RCT7Bootcamp_fnc_taskSetState;

["trenches", "Dig a big trench", "Follow the instructions", "interact", "CREATED", true, -1] call RCT7Bootcamp_fnc_taskCreate;

_loadoutEvent = ["loadout", {
	_hasEntrenchingTool = [player, "ACE_EntrenchingTool"] call BIS_fnc_hasItem;

	if !(_hasEntrenchingTool) exitWith {};

	if (["trenchesStartDigging" call RCT7Bootcamp_fnc_taskAddPrefix ] call BIS_fnc_taskExists) exitWith{};

	_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_desc = [call RCT7Bootcamp_fnc_getACESelfInfo, " and under Equipment, start digging a big trench"] joinString "";
	["trenchesGetTool"] call RCT7Bootcamp_fnc_taskSetState;
	[["trenchesStartDigging", "trenches"], "Start digging", _desc] call RCT7Bootcamp_fnc_taskCreate;

}] call CBA_fnc_addPlayerEventHandler;


[["trenchesGetTool", "trenches"], "Grab an Entreching Tool", "Grab one [Entrenching Tool] out of the box."] call RCT7Bootcamp_fnc_taskCreate;

_trenchPlacedEvent = ["ace_trenches_placed", {

	[] spawn {

		sleep 0.1;

		_trench = (position player nearObjects ["ACE_envelope_big", 5]) # 0;

		["trenchesStartDigging","SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
		[["trenchesWait", "trenches"],"Wait till it is finished", "", "wait"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil {_trench getVariable ["ace_trenches_progress", 0] isEqualTo 1};
		["trenchesWait"] call RCT7Bootcamp_fnc_taskSetState;

		[["trenchesCamouflage", "trenches"], "Camouflage the trench"] call RCT7Bootcamp_fnc_taskCreate;
		waitUntil { sleep 1; _trench getVariable["ace_trenches_camouflaged", false]; };
		["trenchesCamouflage"] call RCT7Bootcamp_fnc_taskSetState;

		[
			["trenchesPlaceGun", "trenches"],
			"Place your gun on the trench",
			["place your gun on the trench with:\n", call compile (actionKeysNames "deployWeaponAuto")] joinString ""
		] call RCT7Bootcamp_fnc_taskCreate;

		waitUntil {sleep 1; isWeaponDeployed [player, false] };
		["trenchesPlaceGun","SUCCEEDED", false] call RCT7Bootcamp_fnc_taskSetState;
		["trenches"] call RCT7Bootcamp_fnc_taskSetState;

	};
	
}] call CBA_fnc_addEventHandler;

// Remove events when tasks are done
[_loadoutEvent, _trenchPlacedEvent] spawn {
	_trenchTask = "trenches" call RCT7Bootcamp_fnc_taskAddPrefix;

	waitUntil { sleep 1; _trenchTask call BIS_fnc_taskCompleted };

	["loadout", _this # 0] call CBA_fnc_removePlayerEventHandler;
	["ace_trenches_placed", _this # 1] call CBA_fnc_removeEventHandler;
};

// TASK Icon: listen
waitUntil { player getVariable ["ACE_hasEarPlugsIn", false]; };

player call RCT7Bootcamp_fnc_sectionStart;

while {  _count isNotEqualTo _index  } do {


	call RCT7Bootcamp_fnc_handleMags;
	_targetCluster = _targetClusterList select _index;

	_target = nil;
	{
		if (typeName (_x getVariable "RCT7_3DReportDescription") isEqualTo "STRING") exitWith {
			_target = _x;
		};
		
	} forEach (synchronizedObjects _targetCluster);

	_invalidTargetCluster =  + _targetClusterList; // copy array

	dbSectionName = ["3DReport", _index] joinString "-";
	

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;


	_descr =  _target getVariable ["RCT7_3DReportDescription", getText(configfile >> "CfgVehicles" >> typeOf _target >> "displayName") ];
	_dir = round(([player, (_target)] call BIS_fnc_dirTo));
	_dist = player distance (_target);
	_distance = round(_dist / 50) * 50;

	// TASK Icon: kill
	hint (["Shoot at the Target:\n\n", "description:", _descr, "\ndirection: ", _dir, "\ndistance: ", _distance , " meters"] joinString "");

	
	[player, dbSectionName, "description", _descr] remoteExec ["RCT7_writeToDb", 2];
	
	{
		{
			_invalidTarget = _x;
			_invalidTarget addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (_unit animationPhase "terc" isEqualTo 0) then {
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					shotsInvalid = shotsInvalid + 1;
					_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");

					[player, dbSectionName, "shotsInvalid", shotsInvalid] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "wrongTargetList", [_name]] remoteExec ["RCT7_appendToKey", 2];
					_unit removeAllMPEventHandlers "MPHit";
				};

			}];
			
		} forEach synchronizedObjects _x;
		
	} forEach _invalidTargetCluster;

	_target removeAllMPEventHandlers "MPHit";
	_target addMPEventHandler ["MPHit", {
			params ["_unit", "_source", "_damage", "_instigator"];
				player call RCT7Bootcamp_fnc_targetHitValid;
				shotsValid = shotsValid + 1;

				_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");

				[player, dbSectionName, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
				[player, dbSectionName, "distance", _unit distance _instigator] remoteExec ["RCT7_writeToDb", 2];

				_unit removeAllMPEventHandlers "MPHit";
		}
	];

	[_targetController, 0] call RCT7Bootcamp_fnc_handleTargets;
	_time = time;
	waitUntil { 1 isEqualTo shotsValid || _magSize isEqualTo firedCount };

	[player, dbSectionName, "time", time - _time - 2] remoteExec ["RCT7_writeToDb", 2];

	_index = _index + 1;
	_shotsMissed = firedCount - (shotsInvalid + shotsValid);
	[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];
	sleep 1;

	(synchronizedObjects _targetController) apply { _x animate["terc", 0]; _x removeAllMPEventHandlers "MPHit"; };
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

[_targetController, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";