call RCT7Bootcamp_fnc_earplugTask;

/* 
	Todo:
	- add comment to use zoomed-out sight
*/

dbSectionName = "Shoothouse";
shotsValid = 0;
shotsInvalid = 0;
_shotsMissed = 0;
firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

private _targetController = TargetControllerShoothouse;
private _targetClusterValid = TargetClusterValid;
private _targetClusterInvalid = TargetClusterInvalid;

private _synchedObjects = synchronizedObjects TargetClusterValid;
private _validTargetList = [];

{
	if (_x isKindOf "TargetBase") then {
		_validTargetList pushBack _x;
		continue;
	};
} forEach _synchedObjects;

_stopwatch = {
	_i = 0;
	while { RCT7ShoothouseInProcess } do {
		hintSilent (["Your Time:\n", _i * 0.1] joinString "");

		_i = (_i + 1);
		sleep 0.1;
	};
};

// handle invalid targets
{
	_invalidTarget = _x;
	_invalidTarget addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];

		if (_unit animationPhase "terc" isEqualTo 0) then {
			player call RCT7Bootcamp_fnc_targetHitInvalid;
			shotsInvalid = shotsInvalid + 1;
			_name = gettext (configfile >> "CfgVehicles" >> typeOf _unit >> "displayName");

			[
				player,
				dbSectionName,
				"shotsInvalid", shotsInvalid,
				[
					["wrongTargetList", [_name]]
				]
			] remoteExec ["RCT7_writeToDb", 2];

			_unit removeAllMPEventHandlers "MPHit";
		};
	}];
} forEach synchronizedObjects TargetClusterInvalid;

// handle valid targets
{
	_x addMPEventHandler ["MPHit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		player call RCT7Bootcamp_fnc_targetHitValid;
		shotsValid = shotsValid + 1;
		systemChat str shotsValid;
		[player, dbSectionName, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
		_unit removeAllMPEventHandlers "MPHit";
	}];
} forEach _validTargetList;

_ShoothouseTaskId = "Shoothouse";
[_ShoothouseTaskId, "Finish the shoothouse", "Go in and shoot the targets. Watch for civilians", "kill", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

player call RCT7Bootcamp_fnc_sectionStart;
_time = time;
RCT7ShoothouseInProcess = true;
[] spawn _stopwatch;

2 call RCT7Bootcamp_fnc_handleMags;

[_targetController, 0] call RCT7Bootcamp_fnc_handleTargets;

waitUntil {
	(count _validTargetList) isEqualTo shotsValid
};

RCT7ShoothouseInProcess = false;

_shotsMissed = firedCount - (shotsInvalid + shotsValid);
[player, dbSectionName, "shotsMissed", _shotsMissed, [["time", time - _time - 2]]] remoteExec ["RCT7_writeToDb", 2];

sleep 1;

(synchronizedObjects _targetController) apply {
	_x animate["terc", 0];
	_x removeAllMPEventHandlers "MPHit";
};

player removeEventHandler ["Fired", _firedIndex];

[_targetController, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
[_ShoothouseTaskId] call RCT7Bootcamp_fnc_taskSetState;

true;