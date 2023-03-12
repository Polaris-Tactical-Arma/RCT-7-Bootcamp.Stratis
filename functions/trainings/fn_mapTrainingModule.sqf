_module = GunGridTraining;
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

[_targetController, 0] call RCT7Bootcamp_fnc_handleTargets;

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_index = 0;
_magSize = getNumber (configfile >> "CfgMagazines" >> (getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0) >> "count");
_count = count(_targetClusterList);

call RCT7Bootcamp_fnc_earplugTask;

private _mainTask = "MapTraining";
[_mainTask, "Finish the Map Training", "Follow the instructions", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;

player call RCT7Bootcamp_fnc_sectionStart;

while { _count isNotEqualTo _index } do {
	call RCT7Bootcamp_fnc_handleMags;
	_targetCluster = _targetClusterList select _index;

	_targetList = [];
	{
		if (_x isKindOf "TargetBase") then {
			_targetList pushBack _x;
		};
	} forEach (synchronizedObjects _targetCluster);

	_targetCount = count(_targetList);

	_invalidTargetCluster =  + _targetClusterList; // copy array
	_invalidTargetCluster deleteAt _index;

	_grid = mapGridPosition (_targetList # 0);

	dbSectionName = ["Grid", _grid] joinString "-";

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_taskDescription = ["Shoot all", _targetCount, "targets at grid:<br/><br/>", _grid select [0, 3], _grid select [3, 5]] joinString " ";
	_subTaskId = ["TargetCluster", _index] joinString "_";
	_subTaskTitle = [_index + 1, "Hit the correct Targets"] joinString " - ";

	systemChat ([_subTaskId, _mainTask] joinString ".....");
	[[_subTaskId, _mainTask], _subTaskTitle, _taskDescription, "search"] call RCT7Bootcamp_fnc_taskCreate;

	{
		{
			_invalidTarget = _x;
			_invalidTarget addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (_unit animationPhase "terc" isEqualTo 0) then {
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					shotsInvalid = shotsInvalid + 1;
					_grid = mapGridPosition _unit;

					[player, dbSectionName, "shotsInvalid", shotsInvalid] remoteExec ["RCT7_writeToDb", 2];
					[player, dbSectionName, "wrongTargetList", [_grid]] remoteExec ["RCT7_appendToKey", 2];

					_unit removeAllMPEventHandlers "MPHit";
				};
			}];
		} forEach synchronizedObjects _x;
	} forEach _invalidTargetCluster;

	{
		_x addMPEventHandler ["MPHit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			player call RCT7Bootcamp_fnc_targetHitValid;
			shotsValid = shotsValid + 1;
			[player, dbSectionName, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
			_unit removeAllMPEventHandlers "MPHit";
		}];
	} forEach _targetList;

	_time = time;
	waitUntil {
		_targetCount isEqualTo shotsValid || _magSize isEqualTo firedCount
	};

	[_subTaskId] call RCT7Bootcamp_fnc_taskSetState;

	[player, dbSectionName, "time", time - _time - 2] remoteExec ["RCT7_writeToDb", 2];

	_index = _index + 1;
	_shotsMissed = firedCount - (shotsInvalid + shotsValid);
	[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];
	sleep 1;

	(synchronizedObjects _targetController) apply {
		_x animate["terc", 0];
		_x removeAllMPEventHandlers "MPHit";
	};

	if (_count > _index) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

[_targetController, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
[_mainTask, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;