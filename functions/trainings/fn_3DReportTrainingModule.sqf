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

if (!(player getVariable ["ACE_hasEarPlugsIn", false])) then {
	_keybind = ["ACE3 Common", "ACE_Interact_Menu_SelfInteractKey"] call RCT7Bootcamp_fnc_getCBAKeybind;
	_earplugs = ["Open ACE Self-Interaction with\n[", _keybind, "]\nand under Equipment, put your earplugs in"] joinString "";
	hint _earplugs;
};

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
	waitUntil { 1 isEqualTo shotsValid || _magSize isEqualTo firedCount };

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