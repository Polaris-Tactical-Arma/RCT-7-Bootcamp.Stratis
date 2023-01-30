
// _getFireMode = {
// 	weaponState player # 2
// };


_controller = TargetController;

[_controller, 0, true] call RCT7Bootcamp_fnc_handleTargets;

firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	firedCount = firedCount + 1;
}];

_logicList = allMissionObjects "Logic";
_targetClusterList = [];
{
	if (["TargetCluster", str _x] call BIS_fnc_inString) then {
  		_targetClusterList pushBack _x;
	};
} forEach _logicList;


_index = 0;
player call RCT7Bootcamp_fnc_sectionStart;

_magSize = getNumber (configfile >> "CfgMagazines" >> (getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0) >> "count");
_count = count(_targetClusterList);

while {  _count isNotEqualTo _index  } do {
	
	call RCT7Bootcamp_fnc_handleMags;
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
					player call RCT7Bootcamp_fnc_targetHitValid;
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
					player call RCT7Bootcamp_fnc_targetHitInvalid;
					shotsInvalid = shotsInvalid + 1;
					[player, rangeSection, "shotsInvalid", shotsInvalid] remoteExec ["RCT7_writeToDb", 2];
					_unit removeAllMPEventHandlers "MPHit";
				};

			}];
			
		} forEach synchronizedObjects _x;
		
	} forEach _invalidTargetCluster;

	waitUntil { _targetCount isEqualTo shotsValid || _magSize isEqualTo firedCount };
		
	player call RCT7Bootcamp_fnc_targetHitValid;
	_index = _index + 1;
	_shotsMissed = firedCount - (shotsInvalid + shotsValid);
	[player, rangeSection, "shotsMissed", _shotsMissed] remoteExec ["RCT7_writeToDb", 2];
	sleep 1;

	(synchronizedObjects _controller) apply { _x animate["terc", 0]; _x removeAllMPEventHandlers "MPHit"; };
	
	if ( _count > _index ) then {
		["Next in", 3] call RCT7Bootcamp_fnc_cooldownHint;
	};
};

player removeEventHandler ["Fired", _firedIndex];

[_controller, 1] call RCT7Bootcamp_fnc_handleTargets;

player call RCT7Bootcamp_fnc_sectionFinished;
hint "Traning completed!";