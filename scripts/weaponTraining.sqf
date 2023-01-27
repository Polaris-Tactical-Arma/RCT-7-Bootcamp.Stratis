
_getFireMode = {
	weaponState player # 2
};


firedCount = 0;

_firedIndex = player addEventHandler ["Fired", {
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

	firedCount = firedCound + 1;

}];


_logicList = allMissionObjects "Logic";
_targetClusterList = [];
{
	if (["TargetCluster", str _x] call BIS_fnc_inString) then {
  		_targetClusterList pushBack _x;
	};
} forEach _logicList;


private _index = 0;

while { count(_targetClusterList) > 1 } do {
	

	_targetCluster = _targetClusterList select _index;

	_targetList = synchronizedObjects _targetCluster;
	_targetCount = count(_targetList);

	_invalidTargetCluster =  + _targetClusterList; // copy array
	_invalidTargetCluster deleteAt _index;

	systemChat (str _invalidTargetCluster);

	_distance = player distance _targetCluster;

	rangeSection = (round(_distance * 0.01) / 100);
	validHit = 0;
	invalidHit = 0;


	systemchat (["distance:", rangeSection] joinString " ");

	{
		_x addEventHandler ["Hit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// valid
				if (cursorObject animationPhase "terc" isEqualTo 1) then {

					validHit = validHit + 1;
					[player, rangeSection, "validHit", validHit] remoteExec ["RCT7_writeToDb", 2];
				};
			}];
		
	} forEach _targetList;


	{
		{
			_invalidTarget = _x;
			_invalidTarget addEventHandler ["Hit", {
				params ["_unit", "_source", "_damage", "_instigator"];
				// invalid
				if (cursorObject animationPhase "terc" isEqualTo 1) then {

					invalidHit = invalidHit + 1;
					[player, rangeSection, "invalidHit", invalidHit] remoteExec ["RCT7_writeToDb", 2];
				};

			}];
			
		} forEach synchronizedObjects _x;
		
	} forEach _invalidTargetCluster;

	_missedShots = firedCount - (invalidHit + validHit);

	systemChat (["missedShots:", _missedShots] joinString " ");

	waitUntil { _targetCount isEqualTo validHit };

	(synchronizedObjects TargetController) apply { _x removeAllEventHandlers "Hit"; };
	 
};

player removeEventHandler ["Fired", _firedIndex];