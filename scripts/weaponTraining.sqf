
_getFireMode = {
	weaponState player # 2
};

private _handleMags = {

	_ammo = getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0;
	player removePrimaryWeaponItem _ammo;
	player addMagazine [_ammo, 30];
	player reload [];
};

{

	_x animate["terc", 0];
	_x setVariable ["nopop", true];
} forEach synchronizedObjects TargetController;


firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

	firedCount = firedCount + 1;

}];


_logicList = allMissionObjects "Logic";
_targetClusterList = [];
{
	if (["TargetCluster", str _x] call BIS_fnc_inString) then {
  		_targetClusterList pushBack _x;
	};
} forEach _logicList;


private _index = 0;

// start sound
playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\course_active.wss", player];

while { count(_targetClusterList) isNotEqualTo (_index)  } do {
	
	[] call _handleMags;
	_targetCluster = _targetClusterList select _index;

	_targetList = synchronizedObjects _targetCluster;
	_targetCount = count(_targetList);

	_invalidTargetCluster =  + _targetClusterList; // copy array
	_invalidTargetCluster deleteAt _index;

	_dist = player distance (_targetList # 0);
	_distance = round(_dist * 0.01) * 100;
	rangeSection = ["ShootingRange", _distance, "meters"] joinString "";

	shotsValid = 0;
	shotsInvalid = 0;
	_shotsMissed = 0;
	firedCount = 0;

	_dir = round(([player, (_targetList # 0)] call BIS_fnc_dirTo));

	hint (["Shoot all", _targetCount ,"targets at:\n\n", "direction:", _dir, "\n",  _distance, "meters"] joinString " ");

	{
		_x addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
					playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\timer.wss", player];
					shotsValid = shotsValid + 1;
					[player, rangeSection, "shotsValid", shotsValid] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
			}];
		
	} forEach _targetList;


	{
		{
			_invalidTarget = _x;
			_invalidTarget addMPEventHandler ["MPHit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (_unit animationPhase "terc" isEqualTo 0) then {
					playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\drill_start.wss", player];
					shotsInvalid = shotsInvalid + 1;
					[player, rangeSection, "shotsInvalid", shotsInvalid] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
				};

			}];
			
		} forEach synchronizedObjects _x;
		
	} forEach _invalidTargetCluster;

	
	// TODO: Check if mag is empty as well

	waitUntil { _targetCount isEqualTo shotsValid };

	
		
	playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\checkpoint_clear.wss", player];
	_index = _index + 1;

	_shotsMissed = firedCount - (shotsInvalid + shotsValid);

	[player, rangeSection, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];

	systemChat (["missedShots:", _shotsMissed] joinString " ");

	sleep 1;

	(synchronizedObjects TargetController) apply { _x animate["terc", 0]; _x removeAllMPEventHandlers "MPHit"; };

};

player removeEventHandler ["Fired", _firedIndex];
(synchronizedObjects TargetController) apply { _x animate["terc", 1]; };

playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\drill_finish.wss", player];
hint "Traning completed!";