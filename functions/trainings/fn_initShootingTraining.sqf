
// _getFireMode = {
// 	weaponState player # 2
// };


_module = param [0,objNull,[objNull]];
_actionLabel = param [1,"Start Shooting Test",[""]];
_trainingType = param [2,1,[1]];

_synchedObjects = synchronizedObjects _module;

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

	if (_syncedObj isKindOf "Thing") then {
		_triggerObj = _syncedObj;
	};
	

} forEach _synchedObjects;

_sectionNameCode = "";
_hintCode = "";

switch (_trainingType) do
{
	case 2: { 
		_sectionNameCode = "_grid = mapGridPosition (_targetList # 0); [""Grid"", _grid] joinString ""-"";";

		_hintCode = "_grid = mapGridPosition (_targetList # 0);[""Shoot all"", _targetCount ,""targets at grid:\n\n"", _grid] joinString "" """;
	};
	default { 
		// Range and direction Shooting
		_sectionNameCode = "_dist = player distance (_targetList # 0);
							_distance = round(_dist * 0.01) * 100;
							[""ShootingRange"", _distance, ""meters""] joinString """";";

		_hintCode = "	_dist = player distance (_targetList # 0);
						_distance = round(_dist * 0.01) * 100;
						_dir = round(([player, (_targetList # 0)] call BIS_fnc_dirTo));
						[""Shoot all"", _targetCount ,""targets at:\n\n"", ""direction:"", _dir, ""\n"",  _distance, ""meters""] joinString "" """;
	};
};


_triggerObj addAction [_actionLabel, RCT7Bootcamp_fnc_shootingTrainingModule, [
	_targetController,
	_targetClusterList,
	_sectionNameCode,
	_hintCode
] ];
