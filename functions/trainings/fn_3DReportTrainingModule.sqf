call RCT7Bootcamp_fnc_joinRedTeam;
call RCT7Bootcamp_fnc_digTrench;
call RCT7Bootcamp_fnc_earplugTask;

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

_3DTaskId = "3DReport";
[_3DTaskId, "Finish the 3D report Training", "Follow the instructions", "intel", "CREATED", true, true, -1] call RCT7Bootcamp_fnc_taskCreate;
player call RCT7Bootcamp_fnc_sectionStart;

while { _count isNotEqualTo _index } do {
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

	_targetDescription = _target getVariable ["RCT7_3DReportDescription", getText(configfile >> "CfgVehicles" >> typeOf _target >> "displayName") ];
	_dir = round(([player, (_target)] call BIS_fnc_dirTo));
	_dist = player distance (_target);
	_distance = round(_dist / 50) * 50;

	_taskDescription = ["Shoot at the Target:<br/><br/>", "description: ", _targetDescription, "<br/>direction: ", _dir, "<br/>distance (ca.): ", _distance, " meters"] joinString "";
	_subTaskId = ["TargetCluster", _index] joinString "_";
	_subTaskTitle = [_index + 1, "Hit the correct Target"] joinString " - ";
	[[_subTaskId, _3DTaskId], _subTaskTitle, _taskDescription, "kill"] call RCT7Bootcamp_fnc_taskCreate;

	[player, dbSectionName, "description", _targetDescription] remoteExec ["RCT7_writeToDb", 2];

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
waitUntil {
	1 isEqualTo shotsValid || _magSize isEqualTo firedCount
};

[_subTaskId] call RCT7Bootcamp_fnc_taskSetState;

[player, dbSectionName, "time", time - _time - 2] remoteExec ["RCT7_writeToDb", 2];

_shotsMissed = firedCount - (shotsInvalid + shotsValid);
[player, dbSectionName, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];

sleep 1;

(synchronizedObjects _targetController) apply {
	_x animate["terc", 0];
	_x removeAllMPEventHandlers "MPHit";
};

_index = _index + 1;
if (_count > _index) then {
	["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
};
};

player removeEventHandler ["Fired", _firedIndex];

[_targetController, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
[_3DTaskId] call RCT7Bootcamp_fnc_taskSetState;

true;