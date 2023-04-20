call RCT7Bootcamp_fnc_earplugTask;

_grenade = param[0, "", [""]];
dbSectionName = param[1, "", [""]];
_module = param[2, objNull, [objNull]];

_syncedObjects = synchronizedObjects _module;

private _targetCluster = nil;

{
	private _syncedObj = _x;

	if (_syncedObj isKindOf "Logic" && ["TargetCluster", str _syncedObj] call BIS_fnc_inString) exitWith {
		// It is a Target Cluster
		_targetCluster = _x;
	};
} forEach _syncedObjects;

firedCount = 0;

_firedIndex = ["ace_firedPlayer", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];

	_projectile addEventHandler ["Explode", {
		params ["_projectile", "_pos", "_velocity"];

		firedCount = firedCount + 1;
	}];
}] call CBA_fnc_addEventHandler;

_index = 0;


private _mainTask = "GrenadeTraining";
[_mainTask, "Finish the grenade training", "Follow the instructions", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;


call RCT7Bootcamp_fnc_sectionStart;

_targetList = [];
{
	if (_x isKindOf "TargetBase") then {
		_targetList pushBack _x;
		_x animate["terc", 1];
		_x setVariable ["nopop", true];
	};
} forEach (synchronizedObjects _targetCluster);

_count = count(_targetList);

while { _count isNotEqualTo _index } do {
	player addMagazine [_grenade, 1];

	_target = _targetList # _index;

	shotsValid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_keybind = ["ACE3 Weapons", "ACE_Advanced_Throwing_Prepare"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_prepareDescription = ["Prepare your grenade with:<br/>[", _keybind, "]"] joinString "";

	_prepareGrenadeTaskId = "PrepareGrenade";
	[[_mainTask, _prepareGrenadeTaskId], "Prepare grenade", _prepareDescription, "use"] call RCT7Bootcamp_fnc_taskCreate;

	waitUntil {
		sleep 0.5;
		player getVariable ["ace_advanced_throwing_inHand", false];
	};
	[_prepareGrenadeTaskId] call RCT7Bootcamp_fnc_taskSetState;

	_throwGrenadeTaskId = "ThrowGrenade";
	[[_mainTask, _throwGrenadeTaskId], "Throw grenade", "Throw the grenade at the target", "destroy"] call RCT7Bootcamp_fnc_taskCreate;

	_target addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		shotsValid = shotsValid + 1;
		[player, dbSectionName, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
		_unit removeAllMPEventHandlers "MPHit";
	}];

	_target animate["terc", 0];

	_time = time;
	waitUntil {
		firedCount isEqualTo 1
	};
	[_throwGrenadeTaskId] call RCT7Bootcamp_fnc_taskSetState;

	_index = _index + 1;
	_shotsMissed = firedCount - shotsValid;
	[player, dbSectionName, "shotsMissed", _shotsMissed, [["time", time - _time - 2]]] remoteExec ["RCT7_writeToDb", 2];
	[ player ] call ACE_medical_treatment_fnc_fullHealLocal;
};

["ace_firedPlayer", _firedIndex] call CBA_fnc_removeEventHandler;

player call RCT7Bootcamp_fnc_sectionFinished;
[_mainTask] call RCT7Bootcamp_fnc_taskSetState;